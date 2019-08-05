using Test
using JSON

using ProgramSynthesis
using ProgramSynthesis.Primitives: base_primitives
using ProgramSynthesis.Enumeration: Request
using ProgramSynthesis.Generation: generator,
                            program_generator,
                            Result,
                            Candidate,
                            InvalidStateException,
                            update_log_probability,
                            finalize_candidates!,
                            get_candidate,
                            get_variable_candidate,
                            update_log_probability,
                            unwind_path,
                            state_violates_symmetry,
                            modify_skeleton,
                            follow_path,
                            application_parse,
                            State,
                            Path,
                            LEFT,
                            RIGHT,
                            get_parent
using ProgramSynthesis.Types: tlist, tint, t0, t1, UNIFICATION_FAILURE
using ProgramSynthesis.Utils: lse, allequal

get_resource(filename) = abspath(@__DIR__, "resources", filename)

const TEST_FILE2 = get_resource("request_enumeration_example_2.json")

@testset "generation.jl" begin
    # TODO: remove when old-style generator is deprecated
    @testset "run program generation file2 bounds1 OLD" begin
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
        @test isa(take!(r), Result)
    end
    # TODO: remove when old-style generator is deprecated
    @testset "run program generation file2 bounds2 OLD" begin
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
        @test isa(take!(r), Result)
    end
    @testset "run program_generator file2 bounds1" begin
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
        r = program_generator(grammar, env, type, 3.0, 1.5, 99)
        @test isa(take!(r), Result)
    end
    @testset "run program_generator file2 bounds2" begin
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
        r = program_generator(grammar, env, type, 6.0, 4.5, 99)
        @test isa(take!(r), Result)
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
        request = tint
        context = Context()
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.name == "1"
        result = get_candidate(request, context, grammar.productions[1])
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
        request = tlist(t0)
        context = Context(2, [(1, tint)])

        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.name == "map"
        result = get_candidate(request, context, grammar.productions[1])
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
        context = Context()
        request = tint
        @test length(grammar.productions) == 1
        @test grammar.productions[1].program.name == "map"
        r = get_candidate(request, context, grammar.productions[1])
        @test r == UNIFICATION_FAILURE
    end
    @testset "test get_candidate contexts" begin
        data = JSON.parsefile(TEST_FILE2)
        request = tlist(tint)
        context = Context()

        primitives = base_primitives()
        getproduction(e) = Dict("expression" => e, "logProbability" => 0.0)

        function getgrammar!(data, func)
            data["DSL"]["productions"] = [getproduction(func)]
            return Grammar(data["DSL"], primitives)
        end

        g = getgrammar!(data, "map")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 2
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 1
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "unfold")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 2
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 1
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "range")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 0
        @test length(c.context.substitution) == 0

        g = getgrammar!(data, "index")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "fold")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 2
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 1
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "if")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "empty")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "cons")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tint)

        g = getgrammar!(data, "car")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tlist(tint))

        g = getgrammar!(data, "cdr")
        c = get_candidate(request, context, g.productions[1])
        @test c.context.next_variable == 1
        @test length(c.context.substitution) == 1
        @test c.context.substitution[1][1] == 0
        @test isequal(c.context.substitution[1][2], tint)
    end
    @testset "test get_variable_candidate" begin
        request = tlist(tint)
        context = Context()

        t = tlist(tint)
        vc = get_variable_candidate(request, context, t, 0)

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
        request = tlist(tint)
        context = Context()

        candidates = Array{Candidate}([])
        for p in grammar.productions
            c = get_candidate(request, context, p)
            @test c.log_probability == 0.0
            push!(candidates, c)
        end

        @test length(candidates) == 10

        t = tlist(tint)
        vc = get_variable_candidate(request, context, t, 0)
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
    @testset "test finalize_candidates" begin
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

        finalize_candidates!(candidates)

        @test round(candidates[1].log_probability, digits=4) == -1.0986
        @test round(candidates[2].log_probability, digits=4) == -1.0986
        @test round(candidates[3].log_probability, digits=4) == -1.0986
    end
    @testset "test finalize_candidates   batch" begin
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

        finalize_candidates!(candidates)
        @test length(candidates) == 999
    end
    @testset "test unwind_path" begin
        path = Path([tlist(tint), LEFT, RIGHT, LEFT, RIGHT,
                     RIGHT, LEFT, LEFT, RIGHT, RIGHT])
        result = unwind_path(path)
        @test allequal(
            result,
            [tlist(tint), LEFT, RIGHT, LEFT, RIGHT, RIGHT, LEFT, RIGHT])

        path = Path([tlist(tint), LEFT, RIGHT, RIGHT, RIGHT])
        result = unwind_path(path)
        @test allequal(
            result,
            [tlist(tint), RIGHT])

        path = Path()
        result = unwind_path(path)
        @test result == []
    end
    @testset "test state_violates_symmetry" begin
        primitives = base_primitives()

        skeleton = Abstraction(
            Application(
                Application(
                    parse_program("+", primitives),
                    Application(
                        Application(
                            parse_program("index", primitives),
                            Application(
                                parse_program("car", primitives),
                                DeBruijnIndex(0)
                            )
                        ),
                        Application(
                            parse_program("car", primitives),
                            Unknown(t0)
                        )
                    )
                ),
                Unknown(t0)
            )
        )
        context = Context(3, [(2, tlist(tint)), (1, tint), (0, tint)])
        path = Path([tlist(tint), LEFT, RIGHT, RIGHT, RIGHT])
        state = State(skeleton, context, path, 11.9894, 94)
        result = state_violates_symmetry(state)
        @test !result

        parent = get_parent(path, skeleton)
        @test isa(parent, Program)
        @test str(parent) == "(car ?)"

        child = Application(
            parse_program("cons", primitives),
            Unknown(t0)
        )
        result = state_violates_symmetry(state, child)
        @test result

        child = parse_program("+", primitives)
        result = state_violates_symmetry(state, child)
        @test !result

        skeleton = Abstraction(
            Application(
                Application(
                    parse_program("*", primitives),
                    parse_program("1", primitives)
                ),
                Application(
                    parse_program("length", primitives),
                    DeBruijnIndex(0)
                )
            )
        )
        context = Context(0, [])
        path = Path()
        state = State(skeleton, context, path, 5.9894, 96)
        result = state_violates_symmetry(state)
        @test result

        skeleton = Abstraction(
            Application(
                Application(
                    parse_program("*", primitives),
                    Unknown(tint)
                ),
                Application(
                    parse_program("length", primitives),
                    DeBruijnIndex(0)
                )
            )
        )
        child = parse_program("1", primitives)
        context = Context(0, [])
        path = Path([tlist(tint), LEFT, LEFT, RIGHT])
        state = State(skeleton, context, path, 5.9894, 96)
        result = state_violates_symmetry(state, child)
        @test result
    end
    @testset "test modify_skeleton complete program" begin
        primitives = base_primitives()

        path1 = Path([tlist(tint), LEFT, RIGHT, RIGHT, RIGHT])
        skeleton1 = Abstraction(
            Application(
                Application(
                    parse_program("+", primitives),
                    Application(
                        Application(
                            parse_program("index", primitives),
                            Application(
                                parse_program("car", primitives),
                                DeBruijnIndex(0)
                            )
                        ),
                        Application(
                            parse_program("car", primitives),
                            Unknown(tlist(tint))
                        )
                    )
                ),
                Unknown(tint)
            )
        )
        p1 = DeBruijnIndex(0)
        skeleton2 = modify_skeleton(path1, skeleton1, p1)
        @test str(skeleton2) == "(lambda (+ (index (car \$0) (car \$0)) ?))"

        path2 = Path([tlist(tint), RIGHT])
        p2 = parse_program("1", primitives)
        result = modify_skeleton(path2, skeleton2, p2)
        @test str(result) == "(lambda (+ (index (car \$0) (car \$0)) 1))"
    end
    @testset "test follow_path" begin
        primitives = base_primitives()

        path = Path([tlist(tint), LEFT, RIGHT, RIGHT, RIGHT])
        skeleton = Abstraction(
            Application(
                Application(
                    parse_program("+", primitives),
                    Application(
                        Application(
                            parse_program("index", primitives),
                            Application(
                                parse_program("car", primitives),
                                DeBruijnIndex(0)
                            )
                        ),
                        Application(
                            parse_program("car", primitives),
                            Unknown(tlist(tint))
                        )
                    )
                ),
                Unknown(tint)
            )
        )
        result = follow_path(path, skeleton)

        # TODO: implement isequal / hash for program similar to TypeField
        @test isa(result, Program)
        @test result.name == "?"
        @test result.func == nothing
        @test isequal(result.type, tlist(tint))
    end
    @testset "test application_parse" begin
        primitives = base_primitives()

        p = Application(
            Application(
                parse_program("cons", primitives),
                parse_program("1", primitives),
            ),
            Application(
                parse_program("cdr", primitives),
                DeBruijnIndex(0)
            )
        )
        f, args = application_parse(p)
        @test str(f) == "cons"
        @test length(args) == 2
        @test isa(args[1], Program)
        @test str(args[1]) == "1"
        @test isa(args[2], Program)
        @test str(args[2]) == "(cdr \$0)"
    end
end
