module Types

using ..Utils

export ProgramType, function_arguments

mutable struct ProgramType
    constructor::String
    arguments::Array{ProgramType,1}
    index::Union{Int, Nothing}
    function ProgramType(constructor, arguments, index)
        return new(constructor, map(ProgramType, arguments), index)
    end
end

function ProgramType(data::Dict{String,Any})
    return ProgramType(
        data["constructor"],
        data["arguments"],
        getoptional(data, "index"),
    )
end

const ARROW = "->"

is_arrow(t::ProgramType)::Bool = t.constructor == ARROW

function hashed(t::ProgramType)::UInt64
    h = UInt64(0)
    h += hash(t.constructor)
    for a in t.arguments
        h += hashed(a)
    end
    return h
end

function tostr(t::ProgramType)
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

Base.show(io::IO, t::ProgramType) = print(io, tostr(t))

function function_arguments(t::ProgramType)::Array{ProgramType}
    if is_arrow(t)
        arg1 = t.arguments[1]
        args = function_arguments(t.arguments[2])
        return append!([arg1], args)
    end
    return []
end

end
