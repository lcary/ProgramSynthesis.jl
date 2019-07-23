# Benchmarks the performance of build_candidates

using Statistics
using JSON
using Traceur

using DreamCore
using DreamCore.Types: Context, TypeField
using DreamCore.Generation: build_candidates

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
grammar = Grammar(data["DSL"], base_primitives())
problems = map(Problem, data["tasks"])

env = Array{TypeField}([])
context = Context()
request = problems[1].type

# compile
@trace build_candidates(grammar, request, context, env)
