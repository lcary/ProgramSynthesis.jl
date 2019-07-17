module Programs

using ..Types
using ..Problems

export Program,
       evaluates,
       can_solve,
       try_solve,
       AbstractProgram,
       Abstraction,
       Application,
       AbstractProgram,
       Primitive,
       DeBruijnIndex,
       json_format,
       evaluate

abstract type AbstractProgram end

struct Primitive <: AbstractProgram
    name::String
    type::AbstractType
    func
end

mutable struct Program <: AbstractProgram
    source::String
    expression
    type::AbstractType
end

# TODO: implement type inference logic
function infertype(prog::Any)::AbstractType
    return TypeConstructor("?", [], -1)
end

struct ParseFailure <: Exception
    msg::String
end

# TODO: Support invented, abstraction, application, index, and fragment programs
function parse(s::String, primitives::Dict{String,Primitive})
    if haskey(primitives, s)
        return primitives[s]
    end
    throw(ParseFailure("Unable to parse Program from string ($s)."))
end

# TODO: Maybe don't convert primitives to programs? May help with comparisons.
function Program(name::String, primitives::Dict{String,Primitive})
    expression = parse(name, primitives)
    return Program(
        name,
        expression.func,
        expression.type
    )
end

# TODO: docstring
mutable struct Abstraction <: AbstractProgram
    body::AbstractProgram
end

# TODO: docstring
mutable struct Application <: AbstractProgram
    func::AbstractProgram
    args::AbstractProgram
end

mutable struct DeBruijnIndex <: AbstractProgram
    i::Int
end

str(p::Primitive)::String = p.name
str(p::Program)::String = p.source
str(p::DeBruijnIndex)::String = "\$$(p.i)"
str(p::Abstraction)::String = "(lambda $(string(p.body)))"
str(p::Application)::String = "($(string(p.func)) $(string(p.args)))"

Base.show(io::IO, p::AbstractProgram) = print(io, str(p))

json_format(p::AbstractProgram)::String = str(p)

evaluate(program::Program, env) = program.expression

function joinenv(t, env)
    return append!([t], env)
end

function evaluate(program::Abstraction, env)
    f(x) = evaluate(program.body, joinenv(x, env))
    return f
end

function is_conditional(p::Application)
    return (!isa(p.func, Int)
            && isa(p.func, Application)
            && isa(p.func.func, Application)
            && isa(p.func.func.func, Program)
            && p.func.func.func.source == "if")
end

false_branch(p::Application) = p.args
true_branch(p::Application) = p.func.args
branch(p::Application) = p.func.func.args

function evaluate(p::Application, env)
    if is_conditional(p)
        if evaluate(branch(p), env)
            return evaluate(true_branch(p), env)
        else
            return evaluate(false_branch(p), env)
        end
    else
        return evaluate(p.func, env)(evaluate(p.args, env))
    end
end

evaluate(p::DeBruijnIndex, env) = env[p.i + 1]

function predict(f, inputs)
    for a in inputs
        f = f(a)
    end
    return f
end

function can_solve(f::Function, example::Example)::Bool
    try
        prediction = predict(f, example.inputs)
        if prediction != example.output
            return false
        end
    catch
        return false
    end
    return true
end

function can_solve(program::AbstractProgram, problem::Problem)::Bool
    env = Array{AbstractType}([])
    f = evaluate(program, env)
    for example in problem.examples
        if !can_solve(f, example)
            return false
        end
    end
    return true
end

function is_solved(log_likelihood::Float64)::Bool
    return !isinf(log_likelihood) && !isnan(log_likelihood)
end

function solve_result(log_likelihood::Float64)::Tuple{Bool,Float64}
    return is_solved(log_likelihood), log_likelihood
end

function try_solve(
    program::AbstractProgram,
    problem::Problem
)::Tuple{Bool,Float64}
    try
        if can_solve(program, problem)
            return solve_result(0.0)
        end
    catch
        return solve_result(-Inf)
    end
    return solve_result(-Inf)
end

end
