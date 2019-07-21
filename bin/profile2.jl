using Statistics
using Profile
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

Profile.clear()  # in case we have any previous profiling data
env = Array{AbstractType}([])
gen = generator(grammar, env, type, 10.5, 9.0, 99, false)
@profile [i for i in gen]

out = "messages/prof.txt"
open(out, "w") do s
    Profile.print(IOContext(s, :displaysize => (24, 500), :format => :flat))
end

println("wrote: ", out)
