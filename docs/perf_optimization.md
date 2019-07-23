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
e8d997c:
```
0.777778 seconds (1.36 M allocations: 72.214 MiB, 1.69% gc time)
3.078401 seconds (7.37 M allocations: 371.482 MiB, 5.15% gc time)
```
3d6c692:
```
0.768980 seconds (1.30 M allocations: 69.204 MiB, 1.78% gc time)
3.123315 seconds (7.31 M allocations: 367.989 MiB, 5.13% gc time)
```
711e582:
```
0.165057 seconds (512.13 k allocations: 27.396 MiB, 2.90% gc time)
3.083177 seconds (7.71 M allocations: 382.777 MiB, 5.20% gc time)
```
0c34ab1:
```
0.172249 seconds (510.88 k allocations: 27.305 MiB, 3.97% gc time)
3.191169 seconds (7.81 M allocations: 386.443 MiB, 5.68% gc time)
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
e8d997c:
```
1.687019 seconds (8.93 M allocations: 584.204 MiB, 4.71% gc time)
3.906137 seconds (14.40 M allocations: 855.791 MiB, 5.41% gc time)
```
3d6c692:
```
1.664869 seconds (8.86 M allocations: 580.990 MiB, 5.44% gc time)
3.915507 seconds (14.32 M allocations: 852.583 MiB, 5.62% gc time)
```
711e582:
```
0.859128 seconds (8.03 M allocations: 539.645 MiB, 8.98% gc time)
3.502556 seconds (14.68 M allocations: 868.467 MiB, 6.29% gc time)
```
0c34ab1:
```
0.771682 seconds (7.85 M allocations: 526.781 MiB, 7.60% gc time)
3.605504 seconds (14.60 M allocations: 858.672 MiB, 5.85% gc time)
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
4c5fc4e565e567e9daf3462b46763e572871a937:
```
40.011345 seconds (528.86 M allocations: 36.493 GiB, 11.73% gc time)
42.227773 seconds (534.73 M allocations: 36.778 GiB, 11.45% gc time)
```
711e582:
```
21.617717 seconds (503.37 M allocations: 35.436 GiB, 19.49% gc time)
24.464938 seconds (510.42 M allocations: 35.777 GiB, 17.81% gc time)
```
0c34ab1:
```
19.933620 seconds (464.57 M allocations: 32.697 GiB, 18.83% gc time)
22.957007 seconds (471.71 M allocations: 33.040 GiB, 17.11% gc time)
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
4c5fc4e565e567e9daf3462b46763e572871a937:
```
124.018097 seconds (1.68 G allocations: 115.929 GiB, 13.25% gc time)
126.080682 seconds (1.68 G allocations: 116.194 GiB, 13.13% gc time)
```
711e582:
```
64.921158 seconds (1.60 G allocations: 112.671 GiB, 16.37% gc time)
67.690494 seconds (1.60 G allocations: 112.992 GiB, 15.92% gc time)
```

benchmark1.jl
-------------

script: `julia --project perf/benchmark1.jl`

benchmarks before optimizations:
```
memory:     12950576
allocs:     222208
minimum:    44.560 ms
median:     48.271 ms
mean:       49.654 ms
maximum:    86.619 ms
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
memory:     8241952
allocs:     140999
minimum:    12.654 ms
median:     14.856 ms
mean:       15.055 ms
maximum:    51.643 ms
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
memory:     8244784
allocs:     140996
minimum:    12.979 ms
median:     14.435 ms
mean:       15.042 ms
maximum:    52.220 ms
```
after 946a3a1c3273bf8b7507dda1bf93d0f88a85bb6a:
```
memory:     8223920
allocs:     140460
minimum:    13.584 ms
median:     15.725 ms
mean:       16.171 ms
maximum:    53.191 ms
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1:
```
memory:     7249936
allocs:     128189
minimum:    8.255 ms
median:     9.486 ms
mean:       9.943 ms
maximum:    67.890 ms
```
after a6cb34bddc0d5a8d25e7e4d1c2793dda0892b4d8:
```
memory:     7164672
allocs:     124200
minimum:    8.140 ms
median:     9.633 ms
mean:       9.937 ms
maximum:    44.490 ms
```
711e582:
```
memory:     3766160
allocs:     49976
minimum:    2.573 ms
median:     3.019 ms
mean:       3.328 ms
maximum:    42.151 ms
```

benchmark2.jl
-------------

script: `julia --project perf/benchmark2.jl`

benchmarks before optimizations:
```
memory:     1670782480
allocs:     28741776
minimum:    5.924 s
median:     5.924 s
mean:       5.924 s
maximum:    5.924 s
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
memory:     1051785648
allocs:     18108981
minimum:    1.703 s
median:     1.719 s
mean:       1.738 s
maximum:    1.790 s
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
memory:     1052248784
allocs:     18109245
minimum:    1.687 s
median:     1.701 s
mean:       1.716 s
maximum:    1.761 s
```
after 946a3a1c3273bf8b7507dda1bf93d0f88a85bb6a:
```
memory:     1049241472
allocs:     18032991
minimum:    1.776 s
median:     1.791 s
mean:       1.788 s
maximum:    1.797 s
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1:
```
memory:     923454496
allocs:     16443463
minimum:    984.376 ms
median:     993.925 ms
mean:       997.307 ms
maximum:    1.026 s
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b:
```
memory:     911594112
allocs:     15901701
minimum:    1.013 s
median:     1.074 s
mean:       1.059 s
maximum:    1.099 s
```
711e582:
```
memory:     467918944
allocs:     6190931
minimum:    231.204 ms
median:     243.920 ms
mean:       246.544 ms
maximum:    279.784 ms
```

benchmark3.jl
-------------

script: `julia --project perf/benchmark3.jl`

Benchmarks the performance of build_candidates.

```
memory:     109808
allocs:     1942
minimum:    741.792 μs
median:     750.213 μs
mean:       794.527 μs
maximum:    37.100 ms
```
After 01b5ca3965de8feecb447602c156c61d264ad2ce:
```
memory:     109520
allocs:     1924
minimum:    145.130 μs
median:     151.544 μs
mean:       175.081 μs
maximum:    36.350 ms
```
after a75313dee15506a24bb9937e8de5fc4d67a042f7:
```
memory:     75552
allocs:     1336
minimum:    75.932 μs
median:     78.283 μs
mean:       93.198 μs
maximum:    35.748 ms
```
after 6a4a3a90b14e3379360b477060ac184b04080afb:
```
memory:     75552
allocs:     1336
minimum:    76.981 μs
median:     78.790 μs
mean:       92.582 μs
maximum:    35.304 ms
```
after 946a3a1c3273bf8b7507dda1bf93d0f88a85bb6a:
```
memory:     75552allocs:    1336
minimum:    76.723 μs
median:     80.421 μs
mean:       95.167 μs
maximum:    32.063 ms
```
after 0faaf18d14eed9f6bc40e9993cbb8e3017355ed1:
```
memory:     70832
allocs:     1277
minimum:    74.376 μs
median:     79.960 μs
mean:       91.298 μs
maximum:    33.968 ms
```
after a3d18f79b5dbaee4c750e2f74a49cac73992213b:
```
memory:     69952
allocs:     1252
minimum:    70.636 μs
median:     72.251 μs
mean:       85.862 μs
maximum:    35.884 ms
```
after a94520432b1e99ebaddab8615db0749598401ebe:
```
memory:     69952
allocs:     1252
minimum:    71.450 μs
median:     73.484 μs
mean:       88.512 μs
maximum:    38.025 ms
```
after bacb2a7a8a38a0973b7fa8cb3b6f06a51c909366:
```
memory:     69808
allocs:     1250
minimum:    71.177 μs
median:     72.931 μs
mean:       86.374 μs
maximum:    38.529 ms
```
after d75133b4ec47360e41690b173d4ac4959d8369f5:
```
memory:     69808
allocs:     1250
minimum:    70.728 μs
median:     72.507 μs
mean:       86.604 μs
maximum:    37.671 ms
```
711e582:
```
memory:     30176
allocs:     390
minimum:    11.777 μs
median:     12.673 μs
mean:       19.815 μs
maximum:    34.311 ms
```
