module DreamCore

include("types.jl")
include("program.jl")
include("grammar.jl")
include("enumeration.jl")

using .Types
using .Program
using .Grammar
using .Enumeration

export run_enumeration,
       GrammarData,
       DCType,
       EnumerationData,
       DCProgram

end
