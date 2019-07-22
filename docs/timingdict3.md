output:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27011_20190719_T155300.json
  3.343927 seconds (20.41 M allocations: 1.086 GiB, 5.84% gc time)
{
  total:  7.8e-5 seconds
  ncalls: 681
  avg:    0.0 seconds
  func:   process_arrow(): append!(new_env, env)
}
{
  total:  8.6e-5 seconds
  ncalls: 2643
  avg:    0.0 seconds
  func:   lower_bound <= 0.0 && upper_bound > 0.0
}
{
  total:  0.000114 seconds
  ncalls: 714
  avg:    0.0 seconds
  func:   recurse_appgenerator(): Result(l, new_result.program, new_result.context)
}
{
  total:  0.000118 seconds
  ncalls: 681
  avg:    0.0 seconds
  func:   process_arrow(): new_env = Array{TypeField,1}([lhs])
}
{
  total:  0.000123 seconds
  ncalls: 2168
  avg:    0.0 seconds
  func:   Application
}
{
  total:  0.000327 seconds
  ncalls: 714
  avg:    0.0 seconds
  func:   recurse_appgenerator(): new_result.prior + prev_result.prior
}
{
  total:  0.000604 seconds
  ncalls: 12844
  avg:    0.0 seconds
  func:   Types.is_arrow(type)
}
{
  total:  0.000633 seconds
  ncalls: 12163
  avg:    0.0 seconds
  func:   build_candidates(): for vc in variable_candidates...
}
{
  total:  0.000704 seconds
  ncalls: 12691
  avg:    0.0 seconds
  func:   valid(candidate, upper_bound)
}
{
  total:  0.000884 seconds
  ncalls: 27649
  avg:    0.0 seconds
  func:   stop(upper_bound, depth)
}
{
  total:  0.001027 seconds
  ncalls: 2544
  avg:    0.0 seconds
  func:   !is_symmetrical(...)
}
{
  total:  0.003893 seconds
  ncalls: 132237
  avg:    0.0 seconds
  func:   all_invalid(): valid(c, upper_bound)
}
{
  total:  0.007341 seconds
  ncalls: 12637
  avg:    1.0e-6 seconds
  func:   function_arguments
}
{
  total:  0.011657 seconds
  ncalls: 12163
  avg:    1.0e-6 seconds
  func:   build_candidates(): final_candidates(candidates)
}
{
  total:  0.018689 seconds
  ncalls: 12163
  avg:    2.0e-6 seconds
  func:   build_candidates(): for (i, t) in enumerate(env)...
}
{
  total:  0.507621 seconds
  ncalls: 2168
  avg:    0.000234 seconds
  func:   recurse_appgenerator(): Channel((c) -> appgenerator(...)
}
{
  total:  0.848637 seconds
  ncalls: 2621
  avg:    0.000324 seconds
  func:   put!(channel, Result(0.0, func, context))
}
{
  total:  1.111741 seconds
  ncalls: 12163
  avg:    9.1e-5 seconds
  func:   build_candidates(): for p in grammar.productions...
}
{
  total:  1.154963 seconds
  ncalls: 12163
  avg:    9.5e-5 seconds
  func:   build_candidates
}
{
  total:  1.51207 seconds
  ncalls: 2168
  avg:    0.000697 seconds
  func:   recurse_appgenerator(): for new_result in gen
}
{
  total:  2.023174 seconds
  ncalls: 2544
  avg:    0.000795 seconds
  func:   recurse_appgenerator
}
{
  total:  2.199326 seconds
  ncalls: 12637
  avg:    0.000174 seconds
  func:   process_candidate(): Channel((c) -> appgenerator(...)
}
{
  total:  2.347095 seconds
  ncalls: 12162
  avg:    0.000193 seconds
  func:   recurse_generator(): Channel((c) -> generator(...)
}
{
  total:  2.611198 seconds
  ncalls: 681
  avg:    0.003834 seconds
  func:   process_arrow(): for result in gen...
}
{
  total:  3.114141 seconds
  ncalls: 681
  avg:    0.004573 seconds
  func:   process_arrow
}
{
  total:  9.767602 seconds
  ncalls: 12162
  avg:    0.000803 seconds
  func:   recurse_generator
}
{
  total:  9.896623 seconds
  ncalls: 12637
  avg:    0.000783 seconds
  func:   process_candidate
}
{
  total:  11.078308 seconds
  ncalls: 12163
  avg:    0.000911 seconds
  func:   process_candidates
}
  6.034333 seconds (26.95 M allocations: 1.405 GiB, 5.72% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID34578_20190722_T163428.json
```
