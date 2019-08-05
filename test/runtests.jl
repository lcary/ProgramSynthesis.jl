#!/usr/bin/env julia

using ProgramSynthesis
using Test

@testset "ProgramSynthesis" begin
    include("enumeration.jl")
    include("programs.jl")
    include("parsers.jl")
    include("types.jl")
    include("solutions.jl")
    include("generation.jl")
    include("utils.jl")
end
