## Phase 2 CLOSURE conflict analyzer based on minizinc constraint solver **XXX: Review: Rob** {#conflict-analyzer}  

The role of the conflict analyzer is to evaluate a user annotated program and decide if the annotated program respects the allowable information flows specified in the annotations. As input, the conflict analyzer requires the user annottated C source code. Based on this, if it is properly annotated and a partition is possible it will provide an assingment for every global variable and function to an enclave (cut.json). If the conflict analyzer detects a conflict, it produces a report guiding users to problematic program points that may need to be refactored or additional annotations applied.


The conflict analyzer uses a constraint solver called [MiniZinc @minizinc_handbook ](https://www.minizinc.org/doc-2.5.5/en/index.html)  to perform program analysis and determine a correct-by-construction partition that satifies the constraints
specified by the developer using CLE annotations. MiniZinc provides a high level
language abstraction to express constraint solving problems in an intuitive manner.
MiniZinc compiles a MiniZinc language specification of a problem for 
lower level solver such as Gecode. We use an Integer Logic Program (ILP) 
formulation with MiniZinc. MiniZinc also includes a tool that computes
the minimum unsatisfiable subset (MUS) of constraints if a problem
instance is unsatisfiable. The output of this tool can be used to
provide diagnostic feedback to the user to help refactor the program.

Downstream tools in the CLOSURE toolchain will use the output of the solver to
physically partition the code, and after further analysis (for example, to
determine whether each parameter is an input, output, or both, and the size of
the parameter), the downstream tools will autogenerate code for the marshalling and
serialization of input and output/return data for the cross-domain call, as
well as code for invocation and handling of cross-domain remote-procedure calls
that wrap the function invocations in the cross-domain cut. 

### Introduction to the Conflict Analyzer



### Modeling data and control flows 
Java CLOSURE uses an SDG @joana to construct a call graph, control flow graph, and data flow graph so we can accurately track taints throughout an application. Joana is written in java and builds on wala which analyzes an IR form of java bytecode.

We convert the node and edge types from the SDG to the format presented in our C documentation using the following rules:
```
nodeConversion = {
    "NORM" : "Inst_Other",
    "PRED" : "Inst_Br",
    "EXPR" : "Inst_Other",
    "SYNC" : "Inst_Other",
    "FOLD" : "Inst_Other",
    "CALL" : "Inst_FunCall",
    "ENTR" : "FunctionEntry",
    "EXIT" : "Inst_Ret",
    "ACTI" : "Param_ActualIn",
    "ACTO" : "Param_ActualOut",
    "FRMI" : "Param_FormalIn",
    "FRMO" : "Param_FormalOut",
}

edgeConversion = {
    "CD" : "ControlDep_Other",
    "CE" : "ControlDep_Other",
    "UN" : "ControlDep_Other",
    "CF" : "ControlDep_Other",
    "NF" : "ControlDep_Other",
    "RF" : "ControlDep_CallRet",
    "CC" : "ControlDep_CallInv",
    "CL" : "ControlDep_CallInv",
    "SD" : "ControlDep_Other",
    "JOIN" : "ControlDep_Other",
    "FORK" : "ControlDep_Other",
    "DD" : "DataDepEdge_Other",
    "DH" : "DataDepEdge_Other",
    "DA" : "DataDepEdge_Alias",
    "SU" : "DataDepEdge_Other",
    "SH" : "DataDepEdge_Other",
    "SF" : "DataDepEdge_Other",
    "FD" : "DataDepEdge_Other",
    "FI" : "DataDepEdge_Other",
    "PI" : "Parameter_In",
    "PO" : "Parameter_Out",
    "PS" : "Parameter_Field",
    "PE" : "DataDepEdge_Alias",
    "FORK_IN" : "DataDepEdge_Other",
    "FORK_OUT" : "DataDepEdge_Other",
    "ID" : "DataDepEdge_Other",
    "IW" : "DataDepEdge_Other",
}
```
We show in more detail the node and edges of the SDG in the [appendix](#sdg-appendix).


### Data required by minizinc

The Java conflict analyzer uses three kinds of information in its model. It uses information about data and control flows from the SDG stored. It also collects information from the annotations using a jython script that uses java utilities to extract the CLE annotations from a given jar file. Lastly we make use of reflection feature in Java to relate fields and methods to their associated classes as well as track any modifiers that may be present on those fields and methods. 

These three pieces of data along with the constraints described in the next section are given to minizinc. Minizinc will then either produce at least one enclave assingment per class or report no such assingment exists given the program and user annotations.

### Design Decisions
The Java conflict analyzer permits unannotated classes to reside on multiple enclaves. This choice was made make our approach more practical. This design choice allows developers to annotate child classes with different level taints without necessarily requiring the parent class to be annotated. 

Exceptions are currently modeled as returns and the rettaints component of an annotation also applies to exceptions.




