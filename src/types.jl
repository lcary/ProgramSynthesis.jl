module Types

using ..Utils

export TypeConstructor,
       TypeVariable,
       ProgramType,
       Context,
       apply,
       function_arguments,
       tint,
       tlist,
       t0,
       t1,
       t2,
       treal,
       tbool,
       tchar,
       tstr,
       arrow,
       instantiate,
       returns,
       unify,
       UnificationFailure,
       extend

const ARROW = "->"

abstract type ProgramType end

mutable struct TypeConstructor <: ProgramType
    constructor::String
    arguments::Array{ProgramType,1}  # TODO: Fix
    index::Union{Int, Nothing}
    is_polymorphic::Bool
end

function split_arguments(a::Array{<:ProgramType,1})::Array{<:ProgramType}
    if length(a) >= 3
        return [a[1], a[2:end]]
    else
        return a
    end
end

function TypeConstructor(c, args, index)
    is_polymorphic = any([i.is_polymorphic for i in args])
    return TypeConstructor(c, args, index, is_polymorphic)
end

function TypeConstructor(c::String, a::Array{<:ProgramType,1})
    args = split_arguments(a)
    return TypeConstructor(c, args, nothing)
end

function TypeConstructor(c::String, a::Tuple{N,N} where N<:ProgramType)
    return TypeConstructor(c, [a[1], [a[2]]], nothing)
end

TypeConstructor(c::String) = TypeConstructor(c, Array{TypeConstructor,1}([]))

function TypeConstructor(data::Dict{String,Any})
    return TypeConstructor(
        data["constructor"],
        [TypeConstructor(a) for a in data["arguments"]],
        getoptional(data, "index"),
    )
end

mutable struct TypeVariable <: ProgramType
    value::Int
    is_polymorphic::Bool
    function TypeVariable(value)
        if !isa(value, Int)
            throw(TypeError)
        end
        return new(value, true)
    end
end

const tint = TypeConstructor("int")
const treal = TypeConstructor("real")
const tbool = TypeConstructor("bool")
const tchar = TypeConstructor("char")
tlist(t::ProgramType) = return TypeConstructor("list", [t])
const tstr = tlist(tchar)
const t0 = TypeVariable(0)
const t1 = TypeVariable(1)
const t2 = TypeVariable(2)
const t3 = TypeVariable(3)

is_arrow(t::TypeConstructor)::Bool = t.constructor == ARROW
is_arrow(t::TypeVariable)::Bool = false

arrow(arg::ProgramType) = arg

function arrow(args...)::Any
    if length(args) == 0
        return nothing
    elseif length(args) == 1
        return args[1]
    elseif length(args) == 2
        return TypeConstructor(ARROW, [args[1], args[2]])
    end
    return TypeConstructor(ARROW, [args[1], arrow(args[2:end]...)])
end

function Base.hash(t::TypeConstructor, h::UInt)::UInt
    args = t.arguments
    if length(args) == 0
        return hash(t.constructor, h)
    elseif length(args) == 1
        return hash(t.constructor, hash(args[1], h))
    elseif length(args) == 2
        return hash(t.constructor, hash(args[1], hash(args[2], h)))
    end
end

Base.hash(t::TypeVariable, h::UInt)::UInt = hash(t.value, h)

function Base.isequal(a::ProgramType, b::ProgramType)
    return Base.isequal(hash(a), hash(b))
end

function tostr(t::TypeConstructor)
    if is_arrow(t)
        a1 = tostr(t.arguments[1])
        a2 = tostr(t.arguments[2])
        return "$a1 $ARROW $a2"
    elseif isempty(t.arguments)
        return t.constructor
    else
        cons = t.constructor
        args = join([tostr(x) for x in t.arguments], ", ")
        return "$cons($args)"
    end
end

tostr(t::TypeVariable) = "t$(t.value)"

Base.show(io::IO, t::ProgramType) = print(io, tostr(t))

function Base.show(io::IO, a::Array{<:ProgramType})
    t = join([tostr(i) for i in a], ", ")
    print(io, "[$t]")
end

function function_arguments(t::ProgramType)::Array{ProgramType}
    if is_arrow(t)
        args = Array{Union{TypeConstructor,TypeVariable}}([])  # TODO: better UnionAll syntax?
        arg1 = t.arguments[1]
        arg2 = function_arguments(t.arguments[2])
        push!(args, arg1)
        append!(args, arg2)
        return args
    end
    return []
end

struct Context
    next_variable::Int
    substitution::Array{Tuple{Int,ProgramType}}
end

Context() = Context(0, [])

function apply(type::TypeVariable, context::Context)
    for (v, t) in context.substitution
        if v == type.value
            return apply(t, context)
        end
    end
    return type
end

function apply(type::TypeConstructor, context::Context)
    if !type.is_polymorphic
        return type
    end
    args = [apply(x, context) for x in type.arguments]
    return TypeConstructor(type.constructor, args)
end

function Base.show(io::IO, context::Context)
    n = context.next_variable
    pairs = [(a, apply(b, context)) for (a, b) in context.substitution]
    substr = ["t$a ||> $b" for (a, b) in pairs]
    s = join(substr, ", ")
    print(io, "Context(next=$n, {$s})")
end

function instantiate(
    type::TypeVariable,
    context::Context,
    bindings::Dict{String,TypeVariable}
)
    key = string(type)
    if haskey(bindings, key)
        return (context, bindings[key])
    end
    new_type = TypeVariable(context.next_variable)
    bindings[key] = new_type
    new_context = Context(context.next_variable + 1, context.substitution)
    return new_context, new_type
end

function instantiate(
    type::TypeConstructor,
    context::Context,
    bindings::Dict{String,TypeVariable}
)
    if !type.is_polymorphic
        return context, type
    end
    new_args = Array{Union{TypeConstructor,TypeVariable}}([])
    for a in type.arguments
        context, new_type = instantiate(a, context, bindings)
        push!(new_args, new_type)
    end
    return context, TypeConstructor(type.constructor, new_args)
end

function instantiate(type::TypeConstructor, context::Context)
    return instantiate(type, context, Dict{String,TypeVariable}())
end

returns(t::TypeVariable) = t
returns(t::TypeConstructor) = is_arrow(t) ? returns(t.arguments[2]) : t

struct UnificationFailure <: Exception
    msg
end

struct Occurs <: Exception end  # TODO: docstring

occurs(t::TypeVariable, v::Int) = t.value == v

function occurs(t::TypeConstructor, v::Int)
    if !t.is_polymorphic
        return false
    end
    return any([occurs(a, v) for a in t.arguments])
end

function extend(context::Context, j::Int, t::ProgramType)
    T1 = Union{TypeVariable,TypeConstructor,Int}
    T2 = Union{TypeVariable,TypeConstructor}
    l = Array{Tuple{T1,T2}}([])  # TODO: fix type
    a1 = push!(l, (j, t))
    sub = append!(a1, context.substitution)
    return Context(context.next_variable, sub)
end

function unify(context::Context, t1::ProgramType, t2::ProgramType)
    t1 = apply(t1, context)
    t2 = apply(t2, context)
    if isequal(t1, t2)
        return context
    end
    if !t1.is_polymorphic && !t2.is_polymorphic
        msg = string("Types are not equal: ", t1, " != ", t2)
        throw(UnificationFailure(msg))
    end
    # TODO: use multiple dispatch instead
    if isa(t1, TypeVariable)
        if occurs(t2, t1.value)
            throw(Occurs)
        end
        return extend(context, t1.value, t2)
    end
    # TODO: use multiple dispatch instead
    if isa(t2, TypeVariable)
        if occurs(t1, t2.value)
            throw(Occurs)
        end
        return extend(context, t2.value, t1)
    end
    if t1.constructor != t2.constructor
        msg = string("Types are not equal: ", t1, " != ", t2)
        throw(UnificationFailure(msg))
    end
    k = context
    for (x, y) in zip(t2.arguments, t1.arguments)
        k = unify(k, x, y)
    end
    return k
end

end
