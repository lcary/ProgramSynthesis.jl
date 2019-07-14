using Test
using JSON

using DreamCore
using DreamCore.Types: function_arguments

@testset "types.jl" begin
    @testset "test function_arguments" begin
        d1 = Dict(
            "constructor" => "->", "arguments" => [
                Dict("constructor" => "int", "arguments" => []),
                Dict(
                    "constructor" => "->", "arguments" => [
                        Dict("constructor" => "list(int)", "arguments" => []),
                        Dict("constructor" => "int", "arguments" => [])
                    ]
                )
            ]
        )
        t1 = ProgramType(d1)

        d2 = Dict(
            "constructor" => "->", "arguments" => [
                Dict("constructor" => "list(t0)", "arguments" => []),
                Dict("constructor" => "int", "arguments" => [])
            ]
        )
        t2 = ProgramType(d2)

        d3 = Dict("constructor" => "int", "arguments" => [])
        t3 = ProgramType(d3)

        # TODO: fix and uncomment below
        # @test function_arguments(t1) == []
        # @test function_arguments(t2) == []
        @test function_arguments(t3) == []
    end
end
