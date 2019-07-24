using JSON

using DreamCore
using DreamCore.Generation: program_generator

get_resource(filename) = abspath(@__DIR__, "..", "test", "resources", filename)

const TEST_FILE2 = get_resource("request_enumeration_example_2.json")

data = JSON.parsefile(TEST_FILE2)
log_probability = 0.0
data["DSL"]["productions"] = [
    Dict(
        "expression" => "index",
        "logProbability" => log_probability
    ),
    Dict(
        "expression" => "length",
        "logProbability" => log_probability
    ),
    Dict(
        "expression" => "0",
        "logProbability" => log_probability
    )
]
grammar = Grammar(data["DSL"], base_primitives())
problems = map(Problem, data["tasks"])
type = problems[1].type
env = Array{TypeField}([])
r = program_generator(grammar, env, type, 3.0, 1.5, 99)
for i in r
    println(i)
end
