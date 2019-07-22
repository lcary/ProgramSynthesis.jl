using Statistics
using BenchmarkTools
using JSON

using DreamCore
using DreamCore.Types: Context, TypeField
using DreamCore.Generation: build_candidates

using DreamCore

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
primitives = base_primitives()
grammar = Grammar(data["DSL"], primitives)
problems = map(Problem, data["tasks"])
type = problems[1].type
env = Array{TypeField}([])

# precompile
gen = generator(grammar, env, type, 10.5, 9.0, 99)
[i for i in gen]

gen = generator(grammar, env, type, 10.5, 9.0, 99)
t = @benchmark [i for i in gen]

dump(t)

println("minimum:")
println(minimum(t))
println("median:")
println(median(t))
println("mean:")
println(mean(t))
println("maximum:")
println(maximum(t))
