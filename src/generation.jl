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
end

struct EnumerateAppFrame <: Frame
    context::Context
    env::Any  # TODO: use specific type
    func::Any  # TODO: use specific type
    argument_requests::Array{ProgramType}
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
    original_function::Any # TODO: use specific type
    argument_index::Int
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
    l = -2.3978952727983707
    # !push(candidates, Candidate(l, , Context(1, [("t0", "int")])))
    # "(-2.3978952727983707, int -> list(int) -> int, index, Context(next = 1, {t0 ||> int}))"
    # !push(candidates, Candidate(l, , Context(2, [("t1", "int")]))
    # "(-2.3978952727983707, list(t0) -> int -> (t0 -> int -> int) -> int, fold, Context(next = 2, {t1 ||> int}))"
    d = Dict("constructor" => "->", "arguments" => [Dict("constructor" => "list(t0)", "arguments" => []), Dict("constructor" => "int", "arguments" => [])])
    t3 = ProgramType(d)
    push!(candidates, Candidate(l, t3, Program("index"), Context(1, [])))
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
    return EnumerateFrame(f.context, env, rhs, upper, lower, f.depth)
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

    while !isempty(queue)
        f = pop!(queue)

        if f.upper_bound < 0.0 || f.depth <= 1
            continue
        end

        if isa(f, EnumerateFrame)
            if Types.is_arrow(f.type)
                push!(queue, convert_arrow(f))
            else
                candidates = build_candidates(grammar, f)
                if all_invalid(candidates, f.upper_bound)
                    continue
                end
                for c in candidates
                    if valid(c, f.upper_bound)
                        print("TODO")
                    end
                end
            end
        elseif isa(f, EnumerateAppFrame)
            println("whoa")
        else
            println(f.context, " ", f.env, " ", f.argument_requests)
        end

        # if f.enumerate_application
        #
        # else
    end
    put!(channel, Result(1.0, grammar.library[1].program, Context()))
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
        max_depth
    )
    return Channel((channel) -> generator(channel, grammar, frame))
end

end
