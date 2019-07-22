module Problems

using ..Types

export Problem, Example

mutable struct Example
    inputs
    output
end

Example(data) = Example(data["inputs"], data["output"])

mutable struct Problem
    name::String
    type::AbstractType
    examples::Array{Example,1}
    max_solutions::Int
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
