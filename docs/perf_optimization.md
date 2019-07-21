performance optimization
========================

ocaml_request_enumeration_PID26993_20190719_T155300
---------------------------------------------------

6 seconds in julia, <1s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:

❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
@time for result in generator(args...)
1.795149 seconds (4.68 M allocations: 234.763 MiB, 6.03% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19706_20190720_T194350.json

❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID26993_20190719_T155300.json
  1.781357 seconds (4.68 M allocations: 234.767 MiB, 6.08% gc time)
  ^@time for result in generator(args...)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID21770_20190721_T124433.json

ocaml_request_enumeration_PID27008_20190719_T155300
---------------------------------------------------

12 seconds in julia, <1s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:

❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
@time for result in generator(args...)
8.124766 seconds (34.59 M allocations: 1.840 GiB, 4.50% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19756_20190720_T194412.json

❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27008_20190719_T155300.json
  8.062860 seconds (34.59 M allocations: 1.841 GiB, 4.59% gc time)
  ^@time for result in generator(args...)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID21820_20190721_T124512.json

ocaml_request_enumeration_PID27034_20190719_T155304
---------------------------------------------------

>6min seconds (aborted) in julia, <2s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:

❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27034_20190719_T155304.json
@time for result in generator(args...)
362.197598 seconds (1.83 G allocations: 99.171 GiB, 3.27% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19808_20190720_T195039.json

~/w/mit/DreamCore.jl optimize* 6m 5s

>6min seconds (aborted) in julia, 8s in ocaml (see julia_v_ocaml_speedtest2.txt)

before any optimizations:

❯ julia --project bin/main.jl enumerate ../dreamcoder-testing/messages/messages/ocaml_request_enumeration_PID27039_20190719_T155306.json
@time for result in generator(args...)
381.788591 seconds (1.93 G allocations: 104.542 GiB, 3.36% gc time)
/Users/lcary/w/mit/DreamCore.jl/messages/response_enumeration_PID19906_20190720_T195112.json
