module Enumeration

using Dates
using JSON
using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Tasks
using ..Utils

export EnumerationData, run_enumeration, enumerate_for_tasks

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

function create_response(filepath::String, data::Dict{String,Any})
    stringdata = JSON.json(data)
    open(filepath, "w") do f
        write(f, stringdata)
    end
end

struct EnumerationData
    tasks::Array{ProblemSet}
    grammar::Grammar
    program_timeout::Float64
    verbose::Bool
    lower_bound::Float64
    upper_bound::Float64
    budget_increment::Float64
    max_parameters::Int
end

function EnumerationData(data::Dict{String,Any})
    return EnumerationData(
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

function parse_request_data(filepath::String)::EnumerationData
    data = JSON.parsefile(filepath)
    return EnumerationData(data)
end

struct InvalidTaskType <: Exception
    msg::AbstractString
end

struct EnumerationProgram
    prior::Float64
    program::Program
end

function enumeration(data::EnumerationData)::Array{EnumerationProgram}
    grammar = data.grammar
    return [EnumerationProgram(0.0, p.program) for p in grammar.library]  # TODO: fix priors!
end

struct FrontierEntry
    program::Program
    log_likelihood::Float64
    log_prior::Float64
    hit_time::Float64
end

mutable struct FrontierCache
    index::Dict{String,FrontierEntry}
    counter::Int
end

FrontierCache() = FrontierCache(Dict(), 0)

function addfrontier!(cache::FrontierCache, frontier::FrontierEntry)
    cache.counter += 1
    key = string(cache.counter)
    cache.index[key] = frontier
    return string(cache.counter)
end

struct HitArray
    array::Array{PriorityQueue{String,Float64}}
    function HitArray(n::Int)
        return new([PriorityQueue{String,Float64}() for i in 1:n])
    end
end

function update_frontier(
    index::Int,
    task::ProblemSet,
    result::EnumerationProgram,
    hits::HitArray,
    cache::FrontierCache
)
    prior = result.prior
    program = result.program

    pq = hits.array[index]

    success, likelihood = true, 0.0  # TODO: fix fake data
    # success, likelihood = likelihoodModel.score(p, task)  TODO
    # if not success, skip

    priority = -(likelihood + prior)

    frontier = FrontierEntry(
        program,
        likelihood,
        prior,
        0.0  # TODO: Fix hit_time
    )
    frontier_key = addfrontier!(cache, frontier)
    enqueue!(pq, frontier_key, priority)

    if length(pq) > task.maximum_frontier
        key = dequeue!(pq)
        delete!(cache.index, key)
    end
end

function enumerate_for_tasks(data::EnumerationData)::Dict{String,Any}

    # TODO: make use of budget/upperbound/lowerbound

    hits = HitArray(length(data.tasks))
    cache = FrontierCache()

    start = time()
    while time() < start + data.program_timeout
        for result in enumeration(data)
            for (index, task) in enumerate(data.tasks)
                update_frontier(index, task, result, hits, cache)
            end
        end
    end

    frontiers = Dict()
    for (index, task) in enumerate(data.tasks)
        sublist = []
        for (key, priority) in hits.array[index]
            frontier = cache.index[key]
            entry = Dict{String,Union{String,Float64}}(
                "program" => frontier.program.source,
                "time" => frontier.hit_time,
                "logLikelihood" => frontier.log_likelihood,
                "logPrior" => frontier.log_prior
            )
            push!(sublist, entry)
        end
        frontiers[task.name] = sublist
    end
    return frontiers
end

function run_enumeration(request_file::String)::String
    create_message_dir()
    enumeration_data = parse_request_data(request_file)
    response_data = enumerate_for_tasks(enumeration_data)
    response_file = get_response_filename()
    create_response(response_file, response_data)
    return response_file
end

end
