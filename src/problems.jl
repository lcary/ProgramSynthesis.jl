module Problems

using ..Types

export Problem, Example

# TODO: should output support any type?
mutable struct Example
    inputs::Array{Any}
    output::Union{Array{Any},Int,Bool}
end

mutable struct Problem
    name::String
    type::ProgramType
    examples::Array{Example}
    max_solutions::Int
end

function Example(data::Dict{String,Any})
    return Example(data["inputs"], data["output"])
end

function Problem(data::Dict{String,Any})
    return Problem(
        data["name"],
        TypeConstructor(data["request"]),
        map(Example, data["examples"]),
        data["maximumFrontier"]
    )
end

end
