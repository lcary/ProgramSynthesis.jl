using Test
using JSON

using DreamCore
using DreamCore.Enumeration: Request
using DreamCore.Generation: generator, Result

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE2 = get_resource("request_enumeration_example_2.json")

@testset "enumeration.jl" begin
    @testset "run program generation file2 good bounds" begin
        data = JSON.parsefile(TEST_FILE2)
        grammar = Grammar(data["DSL"])
        problems = map(Problem, data["tasks"])
        type = problems[1].type
        r = generator(grammar, [], type, 3.0, 1.5, 99)
        r1 = take!(r)
        println(r1)
        @test isa(r1, Result)
        @test r1.program.source == "0"
        @test r1.prior == 1.0
        @test r1.context.next_variable == 0
        @test r1.context.substitution == []
    end
    @testset "run program generation file2 bad bounds" begin
        data = JSON.parsefile(TEST_FILE2)
        grammar = Grammar(data["DSL"])
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
