Benchmark
=========

Julia repl w/ `julia --project`:
```
f = "../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json"
using ProgramSynthesis
run_enumeration(f)
using BenchmarkTools
@benchmark run_enumeration(f)
```
Output
```
...
BenchmarkTools.Trial:
  memory estimate:  12.35 MiB
  allocs estimate:  222242
  --------------
  minimum time:     56.051 ms (0.00% GC)
  median time:      63.777 ms (3.82% GC)
  mean time:        64.103 ms (3.82% GC)
  maximum time:     101.785 ms (42.98% GC)
  --------------
  samples:          78
  evals/sample:     1
```
