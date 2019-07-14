using Test
using JSON

using DreamCore
using DreamCore.Enumeration: Request
using DreamCore.Generation: generator

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE2 = get_resource("request_enumeration_example_2.json")

@testset "enumeration.jl" begin
    @testset "run program generation file2" begin
        data = JSON.parsefile(TEST_FILE2)
        grammar = Grammar(data["DSL"])
        problems = map(Problem, data["tasks"])
        type = problems[1].type
        r = generator(grammar, [], type, 6.0, 4.5, 99)
        r1 = take!(r)
        println(r1)
        @test true  # TODO: add actual tests
    end
end
