module Frontiers

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Tasks
using ..Utils

export update_frontier!,
       Frontier,
       FrontierElement,
       json_format,
       is_explored,
       priority

"""
A program and its task-solving metrics within a Frontier.
The search time is the time it took to find the program.
"""
struct FrontierElement
    program::Program
    log_likelihood::Float64
    log_prior::Float64
    search_time::Float64
end

"""

    priority(frontier)

The priority of the frontier is proportional to the likelihood and prior.
This value is used by the Frontier to prune programs with low priorities.
"""
priority(fe::FrontierElement) = fe.log_likelihood + fe.log_prior

function json_format(element::FrontierElement)
    return Dict(
        "program" => element.program.source,
        "time" => element.search_time,
        "logLikelihood" => element.log_likelihood,
        "logPrior" => element.log_prior
    )
end

"""
Contains a lookup table for quickly looking up the frontier element
for a given counter key. The key is used in `solutions` to refer to the top
frontiers for all tasks as ordered by the priority of those frontiers.

Note that the index of each priority queue corresponds to the index of
each task in a complete list of tasks that we are enumerating programs for.
"""
mutable struct Frontier
    lookup::Dict{String,FrontierElement}
    counter::Int
    solutions::Array{PriorityQueue{String,Float64}}

    function Frontier(n::Int)
        solutions = [PriorityQueue{String,Float64}() for i in 1:n]
        return new(Dict(), 0, solutions)
    end
end

"""

    add!(frontier, element, index)

Add the frontier to the lookup table of the frontier, then add the lookup key
of the program to the priority queue in `solutions`.
"""
function add!(frontier::Frontier, element::FrontierElement, index::Int)
    frontier.counter += 1
    key = string(frontier.counter)
    frontier.lookup[key] = element

    pq = frontier.solutions[index]
    enqueue!(pq, key, priority(element))
    return key
end

"""

    prune!(frontier, index, max_solutions)

Conditionally prune low-priority frontiers in `solutions` and the lookup table.
"""
function prune!(frontier::Frontier, index::Int, max_solutions::Int)
    pq = frontier.solutions[index]
    if length(pq) > max_solutions
        key = dequeue!(pq)
        delete!(frontier.lookup, key)
    end
end

function is_explored(frontier::Frontier, max_solutions::Array{Int})::Bool
    pairs = zip(frontier.solutions, max_solutions)
    return all(length(h) >= maxfrontier for (h, maxfrontier) in pairs)
end

function update_frontier!(
    frontier::Frontier,
    element::FrontierElement,
    task::ProgramTask,
    index::Int
)
    add!(frontier, element, index)
    prune!(frontier, index, task.max_solutions)
end

end
