module Enumeration

using Dates
using JSON

using ..Types
using ..Grammars
using ..Programs
using ..Tasks
using ..Utils
using ..Frontiers

export run_enumeration, enumerate_for_tasks

const message_dir = "messages"

function create_message_dir()
    if !isdir(message_dir)
        mkdir(message_dir)
    end
end

function response_filename()::String
    ts = Dates.format(Dates.now(), "yyyymmdd_THHMMSS")
    parts = ["response", "enumeration", "PID", getpid(), ts]
    filename = "response_enumeration_PID$(getpid())_$(ts).json"
    return abspath("messages", filename)
end

function write_response(data::Dict{String,Any})::String
    stringdata = JSON.json(data)
    filename = response_filename()
    open(filename, "w") do f
        write(f, stringdata)
    end
    return filename
end

struct Request
    tasks::Array{ProblemSet}
    grammar::Grammar
    program_timeout::Float64
    verbose::Bool
    lower_bound::Float64
    upper_bound::Float64
    budget_increment::Float64
    max_parameters::Int
end

function Request(data::Dict{String,Any})
    return Request(
        map(ProblemSet, data["tasks"]),
        Grammar(data["DSL"]),
        data["programTimeout"],
        data["verbose"],
        data["lowerBound"],
        data["upperBound"],
        data["budgetIncrement"],
        getoptional(data, "maxParameters", 99)
    )
end

struct EnumerationResult
    prior::Float64
    program::Program
end

function enumeration(data::Request)::Array{EnumerationResult}
    grammar = data.grammar
    return [EnumerationResult(0.0, p.program) for p in grammar.library]  # TODO: fix priors!
end

function json_format(data::Request, cache::FrontierCache)::Dict{String,Any}
    response = Dict()
    for (index, task) in enumerate(data.tasks)
        sublist = []
        for (key, priority) in cache.hits[index]
            entry = Frontiers.json_format(cache.index[key])
            push!(sublist, entry)
        end
        response[task.name] = sublist
    end
    return response
end

function enumerate_for_tasks(data::Request)::Dict{String,Any}
    budget = data.lower_bound + data.budget_increment
    max_frontiers = [t.max_frontier for t in data.tasks]

    cache = FrontierCache(length(data.tasks))

    start = time()
    while (
        time() < start + data.program_timeout
        && !is_explored(cache, max_frontiers)
        && budget <= data.upper_bound
    )
        for result in enumeration(data)
            prior = result.prior
            program = result.program
            update_frontiers!(cache, prior, program, data.tasks)
        end
    end

    return json_format(data, cache)
end

function enumerate_for_tasks(request::Dict{String,Any})::Dict{String,Any}
    return enumerate_for_tasks(Request(request))
end

function run_enumeration(filename::String)::String
    create_message_dir()
    request = JSON.parsefile(filename)
    response = enumerate_for_tasks(request)
    return write_response(response)
end

end
