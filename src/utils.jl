module Utils

export getoptional

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

end
