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

end
