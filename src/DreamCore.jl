module DreamCore

include("types.jl")
include("grammar.jl")
include("enumeration.jl")

using .Types
using .Grammar
using .Enumeration

export run_enumeration,
       GrammarData,
       DCType,
       EnumerationData

end
