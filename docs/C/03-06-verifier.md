## Verifier **XXX: Review: Max, Rob** {#verifier}

### ECT/ParTV

#### Overview

ECT/ParTV, a translation validation tool for post-partition verification @cprogpartv that certifies a partition is
behaviorally equivalent to its original program and complies with the annotated fine-grained
data sharing—the first such verification tool for program partitioners. 

Determining and generating a secure partition that both respects the developer’s annotations and
is semantically equivalent to the original program is a non-trivial process prone to subtle bugs.

Given the security aims of program partitioning, partitioner correctness is paramount, but manually inspecting the generated partition for security violations and semantic inconsistencies would
be nearly as burdensome as constructing the partition manually. ECT/ParTV confirms a form of behavioral equivalence between the original application and the generated
partition checks the partition’s adherence to the security policy defined by cle annotations and is
solver-backed at each step for increased assurance.

ECT/ParTV verifies the equivalence between 
the refactored program and those in the various enclaves by checking, 
function-by-function, that the generated code and its annotations 
have been paritioned without undue modification and will 
thus behave like the refactored code.  The tool, written in
Haskell @haskell, loads both programs then starts
establishing their equivalence. As it proceeds, it construct a
modular, bottom-up proof in the
Z3 @Z3 theorem prover that is both
checked as the tool proceeds and written out in
[SMT-LIB](http://smtlib.cs.uiowa.edu/) format, a format that can audited both manually and by Z3 or another theorem prover able to read and check SMT-LIB files.

![ECT/ParTV Workflow](docs/C/images/ect-workflow.png)

#### Invocation

ECT/ParTV can be invoked as follows:

```text
Usage: ect [options] (orange.ll | purple.ll | ..)+ ref.ll (orange.json | purple.json | ..)+ ref.json
  -h                  --help                            Print help
  -f <function-name>  --entry-function=<function-name>  Specify the entry function (default: main)
  -d                  --display                         Dump information about the entry functions
  -l <log-file.smt2>  --logfile=<log-file.smt2>         Write the proof log to the given file after solving
```

As inputs, it takes in LLVM linked `.ll` files whose source files have been preprocessed by CLE, and it takes the corresponding CLE-JSON. 
It expects the partitioned `.ll` for each enclave first and the unpartitioned `.ll` last. It expects the CLE-JSON to correspond one-to-one with the LLVM files. 

A linked `.ll` can be obtained from usage of `clang -S -emit-llvm` for each source file and `llvm-link` to combine multiple `.ll`s. More information on creating these `.ll`s can be found in the
[examples](#examples).

### Downstream conflict analyzer 

The conflict analyzer is run once more on each partition 
to check the consistency of the annotations in each partition.
Each partition should have annotations associated with a single level,
and should be internally consistent, with additional generated `TAG_`
from the [`rpc_generator`](#rpc) annotations being checked as well.
The invocation of the conflict analyzer on the partitioned code
is similar to that of the unpartitioned code, however, 
the exact invocation of the downstream conflict analyzer can be found
in the [examples](#examples).
