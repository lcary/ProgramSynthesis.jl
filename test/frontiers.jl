using Test
using JSON
using DataStructures

using DreamCore
using DreamCore.Frontiers: add!, prune!
using DreamCore.Likelihood: AllOrNothingLikelihoodModel

function get_test_task()
    filename = abspath(@__DIR__, "resources", "example_request_task_1.json")
    data = JSON.parsefile(filename)
    return ProgramTask(data)
end

@testset "frontiers.jl" begin
    @testset "test FrontierElement" begin
        ptype = ProgramType("?", ProgramType[], -1)
        program = Program("(+ 1)", "(+ 1)", ptype)
        frontier = FrontierElement(program, 1.0, 1.0, 0.0)

        expect = Dict(
            "program" => "(+ 1)",
            "time" => 0.0,
            "logLikelihood" => 1.0,
            "logPrior" => 1.0
        )

        @test frontier.program == program
        @test priority(frontier) == 2.0
        @test json_format(frontier) == expect
    end
    @testset "test Frontier" begin
        frontier = Frontier(1)
        @test length(frontier.lookup) == 0
        @test length(frontier.solutions) == 1
        solutions1 = frontier.solutions[1]
        @test length(solutions1) == 0

        ptype = ProgramType("?", ProgramType[], -1)
        program = Program("(+ 1)", "(+ 1)", ptype)
        frontier1 = FrontierElement(program, 1.0, 1.0, 0.0)
        frontier2 = FrontierElement(program, 0.1, 0.1, 0.0)
        frontier3 = FrontierElement(program, 0.11, 0.11, 0.0)

        key1 = add!(frontier, frontier1, 1)
        key2 = add!(frontier, frontier2, 1)
        key3 = add!(frontier, frontier3, 1)

        @test key1 == "1"
        @test key2 == "2"
        @test key3 == "3"
        @test length(frontier.lookup) == 3
        @test length(frontier.solutions) == 1
        @test length(solutions1) == 3

        prune!(frontier, 1, 2)

        @test length(frontier.lookup) == 2
        @test length(frontier.solutions) == 1
        @test length(solutions1) == 2

        frontier4 = FrontierElement(program, 0.2, 0.2, 0.0)
        key4 = add!(frontier, frontier4, 1)
        prune!(frontier, 1, 2)

        @test key4 == "4"
        @test length(frontier.lookup) == 2
        @test length(frontier.solutions) == 1
        @test length(solutions1) == 2

        # All that should be left are the keys for frontiers 1 and 4
        # since they had the highest priority.
        res1 = dequeue!(solutions1)
        res2 = dequeue!(solutions1)
        @test res1 == key4
        @test res2 == key1
    end
    @testset "test is_explored" begin
        frontier = Frontier(2)
        enqueue!(frontier.solutions[1], "x1", 1)
        enqueue!(frontier.solutions[2], "y1", 1)
        enqueue!(frontier.solutions[2], "y2", 2)
        max_solutions = [2, 2]
        @test !is_explored(frontier, max_solutions)
        enqueue!(frontier.solutions[1], "x2", 2)
        @test is_explored(frontier, max_solutions)
    end
    @testset "test update_frontier!" begin
        tasks = [get_test_task()]
        frontier = Frontier(length(tasks))
        model = AllOrNothingLikelihoodModel(1.0)
        prior = 0.0
        program = Program("(+ 1)")
        update_frontier!(frontier, prior, program, tasks, model)
        key = "1"

        @test length(frontier.lookup) == 1
        @test haskey(frontier.lookup, key)
        @test isa(frontier.lookup[key], FrontierElement)

        element = frontier.lookup[key]
        @test element.program == program
        @test length(frontier.solutions) == 1
        @test haskey(frontier.solutions[1], key)
        @test frontier.solutions[1][key] == priority(element)
    end
end
