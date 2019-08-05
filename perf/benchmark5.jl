using Statistics
using BenchmarkTools
using JSON

using ProgramSynthesis
using ProgramSynthesis.Types: Context, TypeField
using ProgramSynthesis.Generation: program_generator

using ProgramSynthesis

filepath = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(filepath)
primitives = base_primitives()
grammar = Grammar(data["DSL"], primitives)
problems = map(Problem, data["tasks"])
type = problems[1].type

upper_bound = 10.5
lower_bound = 9.0
max_depth = 99

function f(grammar, type, upper_bound, lower_bound, max_depth)
    gen = program_generator(grammar, type, upper_bound, lower_bound, max_depth)
    return [i for i in gen]
end

# precompile
f(grammar, type, upper_bound, lower_bound, max_depth)

t = @benchmark f(grammar, type, upper_bound, lower_bound, max_depth)

dump(t)

println("minimum:")
println(minimum(t))
println("median:")
println(median(t))
println("mean:")
println(mean(t))
println("maximum:")
println(maximum(t))
