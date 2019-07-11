module Enumeration

using Dates
using JSON
using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Tasks
using ..Utils

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

struct FrontierEntry
    program::Program
    log_likelihood::Float64
    log_prior::Float64
    hit_time::Float64
end

priority(f::FrontierEntry) = -(f.log_likelihood + f.log_prior)

function json_format(frontier::FrontierEntry)
    return Dict(
        "program" => frontier.program.source,
        "time" => frontier.hit_time,
        "logLikelihood" => frontier.log_likelihood,
        "logPrior" => frontier.log_prior
    )
end

mutable struct FrontierCache
    index::Dict{String,FrontierEntry}
    counter::Int
    hits::Array{PriorityQueue{String,Float64}}

    function FrontierCache(n::Int)
        hits = [PriorityQueue{String,Float64}() for i in 1:n]
        return new(Dict(), 0, hits)
    end
end

function add!(cache::FrontierCache, index::Int, frontier::FrontierEntry)
    cache.counter += 1
    key = string(cache.counter)
    cache.index[key] = frontier

    pq = cache.hits[index]
    enqueue!(pq, key, priority(frontier))
end

# TODO: unit test that this only prunes the lowest frontiers if necessary
function prune!(cache::FrontierCache, index::Int, max_frontier::Int)
    pq = cache.hits[index]
    if length(pq) > max_frontier
        # delete the lowest priority frontier
        key = dequeue!(pq)
        delete!(cache.index, key)
    end
end

function update_frontier(
    index::Int,
    task::ProblemSet,
    result::EnumerationResult,
    cache::FrontierCache
)
    prior = result.prior
    program = result.program

    success, likelihood = true, 0.0  # TODO: fix fake data
    # success, likelihood = likelihoodModel.score(p, task)  TODO
    # if not success, skip

    frontier = FrontierEntry(
        program,
        likelihood,
        prior,
        0.0  # TODO: Fix hit_time
    )

    add!(cache, index, frontier)
    prune!(cache, index, task.max_frontier)
end

function is_explored(cache::FrontierCache, max_frontiers::Array{Int})::Bool
    pairs = zip(cache.hits, max_frontiers)
    return all(length(h) >= maxfrontier for (h, maxfrontier) in pairs)
end

function json_format(data::Request, cache::FrontierCache)::Dict{String,Any}
    response = Dict()
    for (index, task) in enumerate(data.tasks)
        sublist = []
        for (key, priority) in cache.hits[index]
            entry = json_format(cache.index[key])
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
            for (index, task) in enumerate(data.tasks)
                update_frontier(index, task, result, cache)
            end
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
