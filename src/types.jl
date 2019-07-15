module Types

using ..Utils

export TypeConstructor,
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
end

function TypeConstructor(c::String, a::Array{ProgramType,1})
    if length(a) >= 3
        args = [a[1], a[2:end]]
    else
        args = a
    end
    return TypeConstructor(c, args, nothing)
end

function TypeConstructor(c::String, a::Array{TypeConstructor,1})
    if length(a) >= 3
        args = [a[1], a[2:end]]
    else
        args = a
    end
    return TypeConstructor(c, args, nothing)
end

function TypeConstructor(c::String, a::Tuple{TypeConstructor,TypeConstructor})
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

function TypeConstructor(c::String, a::Array{TypeVariable,1})
    if length(a) >= 3
        args = [a[1], a[2:end]]
    else
        args = a
    end
    return TypeConstructor(c, args, nothing)
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

function Base.show(io::IO, a::Array{TypeConstructor})
    t = join([tostr(i) for i in a], ", ")
    print(io, "[$t]")
end

function function_arguments(t::TypeConstructor)::Array{TypeConstructor}
    if is_arrow(t)
        arg1 = t.arguments[1]
        args = function_arguments(t.arguments[2])
        return append!([arg1], args)
    end
    return []
end

struct Context
    next_variable::Int
    substitution::Array{Tuple}
end

Context() = Context(0, [])

function apply(type::TypeConstructor, context::Context)
    # TODO: implement for TypeVariables too
    return type
end

function Base.show(io::IO, context::Context)
    n = context.next_variable
    pairs = [(a, apply(b, context)) for (a, b) in context.substitution]
    substr = ["$a ||> $b" for (a, b) in pairs]
    s = join(substr, ", ")
    print(io, "Context(next=$n, {$s})")
end

end
