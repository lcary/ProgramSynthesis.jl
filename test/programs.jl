using Test
using JSON

using DreamCore
using DreamCore.Programs: evaluate,
                          DeBruijnIndex,
                          try_solve,
                          Abstraction,
                          Application
using DreamCore.Problems: Problem
using DreamCore.Primitives: base_primitives
using DreamCore.Types: arrow, t0, t1, tlist

fakeparse(x) = true  # TODO: test with actual program functions!

@testset "programs.jl" begin
    @testset "fakeparse program strings" begin
        @test fakeparse("(+ 1)")
        @test fakeparse("(\$0 \$1)")
        @test fakeparse("(+ 1 \$0 \$2)")
        @test fakeparse("(map (+ 1) \$0 \$1)")
        @test fakeparse("(map (+ 1) (\$0 (+ 1) (- 1) (+ -)) \$1)")
        @test fakeparse("(lambda \$0)")
        @test fakeparse("(lambda (+ 1 #(* 8 1)))")
        @test fakeparse("(lambda (+ 1 #(* 8 map)))")
    end
    @testset "parse primitive programs" begin
        p = Program("map", base_primitives())
        @test isequal(p.type, arrow(arrow(t0, t1), tlist(t0), tlist(t1)))
        @test p.source == "map"
        f = (x) -> (x + x)
        mapf = p.expression(f)
        @test mapf([1, 2]) == [2, 4]
    end
    @testset "evaluate primitive programs" begin
        primitives = base_primitives()

        p1 = Program("+", primitives)
        f1 = evaluate(p1, [])
        @test f1(3)(4) == 7
        @test f1(-123)(555) == 432

        p2 = Program("length", primitives)
        f2 = evaluate(p2, [])
        @test f2([1,2,3]) == 3
        @test f2([]) == 0
    end
    @testset "try_solve length problem with length" begin
        primitives = base_primitives()

        len = Program("length", primitives)
        program  = Abstraction(Application(len, DeBruijnIndex(0)))

        data = Dict(
            "name" => "length-test",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "int", "arguments" => [])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict("inputs" => [[1,3]], "output" => 2),
                Dict("inputs" => [[5,5,0,6,2]], "output" => 5),
                Dict("inputs" => [[2,5,0,5,0]], "output" => 5),
                Dict("inputs" => [[4,4,5,4,4]], "output" => 5),
                Dict("inputs" => [[4,4,5,4]], "output" => 4),
                Dict("inputs" => [[4,4,5]], "output" => 3),
                Dict("inputs" => [[]], "output" => 0),
                Dict("inputs" => [[4]], "output" => 1)
            ]
        )
        problem = Problem(data)
        success, log_likelihood = try_solve(program, problem)
        @test success
        @test log_likelihood == 0.0
    end
    @testset "try_solve non-length problem with length" begin
        primitives = base_primitives()

        len = Program("length", primitives)
        program  = Abstraction(Application(len, DeBruijnIndex(0)))

        data = Dict(
            "name" => "non-length-test",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict("inputs" => [[1,3]], "output" => [1,3]),
                Dict("inputs" => [[1,3]], "output" => [2])
            ]
        )
        problem = Problem(data)
        success, log_likelihood = try_solve(program, problem)
        @test !success
        @test log_likelihood == -Inf
    end
    @testset "try_solve 0 problem with 0" begin
        primitives = base_primitives()

        program = Abstraction(Program("0", primitives))

        data = Dict(
            "name" => "0-test",
            "request" => Dict(
                "constructor" => "int",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "int", "arguments" => [])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict("inputs" => [[3,6,4,2]], "output" => 0),
                Dict("inputs" => [1], "output" => 0),
                Dict("inputs" => [[1,3]], "output" => 0),
                Dict("inputs" => [[1]], "output" => 0)
            ]
        )
        problem = Problem(data)
        success, log_likelihood = try_solve(program, problem)
        @test success
        @test log_likelihood == 0.0
    end
end
