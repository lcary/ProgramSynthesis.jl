using Test
using JSON

using DreamCore

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE1 = get_resource("request_enumeration_example_1.json")
const TEST_FILE2 = get_resource("request_enumeration_example_2.json")

@testset "enumeration.jl" begin
    @testset "parse list-to-list enumeration request data" begin
        json_data = JSON.parsefile(TEST_FILE1)
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
    @testset "parse list-to-int enumeration request data" begin
        json_data = JSON.parsefile(TEST_FILE2)
        enum_data = EnumerationData(json_data)

        @test length(enum_data.grammar.library) == 22
        @test length(enum_data.tasks) == 2
        @test enum_data.tasks[1].name == "kth-largest with k=1"
        @test length(enum_data.tasks[1].examples) == 15
        @test length(enum_data.tasks[1].examples[1].inputs) == 1
        @test enum_data.tasks[1].examples[1].output == 15
        @test enum_data.program_timeout == 0.0005
        @test enum_data.max_parameters == 99
        @test enum_data.lower_bound == 0.0
        @test enum_data.upper_bound == 1.5
        @test enum_data.budget_increment == 1.5
    end
end
