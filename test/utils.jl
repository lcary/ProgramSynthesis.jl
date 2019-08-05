using Test

using DreamCore
using DreamCore.Utils

@testset "utils.jl" begin
    @testset "getoptional" begin
        data = Dict{String,Any}("a" => 1, "b" => 2)
        @test getoptional(data, "a") == 1
        @test getoptional(data, "b") == 2
        @test getoptional(data, "c") == nothing
        @test getoptional(data, "c", "foo") == "foo"
    end
    @testset "allsame" begin
        @test !allsame([1, 2, 3, 4, 5, 6])
        @test allsame([1, 1, 1, 1, 1, 1])
        @test !allsame([true, true, false, true, true, true])
        @test allsame([true, true, true, true, true, true])
        @test !allsame(["a", "b", "a", "ca", "a", "a"])
        @test allsame(["a", "a", "a", "a", "a", "a"])
    end
    @testset "lse" begin
        z1 = lse([2.0, -2.3, -2.2, -2.32])
        @test round(z1, digits=4) == 2.0410
        z2 = lse([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        @test round(z2, digits=4) == 2.3979
        z3 = lse([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
        @test round(z3, digits=4) == 2.1972
    end
end
