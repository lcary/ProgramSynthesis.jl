module Enumeration

using Dates
using JSON

using ..Types
using ..Grammars
using ..Programs
using ..Problems
using ..Utils
using ..Solutions

export run_enumeration

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
    problems::Array{Problem}
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
        map(Problem, data["tasks"]),
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

function json_format(data::Request, solutions::SolutionSet)::Dict{String,Any}
    response = Dict()
    for (index, problem) in enumerate(data.problems)
        response[problem.name] = Solutions.json_format(solutions, index)
    end
    return response
end

function solved(log_likelihood::Float64)::Bool
    return !isinf(log_likelihood) && !isnan(log_likelihood)
end

function solve!(
    solutions::SolutionSet,
    result::EnumerationResult,
    problem::Problem,
    index::Int,
    start::Float64
)
    prior = result.prior
    program = result.program
    log_likelihood = try_solve(program, problem)
    search_time = time() - start
    if solved(log_likelihood)
        solution = Solution(program, log_likelihood, prior, search_time)
        update_solutions!(solutions, solution, problem, index)
    end
end

function run_enumeration(data::Request)::Dict{String,Any}
    budget = data.lower_bound + data.budget_increment
    max_solutions = [t.max_solutions for t in data.problems]

    solutions = SolutionSet(length(data.problems))

    start = time()
    while (
        time() < start + data.program_timeout
        && !is_explored(solutions, max_solutions)
        && budget <= data.upper_bound
    )
        for result in enumeration(data)
            for (index, problem) in enumerate(data.problems)
                # TODO: run with program timeout
                solve!(solutions, result, problem, index, start)
            end
        end
    end

    return json_format(data, solutions)
end

function run_enumeration(request::Dict{String,Any})::Dict{String,Any}
    return run_enumeration(Request(request))
end

function run_enumeration(filename::String)::String
    create_message_dir()
    request = JSON.parsefile(filename)
    response = run_enumeration(request)
    return write_response(response)
end

end
