using Test
using JSON

using DreamCore
using DreamCore.Primitives: base_primitives
using DreamCore.Enumeration: Request
using DreamCore.Generation: generator, Result

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE2 = get_resource("request_enumeration_example_2.json")
const log_probability = -2.3978952727983707

@testset "generation.jl" begin
    @testset "run program generation file2 good bounds" begin
        data = JSON.parsefile(TEST_FILE2)
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
end