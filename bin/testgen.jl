"""
Program generation testing...
"""
module TestGenerator

using JSON

using DreamCore

filename = "request_enumeration_example_2.json"
filepath = abspath(@__DIR__, "..", "test", "resources", filename)
data = JSON.parsefile(filepath)
primitives = base_primitives()
grammar = Grammar(data["DSL"], primitives)
problems = map(Problem, data["tasks"])
type = problems[1].type
program_timeout = 5.0

start_time = time()

println("\nGenerate programs with upper=3.0, lower=1.5")
r = generator(grammar, [], type, 3.0, 1.5, 99, false)
for i in r
    println(string("=> ", i))
    if time() > start_time + program_timeout
        println("timeout exceeded")
        break
    end
end
#
# println("\nGenerate programs with upper=6.0, lower=4.5")
# r = generator(grammar, [], type, 6.0, 4.5, 99, true)
# for i in r
#     println(string("=> ", i))
#     if time() > start_time + program_timeout
#         println("timeout exceeded")
#         break
#     end
# end

end
