module Utils

export getoptional, lse, curry, allequal

function getoptional(
    data::Dict{String,Any},
    key::String,
    default::Any=nothing,
)
    try
        return data[key]
    catch e
        if typeof(e) <: KeyError
            return default
        else
            rethrow(e)
        end
    end
end

allequal(x) = all(y -> isequal(y, x[1]), x)

curry(f, x) = (xs...) -> f(x, xs...)

function lse(x::Array{Float64})::Float64
    if length(x) == 1
        return x[1]
    end
    m = maximum(x)
    return m + log(sum(exp(n - m) for n in x))
end

end
