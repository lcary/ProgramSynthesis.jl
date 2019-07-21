using Statistics
using JSON
using BenchmarkTools

using DreamCore
using DreamCore.Types: Context
using DreamCore.Types: ProgramState

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
grammar = Grammar(data["DSL"], base_primitives())

state = ProgramState(
    Context(),
    env,
    type,
    upper_bound,
    lower_bound,
    max_depth
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
