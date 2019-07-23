module Grammars

using ..Programs
using ..Parsers
using ..Types
using ..Utils

export Grammar, Production

struct Production
    program::Program
    log_probability::Float64
end

function Production(data::Dict{String,Any}, primitives::Dict{String,Program})
    program = parse_program(data["expression"], primitives)
    return Production(program, data["logProbability"])
end

struct Grammar
    primitives::Dict{String,Program}
    productions::Array{Production,1}
    log_variable::Float64
    continuation_type::Union{TypeField,Nothing}
end

function Grammar(data::Dict{String,Any}, primitives::Dict{String,Program})
    return Grammar(
        primitives,
        [Production(p, primitives) for p in data["productions"]],
        data["logVariable"],
        getoptional(data, "continuationType")
    )
end

end
