module Generation

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Utils

export generator, Result, generator

struct Result
    prior::Float64
    program::AbstractProgram
    context::Context
end

function Base.show(io::IO, r::Result)
    print(io, "Result($(r.prior), $(r.program), $(r.context))")
end

abstract type State end

struct ProgramState <: State
    context::Context
    env::Array{TypeField,1}
    type::TypeField
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
end

function Base.show(io::IO, state::ProgramState)
    cls = "ProgramState"
    t = state.type
    e = state.env
    c = state.context
    u = round(state.upper_bound, digits=3)
    l = round(state.lower_bound, digits=3)
    d = state.depth
    print(io, "$cls($t, env=$e, $c, upper=$u, lower=$l, depth=$d)")
end

function convert_arrow(state::ProgramState)::ProgramState
    lhs = state.type.arguments[1]
    rhs = state.type.arguments[2]
    env1 = Array{TypeField,1}([lhs])  # TODO: better UnionAll syntax?
    env = append!(env1, state.env)
    upper = state.upper_bound
    lower = state.lower_bound
    return ProgramState(state.context, env, rhs, upper, lower, state.depth)
end

struct ApplicationState <: State
    context::Context
    env::Array{TypeField,1}
    func::AbstractProgram
    func_args::Array{TypeField,1}
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
    argument_index::Int
    original_func::AbstractProgram
end

function Base.show(io::IO, state::ApplicationState)
    cls = "ApplicationState"
    f = state.func
    a = state.func_args
    e = state.env
    c = state.context
    u = round(state.upper_bound, digits=3)
    l = round(state.lower_bound, digits=3)
    d = state.depth
    print(io, "$cls($f, args=$a, env=$e, $c, upper=$u, lower=$l, depth=$d)")
end

struct Candidate
    log_probability::Float64
    type::TypeField
    program::AbstractProgram
    context::Context
end

function to_app_state1(candidate::Candidate, state::ProgramState)
    func_args = function_arguments(candidate.type)
    new_upper = state.upper_bound + candidate.log_probability
    new_lower = state.lower_bound + candidate.log_probability
    new_depth = state.depth - 1
    return ApplicationState(
        candidate.context, state.env, candidate.program, func_args,
        new_upper, new_lower, new_depth, 0, candidate.program)
end

function to_program_state(state::ApplicationState)
    arg_request = apply(state.func_args[1], state.context)
    outer_args = state.func_args[2:end]
    newstate = ProgramState(
        state.context, state.env, arg_request,
        state.upper_bound, 0.0, state.depth)
    return newstate, outer_args
end

function to_app_state2(
    state::ApplicationState,
    result::Result,
    args::Array{TypeField,1}
)
    new_func = Application(state.func, result.program)
    new_upper = state.upper_bound + result.prior
    new_lower = state.lower_bound + result.prior
    new_arg_index = state.argument_index + 1
    return ApplicationState(
        result.context, state.env, new_func, args,
        new_upper, new_lower, state.depth, new_arg_index,
        state.func)
end

struct VariableCandidate
    type::TypeField
    index::DeBruijnIndex
    context::Context
end

function Candidate(vc::VariableCandidate, l::Float64)
    return Candidate(l, vc.type, vc.index, vc.context)
end

function get_candidate(state::State, production::Production)
    request = state.type
    context = state.context
    l = production.log_probability
    p = production.program
    new_context, t = instantiate(p.type, context)
    new_context = unify(new_context, returns(t), request)
    if new_context == UnificationFailure
        return UnificationFailure
    end
    t = apply(t, new_context)
    return Candidate(l, t, p, new_context)
end

function get_variable_candidate(state::State, t::TypeField, i::Int)
    request = state.type
    context = state.context
    new_context = unify(context, returns(t), request)
    if new_context == UnificationFailure
        return UnificationFailure
    end
    t = apply(t, new_context)
    return VariableCandidate(t, DeBruijnIndex(i), new_context)
end

struct NoCandidates <: Exception end

function update_log_probability(z::Float64, c::Candidate)::Candidate
    new_l = c.log_probability - z
    return Candidate(new_l, c.type, c.program, c.context)
end

function final_candidates(candidates::Array{Candidate,1})::Array{Candidate,1}
    z::Float64 = lse([c.log_probability for c in candidates])
    f = curry(update_log_probability, z)
    final_candidates::Array{Candidate,1} = map(f, candidates)
    return final_candidates
end

function build_candidates(grammar::Grammar, state::State)::Array{Candidate,1}
    candidates = Array{Candidate,1}([])
    variable_candidates = Array{VariableCandidate,1}([])

    for p in grammar.productions
        r = get_candidate(state, p)
        if r == UnificationFailure
            continue
        end
        push!(candidates, r)
    end

    for (i, t) in enumerate(state.env)
        r = get_variable_candidate(state, t, i - 1)
        if r == UnificationFailure
            continue
        end
        push!(variable_candidates, r)
    end

    # TODO: check continuationType

    vl = grammar.log_variable - log(length(variable_candidates))
    for vc in variable_candidates
        push!(candidates, Candidate(vc, vl))
    end

    if isempty(candidates)
        throw(NoCandidates)
    end

    return final_candidates(candidates)
end

# TODO: rename log_probability
function valid(candidate::Candidate, upper_bound::Float64)::Bool
    return -candidate.log_probability < upper_bound
end

function all_invalid(candidates::Array{Candidate,1}, upper_bound::Float64)::Bool
    for c in candidates
        if valid(c, upper_bound)
            return false
        end
    end
    return true
end

struct InvalidStateType <: Exception end

# TODO: move to programs.ml
tosource(p::Program)::String = p.source
tosource(p::DeBruijnIndex)::String = string(p.i)  # TODO: check if correct
tosource(p::Application)::String = tosource(p.func)
tosource(p::Abstraction)::String = tosource(p.body)

# TODO: unit tests
function is_symmetrical(
    s::ApplicationState,
    program::AbstractProgram,
    primitives::Dict{String,Primitive}
)::Bool
    argument_index = s.argument_index
    if !isa(s.original_func, Program)
        return true
    end
    orig = s.original_func.source
    if !haskey(primitives, orig)
        return true
    end
    newf = tosource(program)
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

function debug_state(state::State, debug::Bool)
    if debug
        println("state: $state")
    end
end

banner(msg::String)::String = "=========$msg========="

function debug_result(result::Result, debug::Bool, msg::String)
    if debug
        println(banner(msg))
        println("result: $result")
    end
end

function stop(state::State, debug::Bool)::Bool
    if state.upper_bound < 0.0 || state.depth <= 1
        if debug
            println(banner("ENDSTATE"))
        end
        return true
    else
        return false
    end
end

function debug_candidates(candidates::Array{Candidate,1}, debug::Bool)
    if debug && !isempty(candidates)
        println("candidates: [")
        for c in candidates
            println("    ", c, ",")
        end
        println("]")
    end
end

function appgenerator(
    channel::Channel,
    grammar::Grammar,
    state::ApplicationState,
    debug::Bool=false
)
    debug_state(state, debug)
    if stop(state, debug)
        return
    end
    if state.func_args == []
        if state.lower_bound <= 0.0 && state.upper_bound > 0.0
            r = Result(0.0, state.func, state.context)
            d = state.depth
            debug_result(r, debug, "RESULT(APP CHANNEL #1)(depth=$d)")
            put!(channel, r)
            return
        else
            # Reject this enumerate application state
            return
        end
    else
        s1, args = to_program_state(state)
        g1 = Channel((c) -> generator(c, grammar, s1, debug))
        for r1 in g1
            if !is_symmetrical(state, r1.program, grammar.primitives)
                continue
            end
            s2 = to_app_state2(state, r1, args)
            g2 = Channel((c) -> appgenerator(c, grammar, s2, debug))
            for r2 in g2
                l = r2.prior + r1.prior
                r = Result(l, r2.program, r2.context)
                d = state.depth
                debug_result(r, debug, "RESULT(APP CHANNEL #2)(depth=$d)")
                put!(channel, r)
            end
        end
    end
end

function generator(
    channel::Channel,
    grammar::Grammar,
    state::ProgramState,
    debug::Bool=false
)
    debug_state(state, debug)
    if stop(state, debug)
        return
    end
    if Types.is_arrow(state.type)
        newstate = convert_arrow(state)
        gen = Channel((c) -> generator(c, grammar, newstate, debug))
        for result in gen
            program = Abstraction(result.program)
            r = Result(result.prior, program, result.context)
            d = state.depth
            debug_result(r, debug, "RESULT(PRG CHANNEL #1)(depth=$d)")
            put!(channel, r)
        end
        return
    else
        candidates = build_candidates(grammar, state)
        debug_candidates(candidates, debug)
        if all_invalid(candidates, state.upper_bound)
            return
        end
        for candidate in candidates
            if valid(candidate, state.upper_bound)
                appstate = to_app_state1(candidate, state)
                gen = Channel((c) -> appgenerator(c, grammar, appstate, debug))
                for result in gen
                    l = result.prior + candidate.log_probability
                    r = Result(l, result.program, result.context)
                    d = state.depth
                    debug_result(r, debug, "RESULT(PRG CHANNEL #2)(depth=$d)")
                    put!(channel, r)
                end
            end
        end
    end
end

function generator(
    grammar::Grammar,
    env::Array{TypeField,1},
    type::TypeField,
    upper_bound::Float64,
    lower_bound::Float64,
    max_depth::Int,
    debug::Bool=false
)
    state = ProgramState(
        Context(),
        env,
        type,
        upper_bound,
        lower_bound,
        max_depth
    )
    return Channel((channel) -> generator(channel, grammar, state, debug))
end

end
