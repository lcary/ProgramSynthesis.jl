module Generation

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Utils

export generator, Result, generator, program_generator

struct Result
    prior::Float64
    program::Program
    context::Context
end

function Base.show(io::IO, r::Result)
    print(io, "Result($(r.prior), $(r.program), $(r.context))")
end

struct Candidate
    log_probability::Float64
    type::TypeField
    program::Program
    context::Context
end

struct VariableCandidate
    type::TypeField
    index::Program
    context::Context
end

function Candidate(vc::VariableCandidate, l::Float64)::Candidate
    return Candidate(l, vc.type, vc.index, vc.context)
end

function get_candidate(
        request::TypeField, context::Context,
        production::Production)::Union{Candidate,Float64}
    l = production.log_probability
    p = production.program
    new_context, t = instantiate(p.type, context)
    new_context = unify(new_context, returns(t), request)
    if new_context == UNIFICATION_FAILURE
        return UNIFICATION_FAILURE
    end
    t = apply(t, new_context)
    return Candidate(l, t, p, new_context)
end

function get_variable_candidate(
        request::TypeField, context::Context, t::TypeField,
        i::Int)::Union{VariableCandidate,Float64}
    new_context = unify(context, returns(t), request)
    if new_context == UNIFICATION_FAILURE
        return UNIFICATION_FAILURE
    end
    t = apply(t, new_context)
    return VariableCandidate(t, DeBruijnIndex(i), new_context)
end

struct NoCandidates <: Exception end

function update_log_probability(z::Float64, c::Candidate)::Candidate
    new_l = c.log_probability - z
    return Candidate(new_l, c.type, c.program, c.context)
end

function get_logs(candidates::Array{Candidate,1})
    arr = Array{Float64,1}(undef, length(candidates))
    for (index, c) in enumerate(candidates)
        arr[index] = c.log_probability
    end
    return arr
end

function calculate_lse(candidates::Array{Candidate,1})
    return lse(get_logs(candidates))
end

function finalize_candidates!(candidates::Array{Candidate,1})
    z = calculate_lse(candidates)
    for (index, c) in enumerate(candidates)
        candidates[index] = update_log_probability(z, c)
    end
end

function get_candidates!(
        grammar::Grammar, request::TypeField, context::Context,
        candidates::Array{Candidate,1})
    for p in grammar.productions
        r = get_candidate(request, context, p)
        if r == UNIFICATION_FAILURE
            continue
        end
        push!(candidates, r)
    end
end

function get_variable_candidates!(
        request::TypeField, context::Context, env::Array{TypeField,1},
        variable_candidates::Array{VariableCandidate,1})
    for (i, t) in enumerate(env)
        r = get_variable_candidate(request, context, t, i - 1)
        if r == UNIFICATION_FAILURE
            continue
        end
        push!(variable_candidates, r)
    end
end

function add_variable_candidates!(
        grammar::Grammar,
        variable_candidates::Array{VariableCandidate,1},
        candidates::Array{Candidate,1})
    vl = grammar.log_variable - log(length(variable_candidates))
    for vc in variable_candidates
        push!(candidates, Candidate(vc, vl))
    end
end

function build_candidates(
        grammar::Grammar, request::TypeField, context::Context,
        env::Array{TypeField,1})::Array{Candidate,1}

    candidates = Array{Candidate,1}()
    variable_candidates = Array{VariableCandidate,1}()

    get_candidates!(grammar, request, context, candidates)
    get_variable_candidates!(request, context, env, variable_candidates)

    # TODO: check continuationType

    add_variable_candidates!(grammar, variable_candidates, candidates)
    variable_candidates = nothing

    if isempty(candidates)
        throw(NoCandidates)
    end

    finalize_candidates!(candidates)

    return candidates
end

# TODO: rename log_probability
function valid(candidate::Candidate, upper_bound::Float64)::Bool
    return -candidate.log_probability < upper_bound
end

struct InvalidStateType <: Exception end

# TODO: unit tests
function violates_symmetry(
        argument_index::Int, original_func::Program, program::Program,
        primitives::Dict{String,Program})::Bool
    if original_func.ptype != PRIMITIVE
        return false
    end
    f1 = original_func.name
    program_func = getfunc(program)
    if program_func.ptype != PRIMITIVE
        return false
    end
    f2 = program_func.name
    if argument_index == 0 && f1 == "car" && f2 == "cons"
        return true
    elseif argument_index == 0 && f1 == "car" && f2 == "empty"
        return true
    elseif argument_index == 0 && f1 == "cdr" && f2 == "cons"
        return true
    elseif argument_index == 0 && f1 == "cdr" && f2 == "empty"
        return true
    elseif f1 == "+" && f2 == "0"
        return true
    elseif argument_index == 1 && f1 == "-" && f2 == "0"
        return true
    elseif argument_index == 0 && f1 == "+" && f2 == "+"
        return true
    elseif argument_index == 0 && f1 == "*" && f2 == "*"
        return true
    elseif f1 == "*" && f2 == "0"
        return true
    elseif f1 == "*" && f2 == "1"
        return true
    elseif argument_index == 0 && f1 == "empty?" && f2 == "cons"
        return true
    elseif argument_index == 0 && f1 == "empty?" && f2 == "empty"
        return true
    elseif argument_index == 0 && f1 == "zero?" && f2 == "0"
        return true
    elseif argument_index == 0 && f1 == "zero?" && f2 == "1"
        return true
    elseif argument_index == 0 && f1 == "zero?" && f2 == "-1"
        return true
    elseif argument_index == 1 && f1 == "map" && f2 == "empty"
        return true
    elseif f1 == "zip" && f2 == "empty"
        return true
    elseif argument_index == 0 && f1 == "fold" && f2 == "empty"
        return true
    elseif argument_index == 1 && f1 == "index" && f2 == "empty"
        return true
    elseif f1 == "left" && (f2 == "left" || f2 == "right")
        return true
    elseif f1 == "right" && (f2 == "right" || f2 == "left")
        return true
    end
    return false
end

function stop(upper_bound::Float64, depth::Int)::Bool
    if upper_bound < 0.0 || depth <= 1
        return true
    else
        return false
    end
end

function generator(
        grammar::Grammar, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, max_depth::Int)
    return Channel((channel) -> generator(
        channel, grammar, Context(), env,
        type, upper_bound, lower_bound, max_depth))
end

# TODO: deprecate in favor of iteration
function generator(
        channel::Channel,
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    if !stop(upper_bound, depth)
        if Types.is_arrow(type)
            process_arrow(
                channel, grammar, context, env,
                type, upper_bound, lower_bound, depth)
        else
            process_candidates(
                channel, grammar, context, env,
                type, upper_bound, lower_bound, depth)
        end
    end
end

function get_new_env(type::TypeField, env::Array{TypeField,1})
    new_env = Array{TypeField,1}(undef, length(env) + 1)
    new_env[1] = type
    new_env[2:end] = env
    return new_env
end

function abstract_result(r::Result)::Result
    return Result(r.prior, Abstraction(r.program), r.context)
end

# TODO: deprecate in favor of iteration
function process_arrow(
        channel::Channel,
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    env = get_new_env(type.arguments[1], env)
    gen = Channel((c) -> generator(
        c, grammar, context, env,
        type.arguments[2], upper_bound, lower_bound, depth))
    for result in gen
        put!(channel, abstract_result(result))
    end
end

# TODO: deprecate in favor of iteration
function process_candidates(
        channel::Channel,
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int)
    for candidate in build_candidates(grammar, type, context, env)
        if valid(candidate, upper_bound)
            process_candidate(
                channel, grammar, context, env,
                type, upper_bound, lower_bound, depth, candidate)
        end
    end
end

function candidate_result(r::Result, c::Candidate)::Result
    l = r.prior + c.log_probability
    return Result(l, r.program, r.context)
end

# TODO: deprecate in favor of iteration
function process_candidate(
        channel::Channel,
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, depth::Int,
        candidate::Candidate)
    func_args = function_arguments(candidate.type)
    new_upper = upper_bound + candidate.log_probability
    new_lower = lower_bound + candidate.log_probability
    new_depth = depth - 1
    arg_index = 0

    gen = Channel((c) -> appgenerator(
        c, grammar, candidate.context, env,
        candidate.program, func_args, new_upper, new_lower,
        new_depth, arg_index, candidate.program))
    for result in gen
        put!(channel, candidate_result(result, candidate))
    end
end

function end_result(func::Program, context::Context)::Result
    return Result(0.0, func, context)
end

function bounds_check(lower_bound::Float64, upper_bound::Float64)
    return lower_bound <= 0.0 && upper_bound > 0.0
end

# TODO: deprecate in favor of iteration
function appgenerator(
        channel::Channel,
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program)
    if !stop(upper_bound, depth)
        if isempty(func_args)
            if bounds_check(lower_bound, upper_bound)
                put!(channel, end_result(func, context))
            end
        else
            recurse_generator(
                channel, grammar, context, env,
                func, func_args, upper_bound, lower_bound,
                depth, argument_index, original_func)
        end
    end
end


function recurse_generator(
        channel::Channel,
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program)
    arg_request = apply(func_args[1], context)
    outer_args = func_args[2:end]

    gen = Channel((c) -> generator(
        c, grammar, context, env,
        arg_request, upper_bound, 0.0, depth))
    for result in gen
        recurse_appgenerator(
            channel, grammar, context, env, func,
            func_args, upper_bound, lower_bound, depth, argument_index,
            original_func, outer_args, result)
    end
end

function combined_result(prev_result::Result, new_result::Result)::Result
    l = new_result.prior + prev_result.prior
    return Result(l, new_result.program, new_result.context)
end

# TODO: deprecate in favor of iteration
function recurse_appgenerator(
        channel::Channel,
        grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        func::Program, func_args::Array{TypeField,1},
        upper_bound::Float64, lower_bound::Float64,
        depth::Int, argument_index::Int,
        original_func::Program, outer_args::Array{TypeField,1},
        prev_result::Result)
    if !violates_symmetry(
            argument_index, original_func,
            prev_result.program, grammar.primitives)
        new_func = Application(func, prev_result.program)
        new_upper = upper_bound + prev_result.prior
        new_lower = lower_bound + prev_result.prior
        new_arg_index = argument_index + 1

        gen = Channel((c) -> appgenerator(
            c, grammar, prev_result.context, env,
            new_func, outer_args, new_upper, new_lower,
            depth, new_arg_index, func))
        for new_result in gen
            put!(channel, combined_result(prev_result, new_result))
        end
    end
end

@enum PATH LEFT=0 RIGHT=1

PathType = Union{TypeField,PATH}
Path = Array{PathType,1}

function get_env(path::Path)
    return reversed(filter((x) -> isa(x, TypeField), path))
end

struct State
    skeleton::Program
    context::Context
    path::Path
    cost::Float64
    depth::Int
end

"""
Program Generator as Iterative Model
------------------------------------

Do a depth-first search of programs that can be generated for a
given request type within some upper and lower description length bounds.

To do iteration, we use a stack of partial/hole programs, finalizing once both
(1) the description length of the program has exceeded the bounds, and
(2) all partial/incomplete parts of the program have been completed.

As a point of reference, a similar algorithm is implemented by
the `best_first_enumeration` function in dreamcoder's solvers/enumeration.ml
code, where a partial program is represented by the `best_first_state`.

Terms:
  - `skeleton::Program`: skeleton structure of program being created.
  - `context::Context`: type context for program.
  - `path::Array{TypeField}`: path to next "?"/partial part of program.
  - `cost::Float64`: negative log probability of program.

Example: (λ (+ ? ?))

Steps to solve (`log_p` = log probability, `+??`=`(+??)`=`(App(+,?),?)`):
  1.  ?     log_p=0
  2a. 1     log_p=-log2
  2b. + ? ?     log_p=-log2
  3.  + ? ?     log_p=-log2
  4a. + 1 ?     log_p=-log2-log2
  4b. + (+ ? ?) ?       log_p=-log2-log2
  5a. + 1 1             log_p=-log2-log2-log2
  5b. + 1 (+ ? ?)       log_p=-log2-log2-log2
  5c. + (+ ? ?) ?       log_p=-log2-log2

From the above steps, each step of adding a concrete program (e.g. "1")
adds to the log probability. Each step of adding a partial program ("?")
means a skeleton is added back to the stack for additional exploration,
in which other programs will be inserted to the space occupied by the "?"
in subsequent iterations.

In graphical form:
         ?
        /  \\
       / \\  x
      /\\ \\
     /\\/\\\\
  [ x /\\/\\ x ]  <-- yield all x's (leafs)

From the above small graph of "/\\"s which represents the search space,
when all of the partial/hole ("?") programs are completed for a skeleton,
we consider the skeleton program to be complete. Completed programs are
considered leaf nodes in the graph that is the search space. The brackets
in the graph depict the point at which the bounds for the mean description
length of the programs have been passed, and is the point where all completed
programs should be returned to the outside world.

In this enumeration algorithm, programs are returned via a `Channel`
in order to avoid running out of memory, since accumulating the programs
in an array would be infeasable in the case where we are searching over
billions of programs. Assumption: the stack size should grow logarithmically
with the depth of the search space, so it would require absurdly deep spaces
to run out of memory during iteration.
"""
function program_generator(
        channel::Channel, grammar::Grammar,
        context::Context, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, max_depth::Int)

    stack = Stack{State}()

    path = Array{Union{PATH,TypeField},1}()
    initial = State(Unknown(type), context, path, 0.0, max_depth)

    push!(stack, initial)

    # also check time with each iteration
    while !isempty(stack)

        state = pop!(stack)

        skeleton = state.skeleton
        context = state.context
        path = state.path
        cost = state.cost
        depth = state.depth

        if out_of_bounds(cost, upper_bound, depth)
            continue
        end

        if program_is_finished(path, skeleton)
            if bounds_check(lower_bound, cost, upper_bound)
                put!(channel, Result(cost, skeleton, context))
                continue
            end
        end

        for (child, l) in children(state)
            error("Not implemented")
        end
    end
end

# TODO: should entire state be passed?
function children(state::State)
    skeleton = state.skeleton
    context = state.context
    path = state.path
    cost = state.cost
    depth = state.depth

    type = follow_path(skeleton, path).type
    println(state, type)
    children = Array{State,1}()

    if Types.is_arrow(type)
        new_program = Abstraction(Unknown(type.arguments[2]))
        skeleton = modify_skeleton(skeleton, new_program, path)
        path = get_new_path(path, type.arguments[1])
        state = State(skeleton, context, path, cost, depth)
        push!(children, state)
    else
        env = get_env(path)
        for c in build_candidates(grammar, type, context, env)
            # TODO: refactor, extract to method
            func_args = function_arguments(c.type)
            new_upper = upper_bound + c.log_probability
            new_lower = lower_bound + c.log_probability
            new_depth = depth - 1
            arg_index = 0
            if isempty(func_args)
                new_skeleton = modify_skeleton(skeleton, c.program, path)
                new_path = unwind_path(path)
                new_cost = cost - c.log_probability
                state = State(new_skeleton, c.context, new_path, cost)
                push!(children, state)
            else
                new_program = foldl(apply_unknown, func_args; init=c)
                new_skeleton = modify_skeleton(skeleton, new_program, path)
                new_cost = cost - c.log_probability
                new_path = get_new_path(path, func_args[2:end])
                state = State(new_skeleton, c.context, new_path, cost, depth)
                push!(children, state)
            end
        end
    end
    return filter(!state_violates_symmetry, children)
end

function state_violates_symmetry(state::State)
    error("Not implemented!")
end

function apply_unknown(e::Program, t::TypeField)
    return Application(e, Unknown(t))
end

function get_new_path(path::Path, type::TypeField)
    new_path = copy(path)
    push!(new_path, type)
    return new_path
end

function get_new_path(path::Path, typearray::Array{TypeField,1})
    new_path = copy(path)
    for a in typearray
        push!(new_path, LEFT)
    end
    push!(new_path, RIGHT)
    return new_path
end

function modify_skeleton(p1::Program, p2::Program, path::Path)
    if is_initial_state(p1, path)
        return p2
    else
        error("Not implemented yet")
    end
end

function follow_path(p::Program, path::Path)
    if is_initial_state(p, path)
        return p
    else
        error("Not implemented yet")
    end
end

function is_initial_state(p::Program, path::Path)
    return isempty(path) && p.ptype == UNKNOWN
end

function bounds_check(lower_bound::Float64, cost::Float64, upper_bound::Float64)
    return lower_bound <= cost < upper_bound
end

function out_of_bounds(cost::Float64, upper_bound::Float64, depth::Int)::Bool
    if upper_bound < cost || depth <= 1
        return true
    else
        return false
    end
end

function program_is_finished(
        path::Array{Union{PATH,TypeField},1}, program)
    return isempty(path) && program.ptype != UNKNOWN
end

function program_generator(
        grammar::Grammar, env::Array{TypeField,1},
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, max_depth::Int)
    return Channel((channel) -> program_generator(
        channel, grammar, Context(), env,
        type, upper_bound, lower_bound, max_depth))
end

end
