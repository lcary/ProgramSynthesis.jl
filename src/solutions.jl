module Solutions

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Problems
using ..Utils

export update_solutions!,
       SolutionSet,
       Solution,
       json_format,
       is_explored,
       priority

"""
A program that solves a given problem within a set of problems.
The search time is the time it took to find the program.
"""
struct Solution
    program::Program
    log_likelihood::Float64
    log_prior::Float64
    search_time::Float64
end

"""

    priority(solution)

The priority of the solution is proportional to the likelihood and prior.
This value is used by the `SolutionSet` to prune suboptimal programs.
"""
priority(s::Solution) = s.log_likelihood + s.log_prior

function json_format(element::Solution)
    return Dict(
        "program" => element.program.source,
        "time" => element.search_time,
        "logLikelihood" => element.log_likelihood,
        "logPrior" => element.log_prior
    )
end

"""
The space of all solutions for a set of problems.

Contains a lookup table for quickly looking up the Solution
for a given counter key. The key is used in `best_solutions` to refer
to the top solutions to all problems as ordered by their priority.
The index of each priority queue corresponds to the index of each problem
in a complete list of problems.
"""
mutable struct SolutionSet
    lookup::Dict{String,Solution}
    counter::Int
    best_solutions::Array{PriorityQueue{String,Float64}}

    function SolutionSet(n::Int)
        best_solutions = [PriorityQueue{String,Float64}() for i in 1:n]
        return new(Dict(), 0, best_solutions)
    end
end

"""

    add!(solution, element, index)

Add the solution to the lookup table of the solution set, then add
the lookup key of the program to the priority queue in `best_solutions`.
"""
function add!(solutions::SolutionSet, element::Solution, index::Int)
    solutions.counter += 1
    key = string(solutions.counter)
    solutions.lookup[key] = element

    best = solutions.best_solutions[index]
    enqueue!(best, key, priority(element))
    return key
end

"""

    prune!(solution, index, max_solutions)

Conditionally prune low-scoring solutions in `best_solutions` and
the lookup table.
"""
function prune!(solutions::SolutionSet, index::Int, max_solutions::Int)
    best = solutions.best_solutions[index]
    if length(best) > max_solutions
        key = dequeue!(best)
        delete!(solutions.lookup, key)
    end
end

function is_explored(solutions::SolutionSet, max_solutions::Array{Int})::Bool
    pairs = zip(solutions.best_solutions, max_solutions)
    return all(length(h) >= max_solns for (h, max_solns) in pairs)
end

function json_format(solutions::SolutionSet, index::Int)
    best = solutions.best_solutions[index]
    return [json_format(solutions.lookup[key]) for (key, priority) in best]
end

function update_solutions!(
    solutions::SolutionSet,
    element::Solution,
    problem::Problem,
    index::Int
)
    add!(solutions, element, index)
    prune!(solutions, index, problem.max_solutions)
end

end
