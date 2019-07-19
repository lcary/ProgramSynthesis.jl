using Test

using DreamCore
using DreamCore.Parsers: parse_s_expression,
                         ParseSExprFailure,
                         ParseFailure
using DreamCore.Programs: DeBruijnIndex,
                          Abstraction,
                          Application,
                          str

@testset "parsers.jl" begin
    @testset "parse program strings" begin
        prim = base_primitives()

        pstr = "+"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, Program)

        pstr = "(+ 1)"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, Application)

        pstr = raw"$1"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, DeBruijnIndex)

        pstr = raw"($0 $1)"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, Application)

        pstr = raw"(+ 1 $0 $2)"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, Application)

        pstr = raw"(map (+ 1) $0 $1)"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, Application)

        pstr = raw"(map (+ 1) ($0 (+ 1) (- 1) (+ -)) $1)"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, Application)

        pstr = raw"(lambda $0)"
        p = parse_program(pstr, prim)
        @test str(p) == pstr
        @test isa(p, Abstraction)

        # TODO: implement parsing invented programs
        # p = parse_program("(lambda (+ 1 #(* 8 1)))", prim)
        # @test isa(p, Abstraction)
        # p = parse_program("(lambda (+ 1 #(* 8 map)))", prim)
        # @test isa(p, Abstraction)
    end
    @testset "parse program error" begin
        error_raised = false
        prim = base_primitives()
        pstr = raw"(lambda $0 asdlfihj)"
        try
            parse_program(pstr, prim)
        catch e
            if isa(e, ParseFailure)
                error_raised = true
            else
                rethrow(e)
            end
        end
        @test error_raised
    end
    @testset "parse program s-expressions" begin
        pstr = "+"
        s_expr = parse_s_expression(pstr)
        @test s_expr == "+"

        pstr = "(+ 1)"
        s_expr = parse_s_expression(pstr)
        @test s_expr == ["+", "1"]

        pstr = raw"$1"
        s_expr = parse_s_expression(pstr)
        @test s_expr == "\$1"

        pstr = raw"($0 $1)"
        s_expr = parse_s_expression(pstr)
        @test s_expr == ["\$0", "\$1"]

        pstr = raw"(+ 1 $0 $2)"
        s_expr = parse_s_expression(pstr)
        @test s_expr == ["+", "1", "\$0", "\$2"]

        pstr = raw"(map (+ 1) $0 $1)"
        s_expr = parse_s_expression(pstr)
        @test s_expr == ["map", ["+", "1"], "\$0", "\$1"]

        pstr = raw"(map (+ 1) ($0 (+ 1) (- 1) (+ -)) $1)"
        s_expr = parse_s_expression(pstr)
        @test s_expr == ["map",
            ["+", "1"], ["\$0", ["+", "1"], ["-", "1"], ["+", "-"]], "\$1"
        ]

        pstr = raw"(lambda $0)"
        s_expr = parse_s_expression(pstr)
        @test s_expr == ["lambda", "\$0"]
    end
    @testset "parse program s-expression error" begin
        error_raised = false
        pstr = raw"(lambda"
        try
            parse_s_expression(pstr)
        catch e
            if isa(e, BoundsError)
                error_raised = true
            else
                rethrow(e)
            end
        end
        @test error_raised

        error_raised = false
        pstr = raw"cons 3)"
        try
            parse_s_expression(pstr)
        catch e
            if isa(e, ParseSExprFailure)
                error_raised = true
            else
                rethrow(e)
            end
        end
        @test error_raised
    end
end

1
