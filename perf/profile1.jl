using Statistics
using Profile

using ProgramSynthesis

f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"

# precompile
run_enumeration(f)

Profile.clear()  # in case we have any previous profiling data
@profile run_enumeration(f)
out = "messages/prof.txt"
open(out, "w") do s
    Profile.print(IOContext(s, :displaysize => (24, 500)))
end

println("wrote: ", out)
