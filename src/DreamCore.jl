module DreamCore

import Random
import JSON

export greet, greet_alien

greet() = "Hello World!"
const x = Random.randstring(8)
greet_alien() = "Hello $x"

end
