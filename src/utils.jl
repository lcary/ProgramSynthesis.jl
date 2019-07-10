module Utils

export getoptional, allequal

function getoptional(
    data::Dict{String,Any},
    key::String,
    default::Any=nothing,
)
    try
        return data[key]
    catch KeyError
        return default
    end
end

allequal(x) = all(y->y == x[1], x)

end
