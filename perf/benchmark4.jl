using Statistics
using BenchmarkTools
using JSON

using DreamCore
using DreamCore.Types: Context, AbstractType
using DreamCore.Generation: ProgramState, build_candidates

using DreamCore

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
primitives = base_primitives()
grammar = Grammar(data["DSL"], primitives)
problems = map(Problem, data["tasks"])
type = problems[1].type

# precompile
env = Array{AbstractType}([])
gen = generator(grammar, env, type, 10.5, 9.0, 99, false)
[i for i in gen]

env = Array{AbstractType}([])
gen = generator(grammar, env, type, 10.5, 9.0, 99, false)
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
