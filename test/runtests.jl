#!/usr/bin/env julia

using DreamCore
using Test

@testset "DreamCore" begin
    include("enumeration.jl")
    include("programs.jl")
    include("types.jl")
    include("solutions.jl")
    include("generation.jl")
end
