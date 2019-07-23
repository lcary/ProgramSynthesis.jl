output:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27017_20190719_T155300.json
 14.788860 seconds (124.29 M allocations: 6.713 GiB, 6.91% gc time)
{
  total:  0.00053 seconds
  ncalls: 4199
  avg:    0.0 seconds
  func:   process_arrow(): append!(new_env, env)
}
{
  total:  0.00068 seconds
  ncalls: 19044
  avg:    0.0 seconds
  func:   lower_bound <= 0.0 && upper_bound > 0.0
}
{
  total:  0.000788 seconds
  ncalls: 4199
  avg:    0.0 seconds
  func:   process_arrow(): new_env = Array{TypeField,1}([lhs])
}
{
  total:  0.00101 seconds
  ncalls: 15601
  avg:    0.0 seconds
  func:   Application
}
{
  total:  0.001088 seconds
  ncalls: 5775
  avg:    0.0 seconds
  func:   recurse_appgenerator(): Result(l, new_result.program, new_result.context)
}
{
  total:  0.002311 seconds
  ncalls: 5775
  avg:    0.0 seconds
  func:   recurse_appgenerator(): new_result.prior + prev_result.prior
}
{
  total:  0.004373 seconds
  ncalls: 91043
  avg:    0.0 seconds
  func:   Types.is_arrow(type)
}
{
  total:  0.004381 seconds
  ncalls: 86844
  avg:    0.0 seconds
  func:   build_candidates(): for vc in variable_candidates...
}
{
  total:  0.005468 seconds
  ncalls: 90397
  avg:    0.0 seconds
  func:   valid(candidate, upper_bound)
}
{
  total:  0.006452 seconds
  ncalls: 196930
  avg:    0.0 seconds
  func:   stop(upper_bound, depth)
}
{
  total:  0.007928 seconds
  ncalls: 18620
  avg:    0.0 seconds
  func:   !is_symmetrical(...)
}
{
  total:  0.027997 seconds
  ncalls: 931981
  avg:    0.0 seconds
  func:   all_invalid(): valid(c, upper_bound)
}
{
  total:  0.065774 seconds
  ncalls: 86844
  avg:    1.0e-6 seconds
  func:   build_candidates(): final_candidates(candidates)
}
{
  total:  0.066395 seconds
  ncalls: 90286
  avg:    1.0e-6 seconds
  func:   function_arguments
}
{
  total:  0.133574 seconds
  ncalls: 86844
  avg:    2.0e-6 seconds
  func:   build_candidates(): for (i, t) in enumerate(env)...
}
{
  total:  3.051641 seconds
  ncalls: 15601
  avg:    0.000196 seconds
  func:   recurse_appgenerator(): Channel((c) -> appgenerator(...)
}
{
  total:  3.815399 seconds
  ncalls: 18945
  avg:    0.000201 seconds
  func:   put!(channel, Result(0.0, func, context))
}
{
  total:  7.632095 seconds
  ncalls: 86844
  avg:    8.8e-5 seconds
  func:   build_candidates(): for p in grammar.productions...
}
{
  total:  7.920847 seconds
  ncalls: 86844
  avg:    9.1e-5 seconds
  func:   build_candidates
}
{
  total:  10.641464 seconds
  ncalls: 15601
  avg:    0.000682 seconds
  func:   recurse_appgenerator(): for new_result in gen
}
{
  total:  11.823128 seconds
  ncalls: 90286
  avg:    0.000131 seconds
  func:   process_candidate(): Channel((c) -> appgenerator(...)
}
{
  total:  13.278982 seconds
  ncalls: 86843
  avg:    0.000153 seconds
  func:   recurse_generator(): Channel((c) -> generator(...)
}
{
  total:  13.718774 seconds
  ncalls: 18620
  avg:    0.000737 seconds
  func:   recurse_appgenerator
}
{
  total:  14.432323 seconds
  ncalls: 4199
  avg:    0.003437 seconds
  func:   process_arrow(): for result in gen...
}
{
  total:  15.481962 seconds
  ncalls: 4199
  avg:    0.003687 seconds
  func:   process_arrow
}
{
  total:  72.431116 seconds
  ncalls: 90286
  avg:    0.000802 seconds
  func:   process_candidate
}
{
  total:  73.561918 seconds
  ncalls: 86843
  avg:    0.000847 seconds
  func:   recurse_generator
}
{
  total:  80.544738 seconds
  ncalls: 86844
  avg:    0.000927 seconds
  func:   process_candidates
}
 17.473700 seconds (130.83 M allocations: 7.031 GiB, 6.64% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID34729_20190722_T163602.json
```
