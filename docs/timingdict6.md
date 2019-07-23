output:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27021_20190719_T155301.json
 26.105848 seconds (226.76 M allocations: 12.268 GiB, 7.20% gc time)
{
  total:  0.001235 seconds
  ncalls: 10387
  avg:    0.0 seconds
  func:   process_arrow(): append!(new_env, env)
}
{
  total:  0.001256 seconds
  ncalls: 35721
  avg:    0.0 seconds
  func:   lower_bound <= 0.0 && upper_bound > 0.0
}
{
  total:  0.001766 seconds
  ncalls: 30404
  avg:    0.0 seconds
  func:   Application
}
{
  total:  0.001873 seconds
  ncalls: 9647
  avg:    0.0 seconds
  func:   recurse_appgenerator(): Result(l, new_result.program, new_result.context)
}
{
  total:  0.00195 seconds
  ncalls: 10387
  avg:    0.0 seconds
  func:   process_arrow(): new_env = Array{TypeField,1}([lhs])
}
{
  total:  0.004067 seconds
  ncalls: 9647
  avg:    0.0 seconds
  func:   recurse_appgenerator(): new_result.prior + prev_result.prior
}
{
  total:  0.007915 seconds
  ncalls: 169729
  avg:    0.0 seconds
  func:   Types.is_arrow(type)
}
{
  total:  0.009024 seconds
  ncalls: 159342
  avg:    0.0 seconds
  func:   build_candidates(): for vc in variable_candidates...
}
{
  total:  0.010134 seconds
  ncalls: 165652
  avg:    0.0 seconds
  func:   valid(candidate, upper_bound)
}
{
  total:  0.011637 seconds
  ncalls: 364791
  avg:    0.0 seconds
  func:   stop(upper_bound, depth)
}
{
  total:  0.014542 seconds
  ncalls: 35331
  avg:    0.0 seconds
  func:   !is_symmetrical(...)
}
{
  total:  0.052487 seconds
  ncalls: 1762425
  avg:    0.0 seconds
  func:   all_invalid(): valid(c, upper_bound)
}
{
  total:  0.109568 seconds
  ncalls: 164658
  avg:    1.0e-6 seconds
  func:   function_arguments
}
{
  total:  0.137954 seconds
  ncalls: 159342
  avg:    1.0e-6 seconds
  func:   build_candidates(): final_candidates(candidates)
}
{
  total:  0.286282 seconds
  ncalls: 159342
  avg:    2.0e-6 seconds
  func:   build_candidates(): for (i, t) in enumerate(env)...
}
{
  total:  5.974306 seconds
  ncalls: 30404
  avg:    0.000196 seconds
  func:   recurse_appgenerator(): Channel((c) -> appgenerator(...)
}
{
  total:  6.633264 seconds
  ncalls: 35489
  avg:    0.000187 seconds
  func:   put!(channel, Result(0.0, func, context))
}
{
  total:  14.113348 seconds
  ncalls: 159342
  avg:    8.9e-5 seconds
  func:   build_candidates(): for p in grammar.productions...
}
{
  total:  14.722026 seconds
  ncalls: 159342
  avg:    9.2e-5 seconds
  func:   build_candidates
}
{
  total:  20.026039 seconds
  ncalls: 30404
  avg:    0.000659 seconds
  func:   recurse_appgenerator(): for new_result in gen
}
{
  total:  20.726906 seconds
  ncalls: 164658
  avg:    0.000126 seconds
  func:   process_candidate(): Channel((c) -> appgenerator(...)
}
{
  total:  24.160919 seconds
  ncalls: 159341
  avg:    0.000152 seconds
  func:   recurse_generator(): Channel((c) -> generator(...)
}
{
  total:  26.047448 seconds
  ncalls: 35331
  avg:    0.000737 seconds
  func:   recurse_appgenerator
}
{
  total:  35.002713 seconds
  ncalls: 10387
  avg:    0.00337 seconds
  func:   process_arrow(): for result in gen...
}
{
  total:  37.118013 seconds
  ncalls: 10387
  avg:    0.003574 seconds
  func:   process_arrow
}
{
  total:  134.027528 seconds
  ncalls: 164658
  avg:    0.000814 seconds
  func:   process_candidate
}
{
  total:  137.925832 seconds
  ncalls: 159341
  avg:    0.000866 seconds
  func:   recurse_generator
}
{
  total:  149.108083 seconds
  ncalls: 159342
  avg:    0.000936 seconds
  func:   process_candidates
}
 28.546985 seconds (232.75 M allocations: 12.560 GiB, 7.03% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID34783_20190722_T163729.json
```
