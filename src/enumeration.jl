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
    max_depth::Int
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
        getoptional(data, "maxParameters", 99),
        getoptional(data, "maxDepth", 99)
    )
end

struct Context
end

struct Result
    prior::Float64
    program::AbstractProgram
    context::Context
end

abstract type Frame end

struct EnumerateFrame <: Frame
    context::Context
    env::Any  # TODO: use specific type
    type::ProgramType
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
end

struct EnumerateAppFrame <: Frame
    context::Context
    env::Any  # TODO: use specific type
    func::Any  # TODO: use specific type
    argument_requests::Array{ProgramType}
    upper_bound::Float64
    lower_bound::Float64
    depth::Int
    original_function::Any # TODO: use specific type
    argument_index::Int
end

struct Candidate
    log_probability::Float64
    type::ProgramType
    program::Program
    context::Context
end

function build_candidates(grammar::Grammar, frame::Frame)::Array{Candidate}
    type, context, env = frame.type, frame.context, frame.env
    candidates = Array{Candidate}([])
    return candidates
end

function valid(c::Candidate, upper_bound::Float64)::Bool
    return -c.log_probability < upper_bound
end

function all_invalid(candidates::Array{Candidate}, upper_bound::Float64)::Bool
    for c in candidates
        if !valid(c, upperBound)
            return true
        end
    end
    return false
end

function convert_arrow_frame(f::EnumerateFrame)::EnumerateFrame
    lhs = f.type.arguments[1]
    rhs = f.type.arguments[2]
    env = append!([lhs], f.env)
    upper = f.upper_bound
    lower = f.lower_bound
    return EnumerateFrame(f.context, env, rhs, upper, lower, f.depth)
end

function shadow_enumeration(
    grammar::Grammar,
    frame::EnumerateFrame
)
    results = Array{Result}([])

    # do a depth-first search of the queue
    queue = Stack{Frame}()
    push!(queue, frame)

    while !isempty(queue)
        f = pop!(queue)

        if f.upper_bound < 0.0 || f.depth <= 1
            continue
        end

        if isa(f, EnumerateFrame)
            println(f.context, " ", f.env, " ", f.type)
            if Types.is_arrow(f.type)
                push!(queue, convert_arrow_frame(f))
            else
                candidates = build_candidates(grammar, f)
                if all_invalid(candidates, f.upper_bound)
                    continue
                end
                for c in candidates
                    if valid(c, f.upper_bound)
                        print("TODO")
                    end
                end
            end
        else
            println(f.context, " ", f.env, " ", f.argument_requests)
        end

        # if f.enumerate_application
        #
        # else
    end
    push!(results, Result(1.0, grammar.library[1].program, Context()))
    return results
end

function shadow_generate_results(
    request::Request,
    env::Array{Any},  # TODO: improve type
    type::ProgramType,
    upper_bound::Float64,
    lower_bound::Float64
)
    frame = EnumerateFrame(
        Context(),
        env,
        type,
        upper_bound,
        lower_bound,
        request.max_depth
    )
    return shadow_enumeration(request.grammar, frame)
end

# TODO: replace with shadow_enumeration eventually
function enumeration(
    channel::Channel,
    grammar::Grammar,
    context::Context,
    env::Array{Any},  # TODO: improve type
    type::ProgramType,
    upper_bound::Float64,
    lower_bound::Float64,
    depth::Int
)
    if upper_bound < 0 || depth == 1
        return
    end
    for p in grammar.library
        put!(channel, Result(0.0, p.program, context))
    end
end

# TODO: replace with shadow_generate_results eventually
function generate_results(
    request::Request,
    env::Array{Any},  # TODO: improve type
    type::ProgramType
)
    grammar = request.grammar
    context = Context()
    upper = request.upper_bound
    lower = request.lower_bound
    depth = request.max_depth
    args = (grammar, context, env, type, upper, lower, depth)
    return Channel((channel) -> enumeration(channel, args...))
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
    result::Result,
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

struct TypeMismatchError <: Exception
    msg::String
end

function run_enumeration(request::Request)::Dict{String,Any}
    problems = request.problems
    previous_budget = request.lower_bound
    budget = request.lower_bound + request.budget_increment
    max_solutions = [p.max_solutions for p in problems]
    solutions = SolutionSet(length(problems))

    if !Utils.allequal([Types.hashed(p.type) for p in problems])
        throw(TypeMismatchError("Types differ in problem set."))
    end
    type = problems[1].type

    start = time()
    while (
        time() < start + request.program_timeout
        && !is_explored(solutions, max_solutions)
        && budget <= request.upper_bound
    )
        for result in generate_results(request, [], type)
            for (index, problem) in enumerate(problems)
                # TODO: run with program timeout
                solve!(solutions, result, problem, index, start)
            end
        end
        args = (request, [], type, budget, previous_budget)
        for result in shadow_generate_results(args...)
            println("shadow_generate_results:")
            println(result)
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
