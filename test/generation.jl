using Test
using JSON

using DreamCore
using DreamCore.Primitives: base_primitives
using DreamCore.Enumeration: Request
using DreamCore.Generation: generator,
                            Result,
                            build_candidate,
                            StateMetadata,
                            ProgramState
using DreamCore.Types: tlist, tint

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE2 = get_resource("request_enumeration_example_2.json")

@testset "generation.jl" begin
    @testset "run program generation file2 good bounds" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = -2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "index",
                "logProbability" => log_probability
            ),
            Dict(
                "expression" => "length",
                "logProbability" => log_probability
            ),
            Dict(
                "expression" => "0",
                "logProbability" => log_probability
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        problems = map(Problem, data["tasks"])
        type = problems[1].type
        r = generator(grammar, [], type, 3.0, 1.5, 99)
        r1 = take!(r)
        @test isa(r1, Result)
        @test r1.program.body.source == "0"
        @test r1.prior == 1.0
        @test r1.context.next_variable == 0
        @test r1.context.substitution == []
    end
    @testset "run program generation file2 bad bounds" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = -2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "index",
                "logProbability" => log_probability
            ),
            Dict(
                "expression" => "length",
                "logProbability" => log_probability
            ),
            Dict(
                "expression" => "0",
                "logProbability" => log_probability
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        problems = map(Problem, data["tasks"])
        type = problems[1].type
        r = generator(grammar, [], type, 6.0, 4.5, 99)
        threw_error = false
        try
            take!(r)
        catch
            threw_error = true
        end
        @test threw_error
    end
    @testset "test build_candidate" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = -2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "1",
                "logProbability" => log_probability
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        state = ProgramState(
            Context(),
            [tlist(tint)],
            tint,
            3.0,
            1.5,
            99,
            nothing,
            StateMetadata()
        )
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.source == "1"
        throws_error = false
        try
            build_candidate(grammar.productions[1], state)
        catch
            throws_error = true
        end
        @test !throws_error
    end
    @testset "test build_candidate error" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = -2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "map",
                "logProbability" => log_probability
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        state = ProgramState(
            Context(),
            [tlist(tint)],
            tint,
            3.0,
            1.5,
            99,
            nothing,
            StateMetadata()
        )
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.source == "map"
        throws_error = false
        try
            build_candidate(grammar.productions[1], state)
        catch
            throws_error = true
        end
        @test throws_error
    end
end
