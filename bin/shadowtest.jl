"""
Shadow testing...
"""
module ShadowMain

using JSON

using DreamCore
using DreamCore.Enumeration: Request, shadow_generate_results

filename = "request_enumeration_example_2.json"
filepath = abspath(@__DIR__, "..", "test", "resources", filename)
json_data = JSON.parsefile(filepath)
enum_data = Request(json_data)
type = enum_data.problems[1].type
r = shadow_generate_results(enum_data, [], type, 1.5, 0.0)
for i in r
    println(i)
end

end
