module Task

export TaskData, TaskType, TaskExample

struct TaskType
    constructor::String
    arguments::Array{TaskType}
    index::Int
end

struct TaskExample
    inputs::Array{Any}
    outputs::Array{Any}
end

struct TaskData
    name::String
    type::Array{TaskExample}
    examples::Array{TaskType}
    maximum_frontier::Int
end

end
