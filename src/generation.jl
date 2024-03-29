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
module Generation

using DataStructures

using ..Types
using ..Grammars
using ..Programs
using ..Utils

export Result, program_generator

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

    # TODO: check might unify
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

function valid(candidate::Candidate, upper_bound::Float64)::Bool
    return -candidate.log_probability < upper_bound
end

struct InvalidStateType <: Exception end

function violates_symmetry(
        argument_index::Int, original_func::Program,
        program::Program)::Bool
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

@enum PATH LEFT=0 RIGHT=1

PathType = Union{TypeField,PATH}

is_left(i::PathType) = i == LEFT
is_right(i::PathType) = i == RIGHT

Path = Array{PathType,1}

tail(path::Path)::Path = path[2:end]

function get_env(path::Path)::Array{TypeField,1}
    env = Array{TypeField,1}()
    for p in path
        if isa(p, TypeField)
            push!(env, p)
        end
    end
    return reverse(env)
end

struct State
    skeleton::Program
    context::Context
    path::Path
    cost::Float64
    depth::Int
end

function program_generator(
        channel::Channel, grammar::Grammar,
        context::Context,
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

        # println("DEBUG: current state: ", state)

        if out_of_bounds(cost, upper_bound, depth)
            continue
        end

        if program_is_finished(path, skeleton)
            if bounds_check(lower_bound, cost, upper_bound)
                put!(channel, Result(-cost, skeleton, context))
            end
            continue
        end

        add_children!(stack, state, grammar)
    end
end

function add_children!(
        stack::Stack{State}, state::State, grammar::Grammar)
    skeleton = state.skeleton
    context = state.context
    path = state.path
    cost = state.cost
    depth = state.depth

    type = follow_path(path, skeleton).type

    if Types.is_arrow(type)
        new_program = Abstraction(Unknown(type.arguments[2]))
        skeleton = modify_skeleton(path, skeleton, new_program)
        path = get_new_path(path, type.arguments[1])
        state = State(skeleton, context, path, cost, depth)
        push!(stack, state)
    else
        env = get_env(path)
        depth = depth - 1
        for c in build_candidates(grammar, type, context, env)
            if !state_violates_symmetry(state, c.program)
                push!(stack, process_candidate(c, state, depth, env))
            end
        end
    end
end

function process_candidate(
        c::Candidate, state::State, new_depth::Int,
        env::Array{TypeField,1})::State

    skeleton = state.skeleton
    context = state.context
    path = state.path
    cost = state.cost

    func_args = function_arguments(c.type)
    if isempty(func_args)
        skeleton = modify_skeleton(path, skeleton, c.program)
        path = unwind_path(path)
    else
        new_program = foldl(apply_unknown, func_args; init=c)
        skeleton = modify_skeleton(path, skeleton, new_program)
        path = get_new_path(path, func_args[2:end])
    end
    cost = cost - c.log_probability
    return State(skeleton, c.context, path, cost, new_depth)
end

function unwind_path(p::Path)
    last = findlast(is_left, p)
    if isnothing(last)
        return Path(undef, 0)
    end
    p = p[1:last-1]
    push!(p, RIGHT)
    return p
end

function state_violates_symmetry(state::State, child::Program)::Bool
    parent = get_parent(state.path, state.skeleton)
    if isnothing(parent)
        return false
    else
        index = get_child_index(parent, state.path)
        return violates_symmetry(index, getfunc(parent), child)
    end
end

function get_child_index(p::Program, path::Path)
    if !is_application(p.ptype)
        if isempty(path)
            return 0
        else
            return is_left(path[end]) ? 0 : 1
        end
    end
    i = -1
    while is_application(p.ptype)
        p = p.func
        i += 1
    end
    return i
end

function get_parent(path::Path, p::Program)
    last_apply = nothing
    for i in path
        if is_abstract_path(i, p)
            p = p.func
        elseif !is_application(p.ptype)
            break
        elseif is_left(i)
            last_apply = p
            p = p.func
        elseif is_right(i)
            last_apply = p
            p = p.args
        else
            error("invalid path sent to get_parent has no end")
        end
    end
    return last_apply
end

# TODO: move to programs.ml
function application_parse(p::Program)
    args = Array{Program,1}()
    while is_application(p.ptype)
        pushfirst!(args, p.args)
        p = p.func
    end
    return p, args
end

function apply_unknown(c::Candidate, t::TypeField)
    return apply_unknown(c.program, t)
end

function apply_unknown(p::Program, t::TypeField)
    return Application(p, Unknown(t))
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

# TODO: convert recursion to iteration
function modify_skeleton(path::Path, p1::Program, p2::Program)
    if is_initial_path(path, p1)
        return p2
    elseif is_abstract_path(path, p1)
        return Abstraction(modify_skeleton(tail(path), p1.func, p2))
    elseif is_left_path(path, p1)
        return Application(modify_skeleton(tail(path), p1.func, p2), p1.args)
    elseif is_right_path(path, p1)
        return Application(p1.func, modify_skeleton(tail(path), p1.args, p2))
    else
        error("modify_skeleton(): unexpected state, unable to modify skeleton.")
    end
end

function follow_path(path::Path, p::Program)::Program
    for i in path
        if is_abstract_path(i, p)
            p = p.func
        elseif is_left_path(i, p)
            p = p.func
        elseif is_right_path(i, p)
            p = p.args
        else
            error("follow_path(): unexpected state, unable to resolve path.")
        end
    end
    return p
end

function is_initial_path(path::Path, p::Program)
    return isempty(path) && is_unknown(p.ptype)
end

function is_abstract_path(path::Path, p::Program)
    return isa(path[1], TypeField) && is_abstraction(p.ptype)
end

function is_left_path(path::Path, p::Program)
    return is_left(path[1]) && is_application(p.ptype)
end

function is_right_path(path::Path, p::Program)
    return is_right(path[1]) && is_application(p.ptype)
end

function is_abstract_path(pathi::PathType, p::Program)
    return isa(pathi, TypeField) && is_abstraction(p.ptype)
end

function is_left_path(pathi::PathType, p::Program)
    return is_left(pathi) && is_application(p.ptype)
end

function is_right_path(pathi::PathType, p::Program)
    return is_right(pathi) && is_application(p.ptype)
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
        grammar::Grammar,
        type::TypeField, upper_bound::Float64,
        lower_bound::Float64, max_depth::Int)
    return Channel((channel) -> program_generator(
        channel, grammar, Context(),
        type, upper_bound, lower_bound, max_depth))
end

end
