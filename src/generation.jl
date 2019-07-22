module Generation

using DataStructures

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

function final_candidates(
        candidates::Array{Candidate,1})::Array{Candidate,1}
    z::Float64 = lse([c.log_probability for c in candidates])
    f = curry(update_log_probability, z)
    final_candidates::Array{Candidate,1} = map(f, candidates)
    return final_candidates
end

function build_candidates(
        grammar::Grammar, request::TypeField, context::Context,
        env::Array{TypeField,1})::Array{Candidate,1}
    candidates = Array{Candidate,1}([])
    variable_candidates = Array{VariableCandidate,1}([])

    for p in grammar.productions
        r = get_candidate(request, context, p)
        if r == UNIFICATION_FAILURE
            continue
        end
        push!(candidates, r)
    end

    for (i, t) in enumerate(env)
        r = get_variable_candidate(request, context, t, i - 1)
        if r == UNIFICATION_FAILURE
            continue
        end
        push!(variable_candidates, r)
    end

    # TODO: check continuationType

    vl = grammar.log_variable - log(length(variable_candidates))
    for vc in variable_candidates
        push!(candidates, Candidate(vc, vl))
    end
    variable_candidates = nothing

    if isempty(candidates)
        throw(NoCandidates)
    end

    return final_candidates(candidates)
end

# TODO: rename log_probability
function valid(candidate::Candidate, upper_bound::Float64)::Bool
    return -candidate.log_probability < upper_bound
end

function all_invalid(
        candidates::Array{Candidate,1}, upper_bound::Float64)::Bool
    for c in candidates
        if valid(c, upper_bound)
            return false
        end
    end
    return true
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

function generator(
        grammar::Grammar, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, max_depth::Int)
    return Channel((channel) -> generator(
        channel, grammar, Context(), env,
        type, upper_bound, lower_bound, max_depth))
end

function generator(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    if stop(upper_bound, depth)
        return
    end
    if Types.is_arrow(type)
        process_arrow(
            channel, grammar, context, env,
            type, upper_bound, lower_bound, depth)
        return
    else
        process_candidates(
            channel, grammar, context, env,
            type, upper_bound, lower_bound, depth)
        return
    end
end

function process_arrow(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    lhs = type.arguments[1]
    rhs = type.arguments[2]
    new_env = Array{TypeField,1}([lhs])  # TODO: better UnionAll syntax?
    append!(new_env, env)

    gen = Channel((c) -> generator(
        c, grammar, context, new_env,
        rhs, upper_bound, lower_bound, depth))

    for result in gen
        program = Abstraction(result.program)
        r = Result(result.prior, program, result.context)
        put!(channel, r)
    end
end

function process_candidates(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    candidates = build_candidates(grammar, type, context, env)

    if all_invalid(candidates, upper_bound)
        return
    end
    for candidate in candidates
        if valid(candidate, upper_bound)
            process_candidate(
                channel, grammar, context, env,
                type, upper_bound, lower_bound, depth, candidate)
        end
    end
end

function process_candidate(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int,
        candidate::Candidate)
    func_args = function_arguments(candidate.type)
    new_upper = upper_bound + candidate.log_probability
    new_lower = lower_bound + candidate.log_probability
    new_depth = depth - 1
    arg_index = 0

    gen = Channel((c) -> appgenerator(
        c, grammar, candidate.context, env,
        candidate.program, func_args, new_upper, new_lower,
        new_depth, arg_index, candidate.program))

    for result in gen
        l = result.prior + candidate.log_probability
        r = Result(l, result.program, result.context)
        put!(channel, r)
    end
end

function appgenerator(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program)
    if stop(upper_bound, depth)
        return
    end
    if func_args == []
        if lower_bound <= 0.0 && upper_bound > 0.0
            put!(channel, Result(0.0, func, context))
            return
        else
            # Reject this enumerate application state
            return
        end
    else
        recurse_generator(
            channel, grammar, context, env,
            func, func_args, upper_bound, lower_bound,
            depth, argument_index, original_func)
    end
end

function recurse_generator(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program)
    arg_request = apply(func_args[1], context)
    outer_args = func_args[2:end]

    gen = Channel((c) -> generator(
        c, grammar, context, env,
        arg_request, upper_bound, 0.0, depth))

    for result in gen
        recurse_appgenerator(
            channel, grammar, context, env, func,
            func_args, upper_bound, lower_bound, depth, argument_index,
            original_func, outer_args, result)
    end
end

function recurse_appgenerator(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program, outer_args::Array{TypeField,1},
        prev_result::Result)
    if !is_symmetrical(
            argument_index, original_func,
            prev_result.program, grammar.primitives)
        return
    end

    new_func = Application(func, prev_result.program)
    new_upper = upper_bound + prev_result.prior
    new_lower = lower_bound + prev_result.prior
    new_arg_index = argument_index + 1

    gen = Channel((c) -> appgenerator(
        c, grammar, prev_result.context, env,
        new_func, outer_args, new_upper, new_lower,
        depth, new_arg_index, func))

    for new_result in gen
        l = new_result.prior + prev_result.prior
        r = Result(l, new_result.program, new_result.context)
        put!(channel, r)
    end
end

end
