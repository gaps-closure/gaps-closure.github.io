## Phase 2 CLOSURE conflict analyzer based on MiniZinc constraint solver {#conflict-analyzer}  

The role of the conflict analyzer is to evaluate a user annotated program and
decide if the annotated program respects the allowable information flows
specified in the annotations. As input, the conflict analyzer requires the user
annotated Java source code. Based on this, if it is properly annotated and a
partition is possible it will produce an assignment for each class to an
enclave (cut.json). If the conflict analyzer detects an inconsistency in the
given annotations and program, it reports this and the user can run MinZinc on
the model to produce diagnostics identifying problematic constraints.

The conflict analyzer uses a constraint solver called [MiniZinc
@minizinc_handbook ](https://www.minizinc.org/doc-2.5.5/en/index.html)  to
perform program analysis and determine a correct-by-construction partition that
satisfies the constraints
specified by the developer using CLE annotations. MiniZinc provides a high-level language abstraction to express constraint-solving problems in an intuitive manner.
MiniZinc compiles a MiniZinc language specification of a problem for lower-level solvers such as Gecode. We use an Integer Logic Program (ILP) 
formulation with MiniZinc. MiniZinc also includes a tool that computes
the minimum unsatisfiable subset (MUS) of constraints if a problem
instance is unsatisfiable. The output of this tool can be used to
provide diagnostic feedback to the user to help refactor the program.

Downstream tools in the CLOSURE toolchain will use the output of the solver to
physically partition the code, and after further analysis (for example, to
determine whether each parameter is an input, output, or both, and the size of
the parameter), the downstream tools will autogenerate code for the marshaling and serialization of input and output/return data for the cross-domain call, as
well as code for invocation and handling of cross-domain remote-procedure calls
that wrap the function invocations in the cross-domain cut. 

### Introduction to the Conflict Analyzer

### Usage 

The usage of the conflict analyzer is described in the [previous section](#addl-notes).

### Modeling data and control flows 

Java CLOSURE uses JOANA @joana to construct a system dependency graph (SDG) which
is composed of a call graph, control flow graph, and data flow graph among
other things allowing us to soundly track taints throughout an application.
Joana is written in java and builds on Wala which analyzes an IR form of java
bytecode.

We convert the node and edge types from the SDG to the format presented in our
C documentation @CDoc. The transformation is shown in detail in the
[appendix](#sdg-appendix).

### Data required by MiniZinc

The Java conflict analyzer uses three kinds of information in its model. It
uses information about data and control flows from the SDG. It also collects
information from the annotations using a jython script that uses java utilities
to extract the CLE annotations from a given jar file. Lastly, we make use of the reflection feature in Java to relate fields and methods to their associated
classes as well as track any modifiers that may be present on those fields and
methods. 

These three pieces of data along with the [constraints](#constraints) described
in the next section are given to MiniZinc. MiniZinc will then either produce at
least one enclave assignment per class or report no such assignment exists
given the program and user annotations.

### Design Decisions
The Java conflict analyzer permits unannotated classes to reside in multiple enclaves. This choice was made to make our approach more practical. This design
choice allows developers to annotate child classes with different level taints
without necessarily requiring the parent class to be annotated. 

Exceptions are currently modeled as returns and the rettaints component of an
annotation also applies to exceptions.

