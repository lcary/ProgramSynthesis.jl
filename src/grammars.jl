module Grammars

using ..Programs
using ..Types
using ..Utils

export Grammar

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

mutable struct Grammar
    library::Array{GrammarProduction}
    log_variable::Float64
    continuation_type::Union{ProgramType,Nothing}
end

function Grammar(data::Dict{String,Any})
    return Grammar(
        map(GrammarProduction, data["productions"]),
        data["logVariable"],
        getoptional(data, "continuationType")
    )
end

end
