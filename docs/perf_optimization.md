performance optimization
========================

ocaml_request_enumeration_PID26993_20190719_T155300
---------------------------------------------------

6 seconds in julia, <1s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
@time for result in generator(args...)
1.795149 seconds (4.68 M allocations: 234.763 MiB, 6.03% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19706_20190720_T194350.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.781357 seconds (4.68 M allocations: 234.767 MiB, 6.08% gc time)
  ^@time for result in generator(args...)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID21770_20190721_T124433.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.877394 seconds (4.68 M allocations: 234.870 MiB, 5.75% gc time)
  ^@time for result in generator(args...)
  4.740023 seconds (12.15 M allocations: 608.340 MiB, 5.73% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID27166_20190721_T142106.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.751759 seconds (4.68 M allocations: 234.285 MiB, 3.85% gc time)
  ^@time for result in generator(args...)
  4.572324 seconds (12.15 M allocations: 607.935 MiB, 4.99% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID27208_20190721_T142113.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.765500 seconds (4.68 M allocations: 234.285 MiB, 3.71% gc time)
  ^@time for result in generator(args...)
  4.563093 seconds (12.15 M allocations: 607.935 MiB, 4.80% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID27255_20190721_T142119.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.738592 seconds (4.68 M allocations: 234.285 MiB, 3.73% gc time)
  ^@time for result in generator(args...)
  4.507864 seconds (12.15 M allocations: 607.935 MiB, 4.84% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID27300_20190721_T142125.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.810187 seconds (4.68 M allocations: 234.285 MiB, 3.39% gc time)
  ^@time for result in generator(args...)
  4.599063 seconds (12.15 M allocations: 607.935 MiB, 4.73% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID27356_20190721_T142132.json
```
benchmarks:
```
julia --project bin/benchmark1.jl
BenchmarkTools.Trial
  params: BenchmarkTools.Parameters
    seconds: Float64 5.0
    samples: Int64 10000
    evals: Int64 1
    overhead: Float64 0.0
    gctrial: Bool true
    gcsample: Bool false
    time_tolerance: Float64 0.05
    memory_tolerance: Float64 0.01
  times: Array{Float64}((101,)) [4.45598e7, 4.46792e7, 4.47165e7, 4.48056e7, 4.48516e7, 4.49477e7, 4.49791e7, 4.50114e7, 4.50185e7, 4.5093e7  …  5.19742e7, 5.29628e7, 5.35521e7, 5.49511e7, 5.57328e7, 5.80471e7, 5.81774e7, 6.73784e7, 8.06404e7, 8.66193e7]
  gctimes: Array{Float64}((101,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  0.0, 2.08221e6, 0.0, 0.0, 0.0, 2.1508e6, 9.20818e6, 2.59508e6, 2.64918e6, 4.05846e7]
  memory: Int64 12950576
  allocs: Int64 222208
minimum:
TrialEstimate(44.560 ms)
median:
TrialEstimate(48.271 ms)
mean:
TrialEstimate(49.654 ms)
maximum:
TrialEstimate(86.619 ms)
```

ocaml_request_enumeration_PID27008_20190719_T155300
---------------------------------------------------

12 seconds in julia, <1s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
@time for result in generator(args...)
8.124766 seconds (34.59 M allocations: 1.840 GiB, 4.50% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19756_20190720_T194412.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
  8.062860 seconds (34.59 M allocations: 1.841 GiB, 4.59% gc time)
  ^@time for result in generator(args...)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID21820_20190721_T124512.json
```
benchmarks:
```
julia --project bin/benchmark2.jl
BenchmarkTools.Trial
  params: BenchmarkTools.Parameters
    seconds: Float64 5.0
    samples: Int64 10000
    evals: Int64 1
    overhead: Float64 0.0
    gctrial: Bool true
    gcsample: Bool false
    time_tolerance: Float64 0.05
    memory_tolerance: Float64 0.01
  times: Array{Float64}((1,)) [5.92397e9]
  gctimes: Array{Float64}((1,)) [2.60128e8]
  memory: Int64 1670782480
  allocs: Int64 28741776
minimum:
TrialEstimate(5.924 s)
median:
TrialEstimate(5.924 s)
mean:
TrialEstimate(5.924 s)
maximum:
TrialEstimate(5.924 s)
```

ocaml_request_enumeration_PID27034_20190719_T155304
---------------------------------------------------

>6min seconds (aborted) in julia, <2s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27034_20190719_T155304.json
@time for result in generator(args...)
362.197598 seconds (1.83 G allocations: 99.171 GiB, 3.27% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19808_20190720_T195039.json
```

response_enumeration_PID19906_20190720_T195112
----------------------------------------------

>6min seconds (aborted) in julia, 8s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27039_20190719_T155306.json
@time for result in generator(args...)
381.788591 seconds (1.93 G allocations: 104.542 GiB, 3.36% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19906_20190720_T195112.json
```
