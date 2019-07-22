# Benchmarks the performance of build_candidates

using Statistics
using JSON
using Traceur

using DreamCore
using DreamCore.Types: Context, AbstractType
using DreamCore.Generation: ProgramState, build_candidates

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
grammar = Grammar(data["DSL"], base_primitives())
problems = map(Problem, data["tasks"])

env = Array{AbstractType}([])
state = ProgramState(
    Context(),
    env,
    problems[1].type,
    10.5,
    9.0,
    99
)

# compile
@trace build_candidates(grammar, state)
