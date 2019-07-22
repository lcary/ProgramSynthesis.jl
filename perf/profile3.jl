# Profiles the performance of build_candidates

using Statistics
using JSON
using Profile

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
build_candidates(grammar, request, context, env)

Profile.clear()  # in case we have any previous profiling data
@profile build_candidates(grammar, request, context, env)

out = "messages/prof.txt"
open(out, "w") do s
    Profile.print(IOContext(s, :displaysize => (24, 500)))
end

println("wrote: ", out)
