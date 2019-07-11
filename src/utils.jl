module Utils

export getoptional

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

end
