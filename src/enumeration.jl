module Enumeration

using Dates
using JSON
using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Problems
using ..Utils
using ..Solutions
using ..Primitives
using ..Generation

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
    indent = 2
    filename = response_filename()
    open(filename, "w") do f
        JSON.print(f, data, indent)
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
    max_depth::Int
end

function Request(data::Dict{String,Any})
    primitives = base_primitives()
    return Request(
        map(Problem, data["tasks"]),
        Grammar(data["DSL"], primitives),
        data["programTimeout"],
        data["verbose"],
        data["lowerBound"],
        data["upperBound"],
        data["budgetIncrement"],
        getoptional(data, "maxParameters", 99),
        getoptional(data, "maxDepth", 99)
    )
end

function json_format(data::Request, solutions::SolutionSet)::Dict{String,Any}
    response = Dict()
    for (index, problem) in enumerate(data.problems)
        response[problem.name] = Solutions.json_format(solutions, index)
    end
    return response
end

function solve!(
    solutions::SolutionSet,
    result::Result,
    problem::Problem,
    index::Int,
    start::Float64
)
    prior = result.prior
    program = result.program
    success, log_likelihood = try_solve(program, problem)
    search_time = time() - start
    if success
        solution = Solution(program, log_likelihood, prior, search_time)
        update_solutions!(solutions, solution, problem, index)
    end
end

struct TypeMismatchError <: Exception
    msg::String
end

function hit_timeout(start::Float64, timeout::Float64)::Bool
    return time() - start > timeout
end

function run_enumeration(request::Request)::Dict{String,Any}
    problems = request.problems
    previous_budget = request.lower_bound
    budget = request.lower_bound + request.budget_increment
    max_solutions = [p.max_solutions for p in problems]
    solutions = SolutionSet(length(problems))

    if !Utils.allequal([p.type for p in problems])
        throw(TypeMismatchError("Types differ in problem set."))
    end
    type = problems[1].type

    start = time()

    while (
        !is_explored(solutions, max_solutions)
        && budget <= request.upper_bound
    )
        env = Array{AbstractType}([])
        args = (
            request.grammar, env, type, budget,
            previous_budget, request.max_depth
        )
        timeout_exceeded = false
        for result in generator(args...)
            for (index, problem) in enumerate(problems)
                # TODO: run with program timeout
                solve!(solutions, result, problem, index, start)
            end
            if hit_timeout(start, request.program_timeout)
                timeout_exceeded = true
                break
            end
        end
        if timeout_exceeded || hit_timeout(start, request.program_timeout)
            break
        end
        previous_budget = budget
        budget += request.budget_increment
    end
    return json_format(request, solutions)
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
