using Statistics
using Profile
using JSON

using ProgramSynthesis
using ProgramSynthesis.Types: Context, TypeField
using ProgramSynthesis.Generation: build_candidates, program_generator

using ProgramSynthesis

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

data = JSON.parsefile(f)
primitives = base_primitives()
grammar = Grammar(data["DSL"], primitives)
problems = map(Problem, data["tasks"])
type = problems[1].type

# precompile
env = Array{TypeField}([])
gen = program_generator(grammar, env, type, 10.5, 9.0, 99)
[i for i in gen]

Profile.clear()  # in case we have any previous profiling data
env = Array{TypeField}([])
gen = program_generator(grammar, env, type, 10.5, 9.0, 99)
@profile [i for i in gen]

out = "messages/prof.txt"
open(out, "w") do s
    Profile.print(IOContext(s, :displaysize => (24, 500)))
end

println("wrote: ", out)
