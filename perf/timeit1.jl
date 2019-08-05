using Statistics
using BenchmarkTools
using JSON

using ProgramSynthesis
using ProgramSynthesis.Types: Context, TypeField
using ProgramSynthesis.Generation: ProgramState, build_candidates

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
# @time primitives = base_primitives()
primitives = base_primitives()
# @time grammar = Grammar(data["DSL"], primitives)
grammar = Grammar(data["DSL"], primitives)
# @time problems = map(Problem, data["tasks"])
problems = map(Problem, data["tasks"])
type = problems[1].type

# precompile
env = Array{TypeField}([])
gen = generator(grammar, env, type, 10.5, 9.0, 99, false)
@time [i for i in gen]

# env = Array{TypeField}([])
# gen = generator(grammar, env, type, 10.5, 9.0, 99, false)
# @time [i for i in gen]
