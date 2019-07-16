"""
Program generation testing...
"""
module TestGenerator

using JSON

using DreamCore
using DreamCore.Types: tint, tlist, arrow, tbool

filename = "request_enumeration_example_2.json"
filepath = abspath(@__DIR__, "..", "test", "resources", filename)
data = JSON.parsefile(filepath)
primitives = base_primitives()
grammar = Grammar(data["DSL"], primitives)
problems = map(Problem, data["tasks"])

# request = problems[1].type
request = tint
# request = arrow(tlist(tint), tlist(tint))
# request = tbool
# request = tlist(tint)

program_timeout = 5.0
# program_timeout = 0.5

# max_depth = 99
max_depth = 5

# warm the JIT cache
println("\nGenerate single program with upper=3.0, lower=1.5")
r = generator(grammar, [], request, 3.0, 1.5, max_depth, false)
r1 = take!(r)
println("=> ", r1)

start_time = time()

println("\nGenerate $program_timeout seconds of programs with upper=3.0, lower=1.5")
r = generator(grammar, [], request, 3.0, 1.5, max_depth, false)
for i in r
    println(string("=> ", i))
    if time() > start_time + program_timeout
        println("timeout exceeded")
        break
    end
end

start_time = time()

println("\nGenerate $program_timeout seconds of programs with upper=6.0, lower=4.5")
r = generator(grammar, [], request, 6.0, 4.5, max_depth, false)
for i in r
    println(string("=> ", i))
    if time() > start_time + program_timeout
        println("timeout exceeded")
        break
    end
end

end
