"""
Program generation testing...
"""
module TestGenerator

using JSON

using DreamCore

filename = "request_enumeration_example_2.json"
filepath = abspath(@__DIR__, "..", "test", "resources", filename)
data = JSON.parsefile(filepath)
grammar = Grammar(data["DSL"])
problems = map(Problem, data["tasks"])
type = problems[1].type
r = generator(grammar, [], type, 6.0, 4.5, 99)
for i in r
    println(i)
end

end
