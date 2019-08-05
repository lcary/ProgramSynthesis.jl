using Test
using JSON
using DataStructures

using ProgramSynthesis
using ProgramSynthesis.Solutions: add!, prune!

function get_test_problem()
    filename = abspath(@__DIR__, "resources", "example_request_task_1.json")
    data = JSON.parsefile(filename)
    return Problem(data)
end

@testset "solutions.jl" begin
    @testset "test Solution" begin
        ptype = TypeField("?", TypeField[], -1)
        program = Program("(+ 1)", (x) -> (x + 1), ptype)
        solution = Solution(program, 1.0, 1.0, 0.0)

        expect = Dict(
            "program" => "(+ 1)",
            "time" => 0.0,
            "logLikelihood" => 1.0,
            "logPrior" => 1.0
        )

        @test solution.program == program
        @test priority(solution) == 2.0
        @test ProgramSynthesis.Solutions.json_format(solution) == expect
    end
    @testset "test SolutionSet" begin
        solutions = SolutionSet(1)
        @test length(solutions.lookup) == 0
        @test length(solutions.best_solutions) == 1
        best1 = solutions.best_solutions[1]
        @test length(best1) == 0

        ptype = TypeField("?", TypeField[], -1)
        program = Program("(+ 1)", (x) -> (x + 1), ptype)
        solution1 = Solution(program, 1.0, 1.0, 0.0)
        solution2 = Solution(program, 0.1, 0.1, 0.0)
        solution3 = Solution(program, 0.11, 0.11, 0.0)

        key1 = add!(solutions, solution1, 1)
        key2 = add!(solutions, solution2, 1)
        key3 = add!(solutions, solution3, 1)

        @test key1 == "1"
        @test key2 == "2"
        @test key3 == "3"
        @test length(solutions.lookup) == 3
        @test length(solutions.best_solutions) == 1
        @test length(best1) == 3

        prune!(solutions, 1, 2)

        @test length(solutions.lookup) == 2
        @test length(solutions.best_solutions) == 1
        @test length(best1) == 2

        solution4 = Solution(program, 0.2, 0.2, 0.0)
        key4 = add!(solutions, solution4, 1)
        prune!(solutions, 1, 2)

        @test key4 == "4"
        @test length(solutions.lookup) == 2
        @test length(solutions.best_solutions) == 1
        @test length(best1) == 2

        # All that should be left are the keys for solutions 1 and 4
        # since they had the highest priority values.
        res1 = dequeue!(best1)
        res2 = dequeue!(best1)
        @test res1 == key4
        @test res2 == key1
    end
    @testset "test is_explored" begin
        solutions = SolutionSet(2)
        enqueue!(solutions.best_solutions[1], "x1", 1)
        enqueue!(solutions.best_solutions[2], "y1", 1)
        enqueue!(solutions.best_solutions[2], "y2", 2)
        max_solutions = [2, 2]
        @test !is_explored(solutions, max_solutions)
        enqueue!(solutions.best_solutions[1], "x2", 2)
        @test is_explored(solutions, max_solutions)
    end
    @testset "test update_solutions!" begin
        problems = [get_test_problem()]
        solutions = SolutionSet(length(problems))
        prior = 0.0
        ptype = TypeField("?", TypeField[], -1)
        program = Program("(+ 1)", (x) -> (x + 1), ptype)

        for (index, problem) in enumerate(problems)
            element = Solution(program, 0.0, prior, 0.0)
            update_solutions!(solutions, element, problem, index)
        end

        key = "1"

        @test length(solutions.lookup) == 1
        @test haskey(solutions.lookup, key)
        @test isa(solutions.lookup[key], Solution)

        element = solutions.lookup[key]
        @test element.program == program
        @test length(solutions.best_solutions) == 1
        @test haskey(solutions.best_solutions[1], key)
        @test solutions.best_solutions[1][key] == priority(element)
    end
end
