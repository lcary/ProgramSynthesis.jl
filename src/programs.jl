module Programs

using ..Types
using ..Tasks

export Program, evaluates, can_solve

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

function can_solve(program::Program, task::ProgramTask, timeout::Float64)::Bool
    # TODO: actually test solving tasks
    return true
end

end
