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
        t1 = TypeConstructor(d1)

        d2 = Dict(
            "constructor" => "->", "arguments" => [
                Dict("constructor" => "list(t0)", "arguments" => []),
                Dict("constructor" => "int", "arguments" => [])
            ]
        )
        t2 = TypeConstructor(d2)

        d3 = Dict("constructor" => "int", "arguments" => [])
        t3 = TypeConstructor(d3)

        t1_args = function_arguments(t1)
        @test length(t1_args) == 2
        @test t1_args[1].constructor == "int"
        @test t1_args[2].constructor == "list(int)"
        t2_args = function_arguments(t2)
        @test length(t2_args) == 1
        @test t2_args[1].constructor == "list(t0)"
        @test function_arguments(t3) == []
    end
end
