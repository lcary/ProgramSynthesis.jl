using Statistics

using BenchmarkTools

using ProgramSynthesis

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json"

# precompile
run_enumeration(f)

t = @benchmark run_enumeration(f)

dump(t)

println("minimum:")
println(minimum(t))
println("median:")
println(median(t))
println("mean:")
println(mean(t))
println("maximum:")
println(maximum(t))
