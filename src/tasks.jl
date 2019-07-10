module Tasks

using ..Types

export DCTask

# TODO: should output support any type?
mutable struct Example
    inputs::Array{Any}
    output::Union{Array{Any},Int,Bool}
end

mutable struct DCTask
    name::String
    type::DCType
    examples::Array{Example}
    maximum_frontier::Int
end

function Example(data::Dict{String,Any})
    return Example(data["inputs"], data["output"])
end

function DCTask(data::Dict{String,Any})
    return DCTask(
        data["name"],
        DCType(data["request"]),
        map(Example, data["examples"]),
        data["maximumFrontier"]
    )
end

end
