module Frontiers

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Tasks
using ..Utils
using ..Likelihood

export update_frontiers!,
       Frontier,
       FrontierCache,
       json_format,
       is_explored,
       priority

struct Frontier
    program::Program
    log_likelihood::Float64
    log_prior::Float64
    hit_time::Float64
end

"""

    priority(frontier)

The priority of the frontier is proportional to the likelihood and prior.
This value is used by FrontierCache to prune programs with low priorities.
"""
priority(f::Frontier) = f.log_likelihood + f.log_prior

function json_format(frontier::Frontier)
    return Dict(
        "program" => frontier.program.source,
        "time" => frontier.hit_time,
        "logLikelihood" => frontier.log_likelihood,
        "logPrior" => frontier.log_prior
    )
end

"""
Contains a lookup table for quickly looking up the frontier data
for a given counter key. The key is used in `hits` to refer to the top
frontiers for all tasks as ordered by the priority of those frontiers.

Note that the index of each priority queue corresponds to the index of
each task in a complete list of tasks that we are enumerating programs for.
"""
mutable struct FrontierCache
    lookup::Dict{String,Frontier}
    counter::Int
    hits::Array{PriorityQueue{String,Float64}}

    function FrontierCache(n::Int)
        hits = [PriorityQueue{String,Float64}() for i in 1:n]
        return new(Dict(), 0, hits)
    end
end

"""

    add!(cache, frontier, index)

Add the frontier to the lookup table of the cache, then add the lookup key
of the program to the priority queue in `hits`.
"""
function add!(cache::FrontierCache, frontier::Frontier, index::Int)
    cache.counter += 1
    key = string(cache.counter)
    cache.lookup[key] = frontier

    pq = cache.hits[index]
    enqueue!(pq, key, priority(frontier))
    return key
end

"""

    prune!(cache, index, max_frontier)

Conditionally prune low-priority frontiers in `hits` and the lookup table.
"""
function prune!(cache::FrontierCache, index::Int, max_frontier::Int)
    pq = cache.hits[index]
    if length(pq) > max_frontier
        key = dequeue!(pq)
        delete!(cache.lookup, key)
    end
end

function is_explored(cache::FrontierCache, max_frontiers::Array{Int})::Bool
    pairs = zip(cache.hits, max_frontiers)
    return all(length(h) >= maxfrontier for (h, maxfrontier) in pairs)
end

function update_frontiers!(
    cache::FrontierCache,
    prior::Float64,
    program::Program,
    task::ProblemSet,
    index::Int,
    model::LikelihoodModel
)
    success, likelihood = score(model, program, task)
    if !success
        return
    end

    frontier = Frontier(
        program,
        likelihood,
        prior,
        0.0  # TODO: Fix hit_time
    )

    add!(cache, frontier, index)
    prune!(cache, index, task.max_frontier)
end

function update_frontiers!(
    cache::FrontierCache,
    prior::Float64,
    program::Program,
    tasks::Array{ProblemSet},
    model::LikelihoodModel
)
    for (index, task) in enumerate(tasks)
        update_frontiers!(cache, prior, program, task, index, model)
    end
end

end
