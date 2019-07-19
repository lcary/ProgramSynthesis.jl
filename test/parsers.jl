using Test

using DreamCore
using DreamCore.Programs: DeBruijnIndex,
                          Abstraction,
                          Application

@testset "programs.jl" begin
    @testset "parse program strings" begin
        prim = base_primitives()
        p = parse_program("+", prim)
        @test isa(p, Program)
        p = parse_program("(+ 1)", prim)
        @test isa(p, Application)
        p = parse_program(raw"$1", prim)
        @test isa(p, DeBruijnIndex)
        p = parse_program(raw"($0 $1)", prim)
        @test isa(p, Application)
        p = parse_program(raw"(+ 1 $0 $2)", prim)
        @test isa(p, Application)
        p = parse_program(raw"(map (+ 1) $0 $1)", prim)
        @test isa(p, Application)
        p = parse_program(raw"(map (+ 1) ($0 (+ 1) (- 1) (+ -)) $1)", prim)
        @test isa(p, Application)
        p = parse_program(raw"(lambda $0)", prim)
        @test isa(p, Abstraction)
        # TODO: implement parsing invented programs
        # p = parse_program("(lambda (+ 1 #(* 8 1)))", prim)
        # @test isa(p, Abstraction)
        # p = parse_program("(lambda (+ 1 #(* 8 map)))", prim)
        # @test isa(p, Abstraction)
    end
end
