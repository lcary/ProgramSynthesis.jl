output:
```
julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
  3.511999 seconds (22.19 M allocations: 1.179 GiB, 6.02% gc time)
{
  total:  8.6e-5 seconds
  ncalls: 2850
  avg:    0.0 seconds
  func:   lower_bound <= 0.0 && upper_bound > 0.0
}
{
  total:  9.6e-5 seconds
  ncalls: 829
  avg:    0.0 seconds
  func:   process_arrow(): append!(new_env, env)
}
{
  total:  0.000121 seconds
  ncalls: 2389
  avg:    0.0 seconds
  func:   Application
}
{
  total:  0.000132 seconds
  ncalls: 728
  avg:    0.0 seconds
  func:   recurse_appgenerator(): Result(l, new_result.program, new_result.context)
}
{
  total:  0.000154 seconds
  ncalls: 829
  avg:    0.0 seconds
  func:   process_arrow(): new_env = Array{TypeField,1}([lhs])
}
{
  total:  0.000258 seconds
  ncalls: 728
  avg:    0.0 seconds
  func:   recurse_appgenerator(): new_result.prior + prev_result.prior
}
{
  total:  0.000697 seconds
  ncalls: 12964
  avg:    0.0 seconds
  func:   build_candidates(): for vc in variable_candidates...
}
{
  total:  0.000733 seconds
  ncalls: 13491
  avg:    0.0 seconds
  func:   valid(candidate, upper_bound)
}
{
  total:  0.000864 seconds
  ncalls: 13793
  avg:    0.0 seconds
  func:   Types.is_arrow(type)
}
{
  total:  0.000895 seconds
  ncalls: 29606
  avg:    0.0 seconds
  func:   stop(upper_bound, depth)
}
{
  total:  0.000964 seconds
  ncalls: 2785
  avg:    0.0 seconds
  func:   !is_symmetrical(...)
}
{
  total:  0.004019 seconds
  ncalls: 142070
  avg:    0.0 seconds
  func:   all_invalid(): valid(c, upper_bound)
}
{
  total:  0.007537 seconds
  ncalls: 13424
  avg:    1.0e-6 seconds
  func:   function_arguments
}
{
  total:  0.013979 seconds
  ncalls: 12964
  avg:    1.0e-6 seconds
  func:   build_candidates(): final_candidates(candidates)
}
{
  total:  0.022869 seconds
  ncalls: 12964
  avg:    2.0e-6 seconds
  func:   build_candidates(): for (i, t) in enumerate(env)...
}
{
  total:  0.474764 seconds
  ncalls: 2389
  avg:    0.000199 seconds
  func:   recurse_appgenerator(): Channel((c) -> appgenerator(...)
}
{
  total:  1.050694 seconds
  ncalls: 2834
  avg:    0.000371 seconds
  func:   put!(channel, Result(0.0, func, context))
}
{
  total:  1.142419 seconds
  ncalls: 12964
  avg:    8.8e-5 seconds
  func:   build_candidates(): for p in grammar.productions...
}
{
  total:  1.19217 seconds
  ncalls: 12964
  avg:    9.2e-5 seconds
  func:   build_candidates
}
{
  total:  1.992953 seconds
  ncalls: 2389
  avg:    0.000834 seconds
  func:   recurse_appgenerator(): for new_result in gen
}
{
  total:  2.397269 seconds
  ncalls: 13424
  avg:    0.000179 seconds
  func:   process_candidate(): Channel((c) -> appgenerator(...)
}
{
  total:  2.471116 seconds
  ncalls: 2785
  avg:    0.000887 seconds
  func:   recurse_appgenerator
}
{
  total:  2.48186 seconds
  ncalls: 12963
  avg:    0.000191 seconds
  func:   recurse_generator(): Channel((c) -> generator(...)
}
{
  total:  3.331102 seconds
  ncalls: 829
  avg:    0.004018 seconds
  func:   process_arrow(): for result in gen...
}
{
  total:  3.833561 seconds
  ncalls: 829
  avg:    0.004624 seconds
  func:   process_arrow
}
{
  total:  10.653674 seconds
  ncalls: 13424
  avg:    0.000794 seconds
  func:   process_candidate
}
{
  total:  10.687167 seconds
  ncalls: 12963
  avg:    0.000824 seconds
  func:   recurse_generator
}
{
  total:  11.873541 seconds
  ncalls: 12964
  avg:    0.000916 seconds
  func:   process_candidates
}
  5.961716 seconds (28.18 M allocations: 1.471 GiB, 5.77% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID34526_20190722_T163331.json
```
