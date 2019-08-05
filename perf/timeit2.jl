using Statistics
using BenchmarkTools
using JSON
using Test

using DreamCore
using DreamCore.Programs
using DreamCore.Types: Context, TypeField
using DreamCore.Generation: application_parse

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
# @time primitives = base_primitives()
primitives = base_primitives()
# @time grammar = Grammar(data["DSL"], primitives)
grammar = Grammar(data["DSL"], primitives)
# @time problems = map(Problem, data["tasks"])
problems = map(Problem, data["tasks"])
type = problems[1].type

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

@time f, args = application_parse(p)
@time f, args = application_parse(p)

@test str(f) == "cons"
@test length(args) == 2
@test isa(args[1], Program)
@test str(args[1]) == "1"
@test isa(args[2], Program)
@test str(args[2]) == "(cdr \$0)"
