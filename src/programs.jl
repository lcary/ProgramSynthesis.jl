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
       Invented,
       json_format,
       evaluate,
       str

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

# TODO: add type inference
mutable struct Invented <: AbstractProgram
    body::AbstractProgram
    # type::AbstractType
end

str(p::Primitive, isfunc::Bool=false)::String = p.name
str(p::Program, isfunc::Bool=false)::String = p.source
str(p::DeBruijnIndex, isfunc::Bool=false)::String = "\$$(p.i)"
str(p::Invented, isfunc::Bool=false)::String = "#$(str(p.body))"
function str(p::Application, isfunc::Bool=false)::String
    t1 = str(p.func, true)
    t2 = str(p.args, false)
    return isfunc ? "$t1 $t2" : "($t1 $t2)"
end
str(p::Abstraction, isfunc::Bool=false)::String = "(lambda $(str(p.body)))"

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

# TODO: add unit test
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
evaluate(p::Invented, env) = p.body.evaluate([])

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
