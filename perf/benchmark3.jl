# Benchmarks the performance of build_candidates

using Statistics
using JSON
using BenchmarkTools

using DreamCore
using DreamCore.Types: Context, TypeField
using DreamCore.Generation: ProgramState, build_candidates

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
grammar = Grammar(data["DSL"], base_primitives())
problems = map(Problem, data["tasks"])

env = Array{TypeField}([])
state = ProgramState(
    Context(),
    env,
    problems[1].type,
    10.5,
    9.0,
    99
)

# compile
build_candidates(grammar, state)

t = @benchmark build_candidates(grammar, state)

dump(t)

println("minimum:")
println(minimum(t))
println("median:")
println(median(t))
println("mean:")
println(mean(t))
println("maximum:")
println(maximum(t))
