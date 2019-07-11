module Programs

using ..Types
using ..Problems

export Program, evaluates, can_solve, try_solve

mutable struct Program
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

function evaluate(program::Program, environment::Any)
    return program
end


function can_solve(program::Program, example::Example)::Bool
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

function can_solve(program::Program, problem::Problem)::Bool

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

function try_solve(program::Program, problem::Problem)::Float64
    if can_solve(program, problem)
        log_likelihood = 0.0
    else
        log_likelihood = -Inf
    end
    return log_likelihood
end

end
