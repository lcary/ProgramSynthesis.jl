module Programs

using ..Types
using ..Problems

export Program,
       ProgramType,
       evaluates,
       can_solve,
       try_solve,
       Primitive,
       Abstraction,
       Application,
       DeBruijnIndex,
       Invented,
       PROGRAMTYPE,
       PROGRAM,
       PRIMITIVE,
       ABSTRACTION,
       APPLICATION,
       INDEX,
       INVENTED,
       json_format,
       evaluate,
       str,
       getname

@enum PROGRAMTYPE begin
    PROGRAM = 0
    PRIMITIVE = 1
    ABSTRACTION = 2
    APPLICATION = 3
    INDEX = 4
    INVENTED = 5
end

struct Program
    name::String
    type::Union{TypeField,Nothing}
    func::Any
    args::Union{Program,Nothing}
    i::Int
    ptype::PROGRAMTYPE
end

# TODO: reorder args to be (name, type, func)
function Program(name::String, func, type::TypeField)::Program
    return Program(name, type, func, nothing, -1, PROGRAM)
end

function Primitive(name::String, type::TypeField, func)::Program
    return Program(name, type, func, nothing, -1, PRIMITIVE)
end

# TODO: docstring
function Abstraction(body::Program)::Program
    return Program("", nothing, body, nothing, -1, ABSTRACTION)
end

# TODO: docstring
function Application(func::Program, args::Program)::Program
    return Program("", nothing, func, args, -1, APPLICATION)
end

# TODO: docstring
function DeBruijnIndex(i::Int)::Program
    return Program("", nothing, nothing, nothing, i, INDEX)
end

# TODO: add type inference ( # type::TypeField )
function Invented(body::Program)::Program
    return Program("", nothing, body, nothing, -1, INVENTED)
end

function str(p::Program, isfunc::Bool=false)::String
    t = p.ptype
    if t == ABSTRACTION
        return abstraction_str(p, isfunc)
    elseif t == APPLICATION
        return application_str(p, isfunc)
    elseif t == INVENTED
        return invented_str(p, isfunc)
    elseif t == INDEX
        return index_str(p, isfunc)
    else
        return p.name
    end
end

index_str(p::Program, isfunc::Bool=false)::String = "\$$(p.i)"
invented_str(p::Program, isfunc::Bool=false)::String = "#$(str(p.func))"

function application_str(p::Program, isfunc::Bool=false)::String
    t1 = str(p.func, true)
    t2 = str(p.args, false)
    return isfunc ? "$t1 $t2" : "($t1 $t2)"
end

function abstraction_str(p::Program, isfunc::Bool=false)::String
    return "(lambda $(str(p.func)))"
end

Base.show(io::IO, p::Program) = print(io, str(p))

json_format(p::Program)::String = str(p)

function getname(p::Program)::String
    t = p.ptype
    if t == ABSTRACTION
        return getname(p.func)
    elseif t == APPLICATION
        return getname(p.func)
    # TODO: what about invented?
    # elseif t == INVENTED
    #     return invented_str(p)
    elseif t == INDEX
        return string(p.i)  # TODO: check if correct
    else
        return p.name
    end
end

function evaluate(p::Program, env)
    t = p.ptype
    if t == ABSTRACTION
        return evaluate_abstraction(p, env)
    elseif t == APPLICATION
        return evaluate_application(p, env)
    elseif t == INVENTED
        return evaluate_invented(p, env)
    elseif t == INDEX
        return evaluate_index(p, env)
    else
        return p.func
    end
end

function evaluate_abstraction(program::Program, env)
    f(x) = evaluate(program.func, joinenv(x, env))
    return f
end

function evaluate_application(p::Program, env)
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

evaluate_index(p::Program, env) = env[p.i + 1]
evaluate_invented(p::Program, env) = p.func.evaluate([])

function joinenv(t, env)
    return append!([t], env)
end

# TODO: add unit test
function is_conditional(p::Program)
    return (isa(p.func, Program)
            && p.func.ptype == APPLICATION
            && isa(p.func.func, Program)
            && p.func.func.ptype == APPLICATION
            && isa(p.func.func.func, Program)
            && p.func.func.func.ptype == PRIMITIVE
            && p.func.func.func.name == "if")
end

false_branch(p::Program) = p.args
true_branch(p::Program) = p.func.args
branch(p::Program) = p.func.func.args

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

function can_solve(program::Program, problem::Problem)::Bool
    env = Array{TypeField,1}()
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

function try_solve(program::Program, problem::Problem)::Tuple{Bool,Float64}
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
