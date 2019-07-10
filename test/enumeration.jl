using Test
using JSON

using DreamCore

const TEST_FILE = abspath(
    @__DIR__,
    "resources",
    "request_enumeration_example.json"
)

@testset "enumeration.jl" begin
    @testset "parse request data" begin
        json_data = JSON.parsefile(TEST_FILE)
        enum_data = EnumerationData(json_data)

        @test length(enum_data.grammar.library) == 22
        @test length(enum_data.tasks) == 7
        @test enum_data.tasks[1].name == "drop-k with k=3"
        @test length(enum_data.tasks[1].examples) == 15
        @test length(enum_data.tasks[1].examples[1].inputs) == 1
        @test length(enum_data.tasks[1].examples[1].output) == 7
        @test enum_data.program_timeout == 0.0005
        @test enum_data.max_parameters == 99
        @test enum_data.lower_bound == 0.0
        @test enum_data.upper_bound == 1.5
        @test enum_data.budget_increment == 1.5
    end
end
