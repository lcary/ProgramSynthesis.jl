module Problems

using ..Types

export Problem, Example

struct Example
    inputs
    output
end

Example(data) = Example(data["inputs"], data["output"])

struct Problem
    name::String
    type::TypeField
    examples::Array{Example,1}
    max_solutions::Int
end

function Problem(data::Dict{String,Any})
    return Problem(
        data["name"],
        TypeField(data["request"]),
        map(Example, data["examples"]),
        data["maximumFrontier"]
    )
end

end
