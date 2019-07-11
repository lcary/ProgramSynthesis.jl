module Frontiers

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Tasks
using ..Utils

export update_frontiers!, FrontierCache, json_format

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

function update_frontiers!(
    cache::FrontierCache,
    prior::Float64,
    program::Program,
    task::ProblemSet,
    index::Int
)
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

function update_frontiers!(
    cache::FrontierCache,
    prior::Float64,
    program::Program,
    tasks::Array{ProblemSet}
)
    for (index, task) in enumerate(tasks)
        update_frontiers!(cache, prior, program, task, index)
    end
end

end
