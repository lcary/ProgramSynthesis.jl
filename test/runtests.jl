#!/usr/bin/env julia

using DreamCore
using Test

@testset "DreamCore" begin
    include("enumeration.jl")
    include("programs.jl")
    include("frontiers.jl")
end
