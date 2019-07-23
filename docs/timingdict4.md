output:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27014_20190719_T155300.json
 12.370701 seconds (100.97 M allocations: 5.445 GiB, 6.63% gc time)
{
  total:  0.000469 seconds
  ncalls: 3687
  avg:    0.0 seconds
  func:   process_arrow(): append!(new_env, env)
}
{
  total:  0.00052 seconds
  ncalls: 14876
  avg:    0.0 seconds
  func:   lower_bound <= 0.0 && upper_bound > 0.0
}
{
  total:  0.000715 seconds
  ncalls: 3687
  avg:    0.0 seconds
  func:   process_arrow(): new_env = Array{TypeField,1}([lhs])
}
{
  total:  0.000731 seconds
  ncalls: 4167
  avg:    0.0 seconds
  func:   recurse_appgenerator(): Result(l, new_result.program, new_result.context)
}
{
  total:  0.000768 seconds
  ncalls: 12274
  avg:    0.0 seconds
  func:   Application
}
{
  total:  0.001721 seconds
  ncalls: 4167
  avg:    0.0 seconds
  func:   recurse_appgenerator(): new_result.prior + prev_result.prior
}
{
  total:  0.003399 seconds
  ncalls: 72950
  avg:    0.0 seconds
  func:   Types.is_arrow(type)
}
{
  total:  0.003856 seconds
  ncalls: 69263
  avg:    0.0 seconds
  func:   build_candidates(): for vc in variable_candidates...
}
{
  total:  0.004301 seconds
  ncalls: 72162
  avg:    0.0 seconds
  func:   valid(candidate, upper_bound)
}
{
  total:  0.00511 seconds
  ncalls: 157088
  avg:    0.0 seconds
  func:   stop(upper_bound, depth)
}
{
  total:  0.005974 seconds
  ncalls: 14644
  avg:    0.0 seconds
  func:   !is_symmetrical(...)
}
{
  total:  0.022461 seconds
  ncalls: 748526
  avg:    0.0 seconds
  func:   all_invalid(): valid(c, upper_bound)
}
{
  total:  0.054168 seconds
  ncalls: 71864
  avg:    1.0e-6 seconds
  func:   function_arguments
}
{
  total:  0.057672 seconds
  ncalls: 69263
  avg:    1.0e-6 seconds
  func:   build_candidates(): final_candidates(candidates)
}
{
  total:  0.11469 seconds
  ncalls: 69263
  avg:    2.0e-6 seconds
  func:   build_candidates(): for (i, t) in enumerate(env)...
}
{
  total:  2.324822 seconds
  ncalls: 12274
  avg:    0.000189 seconds
  func:   recurse_appgenerator(): Channel((c) -> appgenerator(...)
}
{
  total:  3.070907 seconds
  ncalls: 14811
  avg:    0.000207 seconds
  func:   put!(channel, Result(0.0, func, context))
}
{
  total:  6.143043 seconds
  ncalls: 69263
  avg:    8.9e-5 seconds
  func:   build_candidates(): for p in grammar.productions...
}
{
  total:  6.395047 seconds
  ncalls: 69263
  avg:    9.2e-5 seconds
  func:   build_candidates
}
{
  total:  8.075054 seconds
  ncalls: 12274
  avg:    0.000658 seconds
  func:   recurse_appgenerator(): for new_result in gen
}
{
  total:  9.467429 seconds
  ncalls: 71864
  avg:    0.000132 seconds
  func:   process_candidate(): Channel((c) -> appgenerator(...)
}
{
  total:  10.419716 seconds
  ncalls: 14644
  avg:    0.000712 seconds
  func:   recurse_appgenerator
}
{
  total:  10.577115 seconds
  ncalls: 69262
  avg:    0.000153 seconds
  func:   recurse_generator(): Channel((c) -> generator(...)
}
{
  total:  12.952094 seconds
  ncalls: 3687
  avg:    0.003513 seconds
  func:   process_arrow(): for result in gen...
}
{
  total:  13.940109 seconds
  ncalls: 3687
  avg:    0.003781 seconds
  func:   process_arrow
}
{
  total:  58.323171 seconds
  ncalls: 71864
  avg:    0.000812 seconds
  func:   process_candidate
}
{
  total:  58.954233 seconds
  ncalls: 69262
  avg:    0.000851 seconds
  func:   recurse_generator
}
{
  total:  64.873432 seconds
  ncalls: 69263
  avg:    0.000937 seconds
  func:   process_candidates
}
 14.738214 seconds (106.96 M allocations: 5.737 GiB, 6.41% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID34629_20190722_T163513.json
```
