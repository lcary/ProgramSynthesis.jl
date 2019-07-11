module Frontiers

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Tasks
using ..Utils

export update_frontiers!,
       FrontierEntry,
       FrontierCache,
       json_format,
       is_explored,
       priority

struct FrontierEntry
    program::Program
    log_likelihood::Float64
    log_prior::Float64
    hit_time::Float64
end

"""

    priority(frontier)

The priority of the frontier is proportional to the likelihood
and prior, and lower is better. This is because the priority
value is stored in the PriorityQueue of the FrontierCache, and
the frontiers with the highest priority values are removed first
during pruning.
"""
priority(f::FrontierEntry) = f.log_likelihood + f.log_prior

function json_format(frontier::FrontierEntry)
    return Dict(
        "program" => frontier.program.source,
        "time" => frontier.hit_time,
        "logLikelihood" => frontier.log_likelihood,
        "logPrior" => frontier.log_prior
    )
end

mutable struct FrontierCache
    lookup::Dict{String,FrontierEntry}
    counter::Int
    hits::Array{PriorityQueue{String,Float64}}

    function FrontierCache(n::Int)
        hits = [PriorityQueue{String,Float64}() for i in 1:n]
        return new(Dict(), 0, hits)
    end
end

"""

    add!(cache, frontier, index)

Add the frontier to the lookup table of the cache so that we can retrieve
the program later, then add the lookup key of the program to the priority
queue along with the priority value. The lookup key is a counter that is
incremented with each addition, since we don't want to overwrite any
existing programs in the lookup table.
"""
function add!(cache::FrontierCache, frontier::FrontierEntry, index::Int)
    cache.counter += 1
    key = string(cache.counter)
    cache.lookup[key] = frontier

    pq = cache.hits[index]
    enqueue!(pq, key, priority(frontier))
    return key
end

"""

    prune!(cache, index, max_frontier)

If the maximum number of frontiers is reached, remove the frontiers
that have the highest value, then clear the lookup entry in the cache
for that program to free up space since we don't care about it anymore.
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

    add!(cache, frontier, index)
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
