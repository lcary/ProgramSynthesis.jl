module Types

using ..Utils

export ProgramType

mutable struct ProgramType
    constructor::String
    arguments::Array{ProgramType,1}
    index::Union{Int, Nothing}
    function ProgramType(constructor, arguments, index)
        return new(constructor, map(ProgramType, arguments), index)
    end
end

function ProgramType(data::Dict{String,Any})
    return ProgramType(
        data["constructor"],
        data["arguments"],
        getoptional(data, "index"),
    )
end

const ARROW = "->"

is_arrow(t::ProgramType)::Bool = t.constructor == ARROW

function hashed(t::ProgramType)::UInt64
    h = UInt64(0)
    h += hash(t.constructor)
    for a in t.arguments
        h += hashed(a)
    end
    return h
end

end
