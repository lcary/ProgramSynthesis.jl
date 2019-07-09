module DreamCore

import Random
import JSON

export greet, greet_alien, run_enumeration

greet() = "Hello World!"
const x = Random.randstring(8)
greet_alien() = "Hello $x"

include("enumeration.jl")

end
