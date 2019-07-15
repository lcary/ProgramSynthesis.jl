module Generation

using DataStructures

using ..Types
using ..Grammars
using ..Programs

export generator, Result, Context, generator

struct Context
    next_variable::Int
    substitution::Array{Tuple}
end

Context() = Context(0, [])

function apply(type::ProgramType, context::Context)
    # TODO: implement for TypeVariables too
    return type
end

function Base.show(io::IO, context::Context)
    n = context.next_variable
    pairs = [(a, apply(b, context)) for (a, b) in context.substitution]
    substr = ["$a ||> $b" for (a, b) in pairs]
    s = join(substr, ", ")
    print(io, "Context(next=$n, {$s})")
end

struct Result
    prior::Float64
    program::AbstractProgram
    context::Context
end

abstract type State end

struct StateMetadata
    recurse::Bool
    outer_args::Union{Array{ProgramType}, Nothing}  # TODO: use specific type
    outer_upper::Union{Float64, Nothing}
    outer_lower::Union{Float64, Nothing}
end

StateMetadata() = StateMetadata(false, nothing, nothing, nothing)

struct ProgramState <: State
    context::Context
    env::Any  # TODO: use specific type
    type::ProgramType
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
    previous_state::Union{State, Nothing}  # TODO: might only need previous_state's logProbability, not entire previous_state object reference
    metadata::StateMetadata
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
    env = append!([lhs], state.env)
    upper = state.upper_bound
    lower = state.lower_bound
    return ProgramState(
        state.context, env, rhs, upper, lower,
        state.depth, state.previous_state, state.metadata)
end

struct ApplicationState <: State
    context::Context
    env::Any  # TODO: use specific type
    func::Any  # TODO: use specific type
    func_args::Array{ProgramType}
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
    argument_index::Int
    previous_state::Union{State, Nothing}  # TODO: might only need previous_state's logProbability, not entire previous_state object reference
    original_func::Any  # TODO: use specific type
    metadata::StateMetadata
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
    type::ProgramType
    program::Program
    context::Context
end

function to_application(candidate::Candidate, state::ProgramState)
    func_args = function_arguments(candidate.type)
    new_upper = state.upper_bound + candidate.log_probability
    new_lower = state.lower_bound + candidate.log_probability
    new_depth = state.depth - 1
    return ApplicationState(
        candidate.context, state.env, candidate.program, func_args,
        new_upper, new_lower, new_depth, 0, state, candidate.program,
        state.metadata)
end

function request_candidates(state::ApplicationState)  # TODO: improve func type
    arg_request = apply(state.func_args[1], state.context)
    outer_args = state.func_args[2:end]
    metadata = StateMetadata(
        true, outer_args,
        state.upper_bound, state.lower_bound)
    return ProgramState(
        state.context, state.env, arg_request,
        state.upper_bound, 0.0, state.depth, state, metadata)
end

function to_application(state::ApplicationState)
    new_func = Application(state.func, state.previous_state.type)
    new_upper = state.metadata.outer_upper + 0.0  # TODO: verify if the outer log log_probability is ever non-zero
    new_lower = state.metadata.outer_lower + 0.0  # TODO: verify if the outer log log_probability is ever non-zero
    new_arg_index = state.argument_index + 1
    return ApplicationState(
        state.context, state.env, new_func,
        state.metadata.outer_args,
        new_upper, new_lower, state.depth, new_arg_index,
        state, state.func, StateMetadata())  # TODO: use original_func from outer ApplicationState
end

function build_candidates(grammar::Grammar, state::State)::Array{Candidate}
    type, context, env = state.type, state.context, state.env
    candidates = Array{Candidate}([])

    # TODO: replace with actual logic
    l = -2.3978952727983707

    t1 = ProgramType(Dict(
        "constructor" => "->", "arguments" => [
            Dict("constructor" => "int", "arguments" => []),
            Dict(
                "constructor" => "->", "arguments" => [
                    Dict("constructor" => "list(int)", "arguments" => []),
                    Dict("constructor" => "int", "arguments" => [])
                ]
            )
        ]
    ))
    push!(candidates, Candidate(l, t1, Program("index"), Context(1, [])))

    t2 = ProgramType(Dict(
        "constructor" => "->", "arguments" => [
            Dict("constructor" => "list(t0)", "arguments" => []),
            Dict("constructor" => "int", "arguments" => [])
        ]
    ))
    push!(candidates, Candidate(l, t2, Program("length"), Context(1, [])))

    t3 = ProgramType(Dict("constructor" => "int", "arguments" => []))
    push!(candidates, Candidate(l, t3, Program("0"), Context(1, [])))

    # t4 = ProgramType(Dict("constructor" => "list(t1)", "arguments" => []))
    # ctx = Context(2, [(ProgramType("t0"), ProgramType("t1"))])
    # push!(candidates, Candidate(l, t4, Program("empty"), ctx))

    return candidates
end

function valid(candidate::Candidate, upper_bound::Float64)::Bool
    return -candidate.log_probability < upper_bound
end

function all_invalid(candidates::Array{Candidate}, upper_bound::Float64)::Bool
    for c in candidates
        if !valid(c, upper_bound)
            return true
        end
    end
    return false
end

struct InvalidStateType <: Exception end

function add_candidates!(
    requests::Stack{State},
    grammar::Grammar,
    state::ProgramState
)
    candidates = build_candidates(grammar, state)
    if all_invalid(candidates, state.upper_bound)
        # println("all invalid")
        return
    end
    for c in candidates
        if valid(c, state.upper_bound)
            push!(requests, to_application(c, state))
        end
    end
end

function is_symmetrical(s::ApplicationState)
    # TODO: add implementation
    return true
end

function process_program_state!(
    requests::Stack{State},
    grammar::Grammar,
    state::ProgramState
)
    if Types.is_arrow(state.type)
        push!(requests, convert_arrow(state))
        return
    else
        add_candidates!(requests, grammar, state)
        return
    end
end

function process_application_state!(
    results::Channel,
    requests::Stack{State},
    grammar::Grammar,
    state::ApplicationState
)
    if state.func_args == []
        if state.lower_bound <= 0.0 && state.upper_bound > 0.0
            if state.metadata.recurse
                if !is_symmetrical(state)
                    return
                end
                push!(requests, to_application(state))
            else
                # TODO: verify that the program is always sent to the outside in this case in actual dreamcoder
                put!(results, Result(1.0, Abstraction(state.func), Context()))  # TODO: use actual log_probability calculation!
                return
            end
        else
            # Reject this enumerate application state
            return
        end
    else
        push!(requests, request_candidates(state))
    end
end

function generator(
    results::Channel,
    grammar::Grammar,
    initial::ProgramState,
    debug::Bool=false
)
    requests = Stack{State}()
    push!(requests, initial)

    counter = 0
    while !isempty(requests)
        counter += 1
        state = pop!(requests)

        if debug
            println("state #$counter: $state")
        end

        if state.upper_bound < 0.0 || state.depth <= 1
            continue
        elseif isa(state, ProgramState)
            process_program_state!(requests, grammar, state)
        elseif isa(state, ApplicationState)
            process_application_state!(results, requests, grammar, state)
        else
            throw(InvalidStateType)
        end
    end
end

function generator(
    grammar::Grammar,
    env::Array{Any},  # TODO: improve type
    type::ProgramType,
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
        max_depth,
        nothing,
        StateMetadata()
    )
    return Channel((results) -> generator(results, grammar, state))
end

end
