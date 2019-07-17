module Grammars

using ..Programs
using ..Types
using ..Utils

export Grammar, Production

mutable struct Production
    program::Program
    log_probability::Float64
end

function Production(data::Dict{String,Any}, primitives::Dict{String,Primitive})
    return Production(
        Program(data["expression"], primitives),
        data["logProbability"]
    )
end

mutable struct Grammar
    primitives::Dict{String,Primitive}
    productions::Array{Production}
    log_variable::Float64
    continuation_type::Union{AbstractType,Nothing}
end

function Grammar(data::Dict{String,Any}, primitives::Dict{String,Primitive})
    return Grammar(
        primitives,
        [Production(p, primitives) for p in data["productions"]],
        data["logVariable"],
        getoptional(data, "continuationType")
    )
end

end
