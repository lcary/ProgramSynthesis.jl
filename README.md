ProgramSynthesis.jl
===================

`ProgramSynthesis.jl` is a library of program synthesis routines and tools. This
project aims to introduce a library written in Julia that can be imported and used
to automatically generate programs via enumeration, and filter those programs based on
their ability to solve given problem sets (or sets of input-output examples).

Build Status
------------

[![Build Status](https://travis-ci.com/lcary/ProgramSynthesis.jl.svg?branch=master)](https://travis-ci.com/lcary/ProgramSynthesis.jl)

What is Program Synthesis?
--------------------------

The term "program synthesis" refers to the automatic construction or synthesizing of programs
that match a given specification.

Usage
-----

Currently, the main use case for `ProgramSynthesis.jl` is to receive a "request" consisting of
an array of probems, each having its own set of input-output examples, and produce a "response"
dictionary of solutions, where each key is the name of the problem, and each value list is an array
of programs that solve the problem. The data format of the request and response is JSON.

Example:
```
❯ julia --project bin/main.jl enumerate test/resources/request_enumeration_example_6.json
/Users/lcary/w/mit/ProgramSynthesis.jl/messages/response_enumeration_PID4341_20190805_T104049.json
```

Testing
-------

To run the unit tests, clone the repo and run:
```
./runtests
```

References
----------

This repository implements enumeration algorithms from the following "ec"/"dreamcoder" codebase:
https://github.com/ellisk42/ec

Program synthesis wiki:
https://en.wikipedia.org/wiki/Program_synthesis

The representation of solutions relies on Lambda Calculus:
https://en.wikipedia.org/wiki/Lambda_calculus

The construction of programs in enumeration uses unification:
https://en.wikipedia.org/wiki/Unification_(computer_science)

Request Formats
---------------

Problem request format:
```
{
  "DSL": {
    "logVariable": 0.0,
    "productions": [
      {
        "expression": "map",
        "logProbability": 0.0
      },
      ...
    ]
  },
  "tasks": [
    {
      "examples": [
        {
          "inputs": [[6,1,1,6,3]],
          "output": 5
        },
        ...
      ],
      "name": "length-test",
      "request": {
        "constructor": "->",
        "arguments": [
          {"constructor": "list", "arguments": [{"constructor": "int", "arguments": []}]},
          {"constructor": "int", "arguments": []}
        ]
      },
      "maximumFrontier": 10
    }
  ],
  "programTimeout": 0.0005,
  "nc": 1,
  "timeout": 1.0,
  "lowerBound": 4.5,
  "upperBound": 6.0,
  "budgetIncrement": 1.5,
  "verbose": false,
  "shatter": 10
}
```

Solution response format:
```
{
  "length-test": [
    {
      "program": "(lambda (length $0))",
      "time": 0.9078459739685059,
      "logLikelihood": 0.0,
      "logPrior": -4.795790545596741
    }
  ]
}
```
