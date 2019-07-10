module DreamCore

using Random
using JSON

greet() = "Hello World!"
const x = Random.randstring(8)
greet_alien() = "Hello $x"

include("grammar.jl")
include("enumeration.jl")

using .Grammar
using .Enumeration

export greet, greet_alien, run_enumeration, GrammarDSL

end
