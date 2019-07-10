using Test
using JSON

using DreamCore

parse(x) = true  # TODO: test with actual program functions!

@testset "program.jl" begin
    @testset "parse program strings" begin
        @test parse("(+ 1)")
        @test parse("(\$0 \$1)")
        @test parse("(+ 1 \$0 \$2)")
        @test parse("(map (+ 1) \$0 \$1)")
        @test parse("(map (+ 1) (\$0 (+ 1) (- 1) (+ -)) \$1)")
        @test parse("(lambda \$0)")
        @test parse("(lambda (+ 1 #(* 8 1)))")
        @test parse("(lambda (+ 1 #(* 8 map)))")
    end
end
