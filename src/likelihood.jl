module Likelihood

using ..Programs
using ..Tasks

export LikelihoodModel, AllOrNothingLikelihoodModel, score

abstract type LikelihoodModel end

struct AllOrNothingLikelihoodModel <: LikelihoodModel
    timeout::Float64
end

function score(
    model::AllOrNothingLikelihoodModel,
    program::Program,
    task::ProblemSet
)::Tuple{Bool,Float64}
    return true, 0.0  # TODO: fix fake data
end

end
