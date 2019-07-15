module Types

using ..Utils

export TypeConstructor, ProgramType, Context, function_arguments

abstract type ProgramType end

# TODO:: rename to TypeConstructor, and add TypeVariable
mutable struct TypeConstructor <: ProgramType
    constructor::String
    arguments::Array{TypeConstructor,1}
    index::Union{Int, Nothing}
    function TypeConstructor(constructor, arguments, index)
        return new(constructor, map(TypeConstructor, arguments), index)
    end
end

TypeConstructor(c::String) = TypeConstructor(c, [], nothing)

function TypeConstructor(data::Dict{String,Any})
    return TypeConstructor(
        data["constructor"],
        data["arguments"],
        getoptional(data, "index"),
    )
end

const ARROW = "->"

is_arrow(t::TypeConstructor)::Bool = t.constructor == ARROW

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

Base.show(io::IO, t::TypeConstructor) = print(io, tostr(t))

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
