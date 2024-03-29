module Types

using ..Utils

export TypeField,
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
       UNIFICATION_FAILURE,
       extend

const ARROW = "->"

# TODO: all caps enums
@enum TYPE constructor=1 variable=2

struct TypeField
    constructor::String
    arguments::Array{TypeField,1}
    index::Int
    is_polymorphic::Bool
    type::TYPE
    value::Int
end

function split_arguments(a::Array{TypeField,1})::Array{TypeField,1}
    if length(a) >= 3
        arr = Array{TypeField,1}(undef, 2)
        arr[1] = a[1]
        arr[2] = a[2:end]
        return arr
    else
        return a
    end
end

function TypeField(c, args, index)
    is_polymorphic = any(i.is_polymorphic for i in args)
    return TypeField(c, args, index, is_polymorphic, constructor, -1)
end

function TypeField(c::String, a::Array{TypeField,1})
    args = split_arguments(a)
    return TypeField(c, args, -1)
end

function TypeField(c::String, a::Tuple{TypeField,TypeField})
    subarr = Array{TypeField,1}(undef, 1)
    subarr[1] = a[2]
    arr = Array{TypeField,1}(undef, 2)
    arr[1] = a[1]
    arr[2] = subarr
    return TypeField(c, arr, -1)
end

TypeField(c::String) = TypeField(c, Array{TypeField,1}())

function TypeField(data::Dict{String,Any})
    return TypeField(
        data["constructor"],
        [TypeField(a) for a in data["arguments"]],
        getoptional(data, "index", -1),
    )
end

function TypeField(val::Int)
    args = Array{TypeField,1}()
    return TypeField("", args, -1, true, variable, val)
end

const tint = TypeField("int")
const treal = TypeField("real")
const tbool = TypeField("bool")
const tchar = TypeField("char")
tlist(t::TypeField) = return TypeField("list", [t])
const tstr = tlist(tchar)
const t0 = TypeField(0)
const t1 = TypeField(1)
const t2 = TypeField(2)
const t3 = TypeField(3)

is_arrow(t::TypeField)::Bool = t.type == constructor && t.constructor == ARROW

arrow(arg::TypeField) = arg

function arrow(args...)::TypeField
    if length(args) == 0
        return nothing
    elseif length(args) == 1
        return args[1]
    elseif length(args) == 2
        arr = Array{TypeField,1}(undef, 2)
        arr[1] = args[1]
        arr[2] = args[2]
        return TypeField(ARROW, arr)
    end
    arr = Array{TypeField,1}(undef, 2)
    arr[1] = args[1]
    arr[2] = arrow(args[2:end]...)
    return TypeField(ARROW, arr)
end

function Base.hash(t::TypeField, h::UInt)::UInt
    if t.type == constructor
        return constructor_hash(t, h)
    end
    return variable_hash(t, h)
end

function constructor_hash(t::TypeField, h::UInt)::UInt
    args = t.arguments
    if length(args) == 0
        return hash(t.constructor, h)
    elseif length(args) == 1
        return hash(t.constructor, hash(args[1], h))
    elseif length(args) == 2
        return hash(t.constructor, hash(args[1], hash(args[2], h)))
    end
end

variable_hash(t::TypeField, h::UInt)::UInt = hash(t.value, h)

function Base.isequal(t1::TypeField, t2::TypeField)
    return Base.isequal(hash(t1), hash(t2))
end

function tostr(t::TypeField)::String
    if t.type == constructor
        return constructor_tostr(t)
    end
    return variable_tostr(t)
end

function constructor_tostr(t::TypeField)
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

variable_tostr(t::TypeField) = "t$(t.value)"

Base.show(io::IO, t::TypeField) = print(io, tostr(t))

function Base.show(io::IO, a::Array{TypeField,1})
    t = join([tostr(i) for i in a], ", ")
    print(io, "[$t]")
end

function function_arguments(t::TypeField)::Array{TypeField,1}
    if is_arrow(t)
        args = Array{TypeField,1}()
        arg1 = t.arguments[1]
        arg2 = function_arguments(t.arguments[2])
        push!(args, arg1)
        append!(args, arg2)
        return args
    end
    return Array{TypeField,1}()
end

struct Context
    next_variable::Int
    substitution::Array{Tuple{Int,TypeField},1}
end

Context() = Context(0, Array{Tuple{Int,TypeField},1}())

function apply(t::TypeField, context::Context)::TypeField
    if t.type == constructor
        return constructor_apply(t, context)
    end
    return variable_apply(t, context)
end

function variable_apply(type::TypeField, context::Context)
    for (v, t) in context.substitution
        if v == type.value
            return apply(t, context)
        end
    end
    return type
end

function constructor_apply(type::TypeField, context::Context)
    if !type.is_polymorphic
        return type
    end
    args = Array{TypeField,1}(undef, length(type.arguments))
    for (index, a) in enumerate(type.arguments)
        args[index] = apply(a, context)
    end
    return TypeField(type.constructor, args)
end

function Base.show(io::IO, context::Context)
    n = context.next_variable
    pairs = [(a, apply(b, context)) for (a, b) in context.substitution]
    substr = ["t$a ||> $b" for (a, b) in pairs]
    s = join(substr, ", ")
    print(io, "Context(next=$n, {$s})")
end

function variable_instantiate(
        type::TypeField, context::Context,
        bindings::Dict{String,TypeField})::Tuple{Context,TypeField}
    key = string(type.value)
    if haskey(bindings, key)
        return context, bindings[key]
    end
    new_type = TypeField(context.next_variable)
    bindings[key] = new_type
    new_context = Context(context.next_variable + 1, context.substitution)
    return new_context, new_type
end

function constructor_instantiate(
        type::TypeField, context::Context,
        bindings::Dict{String,TypeField})::Tuple{Context,TypeField}
    if !type.is_polymorphic
        return context, type
    end
    args = Array{TypeField,1}(undef, length(type.arguments))
    for (index, a) in enumerate(type.arguments)
        if a.type == constructor
            context, t = constructor_instantiate(a, context, bindings)
        else
            context, t = variable_instantiate(a, context, bindings)
        end
        args[index] = t
    end
    return context, TypeField(type.constructor, args)
end

function instantiate(
        t::TypeField, context::Context)::Tuple{Context,TypeField}
    args = (t, context, Dict{String,TypeField}())
    if t.type == constructor
        return constructor_instantiate(args...)
    end
    return variable_instantiate(args...)
end

function returns(t::TypeField)::TypeField
    if t.type == constructor
        return is_arrow(t) ? returns(t.arguments[2]) : t
    end
    return t
end

function occurs(t::TypeField, v::Int)::Bool
    if t.type == variable
        return t.value == v
    end
    if !t.is_polymorphic
        return false
    end
    return any(occurs(a, v) for a in t.arguments)
end

const UNIFICATION_FAILURE = -Inf

function extend(context::Context, j::Int, t::TypeField)
    len = length(context.substitution) + 1
    arr = Array{Tuple{Int,TypeField},1}(undef, len)
    arr[1] = (j, t)
    arr[2:end] = context.substitution
    return Context(context.next_variable, arr)
end

function unify(
        context::Context, t1::TypeField,
        t2::TypeField)::Union{Float64, Context}
    t1 = apply(t1, context)
    t2 = apply(t2, context)
    if isequal(t1, t2)
        return context
    end
    if !t1.is_polymorphic && !t2.is_polymorphic
        return UNIFICATION_FAILURE
    end
    # TODO: add unit test for occurs
    if t1.type == variable
        if occurs(t2, t1.value)
            return UNIFICATION_FAILURE
        end
        return extend(context, t1.value, t2)
    end
    # TODO: add unit test for occurs
    if t2.type == variable
        if occurs(t1, t2.value)
            return UNIFICATION_FAILURE
        end
        return extend(context, t2.value, t1)
    end
    if t1.constructor != t2.constructor
        return UNIFICATION_FAILURE
    end
    k = context
    for (x, y) in zip(t2.arguments, t1.arguments)
        k = unify(k, x, y)
    end
    return k
end

end
