using Test
using JSON
using DataStructures

using DreamCore
using DreamCore.Frontiers: add!, prune!
using DreamCore.Likelihood: AllOrNothingLikelihoodModel

function get_test_task()
    filename = abspath(@__DIR__, "resources", "example_request_task_1.json")
    data = JSON.parsefile(filename)
    return ProblemSet(data)
end

@testset "frontiers.jl" begin
    @testset "test Frontier" begin
        ptype = ProgramType("?", ProgramType[], -1)
        program = Program("(+ 1)", "(+ 1)", ptype)
        frontier = Frontier(program, 1.0, 1.0, 0.0)

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
    @testset "test FrontierCache" begin
        cache = FrontierCache(1)
        @test length(cache.lookup) == 0
        @test length(cache.hits) == 1
        hits1 = cache.hits[1]
        @test length(hits1) == 0

        ptype = ProgramType("?", ProgramType[], -1)
        program = Program("(+ 1)", "(+ 1)", ptype)
        frontier1 = Frontier(program, 1.0, 1.0, 0.0)
        frontier2 = Frontier(program, 0.1, 0.1, 0.0)
        frontier3 = Frontier(program, 0.11, 0.11, 0.0)

        key1 = add!(cache, frontier1, 1)
        key2 = add!(cache, frontier2, 1)
        key3 = add!(cache, frontier3, 1)

        @test key1 == "1"
        @test key2 == "2"
        @test key3 == "3"
        @test length(cache.lookup) == 3
        @test length(cache.hits) == 1
        @test length(hits1) == 3

        prune!(cache, 1, 2)

        @test length(cache.lookup) == 2
        @test length(cache.hits) == 1
        @test length(hits1) == 2

        frontier4 = Frontier(program, 0.2, 0.2, 0.0)
        key4 = add!(cache, frontier4, 1)
        prune!(cache, 1, 2)

        @test key4 == "4"
        @test length(cache.lookup) == 2
        @test length(cache.hits) == 1
        @test length(hits1) == 2

        # All that should be left are the keys for frontiers 1 and 4
        # since they had the highest priority.
        res1 = dequeue!(hits1)
        res2 = dequeue!(hits1)
        @test res1 == key4
        @test res2 == key1
    end
    @testset "test is_explored" begin
        cache = FrontierCache(2)
        enqueue!(cache.hits[1], "x1", 1)
        enqueue!(cache.hits[2], "y1", 1)
        enqueue!(cache.hits[2], "y2", 2)
        max_frontiers = [2, 2]
        @test !is_explored(cache, max_frontiers)
        enqueue!(cache.hits[1], "x2", 2)
        @test is_explored(cache, max_frontiers)
    end
    @testset "test update_frontiers!" begin
        tasks = [get_test_task()]
        cache = FrontierCache(length(tasks))
        model = AllOrNothingLikelihoodModel(1.0)
        prior = 0.0
        program = Program("(+ 1)")
        update_frontiers!(cache, prior, program, tasks, model)
        key = "1"

        @test length(cache.lookup) == 1
        @test haskey(cache.lookup, key)
        @test isa(cache.lookup[key], Frontier)

        frontier = cache.lookup[key]
        @test frontier.program == program
        @test length(cache.hits) == 1
        @test haskey(cache.hits[1], key)
        @test cache.hits[1][key] == priority(frontier)
    end
end
