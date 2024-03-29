using Test
using JSON

using ProgramSynthesis
using ProgramSynthesis.Types: function_arguments,
                       instantiate,
                       arrow,
                       Context,
                       arrow,
                       t0,
                       t1,
                       t2,
                       tint,
                       tlist,
                       tbool,
                       unify,
                       extend,
                       returns,
                       apply
using ProgramSynthesis.Utils: allsame

@testset "types.jl" begin
    @testset "test function_arguments" begin
        d1 = Dict(
            "constructor" => "->", "arguments" => [
                Dict("constructor" => "int", "arguments" => []),
                Dict(
                    "constructor" => "->", "arguments" => [
                        Dict("constructor" => "list(int)", "arguments" => []),
                        Dict("constructor" => "int", "arguments" => [])
                    ]
                )
            ]
        )
        t1 = TypeField(d1)

        d2 = Dict(
            "constructor" => "->", "arguments" => [
                Dict("constructor" => "list(t0)", "arguments" => []),
                Dict("constructor" => "int", "arguments" => [])
            ]
        )
        t2 = TypeField(d2)

        d3 = Dict("constructor" => "int", "arguments" => [])
        t3 = TypeField(d3)

        t1_args = function_arguments(t1)
        @test length(t1_args) == 2
        @test t1_args[1].constructor == "int"
        @test t1_args[2].constructor == "list(int)"
        t2_args = function_arguments(t2)
        @test length(t2_args) == 1
        @test t2_args[1].constructor == "list(t0)"
        @test function_arguments(t3) == []
    end
    @testset "test type equality" begin
        d1 = Dict(
            "constructor" => "->", "arguments" => [
                Dict("constructor" => "int", "arguments" => []),
                Dict(
                    "constructor" => "->", "arguments" => [
                        Dict("constructor" => "list(int)", "arguments" => []),
                        Dict("constructor" => "int", "arguments" => [])
                    ]
                )
            ]
        )
        t1 = TypeField(d1)
        t2 = TypeField(d1)
        t3 = TypeField(d1)

        @test isequal(t1, t2)
        @test isequal(t2, t3)
        @test isequal(t1, t3)
        @test allsame([t for t in [t1, t2, t3]])

        d2 = Dict(
            "constructor" => "->", "arguments" => [
                Dict("constructor" => "list(t0)", "arguments" => []),
                Dict("constructor" => "int", "arguments" => [])
            ]
        )
        t4 = TypeField(d2)
        t5 = TypeField(d2)

        @test isequal(t4, t5)
        @test !isequal(t4, t1)

        d3 = Dict("constructor" => "int", "arguments" => [])
        t6 = TypeField(d3)
        t7 = TypeField(d3)

        @test isequal(t6, t7)
        @test !isequal(t6, t4)
        @test !isequal(t6, t1)

        @test isequal(arrow(t0, tbool), arrow(t0, tbool))
        @test isequal(arrow(t1, tbool), arrow(t1, tbool))
        @test !isequal(arrow(t0, tbool), arrow(t1, tbool))
    end
    @testset "test type instantiate" begin
        context = Context(1, [])
        type = arrow(t0, tbool)
        r1 = instantiate(type, context)
        @test isa(r1, Tuple)
        # (Context(next=2, {}), t1 -> bool)
        @test r1[1].next_variable == 2
        @test r1[1].substitution == []
        @test isequal(r1[2], arrow(t1, tbool))

        context = Context(0, [])
        type = arrow(t0, tbool)
        type = arrow(arrow(t0, t1), arrow(tlist(t0), tlist(t1)))
        r2 = instantiate(type, context)
        @test isa(r2, Tuple)
        # (Context(next = 2, {}), (t0 -> t1) -> list(t0) -> list(t1))
        @test r2[1].next_variable == 2
        @test r2[1].substitution == []

        context = Context(1, [(0, tint)])
        t = arrow(tint, tbool)
        new_context, t = instantiate(t, context)
        @test new_context.next_variable == 1
        @test length(new_context.substitution) == 1
        @test new_context.substitution[1][1] == 0
        @test new_context.substitution[1][2] == tint
        @test isequal(t, arrow(tint, tbool))
    end
    @testset "test type unification" begin
        c1 = unify(Context(), tint, tint)
        # Context(next = 0, {})
        @test c1.next_variable == 0
        @test c1.substitution == []

        c2 = unify(Context(1, []), t0, tint)
        # Context(next = 1, {t0 ||> int})
        @test c2.next_variable == 1
        @test length(c2.substitution) == 1
        @test c2.substitution[1][1] == 0
        @test c2.substitution[1][2] == tint

        c3 = unify(Context(1, []), t1, tbool)
        # Context(next = 2, {t1 ||> bool})
        @test c3.next_variable == 1
        @test length(c3.substitution) == 1
        @test c3.substitution[1][1] == 1
        @test c3.substitution[1][2] == tbool

        c4 = unify(Context(2, [(1, tint)]), returns(t0), tint)
        @test c4.next_variable == 2
        @test length(c4.substitution) == 2
        @test c4.substitution[1][1] == 0
        @test c4.substitution[1][2] == tint
        @test c4.substitution[2][1] == 1
        @test c4.substitution[2][2] == tint
    end
    @testset "test type extend" begin
        context = Context(4, [(1, tint)])
        result = extend(context, 0, t2)
        # Context(next=4, {0 ||> t2, t1 ||> int})
        @test result.next_variable == 4
        @test length(result.substitution) == 2
        @test result.substitution[1][1] == 0
        @test result.substitution[1][2] == t2
        @test result.substitution[2][1] == 1
        @test result.substitution[2][2] == tint
    end
    @testset "test type apply" begin
        context = Context(2, [(0, tint), (1, tint)])
        result = apply(t0, context)
        @test isa(result, TypeField)
        @test isequal(result, tint)
    end
end
