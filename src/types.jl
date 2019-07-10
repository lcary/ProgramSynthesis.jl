module Types

include("utils.jl")
using .Utils

export DCType

mutable struct DCType
    constructor::String
    arguments::Array{DCType,1}
    index::Union{Int, Nothing}
    function DCType(constructor, arguments, index)
        return new(constructor, map(DCType, arguments), index)
    end
end

function DCType(data::Dict{String,Any})
    return DCType(
        data["constructor"],
        data["arguments"],
        getoptional(data, "index"),
    )
end

end
