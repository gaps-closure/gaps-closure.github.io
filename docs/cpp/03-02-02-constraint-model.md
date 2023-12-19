### Detailed MiniZinc constraint model [TODO: DANNIE] {#constraints}

XXX: Replace with whatever we have for C++


In this section, we present an informal statement of constraints to be enforced
by our conflict analyzer. We then present the main constraints coded in
MiniZinc used by our model to achieve these constraints. More information
about MiniZinc including its usage and syntax can be found [here](https://www.minizinc.org/). 

In the model below, the `nodeEnclave` decision variable stores the enclave
assignment for each node, the `taint` decision variable stores the label
assignment for each node, and the `xdedge` decision variable stores whether a
given edge is in the enclave cut (i.e., the source and destination nodes of the
edge are in different enclaves. Several other auxiliary decision variables are
used in the constraint model to express the constraints or for efficient
compilation. 

The solver will attempt to assign a node annotation label to all nodes except a
user annotated function. Only user annotated functions may have a function
annotation. Functions lacking a function annotation cannot be invoked
cross-domain and can only have exactly one taint across all invocations. This
ensures that the arguments, return and function body only touches the same taint. 

### General Constraints
XXX: Provide the constraints here for any of those used in our C++ examples.
These subsections will not be complete

### Constraints on the Cross-Domain Control Flow

### Constraints on the Cross-Domain Data Flow

### Constraints on Taint Coercion Within Each Enclave

### Class Constraints

#### Solution Objective 

In this model, we require the solver to provide a satisfying assignment that
minimizes the total number of call invocations that are in the cross-domain cut.
Other objectives could be used instead.

```minizinc
var int: objective = sum(e in ControlDep_CallInv, l in nonNullEnclave where xdedge[e,l])(1);
solve minimize objective;
```

Once the CAPO partitioning conflict analyzer has analyzed the CLE-annotated application code and determined that all remaining conflicts are resolvable by RPC-wrapping to result in a security-compliant cross-domain partitioned code, the conflict analyzer will produce a topology file (JSON) containing the assignment of every class to an enclave/level. A full-length version of the topology can be found in the [appendix](#topology.json)

### Remarks and Limitations

XXX: TODO
