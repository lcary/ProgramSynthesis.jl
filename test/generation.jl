using Test
using JSON

using DreamCore
using DreamCore.Primitives: base_primitives
using DreamCore.Enumeration: Request
using DreamCore.Generation: generator,
                            Result,
                            Candidate,
                            ProgramState,
                            InvalidStateException,
                            update_log_probability,
                            final_candidates,
                            get_candidate,
                            get_variable_candidate,
                            update_log_probability
using DreamCore.Types: tlist, tint, t0, t1, UnificationFailure
using DreamCore.Utils: lse

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE2 = get_resource("request_enumeration_example_2.json")

@testset "generation.jl" begin
    @testset "run program generation file2 bounds1" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = 0.0
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
        env = Array{TypeField}([])
        r = generator(grammar, env, type, 3.0, 1.5, 99)
        r1 = take!(r)
        @test isa(r1, Result)
    end
    @testset "run program generation file2 bounds2" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = 0.0
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
        env = Array{TypeField}([])
        r = generator(grammar, env, type, 6.0, 4.5, 99)
        r1 = take!(r)
        @test isa(r1, Result)
    end
    @testset "test get_candidate 1" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = 0.0
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
            99
        )
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.name == "1"
        result = get_candidate(state, grammar.productions[1])
        @test result.program.name == "1"
    end
    @testset "test get_candidate map" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = 0.0
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "map",
                "logProbability" => log_probability
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        state = ProgramState(
            Context(2, [(1, tint)]),
            [tlist(tint)],
            tlist(t0),
            3.0,
            0.0,
            2
        )
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.name == "map"
        result = get_candidate(state, grammar.productions[1])
        @test result.program.name == "map"
    end
    @testset "test get_candidate error1" begin
        data = JSON.parsefile(TEST_FILE2)
        log_probability = 0.0
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
            99
        )
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.name == "map"
        r = get_candidate(state, grammar.productions[1])
        @test r == UnificationFailure
    end
    @testset "test get_candidate contexts" begin
        data = JSON.parsefile(TEST_FILE2)
        state = ProgramState(
            Context(),
            [tlist(tint)],
            tlist(tint),
            3.0,
            1.5,
            99
        )

        primitives = base_primitives()
        getproduction(e) = Dict("expression" => e, "logProbability" => 0.0)

        function getgrammar!(data, func)
            data["DSL"]["productions"] = [getproduction(func)]
            return Grammar(data["DSL"], primitives)
        end

        g = getgrammar!(data, "map")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 2
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 1
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "unfold")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 2
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 1
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "range")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 0
        @test length(c.context.substitution) == 0

        g = getgrammar!(data, "index")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "fold")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 2
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 1
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "if")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "empty")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "cons")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "car")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "cdr")
        c = get_candidate(state, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tint)
    end
    @testset "test get_variable_candidate" begin
        state = ProgramState(
            Context(),
            [tlist(tint)],
            tlist(tint),
            3.0,
            1.5,
            99
        )
        t = tlist(tint)
        vc = get_variable_candidate(state, t, 0)

        @test isequal(vc.type, tlist(tint))
        @test vc.index.i == 0
        @test vc.context.next_variable == 0
        @test isempty(vc.context.substitution)

        ll = log(length([vc]))
        @test ll == 0.0
    end
    @testset "test update_log_probability" begin
        data = JSON.parsefile(TEST_FILE2)
        z = 2.3978952727983707
        data["DSL"]["productions"] = [
            Dict(
                "expression" => "map",
                "logProbability" => 0.0
            )
        ]
        grammar = Grammar(data["DSL"], base_primitives())
        type = tlist(t0)
        program = grammar.productions[1].program
        c = Candidate(0.0, type, program, Context(2, [(1, tint)]))
        new_c = update_log_probability(z, c)
        @test round(new_c.log_probability, digits=4) == -2.3979
    end
    @testset "test build_candidates line-by-line" begin
        data = JSON.parsefile(TEST_FILE2)
        funcs = [
            "map", "unfold", "range", "index", "fold",
            "if", "empty", "cons", "car", "cdr"]
        getproduction(f) = Dict("expression" => f, "logProbability" => 0.0)
        data["DSL"]["productions"] = map(getproduction, funcs)
        grammar = Grammar(data["DSL"], base_primitives())
        state = ProgramState(
            Context(),
            [tlist(tint)],
            tlist(tint),
            3.0,
            1.5,
            99
        )
        candidates = Array{Candidate}([])
        for p in grammar.productions
            c = get_candidate(state, p)
            @test c.log_probability == 0.0
            push!(candidates, c)
        end

        @test length(candidates) == 10

        t = state.env[1]
        @test isequal(t, tlist(tint))
        vc = get_variable_candidate(state, t, 0)
        vl = grammar.log_variable - log(length([vc]))
        @test vl == 0.0
        push!(candidates, Candidate(vc, vl))

        @test length(candidates) == 11

        vals = [c.log_probability for c in candidates]
        @test vals == [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

        z = lse(vals)
        @test round(z, digits=4) == 2.3979

        for c in candidates
            new_c = update_log_probability(z, c)
            @test round(new_c.log_probability, digits=4) == -2.3979
        end
    end
    @testset "test final_candidates" begin
        data = JSON.parsefile(TEST_FILE2)
        l = 0.0
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

        c1 = Candidate(l, type, p1, Context(2, [(1, tint)]))
        c2 = Candidate(l, type, p2, Context(2, [(1, tint)]))
        c3 = Candidate(l, type, p3, Context(2, [(1, tint)]))
        push!(candidates, c1)
        push!(candidates, c2)
        push!(candidates, c3)

        results = final_candidates(candidates)
        @test length(results) == 3
        @test round(results[1].log_probability, digits=4) == -1.0986
        @test round(results[2].log_probability, digits=4) == -1.0986
        @test round(results[3].log_probability, digits=4) == -1.0986
    end
    @testset "test final_candidates batch" begin
        data = JSON.parsefile(TEST_FILE2)
        l = 0.0
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
            c1 = Candidate(l + x[c], type, p1, Context(2, [(1, tint)]))
            c2 = Candidate(l + x[c + 1], type, p2, Context(2, [(1, tint)]))
            c3 = Candidate(l + x[c + 2], type, p3, Context(2, [(1, tint)]))
            push!(candidates, c1)
            push!(candidates, c2)
            push!(candidates, c3)
            c += 3
        end

        results = final_candidates(candidates)
        @test length(results) == 999
    end
end
