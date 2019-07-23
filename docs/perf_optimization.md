performance optimization
========================

ocaml_request_enumeration_PID26993_20190719_T155300
---------------------------------------------------

tested with:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
```

total originally 6 seconds in julia, <1s in ocaml (see julia_v_ocaml_speedtest2.txt)

before optimizations, results for T1 `@time for result in generator(args...)`:
```
1.795149 seconds (4.68 M allocations: 234.763 MiB, 6.03% gc time)
1.781357 seconds (4.68 M allocations: 234.767 MiB, 6.08% gc time)
1.877394 seconds (4.68 M allocations: 234.870 MiB, 5.75% gc time)
1.751759 seconds (4.68 M allocations: 234.285 MiB, 3.85% gc time)
1.765500 seconds (4.68 M allocations: 234.285 MiB, 3.71% gc time)
1.738592 seconds (4.68 M allocations: 234.285 MiB, 3.73% gc time)
1.810187 seconds (4.68 M allocations: 234.285 MiB, 3.39% gc time)
```
results for T2 `@time run_enumeration(request_message_file)`:
```
4.740023 seconds (12.15 M allocations: 608.340 MiB, 5.73% gc time)
4.572324 seconds (12.15 M allocations: 607.935 MiB, 4.99% gc time)
4.563093 seconds (12.15 M allocations: 607.935 MiB, 4.80% gc time)
4.507864 seconds (12.15 M allocations: 607.935 MiB, 4.84% gc time)
4.599063 seconds (12.15 M allocations: 607.935 MiB, 4.73% gc time)
```

After eb1925f1fb64f37f592871449a1f1fb41186162f, T2:
```
4.420796 seconds (11.65 M allocations: 581.888 MiB, 4.88% gc time)
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7, T2:
```
3.251178 seconds (8.94 M allocations: 446.567 MiB, 5.56% gc time)
```
after 6a4a3a90b14e3379360b477060ac184b04080afb, T1 and T2:
```
1.212398 seconds (3.15 M allocations: 157.087 MiB, 3.71% gc time)
3.595471 seconds (9.27 M allocations: 462.037 MiB, 4.79% gc time)
```
after 9149c967743168e6dd61b9cadc497c179d4e14c7, T1 and T2:
```
1.168213 seconds (3.18 M allocations: 158.357 MiB, 3.49% gc time)
3.573195 seconds (9.29 M allocations: 462.875 MiB, 5.00% gc time)
```
after fda2757a72796255bbd660e65d54d837d4bc26be, T2:
```
3.298817 seconds (8.63 M allocations: 430.709 MiB, 4.89% gc time)
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1, T1 and T2:
```
0.254832 seconds (658.38 k allocations: 34.181 MiB, 2.57% gc time)
3.502173 seconds (8.18 M allocations: 407.674 MiB, 5.59% gc time)
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b, T2:
```
3.319275 seconds (7.94 M allocations: 400.044 MiB, 5.16% gc time)
```
after a94520432b1e99ebaddab8615db0749598401ebe, T1 and T2:
```
0.953247 seconds (1.89 M allocations: 98.253 MiB, 2.37% gc time)
3.386845 seconds (7.95 M allocations: 400.740 MiB, 4.64% gc time)
```
after d75133b4ec47360e41690b173d4ac4959d8369f5, T1 and T2:
```
0.950576 seconds (1.81 M allocations: 94.059 MiB, 2.40% gc time)
3.384675 seconds (8.03 M allocations: 404.340 MiB, 4.34% gc time)
```
after fa4fa5c713463bf395af2b034031aefd816ae24e, T1 and T2:
```
0.883232 seconds (1.75 M allocations: 90.767 MiB, 2.65% gc time)
3.257085 seconds (7.99 M allocations: 401.812 MiB, 4.81% gc time)
```
5d6f56238f9399a566cb5051775e7bb55a785283:
```
0.884871 seconds (1.65 M allocations: 86.247 MiB, 1.99% gc time)
3.396977 seconds (7.83 M allocations: 393.275 MiB, 4.63% gc time)
```
f8dd50783c7151f7ba0edadfc5a47fbfc81b7373:
```
2.057143 seconds (13.19 M allocations: 736.446 MiB, 5.53% gc time)
4.225431 seconds (18.66 M allocations: 1008.039 MiB, 5.73% gc time)
```
f8dd50783c7151f7ba0edadfc5a47fbfc81b7373:
```
0.955808 seconds (1.65 M allocations: 86.247 MiB, 1.96% gc time)
3.451366 seconds (7.66 M allocations: 385.078 MiB, 4.40% gc time)
```
3fd03844c32bc6ade16e0899c58cdcf9e4ca1788:
```
0.915033 seconds (1.59 M allocations: 83.689 MiB, 2.18% gc time)
3.359585 seconds (7.61 M allocations: 382.513 MiB, 4.64% gc time)
```
9a0ec2f:
```
0.873928 seconds (1.59 M allocations: 83.611 MiB, 2.33% gc time)
3.276473 seconds (7.60 M allocations: 382.438 MiB, 4.57% gc time)
```
8345b58:
```
0.882052 seconds (1.55 M allocations: 81.487 MiB, 2.29% gc time)
3.293184 seconds (7.56 M allocations: 380.443 MiB, 4.42% gc time)
```
4c5fc4e:
```
0.882432 seconds (1.48 M allocations: 78.325 MiB, 1.78% gc time)
3.400390 seconds (7.50 M allocations: 377.336 MiB, 4.54% gc time)
```

ocaml_request_enumeration_PID27008_20190719_T155300
---------------------------------------------------

test command:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
```

total 12 seconds in julia, <1s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations, `@time for result in generator(args...)` T1:
```
8.124766 seconds (34.59 M allocations: 1.840 GiB, 4.50% gc time)
8.062860 seconds (34.59 M allocations: 1.841 GiB, 4.59% gc time)
```
After eb1925f1fb64f37f592871449a1f1fb41186162f, T1 and T2:
```
5.206285 seconds (34.00 M allocations: 1.817 GiB, 6.67% gc time)
7.649697 seconds (40.73 M allocations: 2.145 GiB, 6.44% gc time)
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7, T1 and T2:
```
3.134039 seconds (22.40 M allocations: 1.187 GiB, 6.37% gc time)
5.105741 seconds (27.75 M allocations: 1.447 GiB, 6.58% gc time)
```
after 6a4a3a90b14e3379360b477060ac184b04080afb, T1 and T2:
```
3.287473 seconds (22.48 M allocations: 1.193 GiB, 7.67% gc time)
5.613945 seconds (28.05 M allocations: 1.464 GiB, 7.00% gc time)
```
after 9149c967743168e6dd61b9cadc497c179d4e14c7, T1 and T2:
```
3.190760 seconds (22.50 M allocations: 1.194 GiB, 5.34% gc time)
5.234920 seconds (28.06 M allocations: 1.464 GiB, 5.52% gc time)
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1, T1 and T2:
```
1.666996 seconds (18.33 M allocations: 976.201 MiB, 7.72% gc time)
4.545484 seconds (25.30 M allocations: 1.290 GiB, 6.27% gc time)
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b, T2:
```
4.540733 seconds (24.29 M allocations: 1.261 GiB, 6.12% gc time)
```
after a94520432b1e99ebaddab8615db0749598401ebe, T1 and T2:
```
2.456591 seconds (18.92 M allocations: 1021.341 MiB, 6.05% gc time)
4.694774 seconds (24.44 M allocations: 1.266 GiB, 5.93% gc time)
```
after bacb2a7a8a38a0973b7fa8cb3b6f06a51c909366, T1 and T2:
```
2.483610 seconds (18.84 M allocations: 1015.842 MiB, 6.14% gc time)
4.654759 seconds (24.36 M allocations: 1.261 GiB, 6.30% gc time)
```
after d75133b4ec47360e41690b173d4ac4959d8369f5, T1 and T2:
```
2.523960 seconds (18.80 M allocations: 1014.093 MiB, 5.69% gc time)
4.825156 seconds (24.48 M allocations: 1.267 GiB, 5.59% gc time)
```
after fa4fa5c713463bf395af2b034031aefd816ae24e, T1 and T2:
```
2.545248 seconds (18.62 M allocations: 988.995 MiB, 6.37% gc time)
4.824482 seconds (24.31 M allocations: 1.243 GiB, 6.01% gc time)
```
5d6f56238f9399a566cb5051775e7bb55a785283:
```
2.091745 seconds (13.19 M allocations: 736.446 MiB, 5.80% gc time)
4.389511 seconds (18.83 M allocations: 1016.255 MiB, 5.70% gc time)
```
3fd03844c32bc6ade16e0899c58cdcf9e4ca1788:
```
2.059342 seconds (12.12 M allocations: 710.540 MiB, 5.05% gc time)
4.152643 seconds (17.58 M allocations: 982.066 MiB, 5.87% gc time)
```
9a0ec2f:
```
2.067180 seconds (11.61 M allocations: 695.225 MiB, 5.15% gc time)
4.319328 seconds (17.08 M allocations: 966.813 MiB, 5.38% gc time)
```
8345b58:
```
1.983472 seconds (11.43 M allocations: 689.292 MiB, 5.72% gc time)
4.152376 seconds (16.90 M allocations: 960.909 MiB, 6.23% gc time)
```
e28b1c1:
```
1.967134 seconds (11.43 M allocations: 689.281 MiB, 5.53% gc time)
4.203669 seconds (16.90 M allocations: 960.799 MiB, 6.32% gc time)
```
4c5fc4e:
```
1.704416 seconds (9.04 M allocations: 590.171 MiB, 4.88% gc time)
3.963759 seconds (14.51 M allocations: 861.901 MiB, 5.46% gc time)
```

ocaml_request_enumeration_PID27034_20190719_T155304
---------------------------------------------------

command:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27034_20190719_T155304.json
```

>6min in julia, <2s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations (note, running with ocaml_request_enumeration_PID27039_20190719_T155306 in parallel), T2:
```
362.197598 seconds (1.83 G allocations: 99.171 GiB, 3.27% gc time)
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7, T1 and T2:
```
129.488836 seconds (1.48 G allocations: 79.780 GiB, 6.62% gc time)
131.618129 seconds (1.48 G allocations: 80.060 GiB, 6.60% gc time)
```
after 6a4a3a90b14e3379360b477060ac184b04080afb, T1 and T2:
```
140.774280 seconds (1.48 G allocations: 79.815 GiB, 7.96% gc time)
143.325902 seconds (1.48 G allocations: 80.105 GiB, 7.92% gc time)
```
after 9149c967743168e6dd61b9cadc497c179d4e14c7, T1 and T2:
```
143.787190 seconds (1.48 G allocations: 79.816 GiB, 8.69% gc time)
146.072933 seconds (1.48 G allocations: 80.106 GiB, 8.65% gc time)
```
most recently at a72b4d7c1b7c355eb8dd1111678af9f6b10f1ce2, T1 and T2:
```
150.205627 seconds (1.47 G allocations: 79.570 GiB, 8.62% gc time)
152.595186 seconds (1.47 G allocations: 79.857 GiB, 8.57% gc time)
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1, T1 and T2:
```
85.489968 seconds (1.34 G allocations: 70.032 GiB, 10.63% gc time)
88.531716 seconds (1.35 G allocations: 70.389 GiB, 10.48% gc time)
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b, T2:
```
94.948203 seconds (1.30 G allocations: 69.455 GiB, 9.47% gc time)
```
5d6f56238f9399a566cb5051775e7bb55a785283:
```
67.508311 seconds (857.13 M allocations: 47.663 GiB, 10.67% gc time)
69.862533 seconds (863.17 M allocations: 47.956 GiB, 10.52% gc time)
```

ocaml_request_enumeration_PID27039_20190719_T155306
---------------------------------------------------

test command:
```
❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27039_20190719_T155306.json
```

>6min in julia, 8s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations (note, running with ocaml_request_enumeration_PID27034_20190719_T155304 in parallel), T2:
```
381.788591 seconds (1.93 G allocations: 104.542 GiB, 3.36% gc time)
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7, T1 and T2 over 2 sessions:
```
364.932885 seconds (4.13 G allocations: 223.375 GiB, 8.27% gc time)
366.894658 seconds (4.14 G allocations: 223.641 GiB, 8.25% gc time)
```
```
356.781747 seconds (3.97 G allocations: 214.368 GiB, 9.03% gc time)
358.796908 seconds (3.97 G allocations: 214.634 GiB, 9.01% gc time)
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1, T1 and T2:
```
269.430770 seconds (4.29 G allocations: 223.980 GiB, 9.90% gc time)
272.325908 seconds (4.29 G allocations: 224.318 GiB, 9.85% gc time)
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b, T1 and T2:
```
289.711500 seconds (4.14 G allocations: 220.997 GiB, 11.64% gc time)
291.897993 seconds (4.15 G allocations: 221.266 GiB, 11.60% gc time)
```

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
after 946a3a1c3273bf8b7507dda1bf93d0f88a85bb6a:
```
❯ julia --project perf/benchmark1.jl
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
  times: Array{Float64}((309,)) [1.35842e7, 1.38743e7, 1.38963e7, 1.39155e7, 1.39332e7, 1.39418e7, 1.39971e7, 1.40465e7, 1.40527e7, 1.40568e7  …  2.02053e7, 2.02119e7, 2.11744e7, 2.26098e7, 2.26513e7, 2.34254e7, 2.37464e7, 2.38619e7, 2.58619e7, 5.31911e7]
  gctimes: Array{Float64}((309,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  0.0, 4.32879e6, 2.5212e6, 3.1123e6, 2.41763e6, 2.64251e6, 0.0, 0.0, 1.07394e7, 3.75871e7]
  memory: Int64 8223920
  allocs: Int64 140460
minimum:
TrialEstimate(13.584 ms)
median:
TrialEstimate(15.725 ms)
mean:
TrialEstimate(16.171 ms)
maximum:
TrialEstimate(53.191 ms)
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1:
```
❯ julia --project perf/benchmark1.jl
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
  times: Array{Float64}((503,)) [8.25534e6, 8.38645e6, 8.39378e6, 8.40202e6, 8.42088e6, 8.4505e6, 8.48834e6, 8.49027e6, 8.51445e6, 8.51785e6  …  1.34385e7, 1.4229e7, 1.4263e7, 1.5724e7, 1.59111e7, 1.659e7, 1.69689e7, 1.7345e7, 1.94011e7, 6.78902e7]
  gctimes: Array{Float64}((503,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  3.22832e6, 2.09411e6, 3.04813e6, 0.0, 0.0, 3.38247e6, 0.0, 2.98226e6, 9.81956e6, 5.66769e7]
  memory: Int64 7249936
  allocs: Int64 128189
minimum:
TrialEstimate(8.255 ms)
median:
TrialEstimate(9.486 ms)
mean:
TrialEstimate(9.943 ms)
maximum:
TrialEstimate(67.890 ms)
```
after a6cb34bddc0d5a8d25e7e4d1c2793dda0892b4d8:
```
❯ julia --project perf/benchmark1.jl
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
  times: Array{Float64}((503,)) [8.13995e6, 8.193e6, 8.25309e6, 8.25497e6, 8.25548e6, 8.26158e6, 8.2644e6, 8.33644e6, 8.35435e6, 8.36508e6  …  1.34091e7, 1.34406e7, 1.3532e7, 1.36861e7, 1.38207e7, 1.45572e7, 1.48643e7, 1.52867e7, 2.13777e7, 4.44901e7]
  gctimes: Array{Float64}((503,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.78294e6, 1.41514e6, 1.60934e6, 1.38012e6, 2.679e6, 1.69975e6, 0.0, 1.89576e6, 1.13919e7, 3.57553e7]
  memory: Int64 7164672
  allocs: Int64 124200
minimum:
TrialEstimate(8.140 ms)
median:
TrialEstimate(9.633 ms)
mean:
TrialEstimate(9.937 ms)
maximum:
TrialEstimate(44.490 ms)
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
after 946a3a1c3273bf8b7507dda1bf93d0f88a85bb6a:
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
  times: Array{Float64}((3,)) [1.77623e9, 1.79095e9, 1.79688e9]
  gctimes: Array{Float64}((3,)) [1.18528e8, 1.18576e8, 1.49859e8]
  memory: Int64 1049241472
  allocs: Int64 18032991
minimum:
TrialEstimate(1.776 s)
median:
TrialEstimate(1.791 s)
mean:
TrialEstimate(1.788 s)
maximum:
TrialEstimate(1.797 s)
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1:
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
  times: Array{Float64}((6,)) [9.84376e8, 9.8656e8, 9.93808e8, 9.94041e8, 9.99038e8, 1.02602e9]
  gctimes: Array{Float64}((6,)) [6.18547e7, 5.81042e7, 6.77323e7, 6.61274e7, 6.67962e7, 9.28976e7]
  memory: Int64 923454496
  allocs: Int64 16443463
minimum:
TrialEstimate(984.376 ms)
median:
TrialEstimate(993.925 ms)
mean:
TrialEstimate(997.307 ms)
maximum:
TrialEstimate(1.026 s)
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b:
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
  times: Array{Float64}((5,)) [1.01251e9, 1.0238e9, 1.07422e9, 1.08511e9, 1.09869e9]
  gctimes: Array{Float64}((5,)) [5.78005e7, 6.5488e7, 7.21054e7, 9.13673e7, 1.32985e8]
  memory: Int64 911594112
  allocs: Int64 15901701
minimum:
TrialEstimate(1.013 s)
median:
TrialEstimate(1.074 s)
mean:
TrialEstimate(1.059 s)
maximum:
TrialEstimate(1.099 s)
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
after 946a3a1c3273bf8b7507dda1bf93d0f88a85bb6a:
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
 times: Array{Float64}((10000,)) [76723.0, 76759.0, 76954.0, 76961.0, 77002.0, 77012.0, 77047.0, 77052.0, 77067.0, 77078.0  …  1.98028e6, 2.08673e6, 2.13149e6, 2.16732e6, 2.27917e6, 2.68645e6, 2.71897e6, 5.12441e6, 7.4151e6, 3.2063e7]
 gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  1.863e6, 1.9939e6, 1.97345e6, 2.0654e6, 2.18234e6, 2.58372e6, 2.60311e6, 4.90338e6, 7.3194e6, 3.19563e7]
 memory: Int64 75552
 allocs: Int64 1336
minimum:
TrialEstimate(76.723 μs)
median:
TrialEstimate(80.421 μs)
mean:
TrialEstimate(95.167 μs)
maximum:
TrialEstimate(32.063 ms)
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1:
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
  times: Array{Float64}((10000,)) [74376.0, 74401.0, 74571.0, 74588.0, 74589.0, 74607.0, 74607.0, 74622.0, 74638.0, 74638.0  …  1.16037e6, 1.16178e6, 1.17493e6, 1.19103e6, 1.21929e6, 1.24762e6, 1.26971e6, 1.31794e6, 9.57012e6, 3.39677e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  1.05559e6, 1.06312e6, 1.0586e6, 1.10284e6, 1.0561e6, 1.15895e6, 1.18823e6, 1.22476e6, 9.47856e6, 3.38761e7]
  memory: Int64 70832
  allocs: Int64 1277
minimum:
TrialEstimate(74.376 μs)
median:
TrialEstimate(79.960 μs)
mean:
TrialEstimate(91.298 μs)
maximum:
TrialEstimate(33.968 ms)
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b:
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
  times: Array{Float64}((10000,)) [70636.0, 70727.0, 70747.0, 70771.0, 70777.0, 70810.0, 70821.0, 70839.0, 70848.0, 70849.0  …  2.1472e6, 2.15192e6, 2.16535e6, 2.18402e6, 2.36212e6, 2.46261e6, 2.52076e6, 2.66956e6, 9.37321e6, 3.58843e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.06305e6, 2.06161e6, 2.08302e6, 2.09001e6, 2.27445e6, 2.36534e6, 2.41932e6, 2.5836e6, 9.21288e6, 3.57697e7]
  memory: Int64 69952
  allocs: Int64 1252
minimum:
TrialEstimate(70.636 μs)
median:
TrialEstimate(72.251 μs)
mean:
TrialEstimate(85.862 μs)
maximum:
TrialEstimate(35.884 ms)
```
after a94520432b1e99ebaddab8615db0749598401ebe:
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
  times: Array{Float64}((10000,)) [71450.0, 71486.0, 71530.0, 71547.0, 71593.0, 71604.0, 71605.0, 71615.0, 71617.0, 71675.0  …  2.35171e6, 2.36103e6, 2.36525e6, 2.38108e6, 2.48257e6, 2.49156e6, 2.61078e6, 4.26561e6, 9.90922e6, 3.80245e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.2527e6, 2.2687e6, 2.26891e6, 2.28951e6, 2.33603e6, 2.30222e6, 2.39278e6, 4.0527e6, 9.77994e6, 3.79067e7]
  memory: Int64 69952
  allocs: Int64 1252
minimum:
TrialEstimate(71.450 μs)
median:
TrialEstimate(73.484 μs)
mean:
TrialEstimate(88.512 μs)
maximum:
TrialEstimate(38.025 ms)
```
after bacb2a7a8a38a0973b7fa8cb3b6f06a51c909366:
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
  times: Array{Float64}((10000,)) [71177.0, 71410.0, 71418.0, 71427.0, 71450.0, 71459.0, 71498.0, 71513.0, 71521.0, 71523.0  …  2.17883e6, 2.20941e6, 2.22405e6, 2.26426e6, 2.33974e6, 2.52692e6, 2.55003e6, 2.55316e6, 9.4524e6, 3.85289e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.08918e6, 2.11925e6, 2.1359e6, 2.17659e6, 2.23767e6, 2.41591e6, 2.4015e6, 2.44396e6, 9.35224e6, 3.84121e7]
  memory: Int64 69808
  allocs: Int64 1250
minimum:
TrialEstimate(71.177 μs)
median:
TrialEstimate(72.931 μs)
mean:
TrialEstimate(86.374 μs)
maximum:
TrialEstimate(38.529 ms)
```
after d75133b4ec47360e41690b173d4ac4959d8369f5:
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
  times: Array{Float64}((10000,)) [70728.0, 70826.0, 70848.0, 70912.0, 70917.0, 70940.0, 70949.0, 70952.0, 70954.0, 70967.0  …  2.24451e6, 2.24488e6, 2.27858e6, 2.31584e6, 2.36273e6, 2.39236e6, 2.39674e6, 2.58679e6, 9.8318e6, 3.76713e7]
  gctimes: Array{Float64}((10000,)) [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0  …  2.157e6, 2.15715e6, 2.19331e6, 2.23097e6, 2.27487e6, 2.28157e6, 2.29825e6, 2.49989e6, 9.7291e6, 3.7557e7]
  memory: Int64 69808
  allocs: Int64 1250
minimum:
TrialEstimate(70.728 μs)
median:
TrialEstimate(72.507 μs)
mean:
TrialEstimate(86.604 μs)
maximum:
TrialEstimate(37.671 ms)
```
