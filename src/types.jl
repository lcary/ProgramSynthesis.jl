module Types

using ..Utils

export TypeConstructor,
       TypeVariable,
       ProgramType,
       Context, apply,
       function_arguments,
       tint, tlist, t0, t1, t2,
       treal, tbool, tchar, tstr,
       arrow

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
    return TypeConstructor(ARROW, [args[1], arrow(args[2])])
end

function hashed(t::TypeConstructor)::UInt64
    h = UInt64(0)
    h += hash(t.constructor)
    for a in t.arguments
        h += hashed(a)
    end
    return h
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
    substitution::Array{Tuple}
end

Context() = Context(0, [])

function apply(type::TypeConstructor, context::Context)
    return type
end

function apply(type::TypeVariable, context::Context)
    for (v, t) in context.substitution
        if v == type.value
            return apply(t, context)
        end
    end
    return type
end

function Base.show(io::IO, context::Context)
    n = context.next_variable
    pairs = [(a, apply(b, context)) for (a, b) in context.substitution]
    substr = ["$a ||> $b" for (a, b) in pairs]
    s = join(substr, ", ")
    print(io, "Context(next=$n, {$s})")
end

function instantiate(t::TypeConstructor, c::Context)
    throw(TypeError)
end

end
