module Enumeration

using Dates
using JSON

include("types.jl")
using .Types
include("grammar.jl")
using .Grammar
include("tasks.jl")
using .Tasks
include("utils.jl")
using .Utils

export EnumerationData, run_enumeration

const message_dir = "messages"

function create_message_dir()
    if !isdir(message_dir)
        mkdir(message_dir)
    end
end

function get_response_filename()::String
    ts = Dates.format(Dates.now(), "yyyymmdd_THHMMSS")
    parts = ["response", "enumeration", "PID", getpid(), ts]
    filename = "response_enumeration_PID$(getpid())_$(ts).json"
    return abspath("messages", filename)
end

function create_response(filepath::String, data)
    stringdata = JSON.json(data)
    open(filepath, "w") do f
        write(f, stringdata)
    end
end

struct EnumerationData
    tasks::Array{DCTask}
    grammar::GrammarData
    program_timeout::Float64
    verbose::Bool
    lower_bound::Float64
    upper_bound::Float64
    budget_increment::Float64
    max_parameters::Int
end

function EnumerationData(data::Dict{String,Any})
    return EnumerationData(
        map(DCTask, data["tasks"]),
        GrammarData(data["DSL"]),
        data["programTimeout"],
        data["verbose"],
        data["lowerBound"],
        data["upperBound"],
        data["budgetIncrement"],
        getoptional(data, "maxParameters", 99)
    )
end

function parse_request_data(filepath::String)::Dict{String,Any}
    data = JSON.parsefile(filepath)
    enum_data = EnumerationData(data)
    return data
end

function get_response_data(request_data::Dict)::Dict{String,Any}
    response_data = Dict()
    for t in request_data["tasks"]
        response_data[t["name"]] = []
    end
    return response_data
end

function run_enumeration(request_file::String)::String
    create_message_dir()
    request_data = parse_request_data(request_file)
    response_file = get_response_filename()
    response_data = get_response_data(request_data)
    create_response(response_file, response_data)
    return response_file
end

end
