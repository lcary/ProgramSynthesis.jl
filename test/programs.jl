using Test
using JSON

using DreamCore
using DreamCore.Primitives: base_primitives
using DreamCore.Types: arrow, t0, t1, tlist

fakeparse(x) = true  # TODO: test with actual program functions!

@testset "programs.jl" begin
    @testset "fakeparse program strings" begin
        @test fakeparse("(+ 1)")
        @test fakeparse("(\$0 \$1)")
        @test fakeparse("(+ 1 \$0 \$2)")
        @test fakeparse("(map (+ 1) \$0 \$1)")
        @test fakeparse("(map (+ 1) (\$0 (+ 1) (- 1) (+ -)) \$1)")
        @test fakeparse("(lambda \$0)")
        @test fakeparse("(lambda (+ 1 #(* 8 1)))")
        @test fakeparse("(lambda (+ 1 #(* 8 map)))")
    end
    @testset "parse primitive programs" begin
        p = Program("map", base_primitives())
        @test isequal(p.type, arrow(arrow(t0, t1), tlist(t0), tlist(t1)))
        @test p.source == "map"
        f = (x) -> (x + x)
        mapf = p.expression(f)
        @test mapf([1, 2]) == [2, 4]
    end
end
