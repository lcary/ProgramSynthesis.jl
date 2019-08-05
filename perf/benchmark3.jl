# Benchmarks the performance of build_candidates

using Statistics
using JSON
using BenchmarkTools

using ProgramSynthesis
using ProgramSynthesis.Types: Context, TypeField
using ProgramSynthesis.Generation: build_candidates

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
grammar = Grammar(data["DSL"], base_primitives())
problems = map(Problem, data["tasks"])
request = problems[1].type
context = Context()
env = Array{TypeField}([])

# compile
build_candidates(grammar, request, context, env)

t = @benchmark build_candidates(grammar, request, context, env)

dump(t)

println("minimum:")
println(minimum(t))
println("median:")
println(median(t))
println("mean:")
println(mean(t))
println("maximum:")
println(maximum(t))
