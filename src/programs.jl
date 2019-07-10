module Programs

using ..Types

export Program

mutable struct Program
    source::String
    expression::Any
    type::ProgramType
end

function infertype(prog::Any)::ProgramType
    return ProgramType("?", [], -1)
end

function Program(prog::String)
    # expression = Meta.parse(prog)
    expression = prog
    return Program(
        prog,
        expression,
        infertype(expression)
    )
end

end
