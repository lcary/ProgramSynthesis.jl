module Grammar

include("types.jl")
using .Types
include("utils.jl")
using .Utils

export GrammarData

mutable struct Program
    source::String
    expression::Any
    type::DCType
end

function infertype(prog::Any)::DCType
    return DCType("?", [], -1)
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

mutable struct GrammarProduction
    program::Program
    log_probability::Float64
end

function GrammarProduction(data::Dict{String,Any})
    return GrammarProduction(
        Program(data["expression"]),
        data["logProbability"]
    )
end

mutable struct GrammarData
    library::Array{GrammarProduction}
    log_variable::Float64
    continuation_type::Union{DCType,Nothing}
end

function GrammarData(data::Dict{String,Any})
    return GrammarData(
        map(GrammarProduction, data["productions"]),
        data["logVariable"],
        getoptional(data, "continuationType")
    )
end

end
