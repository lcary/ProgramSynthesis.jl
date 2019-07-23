using Test
using JSON

using DreamCore
using DreamCore.Parsers: parse_program
using DreamCore.Programs: evaluate,
                          DeBruijnIndex,
                          try_solve,
                          Abstraction,
                          Application,
                          str,
                          PROGRAMTYPE,
                          PROGRAM,
                          PRIMITIVE,
                          ABSTRACTION,
                          APPLICATION,
                          INDEX,
                          INVENTED
using DreamCore.Problems: Problem
using DreamCore.Primitives: base_primitives
using DreamCore.Types: arrow, t0, t1, tlist

@testset "programs.jl" begin
    @testset "parse primitive programs" begin
        p = parse_program("map", base_primitives())
        @test isequal(p.type, arrow(arrow(t0, t1), tlist(t0), tlist(t1)))
        @test p.name == "map"
        @test p.ptype == PRIMITIVE
        f = (x) -> (x + x)
        mapf = p.func(f)
        @test mapf([1, 2]) == [2, 4]
    end
    @testset "evaluate primitive programs" begin
        primitives = base_primitives()

        p1 = parse_program("+", primitives)
        @test p1.ptype == PRIMITIVE
        f1 = evaluate(p1, [])
        @test f1(3)(4) == 7
        @test f1(-123)(555) == 432

        p2 = parse_program("length", primitives)
        @test p2.ptype == PRIMITIVE
        f2 = evaluate(p2, [])
        @test f2([1,2,3]) == 3
        @test f2([]) == 0
    end
    @testset "check program strings" begin
        primitives = base_primitives()

        p1 = Abstraction(
            Application(
                Application(
                    parse_program("cons", primitives),
                    Application(
                        parse_program("length", primitives),
                        parse_program("empty", primitives)
                    )
                ),
                DeBruijnIndex(0)
            )
        )
        @test str(p1) == "(lambda (cons (length empty) \$0))"

        cdr = parse_program("cdr", primitives)
        p2 = Abstraction(
            Application(
                cdr, Application(
                    cdr, Application(cdr, DeBruijnIndex(0))
                )
            )
        )
        @test str(p2) == "(lambda (cdr (cdr (cdr \$0))))"

        p3 = Abstraction(
            Application(
                parse_program("car", primitives),
                Application(
                    Application(
                        parse_program("map", primitives),
                        Abstraction(DeBruijnIndex(1))
                    ),
                    DeBruijnIndex(0)
                )
            )
        )
        @test str(p3) == "(lambda (car (map (lambda \$1) \$0)))"

        p4 = Abstraction(
            Application(
                Application(
                    parse_program("cons", primitives),
                    parse_program("1", primitives),
                ),
                Application(
                    parse_program("cdr", primitives),
                    DeBruijnIndex(0)
                )
            )
        )
        @test str(p4) == "(lambda (cons 1 (cdr \$0)))"

        p5 = Abstraction(
            Application(
                Application(
                    parse_program("cons", primitives),
                    Application(
                        parse_program("length", primitives),
                        parse_program("empty", primitives)
                    )
                ),
                DeBruijnIndex(0)
            )
        )
        @test str(p5) == "(lambda (cons (length empty) \$0))"

        p6 = Abstraction(
            Application(
                Application(
                    parse_program("index", primitives),
                    Application(
                        parse_program("car", primitives),
                        DeBruijnIndex(0)
                    )
                ),
                DeBruijnIndex(0)
            )
        )
        @test str(p6) == "(lambda (index (car \$0) \$0))"
    end
    @testset "try_solve length problem with length" begin
        primitives = base_primitives()

        len = parse_program("length", primitives)
        program  = Abstraction(Application(len, DeBruijnIndex(0)))

        data = Dict(
            "name" => "length-test",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "int", "arguments" => [])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict("inputs" => [[1,3]], "output" => 2),
                Dict("inputs" => [[5,5,0,6,2]], "output" => 5),
                Dict("inputs" => [[2,5,0,5,0]], "output" => 5),
                Dict("inputs" => [[4,4,5,4,4]], "output" => 5),
                Dict("inputs" => [[4,4,5,4]], "output" => 4),
                Dict("inputs" => [[4,4,5]], "output" => 3),
                Dict("inputs" => [[]], "output" => 0),
                Dict("inputs" => [[4]], "output" => 1)
            ]
        )
        problem = Problem(data)
        success, log_likelihood = try_solve(program, problem)
        @test success
        @test log_likelihood == 0.0
    end
    @testset "try_solve non-length problem with length" begin
        primitives = base_primitives()

        len = parse_program("length", primitives)
        program  = Abstraction(Application(len, DeBruijnIndex(0)))

        data = Dict(
            "name" => "non-length-test",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict("inputs" => [[1,3]], "output" => [1,3]),
                Dict("inputs" => [[1,3]], "output" => [2])
            ]
        )
        problem = Problem(data)
        success, log_likelihood = try_solve(program, problem)
        @test !success
        @test log_likelihood == -Inf
    end
    @testset "try_solve 0 problem with 0" begin
        primitives = base_primitives()

        program = Abstraction(parse_program("0", primitives))

        data = Dict(
            "name" => "0-test",
            "request" => Dict(
                "constructor" => "int",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "int", "arguments" => [])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict("inputs" => [[3,6,4,2]], "output" => 0),
                Dict("inputs" => [1], "output" => 0),
                Dict("inputs" => [[1,3]], "output" => 0),
                Dict("inputs" => [[1]], "output" => 0)
            ]
        )
        problem = Problem(data)
        success, log_likelihood = try_solve(program, problem)
        @test success
        @test log_likelihood == 0.0
    end
    @testset "try_solve prepend-k with k=0" begin
        data = Dict(
            "name" => "prepend-k with k=0",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict(
                    "inputs" => [[12,0,1,9,4]],
                    "output" => [0,12,0,1,9,4]
                ),
                Dict(
                    "inputs" => [[9,10,8]],
                    "output" => [0,9,10,8]
                ),
                Dict(
                    "inputs" => [[]],
                    "output" => [0]
                ),
                Dict(
                    "inputs" => [[5,11,9,0,7,1,7]],
                    "output" => [0,5,11,9,0,7,1,7]
                ),
                Dict(
                    "inputs" => [[14,0,3]],
                    "output" => [0,14,0,3]
                ),
                Dict(
                    "inputs" => [[6,9,8,16,1,2]],
                    "output" => [0,6,9,8,16,1,2]
                ),
                Dict(
                    "inputs" => [[16,11]],
                    "output" => [0,16,11]
                ),
                Dict(
                    "inputs" => [[8,0,16,10,7,12,10]],
                    "output" => [0,8,0,16,10,7,12,10]
                ),
                Dict(
                    "inputs" => [[12,4]],
                    "output" => [0,12,4]
                ),
                Dict(
                    "inputs" => [[1]],
                    "output" => [0,1]
                ),
                Dict(
                    "inputs" => [[1,2,5,13,1,3]],
                    "output" => [0,1,2,5,13,1,3]
                ),
                Dict(
                    "inputs" => [[6,8,0,11]],
                    "output" => [0,6,8,0,11]
                ),
                Dict(
                    "inputs" => [[16]],
                    "output" => [0,16]
                ),
                Dict(
                    "inputs" => [[4,14,11,0]],
                    "output" => [0,4,14,11,0]
                ),
                Dict(
                    "inputs" => [[5]],
                    "output" => [0,5]
                )
            ]
        )
        problem = Problem(data)

        primitives = base_primitives()

        program = Abstraction(
            Application(
                Application(
                    parse_program("cons", primitives),
                    Application(
                        parse_program("length", primitives),
                        parse_program("empty", primitives)
                    )
                ),
                DeBruijnIndex(0)
            )
        )
        success, log_likelihood = try_solve(program, problem)
        @test success
        @test log_likelihood == 0.0
    end
    @testset "try_solve drop-k with k=3" begin
        data = Dict(
            "name" => "drop-k with k=3",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict(
                  "inputs" => [[16,3,9,1,7,12,5,12,4,14]],
                  "output" => [1,7,12,5,12,4,14]
                ),
                Dict(
                  "inputs" => [[10,6,5,4,15,11,8,8]],
                  "output" => [4,15,11,8,8]
                ),
                Dict(
                  "inputs" => [[13,0,5,14,1,12,1,12,5,4]],
                  "output" => [14,1,12,1,12,5,4]
                ),
                Dict(
                  "inputs" => [[10,15,13,9,13,15,7,12,3,14]],
                  "output" => [9,13,15,7,12,3,14]
                ),
                Dict(
                  "inputs" => [[4,1,11,2,3,15,2,0,12]],
                  "output" => [2,3,15,2,0,12]
                ),
                Dict(
                  "inputs" => [[1,5,8,16,15,10,14,11]],
                  "output" => [16,15,10,14,11]
                ),
                Dict(
                  "inputs" => [[11,12,13,4,0,13,6,9,1,9]],
                  "output" => [4,0,13,6,9,1,9]
                ),
                Dict(
                  "inputs" => [[8,5,1,4,15,4,9,11,1]],
                  "output" => [4,15,4,9,11,1]
                ),
                Dict(
                  "inputs" => [[9,15,11,10,4,13]],
                  "output" => [10,4,13]
                ),
                Dict(
                  "inputs" => [[7,11,12,8,15,1,9,2]],
                  "output" => [8,15,1,9,2]
                ),
                Dict(
                  "inputs" => [[9,0,5,8,5,8,13]],
                  "output" => [8,5,8,13]
                ),
                Dict(
                  "inputs" => [[2,5,14,8,8]],
                  "output" => [8,8]
                ),
                Dict(
                  "inputs" => [[14,0,7,11,10,0,5,2]],
                  "output" => [11,10,0,5,2]
                ),
                Dict(
                  "inputs" => [[16,9,15,4]],
                  "output" => [4]
                ),
                Dict(
                  "inputs" => [[14,16,4,13,11,6,13,16,1,5]],
                  "output" => [13,11,6,13,16,1,5]
                )
            ]
        )
        problem = Problem(data)

        primitives = base_primitives()

        cdr = parse_program("cdr", primitives)
        program = Abstraction(
            Application(
                cdr, Application(
                    cdr, Application(cdr, DeBruijnIndex(0))
                )
            )
        )
        success, log_likelihood = try_solve(program, problem)
        @test success
        @test log_likelihood == 0.0
    end
    @testset "solve failure should not change data" begin
        data = Dict(
            "name" => "drop-k with k=3",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict(
                  "inputs" => [[16,3,9,1,7,12,5,12,4,14]],
                  "output" => [1,7,12,5,12,4,14]
                ),
                Dict(
                  "inputs" => [[10,6,5,4,15,11,8,8]],
                  "output" => [4,15,11,8,8]
                ),
                Dict(
                  "inputs" => [[13,0,5,14,1,12,1,12,5,4]],
                  "output" => [14,1,12,1,12,5,4]
                ),
                Dict(
                  "inputs" => [[10,15,13,9,13,15,7,12,3,14]],
                  "output" => [9,13,15,7,12,3,14]
                ),
                Dict(
                  "inputs" => [[4,1,11,2,3,15,2,0,12]],
                  "output" => [2,3,15,2,0,12]
                ),
                Dict(
                  "inputs" => [[1,5,8,16,15,10,14,11]],
                  "output" => [16,15,10,14,11]
                ),
                Dict(
                  "inputs" => [[11,12,13,4,0,13,6,9,1,9]],
                  "output" => [4,0,13,6,9,1,9]
                ),
                Dict(
                  "inputs" => [[8,5,1,4,15,4,9,11,1]],
                  "output" => [4,15,4,9,11,1]
                ),
                Dict(
                  "inputs" => [[9,15,11,10,4,13]],
                  "output" => [10,4,13]
                ),
                Dict(
                  "inputs" => [[7,11,12,8,15,1,9,2]],
                  "output" => [8,15,1,9,2]
                ),
                Dict(
                  "inputs" => [[9,0,5,8,5,8,13]],
                  "output" => [8,5,8,13]
                ),
                Dict(
                  "inputs" => [[2,5,14,8,8]],
                  "output" => [8,8]
                ),
                Dict(
                  "inputs" => [[14,0,7,11,10,0,5,2]],
                  "output" => [11,10,0,5,2]
                ),
                Dict(
                  "inputs" => [[16,9,15,4]],
                  "output" => [4]
                ),
                Dict(
                  "inputs" => [[14,16,4,13,11,6,13,16,1,5]],
                  "output" => [13,11,6,13,16,1,5]
                )
            ]
        )
        problem = Problem(data)

        primitives = base_primitives()

        program = Abstraction(
            Application(
                Application(
                    parse_program("cons", primitives),
                    Application(
                        parse_program("length", primitives),
                        parse_program("empty", primitives)
                    )
                ),
                DeBruijnIndex(0)
            )
        )
        @test data["examples"][1]["inputs"] == [[16,3,9,1,7,12,5,12,4,14]]
        @test data["examples"][1]["output"] == [1,7,12,5,12,4,14]
        success, log_likelihood = try_solve(program, problem)
        @test !success
        @test log_likelihood == -Inf
        @test data["examples"][1]["inputs"] == [[16,3,9,1,7,12,5,12,4,14]]
        @test data["examples"][1]["output"] == [1,7,12,5,12,4,14]
    end
    @testset "solve headth_element_of_tail" begin
        data = Dict(
            "name" => "headth_element_of_tail",
            "request" => Dict(
                "constructor" => "->",
                "arguments" => [
                    Dict("constructor" => "list", "arguments" => [
                        Dict("constructor" => "int", "arguments" => [])
                    ]),
                    Dict("constructor" => "int", "arguments" => [])
                ]
            ),
            "maximumFrontier" => 10,
            "examples" => [
                Dict(
                    "inputs" => [[6,1,7,3,5,8,2]],
                    "output" => 2
                ),
                Dict(
                    "inputs" => [[3,6,6,7,5]],
                    "output" => 7
                ),
                Dict(
                    "inputs" => [[3,5,6,3,2,7,0]],
                    "output" => 3
                ),
                Dict(
                    "inputs" => [[1,6,7,1,2]],
                    "output" => 6
                ),
                Dict(
                    "inputs" => [[1,4]],
                    "output" => 4
                )
            ]
        )
        problem = Problem(data)

        primitives = base_primitives()

        program = Abstraction(
            Application(
                Application(
                    parse_program("index", primitives),
                    Application(
                        parse_program("car", primitives),
                        DeBruijnIndex(0)
                    )
                ),
                DeBruijnIndex(0)
            )
        )

        success, log_likelihood = try_solve(program, problem)
        @test success
        @test log_likelihood == 0.0
    end
end
