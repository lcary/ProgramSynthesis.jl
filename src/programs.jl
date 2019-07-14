module Programs

using ..Types
using ..Problems

export Program,
       evaluates,
       can_solve,
       try_solve,
       AbstractProgram,
       Abstraction

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

mutable struct Program <: AbstractProgram
    source::String
    expression::Any
    type::ProgramType
end

# TODO: implement type inference logic
function infertype(prog::Any)::ProgramType
    return ProgramType("?", [], -1)
end

function Program(prog::String)
    # expression = Meta.parse(prog)  TODO: Actually parse expressions
    expression = prog
    return Program(
        prog,
        expression,
        infertype(expression)
    )
end

Base.show(io::IO, p::Program) = print(io, p.source)

# TODO: implement
function evaluate(program::Program, env::Any)
    return program
end

mutable struct Abstraction <: AbstractProgram
    body::Any  # TODO: improve type
end

function evaluate(program::Abstraction, env::Any)
    return (x) -> program.body.evaluate([x] + env)
end

end
