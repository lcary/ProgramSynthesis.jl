using Test
using JSON

using DreamCore
using DreamCore.Primitives: base_primitives
using DreamCore.Enumeration: Request
using DreamCore.Generation: generator,
                            Result,
                            Candidate,
                            StateMetadata,
                            ProgramState,
                            InvalidStateException,
                            update_log_probability,
                            final_candidates
using DreamCore.Types: tlist, tint, t0, t1, UnificationFailure

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
        catch e
            if typeof(e) <: InvalidStateException
                threw_error = true
            else
                rethrow(e)
            end
        end
        @test threw_error
    end
    @testset "test build_candidate 1" begin
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
        result = Candidate(state, grammar.productions[1])
        @test result.program.source == "1"
    end
    @testset "test build_candidate map" begin
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
            Context(2, [(t1, tint)]),
            [tlist(tint)],
            tlist(t0),
            3.0,
            0.0,
            2,
            nothing,
            StateMetadata()
        )
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.source == "map"
        result = Candidate(state, grammar.productions[1])
        @test result.program.source == "map"
    end
    @testset "test build_candidate error1" begin
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
            Candidate(state, grammar.productions[1])
        catch e
            if typeof(e) <: UnificationFailure
                throws_error = true
            else
                rethrow(e)
            end
        end
        @test throws_error
    end
    @testset "test update_log_probability" begin
        data = JSON.parsefile(TEST_FILE2)
        z = 0.0909090909090909
        l = -2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "map",
                "logProbability" => l
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        type = tlist(t0)
        program = grammar.productions[1].program
        c = Candidate(l, type, program, Context(2, [(t1, tint)]))
        new_c = update_log_probability(z, c)
        @test round(new_c.log_probability, digits=3) == 0.0830
    end
    @testset "test final_candidates" begin
        data = JSON.parsefile(TEST_FILE2)
        l = -2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "index",
                "logProbability" => l
            ),
            Dict(
                "expression" => "length",
                "logProbability" => l
            ),
            Dict(
                "expression" => "0",
                "logProbability" => l
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        type = tlist(t0)
        p1 = grammar.productions[1].program
        p2 = grammar.productions[2].program
        p3 = grammar.productions[3].program
        candidates = Array{Candidate}([])

        c1 = Candidate(l, type, p1, Context(2, [(t1, tint)]))
        c2 = Candidate(l, type, p2, Context(2, [(t1, tint)]))
        c3 = Candidate(l, type, p3, Context(2, [(t1, tint)]))
        push!(candidates, c1)
        push!(candidates, c2)
        push!(candidates, c3)

        results = final_candidates(candidates)
        @test length(results) == 3
        @test round(results[1].log_probability, digits=3) == 0.333
        @test round(results[2].log_probability, digits=3) == 0.333
        @test round(results[3].log_probability, digits=3) == 0.333
    end
    @testset "test final_candidates batch" begin
        data = JSON.parsefile(TEST_FILE2)
        l = -2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "index",
                "logProbability" => l
            ),
            Dict(
                "expression" => "length",
                "logProbability" => l
            ),
            Dict(
                "expression" => "0",
                "logProbability" => l
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        type = tlist(t0)
        p1 = grammar.productions[1].program
        p2 = grammar.productions[2].program
        p3 = grammar.productions[3].program
        candidates = Array{Candidate}([])

        c = 1
        x = rand(1000)
        while c <= 999
            c1 = Candidate(l + x[c], type, p1, Context(2, [(t1, tint)]))
            c2 = Candidate(l + x[c + 1], type, p2, Context(2, [(t1, tint)]))
            c3 = Candidate(l + x[c + 2], type, p3, Context(2, [(t1, tint)]))
            push!(candidates, c1)
            push!(candidates, c2)
            push!(candidates, c3)
            c += 3
        end

        results = final_candidates(candidates)
        @test length(results) == 999
    end
end
