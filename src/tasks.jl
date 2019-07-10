module Tasks

using ..Types

export ProblemSet

# TODO: should output support any type?
mutable struct Example
    inputs::Array{Any}
    output::Union{Array{Any},Int,Bool}
end

mutable struct ProblemSet
    name::String
    type::ProgramType
    examples::Array{Example}
    maximum_frontier::Int
end

function Example(data::Dict{String,Any})
    return Example(data["inputs"], data["output"])
end

function ProblemSet(data::Dict{String,Any})
    return ProblemSet(
        data["name"],
        ProgramType(data["request"]),
        map(Example, data["examples"]),
        data["maximumFrontier"]
    )
end

end
