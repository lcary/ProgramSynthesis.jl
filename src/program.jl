module Program

include("types.jl")
using .Types

export DCProgram

mutable struct DCProgram
    source::String
    expression::Any
    type::DCType
end

function infertype(prog::Any)::DCType
    return DCType("?", [], -1)
end

function DCProgram(prog::String)
    # expression = Meta.parse(prog)
    expression = prog
    return DCProgram(
        prog,
        expression,
        infertype(expression)
    )
end

end
