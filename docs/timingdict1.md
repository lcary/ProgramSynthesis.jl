output:
```
julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
  3.640443 seconds (22.19 M allocations: 1.179 GiB, 5.68% gc time)
{
  total:  8.9e-5 seconds
  ncalls: 2850
  avg:    0.0 seconds
  func:   lower_bound <= 0.0 && upper_bound > 0.0
}
{
  total:  0.000103 seconds
  ncalls: 829
  avg:    0.0 seconds
  func:   process_arrow(): append!(new_env, env)
}
{
  total:  0.000136 seconds
  ncalls: 2389
  avg:    0.0 seconds
  func:   Application
}
{
  total:  0.000136 seconds
  ncalls: 728
  avg:    0.0 seconds
  func:   recurse_appgenerator(): Result(l, new_result.program, new_result.context)
}
{
  total:  0.000166 seconds
  ncalls: 829
  avg:    0.0 seconds
  func:   process_arrow(): new_env = Array{TypeField,1}([lhs])
}
{
  total:  0.000315 seconds
  ncalls: 728
  avg:    0.0 seconds
  func:   recurse_appgenerator(): new_result.prior + prev_result.prior
}
{
  total:  0.000607 seconds
  ncalls: 13793
  avg:    0.0 seconds
  func:   Types.is_arrow(type)
}
{
  total:  0.000684 seconds
  ncalls: 12964
  avg:    0.0 seconds
  func:   build_candidates(): for vc in variable_candidates...
}
{
  total:  0.000743 seconds
  ncalls: 13491
  avg:    0.0 seconds
  func:   valid(candidate, upper_bound)
}
{
  total:  0.000901 seconds
  ncalls: 29606
  avg:    0.0 seconds
  func:   stop(upper_bound, depth)
}
{
  total:  0.00107 seconds
  ncalls: 2785
  avg:    0.0 seconds
  func:   !is_symmetrical(...)
}
{
  total:  0.004298 seconds
  ncalls: 142070
  avg:    0.0 seconds
  func:   all_invalid(): valid(c, upper_bound)
}
{
  total:  0.008137 seconds
  ncalls: 13424
  avg:    1.0e-6 seconds
  func:   function_arguments
}
{
  total:  0.018256 seconds
  ncalls: 12964
  avg:    1.0e-6 seconds
  func:   build_candidates(): final_candidates(candidates)
}
{
  total:  0.024993 seconds
  ncalls: 12964
  avg:    2.0e-6 seconds
  func:   build_candidates(): for (i, t) in enumerate(env)...
}
{
  total:  0.483216 seconds
  ncalls: 2389
  avg:    0.000202 seconds
  func:   recurse_appgenerator(): Channel((c) -> appgenerator(...)
}
{
  total:  1.097643 seconds
  ncalls: 2834
  avg:    0.000387 seconds
  func:   put!(channel, Result(0.0, func, context))
}
{
  total:  1.16794 seconds
  ncalls: 12964
  avg:    9.0e-5 seconds
  func:   build_candidates(): for p in grammar.productions...
}
{
  total:  1.225034 seconds
  ncalls: 12964
  avg:    9.4e-5 seconds
  func:   build_candidates
}
{
  total:  2.091026 seconds
  ncalls: 2389
  avg:    0.000875 seconds
  func:   recurse_appgenerator(): for new_result in gen
}
{
  total:  2.47186 seconds
  ncalls: 13424
  avg:    0.000184 seconds
  func:   process_candidate(): Channel((c) -> appgenerator(...)
}
{
  total:  2.546811 seconds
  ncalls: 12963
  avg:    0.000196 seconds
  func:   recurse_generator(): Channel((c) -> generator(...)
}
{
  total:  2.577896 seconds
  ncalls: 2785
  avg:    0.000926 seconds
  func:   recurse_appgenerator
}
{
  total:  3.430843 seconds
  ncalls: 829
  avg:    0.004139 seconds
  func:   process_arrow(): for result in gen...
}
{
  total:  3.946307 seconds
  ncalls: 829
  avg:    0.00476 seconds
  func:   process_arrow
}
{
  total:  11.057667 seconds
  ncalls: 13424
  avg:    0.000824 seconds
  func:   process_candidate
}
{
  total:  11.090214 seconds
  ncalls: 12963
  avg:    0.000856 seconds
  func:   recurse_generator
}
{
  total:  12.311691 seconds
  ncalls: 12964
  avg:    0.00095 seconds
  func:   process_candidates
}
  6.149634 seconds (28.18 M allocations: 1.471 GiB, 5.77% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID34100_20190722_T163041.json
```
