module DreamCore

include("utils.jl")
include("types.jl")
include("problems.jl")
include("programs.jl")
include("parsers.jl")
include("grammars.jl")
include("solutions.jl")
include("primitives.jl")
include("generation.jl")
include("enumeration.jl")

using .Utils
using .Types
using .Problems
using .Programs
using .Primitives
using .Parsers
using .Grammars
using .Solutions
using .Generation
using .Enumeration

export run_enumeration,
       Grammar,
       Program,
       Primitive,
       Problem,
       TypeField,
       Example,
       try_solve,
       update_solutions!,
       SolutionSet,
       Solution,
       priority,
       json_format,
       is_explored,
       generator,
       base_primitives,
       evaluate,
       parse_program

end
