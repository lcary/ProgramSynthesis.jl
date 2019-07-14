module Generation

using DataStructures

using ..Types
using ..Grammars
using ..Programs

export generator, Result, Context, generator

abstract type Frame end

struct Context
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
    return candidates
end

function valid(c::Candidate, upper_bound::Float64)::Bool
    return -c.log_probability < upper_bound
end

function all_invalid(candidates::Array{Candidate}, upper_bound::Float64)::Bool
    for c in candidates
        if !valid(c, upperBound)
            return true
        end
    end
    return false
end

function convert_arrow_frame(f::EnumerateFrame)::EnumerateFrame
    lhs = f.type.arguments[1]
    rhs = f.type.arguments[2]
    env = append!([lhs], f.env)
    upper = f.upper_bound
    lower = f.lower_bound
    return EnumerateFrame(f.context, env, rhs, upper, lower, f.depth)
end

function generator(
    grammar::Grammar,
    frame::EnumerateFrame
)
    results = Array{Result}([])

    # do a depth-first search of the queue
    queue = Stack{Frame}()
    push!(queue, frame)

    while !isempty(queue)
        f = pop!(queue)

        if f.upper_bound < 0.0 || f.depth <= 1
            continue
        end

        if isa(f, EnumerateFrame)
            println(f.context, " ", f.env, " ", f.type)
            if Types.is_arrow(f.type)
                push!(queue, convert_arrow_frame(f))
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
        else
            println(f.context, " ", f.env, " ", f.argument_requests)
        end

        # if f.enumerate_application
        #
        # else
    end
    push!(results, Result(1.0, grammar.library[1].program, Context()))
    return results
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
    return generator(grammar, frame)
end

end
