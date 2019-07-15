module Programs

using ..Types
using ..Problems

export Program,
       evaluates,
       can_solve,
       try_solve,
       AbstractProgram,
       Abstraction,
       Application,
       AbstractProgram,
       Primitive,
       json_format

abstract type AbstractProgram end

function can_solve(program::AbstractProgram, example::Example)::Bool
    try
        for input in example.inputs
            f = f(input)
        end
    catch
        return false
    end
    if f != example.output
        return false
    end
    return true
end

function can_solve(program::AbstractProgram, problem::Problem)::Bool

    return true  # TODO: REMOVE AFTER COMPLETING IMPLEMENTATION

    try
        f = evaluate(program, [])
    catch
        # free variable
        return false
    end

    for example in problem.examples
        if !can_solve(program, example)
            return false
        end
    end

    return true
end

function try_solve(program::AbstractProgram, problem::Problem)::Float64
    if can_solve(program, problem)
        log_likelihood = 0.0
    else
        log_likelihood = -Inf
    end
    return log_likelihood
end

struct Primitive <: AbstractProgram
    name::String
    type::ProgramType
    func::Any  # TODO: use Function type
end

mutable struct Program <: AbstractProgram
    source::String
    expression::Any
    type::ProgramType
end

# TODO: implement type inference logic
function infertype(prog::Any)::ProgramType
    return TypeConstructor("?", [], -1)
end

struct ParseFailure <: Exception
    msg::String
end

# TODO: Support invented, abstraction, application, index, and fragment programs
function parse(s::String, primitives::Dict{String,Primitive})
    if haskey(primitives, s)
        return primitives[s]
    end
    throw(ParseFailure("Unable to parse Program from string ($s)."))
end

function Program(name::String, primitives::Dict{String,Primitive})
    expression = parse(name, primitives)
    return Program(
        name,
        expression.func,
        expression.type
    )
end

Base.show(io::IO, p::Program) = print(io, p.source)

# TODO: implement
function evaluate(program::Program, env::Any)
    return program
end

# TODO: docstring
mutable struct Abstraction <: AbstractProgram
    body::Any  # TODO: improve type
end

function evaluate(program::Abstraction, env::Any)
    return (x) -> program.body.evaluate([x] + env)
end

# TODO: docstring
mutable struct Application <: AbstractProgram
    func::Any  # TODO: improve type
    args::Any  # TODO: improve type
end

function Base.show(io::IO, p::Application)
    print(io, "Application($(p.func), args=$(p.args))")
end

json_format(p::Program) = p.source
json_format(p::Abstraction) = p.body

end
