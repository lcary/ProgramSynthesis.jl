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

After eb1925f1fb64f37f592871449a1f1fb41186162f:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  4.420796 seconds (11.65 M allocations: 581.888 MiB, 4.88% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID4111_20190722_T084137.json
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  3.251178 seconds (8.94 M allocations: 446.567 MiB, 5.56% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID8389_20190722_T093050.json
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.212398 seconds (3.15 M allocations: 157.087 MiB, 3.71% gc time)
  ^@time for result in generator(args...)
  3.595471 seconds (9.27 M allocations: 462.037 MiB, 4.79% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID13758_20190722_T110451.json
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

After eb1925f1fb64f37f592871449a1f1fb41186162f:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
5.206285 seconds (34.00 M allocations: 1.817 GiB, 6.67% gc time)
^@time for result in generator(args...)
7.649697 seconds (40.73 M allocations: 2.145 GiB, 6.44% gc time)
^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID4255_20190722_T084304.json
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
  3.134039 seconds (22.40 M allocations: 1.187 GiB, 6.37% gc time)
  ^@time for result in generator(args...)
  5.105741 seconds (27.75 M allocations: 1.447 GiB, 6.58% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID8134_20190722_T092919.json
```

after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
  3.287473 seconds (22.48 M allocations: 1.193 GiB, 7.67% gc time)
  ^@time for result in generator(args...)
  5.613945 seconds (28.05 M allocations: 1.464 GiB, 7.00% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID14158_20190722_T110657.json
```

ocaml_request_enumeration_PID27034_20190719_T155304
---------------------------------------------------

>6min in julia, <2s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations (note, running with response_enumeration_PID19906_20190720_T195112 in parallel):
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27034_20190719_T155304.json
@time for result in generator(args...)
362.197598 seconds (1.83 G allocations: 99.171 GiB, 3.27% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19808_20190720_T195039.json
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27034_20190719_T155304.json
129.488836 seconds (1.48 G allocations: 79.780 GiB, 6.62% gc time)
  ^@time for result in generator(args...)
131.618129 seconds (1.48 G allocations: 80.060 GiB, 6.60% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID9595_20190722_T094402.json
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27034_20190719_T155304.json
140.774280 seconds (1.48 G allocations: 79.815 GiB, 7.96% gc time)
  ^@time for result in generator(args...)
143.325902 seconds (1.48 G allocations: 80.105 GiB, 7.92% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID14365_20190722_T111155.json
```

response_enumeration_PID19906_20190720_T195112
----------------------------------------------

>6min in julia, 8s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations (note, running with ocaml_request_enumeration_PID27034_20190719_T155304 in parallel):
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27039_20190719_T155306.json
@time for result in generator(args...)
381.788591 seconds (1.93 G allocations: 104.542 GiB, 3.36% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19906_20190720_T195112.json
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27039_20190719_T155306.json
364.932885 seconds (4.13 G allocations: 223.375 GiB, 8.27% gc time)
  ^@time for result in generator(args...)
366.894658 seconds (4.14 G allocations: 223.641 GiB, 8.25% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID9596_20190722_T094758.json
```
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27039_20190719_T155306.json
356.781747 seconds (3.97 G allocations: 214.368 GiB, 9.03% gc time)
  ^@time for result in generator(args...)
358.796908 seconds (3.97 G allocations: 214.634 GiB, 9.01% gc time)
  ^@time run_enumeration(request_message_file)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID9697_20190722_T095946.json
```
why the regression in G allocations despite speedup?

benchmark1.jl
-------------

benchmarks before optimizations:
```
julia --project perf/benchmark1.jl
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
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
julia --project perf/benchmark1.jl
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
  times: Array{Float64}((332,)) [1.26544e7, 1.28999e7, 1.29208e7, 1.29214e7, 1.29253e7, 1.29364e7, 1.29449e7, 1.29811e7, 1.29868e7, 1.30101e7  …  1.80842e7, 1.81281e7, 1.84248e7, 1.84918e7, 1.86595e7, 1.94852e7, 1.95903e7, 2.00598e7, 2.35085e7, 5.1643e7]
  gctimes: Array{Float64}((332,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.06443e6, 1.58309e6, 3.37346e6, 1.84542e6, 2.46828e6, 2.44111e6, 1.92302e6, 1.62648e6, 9.32717e6, 3.8113e7]
  memory: Int64 8241952
  allocs: Int64 140999
minimum:
TrialEstimate(12.654 ms)
median:
TrialEstimate(14.856 ms)
mean:
TrialEstimate(15.055 ms)
maximum:
TrialEstimate(51.643 ms)
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
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
  times: Array{Float64}((333,)) [1.29793e7, 1.30451e7, 1.30623e7, 1.30847e7, 1.30959e7, 1.3102e7, 1.31174e7, 1.31503e7, 1.31612e7, 1.31692e7  …  1.86704e7, 1.87735e7, 1.92232e7, 1.93048e7, 2.06176e7, 2.11786e7, 2.20229e7, 2.71559e7, 3.02941e7, 5.22205e7]
  gctimes: Array{Float64}((333,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.88752e6, 2.38069e6, 2.04305e6, 0.0, 0.0, 3.61256e6, 2.60829e6, 0.0, 1.43956e7, 3.70866e7]
  memory: Int64 8244784
  allocs: Int64 140996
minimum:
TrialEstimate(12.979 ms)
median:
TrialEstimate(14.435 ms)
mean:
TrialEstimate(15.042 ms)
maximum:
TrialEstimate(52.220 ms)
```

benchmark2.jl
-------------

benchmarks before optimizations:
```
julia --project perf/benchmark2.jl
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
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
julia --project perf/benchmark2.jl
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
  times: Array{Float64}((3,)) [1.70347e9, 1.71891e9, 1.79012e9]
  gctimes: Array{Float64}((3,)) [1.11592e8, 9.01832e7, 1.21307e8]
  memory: Int64 1051785648
  allocs: Int64 18108981
minimum:
TrialEstimate(1.703 s)
median:
TrialEstimate(1.719 s)
mean:
TrialEstimate(1.738 s)
maximum:
TrialEstimate(1.790 s)
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
❯ julia --project perf/benchmark2.jl
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
  times: Array{Float64}((3,)) [1.68676e9, 1.7012e9, 1.7605e9]
  gctimes: Array{Float64}((3,)) [1.16644e8, 1.12255e8, 1.4221e8]
  memory: Int64 1052248784
  allocs: Int64 18109245
minimum:
TrialEstimate(1.687 s)
median:
TrialEstimate(1.701 s)
mean:
TrialEstimate(1.716 s)
maximum:
TrialEstimate(1.761 s)
```

benchmark3.jl
-------------

Benchmarks the performance of build_candidates.

```
julia --project perf/benchmark3.jl
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
  times: Array{Float64}((6280,)) [741792.0, 741936.0, 742018.0, 742038.0, 742101.0, 742228.0, 742269.0, 742534.0, 742637.0, 742656.0  …  3.27623e6, 3.33293e6, 3.35902e6, 3.35956e6, 3.50051e6, 3.51292e6, 3.5164e6, 3.54105e6, 9.71048e6, 3.71e7]
  gctimes: Array{Float64}((6280,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.35429e6, 2.56008e6, 2.5792e6, 2.57218e6, 2.71629e6, 2.67197e6, 2.72993e6, 0.0, 8.8163e6, 3.62721e7]
  memory: Int64 109808
  allocs: Int64 1942
minimum:
TrialEstimate(741.792 μs)
median:
TrialEstimate(750.213 μs)
mean:
TrialEstimate(794.527 μs)
maximum:
TrialEstimate(37.100 ms)
```
After 01b5ca3965de8feecb447602c156c61d264ad2ce:
```
❯ julia --project perf/benchmark3.jl
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
  times: Array{Float64}((10000,)) [145130.0, 145772.0, 146169.0, 146224.0, 146230.0, 146312.0, 146338.0, 146361.0, 146384.0, 146391.0  …  2.75971e6, 2.77252e6, 2.82006e6, 2.92564e6, 2.95226e6, 2.97624e6, 3.17119e6, 3.23846e6, 9.30012e6, 3.63502e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.55102e6, 2.62034e6, 2.58522e6, 2.72215e6, 2.76736e6, 2.78584e6, 2.99101e6, 3.02673e6, 9.09118e6, 3.60922e7]
  memory: Int64 109520
  allocs: Int64 1924
minimum:
TrialEstimate(145.130 μs)
median:
TrialEstimate(151.544 μs)
mean:
TrialEstimate(175.081 μs)
maximum:
TrialEstimate(36.350 ms)
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
julia --project perf/benchmark3.jl
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
  times: Array{Float64}((10000,)) [75932.0, 76037.0, 76067.0, 76115.0, 76118.0, 76122.0, 76134.0, 76139.0, 76140.0, 76171.0  …  2.41357e6, 2.43576e6, 2.44404e6, 2.44711e6, 2.48947e6, 2.53099e6, 2.66868e6, 2.73007e6, 1.00733e7, 3.57478e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.31298e6, 2.33234e6, 2.22509e6, 2.34787e6, 2.38921e6, 2.40889e6, 2.55405e6, 2.49317e6, 9.9623e6, 3.56374e7]
  memory: Int64 75552
  allocs: Int64 1336
minimum:
TrialEstimate(75.932 μs)
median:
TrialEstimate(78.283 μs)
mean:
TrialEstimate(93.198 μs)
maximum:
TrialEstimate(35.748 ms)
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
❯ julia --project perf/benchmark3.jl
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
  times: Array{Float64}((10000,)) [76981.0, 77117.0, 77132.0, 77161.0, 77166.0, 77206.0, 77214.0, 77214.0, 77220.0, 77226.0  …  2.26844e6, 2.32966e6, 2.42411e6, 2.46404e6, 2.48227e6, 2.52354e6, 2.53278e6, 2.58215e6, 9.58828e6, 3.53042e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.16398e6, 2.23623e6, 2.32995e6, 2.36367e6, 2.38445e6, 2.41705e6, 2.43645e6, 2.46467e6, 9.47537e6, 3.51923e7]
  memory: Int64 75552
  allocs: Int64 1336
minimum:
TrialEstimate(76.981 μs)
median:
TrialEstimate(78.790 μs)
mean:
TrialEstimate(92.582 μs)
maximum:
TrialEstimate(35.304 ms)
```
