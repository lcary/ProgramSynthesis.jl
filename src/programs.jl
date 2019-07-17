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
       DeBruijnIndex,
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

mutable struct DeBruijnIndex <: AbstractProgram
    i::Int
end

str(p::Primitive)::String = p.name
str(p::Program)::String = p.source
str(p::DeBruijnIndex)::String = "\$$(p.i)"
str(p::Abstraction)::String = "(lambda $(string(p.body)))"
str(p::Application)::String = "($(string(p.func)) $(string(p.args)))"

Base.show(io::IO, p::AbstractProgram) = print(io, str(p))

json_format(p::AbstractProgram)::String = str(p)

end
