module Tasks

using ..Types

export ProgramTask, Example

# TODO: should output support any type?
mutable struct Example
    inputs::Array{Any}
    output::Union{Array{Any},Int,Bool}
end

mutable struct ProgramTask
    name::String
    type::ProgramType
    examples::Array{Example}
    max_solutions::Int
end

function Example(data::Dict{String,Any})
    return Example(data["inputs"], data["output"])
end

function ProgramTask(data::Dict{String,Any})
    return ProgramTask(
        data["name"],
        ProgramType(data["request"]),
        map(Example, data["examples"]),
        data["maximumFrontier"]
    )
end

end
