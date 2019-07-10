module Grammar

using ..Program
using ..Types
using ..Utils

export GrammarData

mutable struct GrammarProduction
    program::DCProgram
    log_probability::Float64
end

function GrammarProduction(data::Dict{String,Any})
    return GrammarProduction(
        DCProgram(data["expression"]),
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
