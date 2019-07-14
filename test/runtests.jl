#!/usr/bin/env julia

using DreamCore
using Test

@testset "DreamCore" begin
    include("enumeration.jl")
    include("programs.jl")
    include("solutions.jl")
    include("generation.jl")
end
