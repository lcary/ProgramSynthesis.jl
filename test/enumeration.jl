using Test
using JSON

using DreamCore
using DreamCore.Enumeration: Request

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE1 = get_resource("request_enumeration_example_1.json")
const TEST_FILE2 = get_resource("request_enumeration_example_2.json")
const TEST_FILE3 = get_resource("request_enumeration_example_3.json")
const TEST_FILE4 = get_resource("request_enumeration_example_4.json")
const TEST_FILE5 = get_resource("request_enumeration_example_5.json")
const TEST_FILE6 = get_resource("request_enumeration_example_6.json")
const TEST_FILE7 = get_resource("request_enumeration_example_7.json")

@testset "enumeration.jl" begin
    @testset "parse list-to-list enumeration request data" begin
        json_data = JSON.parsefile(TEST_FILE1)
        enum_data = Request(json_data)

        @test length(enum_data.grammar.productions) == 22
        @test length(enum_data.problems) == 7
        @test enum_data.problems[1].name == "drop-k with k=3"
        @test length(enum_data.problems[1].examples) == 15
        @test length(enum_data.problems[1].examples[1].inputs) == 1
        @test length(enum_data.problems[1].examples[1].output) == 7
        @test enum_data.program_timeout == 0.0005
        @test enum_data.max_parameters == 99
        @test enum_data.lower_bound == 0.0
        @test enum_data.upper_bound == 1.5
        @test enum_data.budget_increment == 1.5
    end
    @testset "parse list-to-int enumeration request data" begin
        json_data = JSON.parsefile(TEST_FILE2)
        enum_data = Request(json_data)

        @test length(enum_data.grammar.productions) == 22
        @test length(enum_data.problems) == 2
        @test enum_data.problems[1].name == "kth-largest with k=1"
        @test length(enum_data.problems[1].examples) == 15
        @test length(enum_data.problems[1].examples[1].inputs) == 1
        @test enum_data.problems[1].examples[1].output == 15
        @test enum_data.program_timeout == 0.0005
        @test enum_data.max_parameters == 99
        @test enum_data.lower_bound == 0.0
        @test enum_data.upper_bound == 1.5
        @test enum_data.budget_increment == 1.5
    end
    @testset "parse list-to-bool enumeration request data" begin
        json_data = JSON.parsefile(TEST_FILE4)
        enum_data = Request(json_data)

        @test length(enum_data.grammar.productions) == 22
        @test length(enum_data.problems) == 1
        @test enum_data.problems[1].name == "has-k with k=2"
        @test length(enum_data.problems[1].examples) == 15
        @test length(enum_data.problems[1].examples[1].inputs) == 1
        @test enum_data.problems[1].examples[1].output == true
        @test enum_data.program_timeout == 0.0005
        @test enum_data.max_parameters == 99
        @test enum_data.lower_bound == 0.0
        @test enum_data.upper_bound == 1.5
        @test enum_data.budget_increment == 1.5
    end
    @testset "run_enumeration file5" begin
        json_data = JSON.parsefile(TEST_FILE5)
        result = run_enumeration(json_data)

        @test length(result) == 7
        @test haskey(result, "drop-k with k=3")
        @test haskey(result, "modulo-k with k=3")
        @test haskey(result, "prepend-k with k=0")
        @test haskey(result, "keep-mod-head")
        @test haskey(result, "keep gt 0")
        @test haskey(result, "slice-k-n with k=1 and n=2")
        @test haskey(result, "remove gt 1")
        @test isa(result["remove gt 1"], Array)
    end
    @testset "run_enumeration test length (file6)" begin
        json_data = JSON.parsefile(TEST_FILE6)
        result = run_enumeration(json_data)

        @test length(result) == 1
        @test haskey(result, "length-test")

        @test isa(result["length-test"], Array)

        # TODO: get length working and uncomment!

        # @test length(result["length-test"]) >= 1
        #
        # programs = result["length-test"][1]
        # @test haskey(programs, "program")
        # @test haskey(programs, "time")
        # @test haskey(programs, "logLikelihood")
        # @test haskey(programs, "logPrior")
    end
    @testset "run_enumeration test 0 (file7)" begin
        json_data = JSON.parsefile(TEST_FILE7)
        result = run_enumeration(json_data)

        @test length(result) == 1
        @test haskey(result, "0-test")
        @test isa(result["0-test"], Array)
        @test length(result["0-test"]) == 1

        program1 = result["0-test"][1]
        @test haskey(program1, "program")
        @test haskey(program1, "time")
        @test haskey(program1, "logLikelihood")
        @test haskey(program1, "logPrior")

        @test program1["program"] == "(lambda 0)"
        @test program1["logLikelihood"] == 0.0
        @test round(program1["logPrior"], digits=4) == -2.3979
    end
end
