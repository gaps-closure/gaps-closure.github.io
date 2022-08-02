## Phase 2 CLOSURE conflict analyzer based on minizinc constraint solver **XXX: Rob** {#conflict-analyzer}  

The conflict analyzer takes as input a set of source and header files
and either outputs an assignment of every global variable and function to an enclave,
or produces some conflicts which describe inconsistencies of the application 
of the annotations to the code.

The conflict analyzer uses a constraint solver called [MiniZinc @minizinc_handbook ](https://www.minizinc.org/doc-2.5.5/en/index.html)  to perform program analysis and determine a correct-by-construction partition that satifies the constraints
specified by the developer using CLE annotations. MiniZinc provides a high level
language abstraction to express constraint solving problems clearly.
MiniZinc compiles a MiniZinc language specification of a problem for 
lower level solver such as Gecode. We use an Integer Logic Program (ILP) 
formulation with MiniZinc. MiniZinc also includes a tool that computes
the minimum unsatisfiable subset (MUS) of constraints if a problem
instance is unsatisfiable; the output of this tool can be used to
provide diagnostic feedback to the user to help refactor the program.

The output of the program is described in a json file, called `cut.json` which assigns a
level and enclave to every global variable and function. 
It can also provide a more elaborated version `artifact.json` which gives label, level and enclave 
assignments to every program element.

Downstream tools in the CLOSURE toolchain will use the output of the solver to
physically partition the code, and after further analysis (for example, to
determine whether each parameter is an input, output, or both, and the size of
the parameter), the downstream tools will autogenerate code for marshalling and
serialization of input and output/return data for the cross-domain call, as
well as code for invocation and handling of cross-domain remote-procedure calls
that wrap the function invocations in the cross-domain cut. 

### Introduction to the Conflict Analyzer

### The CLOSURE `preprocessor` {#preprocessor}

The CLOSURE preprocessor is a source transformer that will
take a given source or header file with CLE annotations, and produce

1. A modified source or header file with LLVM `__attribute__` annotations 
2. A cle-json file which contains a mapping from each label to its corresponding definition in JSON form. See appendix for
an [example cle-json file](#cle-extra).

The output C of the preprocessor will go to a minimally modified LLVM clang that will support the CLOSURE-specific LLVM `__attribute__` annotations and pass them down to the LLVM IR level.

In addition, the preprocessor performs several well-formedness checks on the cle labels and definitions, using a [json schema](#cle-schema).

For example:

With an initial source is C file containing the following:
```c
int *secretvar = 0;
```

Developer annotates the C file as follows:
```c
#pragma cle def ORANGE { /* CLE-JSON, possibly \-escaped multi-line with whole bunch of constraints*/ }  
#pragma cle ORANGE 
int *secretvar = 0;
```

After running the preprocessor, we should get a C file with pragmas removed but with `__attribute__` inserted (in all applicable places), e.g.,:
```c
#pragma clang attribute push (__attribute__((annotate("ORANGE"))), apply_to = any(function,type_alias,record,enum,variable(unless(is_parameter)),field))
int *secretvar = 0;
#pragma clang attribute pop
```

Additionally:
- preprocessor no longer uses lark/libclang, entirely done custom using regex, which is
fine because its very simple substitution
- single line `#pragma cle LABEL` now supported, was not previously
- can be called separately from command line, this functionality is used in later steps

### `opt` pass for the Program Dependence Graph (PDG) ** NEED TO UPDATE THIS TO SDG **



### input generation and constraint solving using Minizinc

From the cle json outputted by the preprocessor, the conflict analyzer generates
a `minizinc` representation of the cle json, which describes the annotations
and enclaves for a given program. The `minizinc` produced from the cle json
is designed to be used with the PDG `minizinc` representation, and together
provide a full representation of the program and the constraints provided by the annotations
in `minizinc` form.

Together, this can be fed, along with a static set of constraints, to `minizinc`
producing an assignment of every node in the PDG to a label, or a 
minimally unsatisfied set of constraints. Understanding these constraints is crucial to
understanding why a certain program cannot pass the conflict analyzer.

From these assignments, the `topology.json` and `artifact.json` can be generated.

- cle/enclave instance should be a pure function 
from collated cle json to an encoded minizinc instance 
- inputs are put in temp files for reference/debugging
- minizinc called using Gecode solver, with pdg/cle/enclave instance and constraints
- output parsed and sent back to the console
- if unsat, then it will run findmus  
<!-- 
### diagnostics using findMUS

Diagnostic generation produces commandline output
containing source and dest node and grouped by the constraints violated in minizinc.
When given `--output-json` it should also produce a machine readable `conflicts.json` which can be ingested by [CVI](#cvi)
to show these errors in VSCode. -->
