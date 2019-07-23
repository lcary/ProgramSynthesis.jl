module Generation

using DataStructures
using ResumableFunctions

using ..Types
using ..Grammars
using ..Programs
using ..Utils

export generator, Result, generator

struct Result
    prior::Float64
    program::Program
    context::Context
end

function Base.show(io::IO, r::Result)
    print(io, "Result($(r.prior), $(r.program), $(r.context))")
end

struct Candidate
    log_probability::Float64
    type::TypeField
    program::Program
    context::Context
end

struct VariableCandidate
    type::TypeField
    index::Program
    context::Context
end

function Candidate(vc::VariableCandidate, l::Float64)::Candidate
    return Candidate(l, vc.type, vc.index, vc.context)
end

function get_candidate(
        request::TypeField, context::Context,
        production::Production)::Union{Candidate,Float64}
    l = production.log_probability
    p = production.program
    new_context, t = instantiate(p.type, context)
    new_context = unify(new_context, returns(t), request)
    if new_context == UNIFICATION_FAILURE
        return UNIFICATION_FAILURE
    end
    t = apply(t, new_context)
    return Candidate(l, t, p, new_context)
end

function get_variable_candidate(
        request::TypeField, context::Context, t::TypeField,
        i::Int)::Union{VariableCandidate,Float64}
    new_context = unify(context, returns(t), request)
    if new_context == UNIFICATION_FAILURE
        return UNIFICATION_FAILURE
    end
    t = apply(t, new_context)
    return VariableCandidate(t, DeBruijnIndex(i), new_context)
end

struct NoCandidates <: Exception end

function update_log_probability(z::Float64, c::Candidate)::Candidate
    new_l = c.log_probability - z
    return Candidate(new_l, c.type, c.program, c.context)
end

function get_logs(candidates::Array{Candidate,1})
    arr = Array{Float64,1}(undef, length(candidates))
    for (index, c) in enumerate(candidates)
        arr[index] = c.log_probability
    end
    return arr
end

function calculate_lse(candidates::Array{Candidate,1})
    return lse(get_logs(candidates))
end

function finalize_candidates!(candidates::Array{Candidate,1})
    z = calculate_lse(candidates)
    for (index, c) in enumerate(candidates)
        candidates[index] = update_log_probability(z, c)
    end
end

function get_candidates!(
        grammar::Grammar, request::TypeField, context::Context,
        candidates::Array{Candidate,1})
    for p in grammar.productions
        r = get_candidate(request, context, p)
        if r == UNIFICATION_FAILURE
            continue
        end
        push!(candidates, r)
    end
end

function get_variable_candidates!(
        request::TypeField, context::Context, env::Array{TypeField,1},
        variable_candidates::Array{VariableCandidate,1})
    for (i, t) in enumerate(env)
        r = get_variable_candidate(request, context, t, i - 1)
        if r == UNIFICATION_FAILURE
            continue
        end
        push!(variable_candidates, r)
    end
end

function add_variable_candidates!(
        grammar::Grammar,
        variable_candidates::Array{VariableCandidate,1},
        candidates::Array{Candidate,1})
    vl = grammar.log_variable - log(length(variable_candidates))
    for vc in variable_candidates
        push!(candidates, Candidate(vc, vl))
    end
end

function build_candidates(
        grammar::Grammar, request::TypeField, context::Context,
        env::Array{TypeField,1})::Array{Candidate,1}

    candidates = Array{Candidate,1}()
    variable_candidates = Array{VariableCandidate,1}()

    get_candidates!(grammar, request, context, candidates)
    get_variable_candidates!(request, context, env, variable_candidates)

    # TODO: check continuationType

    add_variable_candidates!(grammar, variable_candidates, candidates)
    variable_candidates = nothing

    if isempty(candidates)
        throw(NoCandidates)
    end

    finalize_candidates!(candidates)

    return candidates
end

# TODO: rename log_probability
function valid(candidate::Candidate, upper_bound::Float64)::Bool
    return -candidate.log_probability < upper_bound
end

struct InvalidStateType <: Exception end

# TODO: unit tests
function is_symmetrical(
        argument_index::Int, original_func::Program, program::Program,
        primitives::Dict{String,Program})::Bool
    argument_index = argument_index
    if original_func.ptype != PRIMITIVE
        return true
    end
    orig = original_func.name
    if !haskey(primitives, orig)
        return true
    end
    newf = getname(program)
    if orig == "car"
        return newf != "cons" && newf != "empty"
    elseif orig == "cdr"
        return newf != "cons" && newf != "empty"
    elseif orig == "+"
        return newf == "0" && (argument_index != 1 || newf != "+")
    elseif orig == "-"
        return argument_index != 1 || newf != "0"
    elseif orig == "empty?"
        return newf != "cons" && newf != "empty"
    elseif orig == "zero?"
        return newf != "0" && newf != "1"
    elseif orig == "index" || orig == "map" || orig == "zip"
        return newf != "empty"
    elseif orig == "range"
        return newf != "0"
    elseif orig == "fold"
        return argument_index != 1 || newf != "empty"
    end
    return true
end

function stop(upper_bound::Float64, depth::Int)::Bool
    if upper_bound < 0.0 || depth <= 1
        return true
    else
        return false
    end
end

@resumable function generator(
        grammar::Grammar, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, max_depth::Int)
    for r in generator(
            grammar, Context(), env,
            type, upper_bound, lower_bound, max_depth)
        @yield r
    end
end

@resumable function generator(
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    if !stop(upper_bound, depth)
        if Types.is_arrow(type)
            for r in process_arrow(
                    grammar, context, env,
                    type, upper_bound, lower_bound, depth)
                @yield r
            end
        else
            for r in process_candidates(
                    grammar, context, env,
                    type, upper_bound, lower_bound, depth)
                @yield r
            end
        end
    end
end

function get_new_env(type::TypeField, env::Array{TypeField,1})
    new_env = Array{TypeField,1}(undef, length(env) + 1)
    new_env[1] = type
    new_env[2:end] = env
    return new_env
end

function abstract_result(r::Result)::Result
    return Result(r.prior, Abstraction(r.program), r.context)
end

@resumable function process_arrow(
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    env = get_new_env(type.arguments[1], env)
    for result in generator(
            grammar, context, env,
            type.arguments[2], upper_bound, lower_bound, depth)
        @yield abstract_result(result)
    end
end

@resumable function process_candidates(
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    for candidate in build_candidates(grammar, type, context, env)
        if valid(candidate, upper_bound)
            for r in process_candidate(
                    grammar, context, env,
                    type, upper_bound, lower_bound, depth, candidate)
                @yield r
            end
        end
    end
end

function candidate_result(r::Result, c::Candidate)::Result
    l = r.prior + c.log_probability
    return Result(l, r.program, r.context)
end

@resumable function process_candidate(
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int,
        candidate::Candidate)
    func_args = function_arguments(candidate.type)
    new_upper = upper_bound + candidate.log_probability
    new_lower = lower_bound + candidate.log_probability
    new_depth = depth - 1
    arg_index = 0

    for result in appgenerator(
            grammar, candidate.context, env,
            candidate.program, func_args, new_upper, new_lower,
            new_depth, arg_index, candidate.program)
        @yield candidate_result(result, candidate)
    end
end

function end_result(func::Program, context::Context)::Result
    return Result(0.0, func, context)
end

function bounds_check(lower_bound::Float64, upper_bound::Float64)
    return lower_bound <= 0.0 && upper_bound > 0.0
end

@resumable function appgenerator(
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program)
    if !stop(upper_bound, depth)
        if isempty(func_args)
            if bounds_check(lower_bound, upper_bound)
                @yield end_result(func, context)
            end
        else
            for r in recurse_generator(
                    grammar, context, env,
                    func, func_args, upper_bound, lower_bound,
                    depth, argument_index, original_func)
                @yield r
            end
        end
    end
end

@resumable function recurse_generator(
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program)
    arg_request = apply(func_args[1], context)
    outer_args = func_args[2:end]

    for result in generator(
            grammar, context, env,
            arg_request, upper_bound, 0.0, depth)
        for r in recurse_appgenerator(
                grammar, context, env, func,
                func_args, upper_bound, lower_bound, depth, argument_index,
                original_func, outer_args, result)
            @yield r
        end
    end
end

function combined_result(prev_result::Result, new_result::Result)::Result
    l = new_result.prior + prev_result.prior
    return Result(l, new_result.program, new_result.context)
end

@resumable function recurse_appgenerator(
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program, outer_args::Array{TypeField,1},
        prev_result::Result)
    if is_symmetrical(
            argument_index, original_func,
            prev_result.program, grammar.primitives)
        new_func = Application(func, prev_result.program)
        new_upper = upper_bound + prev_result.prior
        new_lower = lower_bound + prev_result.prior
        new_arg_index = argument_index + 1

        for new_result in appgenerator(
                grammar, prev_result.context, env,
                new_func, outer_args, new_upper, new_lower,
                depth, new_arg_index, func)
            @yield combined_result(prev_result, new_result)
        end
    end
end

end
