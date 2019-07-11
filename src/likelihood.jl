module Likelihood

using ..Programs
using ..Tasks

export LikelihoodModel, AllOrNothingLikelihoodModel, score

abstract type LikelihoodModel end

struct AllOrNothingLikelihoodModel <: LikelihoodModel
    timeout::Float64
end

function validate(log_likelihood::Float64)::Bool
    return !isinf(log_likelihood) && !isnan(log_likelihood)
end

function score(
    model::AllOrNothingLikelihoodModel,
    program::Program,
    task::ProgramTask
)::Tuple{Bool,Float64}
    if can_solve(program, task, model.timeout)
        log_likelihood = 0.0
    else
        log_likelihood = -Inf
    end
    return validate(log_likelihood), log_likelihood
end

end
