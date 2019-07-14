module Generation

using DataStructures

using ..Types
using ..Grammars
using ..Programs

export generator, Result, Context, generator

abstract type Frame end

struct Context
    next_variable::Int
    substitution::Array{Tuple}
end

Context() = Context(0, [])

function apply(t::ProgramType, c::Context)
    return true  # TODO: implement
end

function Base.show(io::IO, c::Context)
    n = c.next_variable
    # TODO: replace substr with next line when apply is defined
    substr = []
    # substr = ["t$a ||> $b" for (a, b) in c.substitution]
    # substr = ["t$a ||> $b" for (a, apply(b, c)) in c.substitution]
    s = join(substr, ", ")
    print(io, "Context(next = $n, {$s}")
end

struct Result
    prior::Float64
    program::AbstractProgram
    context::Context
end

struct EnumerateFrame <: Frame
    context::Context
    env::Any  # TODO: use specific type
    type::ProgramType
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
    parent::Union{Frame, Nothing}  # TODO: might only need parent's logProbability, not entire parent object reference
end

struct EnumerateAppFrame <: Frame
    context::Context
    env::Any  # TODO: use specific type
    func::Any  # TODO: use specific type
    func_args::Array{ProgramType}
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
    argument_index::Int
    parent::Union{Frame, Nothing}  # TODO: might only need parent's logProbability, not entire parent object reference
end

struct Candidate
    log_probability::Float64
    type::ProgramType
    program::Program
    context::Context
end

function build_candidates(grammar::Grammar, frame::Frame)::Array{Candidate}
    type, context, env = frame.type, frame.context, frame.env
    candidates = Array{Candidate}([])

    # TODO: replace with actual logic
    l = -2.3978952727983707

    d1 = Dict(
        "constructor" => "->", "arguments" => [
            Dict("constructor" => "int", "arguments" => []),
            Dict(
                "constructor" => "->", "arguments" => [
                    Dict("constructor" => "list(int)", "arguments" => []),
                    Dict("constructor" => "int", "arguments" => [])
                ]
            )
        ]
    )
    t1 = ProgramType(d1)
    push!(candidates, Candidate(l, t1, Program("index"), Context(1, [])))

    d2 = Dict(
        "constructor" => "->", "arguments" => [
            Dict("constructor" => "list(t0)", "arguments" => []),
            Dict("constructor" => "int", "arguments" => [])
        ]
    )
    t2 = ProgramType(d2)
    push!(candidates, Candidate(l, t2, Program("length"), Context(1, [])))

    d3 = Dict("constructor" => "int", "arguments" => [])
    t3 = ProgramType(d3)
    push!(candidates, Candidate(l, t3, Program("0"), Context(1, [])))

    return candidates
end

function valid(c::Candidate, upper_bound::Float64)::Bool
    return -c.log_probability < upper_bound
end

function all_invalid(candidates::Array{Candidate}, upper_bound::Float64)::Bool
    for c in candidates
        if !valid(c, upper_bound)
            return true
        end
    end
    return false
end

function convert_arrow(f::EnumerateFrame)::EnumerateFrame
    lhs = f.type.arguments[1]
    rhs = f.type.arguments[2]
    env = append!([lhs], f.env)
    upper = f.upper_bound
    lower = f.lower_bound
    return EnumerateFrame(f.context, env, rhs, upper, lower, f.depth, nothing)
end

function generator(
    channel::Channel,
    grammar::Grammar,
    initial_frame::EnumerateFrame
)
    results = Array{Result}([])

    # do a depth-first search of the queue
    queue = Stack{Frame}()
    push!(queue, initial_frame)

    counter = 0
    while !isempty(queue)
        counter += 1
        f = pop!(queue)

        # DEBUG:
        # println("frame #$counter: $f")

        if f.upper_bound < 0.0 || f.depth <= 1
            continue
        end

        if isa(f, EnumerateFrame)
            if Types.is_arrow(f.type)
                push!(queue, convert_arrow(f))
            else
                candidates = build_candidates(grammar, f)
                if all_invalid(candidates, f.upper_bound)
                    println("All invalid!")
                    continue
                end
                for c in candidates
                    if valid(c, f.upper_bound)
                        func_args = function_arguments(c.type)
                        new_upper = f.upper_bound + c.log_probability
                        new_lower = f.lower_bound + c.log_probability
                        new_frame = EnumerateAppFrame(
                            c.context, f.env, c.program, func_args,
                            new_upper, new_lower, f.depth - 1, 0, f)
                        push!(queue, new_frame)
                    end
                end
            end
        elseif isa(f, EnumerateAppFrame)
            if f.func_args == []
                if f.lower_bound <= 0.0 && f.upper_bound > 0.0
                    # TODO: verify that the program is always sent to the outside in this case in actual dreamcoder
                    put!(channel, Result(1.0, f.func, Context()))  # TODO: use actual log_probability calculation!
                else
                    # Reject this enumerate application frame
                    continue
                end
            end
            println("TODO: other EnumerateAppFrame logic")
        else
            println("other frame?")
            println(f.context, " ", f.env, " ", f.func_args)
        end

        # if f.enumerate_application
        #
        # else
    end
end

function generator(
    grammar::Grammar,
    env::Array{Any},  # TODO: improve type
    type::ProgramType,
    upper_bound::Float64,
    lower_bound::Float64,
    max_depth::Int
)
    frame = EnumerateFrame(
        Context(),
        env,
        type,
        upper_bound,
        lower_bound,
        max_depth,
        nothing
    )
    return Channel((channel) -> generator(channel, grammar, frame))
end

end
