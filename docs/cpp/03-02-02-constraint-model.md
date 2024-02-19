### Detailed MiniZinc Constraint Model {#constraints}

In this section, we present an informal statement of constraints to be enforced
by our conflict analyzer. We then present the main constraints coded in
MiniZinc used by our model to achieve these constraints. More information
about MiniZinc including its usage and syntax can be found [here](https://www.minizinc.org/). 

In the model below, the `nodeEnclave` decision variable stores the enclave
assignment for each node, the `taint` decision variable stores the label
assignment for each node, and the `xdedge` decision variable stores whether a
given edge is in the enclave cut (i.e., the source and destination nodes of the
edge are in different enclaves). Several other auxiliary decision variables are
used in the constraint model to express the constraints or for efficient
compilation.


#### Structural Constraints on Node Enclave/Level

Every node must be assigned to a valid enclave. Functions and classes must be 
assigned to the same enclave as their containing node. The level of the label 
(taint) of every node must match the level of the enclave the node is assigned 
to.

```minizinc
constraint :: "NodeHasEnclave"            forall (n in NodeIdx) (nodeEnclave[n] != nullEnclave);
constraint :: "NodeEnclaveIsFunEnclave"   forall (n in NodeIdx) ((hasFunction[n] != 0) -> (nodeEnclave[n] == nodeEnclave[hasFunction[n]]));
constraint :: "NodeEnclaveIsClassEnclave" forall (n in NodeIdx) ((hasClass[n]    != 0) -> (nodeEnclave[n] == nodeEnclave[hasClass[n]]));
constraint :: "NodeLevelAtEnclaveLevel"   forall (n in NodeIdx) (hasLabelLevel[taint[n]] == hasEnclaveLevel[nodeEnclave[n]]);
```


#### Classifying Annotations

Only functions, methods, and constructors can be assigned a function annotation. 
Function annotations can only be made by the user.

```minizinc
constraint :: "FnAnnotationForFnOnly"
    forall (n in NodeIdx)          (isFunctionAnnotation[taint[n]] -> isFunction(n));
constraint :: "FnAnnotationByUserOnly"
    forall (n in FunOrMethodOrCon) (isFunctionAnnotation[taint[n]] -> userAnnotatedNode[n]);
constraint :: "annotationOnFunctionIsFunAnnotation"
    forall (n in FunOrMethodOrCon) (userAnnotatedNode[n] -> isFunctionAnnotation[taint[n]]);
```

Annotations on classes and their fields are node annotations, not function annotations.

```minizinc
constraint :: "annotationOnClassIsNodeAnnotation"
    forall (n in Decl_Record) (userAnnotatedNode[n] -> not (isFunctionAnnotation[taint[n]]));
constraint :: "annotationOnFieldIsNodeAnnotation"
    forall (n in Decl_Field)  (userAnnotatedNode[n] -> not (isFunctionAnnotation[taint[n]]));
```


#### Structural Taint Relationships Between Nodes

All nodes in an un-annotated function must have the taint of the function. All nodes in an 
un-annotated class must be un-annotated and have the taint of the class.

```minizinc
constraint :: "UnannotatedFunContentTaintMatch"
    forall (n in NodeIdx where hasFunction[n] != 0) ((not userAnnotatedNode[hasFunction[n]]) -> (taint[n] == ftaint(n)));

constraint :: "noAnnotatedDataForUnannotatedClass"
    forall (n in NodeIdx where hasClass[n] != 0)
        ((not userAnnotatedNode[hasClass[n]]) -> (taint[n] == taint[hasClass[n]]));

constraint :: "noAnnotatedDataForUnannotatedClass"
    forall (n in NodeIdx where hasClass[n] != 0)
        ((not userAnnotatedNode[hasClass[n]]) -> (not userAnnotatedNode[n]));
```


Un-annotated constructors, destructors, and methods must have the taint of the class. 

```minizinc
constraint :: "unannotatedConstructorGetsClassTaint"
    forall (n in Decl_Constructor)
        ((hasClass[n] != 0 /\ not userAnnotatedNode[n]) -> (taint[n] == taint[hasClass[n]]));

constraint :: "unannotatedDestructorGetsClassTaint"
    forall (n in Decl_Destructor)
        ((hasClass[n] != 0 /\ not userAnnotatedNode[n]) -> (taint[n] == taint[hasClass[n]]));

constraint :: "unannotatedMethodGetsClassTaint"
    forall (n in Decl_Method)
        ((hasClass[n] != 0 /\ not userAnnotatedNode[n]) -> (taint[n] == taint[hasClass[n]]));
```


Classes connected by an inheritance relationship share the same taint.

```minizinc
constraint :: "inheritTaint"
    forall (e in Record_Inherit) (esTaint(e) == edTaint(e));
```


All nodes in an annotated function must have a taint in the ARCtaints.

```minizinc
constraint :: "AnnotatedFunContentCoercible"
    forall (n in NodeIdx where (hasFunction[n] != 0) /\ (not isFunction(n)))
        (userAnnotatedNode[hasFunction[n]] -> isInArctaint(ftaint(n), taint[n], hasLabelLevel[taint[n]]));
```


Annotated constructors (which are only valid in annotated classes) must have the class .
taint as their sole rettaint in every CDF.

```minizinc
constraint :: "annotatedConstructorReturnsClassTaint"
    forall (n in Decl_Constructor)
        (userAnnotatedNode[n] ->
            (forall (lvl in Level)
                ((cdfForRemoteLevel[taint[n], lvl] != nullCdf) -> hasRettaints[cdfForRemoteLevel[taint[n], lvl], taint[hasClass[n]]])));
```


Any function whose address is taken in the program cannot have a function annotation.

```minizinc
constraint :: "FunctionPtrSinglyTainted"
    forall (e in Data_PointsTo) (isFunction(hasDest[e]) -> not userAnnotatedNode[hasDest[e]]);
```


#### Constraints on the Cross-Domain Control Flow

The control flow can never leave an enclave, unless it is done through an
approved cross-domain call, as expressed in the following constraints.
The only control edges allowed in the cross-domain cut are either call
invocations or returns. For any call invocation edge in the cut, the function
annotation of the function entry being called must have a CDF that allows (with
or without redaction) the level of the label assigned to the callsite.  The
label assigned to the callsite must have a node annotation with a CDF that
allows the data to be shared with the level of the (taint of the) function
entry being called.


```minizinc
constraint :: "NonCallRetControlEnclaveSafe"
    forall (e in Control_EnclaveSafe) (xdedge(e) == false);
constraint :: "XDCallBlest" 
    forall (e in Control_Invocation) (xdedge(e) -> userAnnotatedNode[hasDest[e]]);
constraint :: "XDCallAllowed"
    forall (e in Control_Invocation) (xdedge(e) -> allowOrRedact(edFunCdf(e)));
constraint :: "XDReturnAllowed"
    forall (e in Control_Return) (xdedge(e) -> allowOrRedact(esFunCdf(e)));
```

Note: The conflict analyzer is working with the annotated unpartitioned
code and not the fully partitioned code which will includes autogenerated
code. The actual cut in the partitioned code with autogenerated code to
handle cross-domain communications will be between the cross-domain send 
and receive functions that are several steps removed from the cut in the
`xdedge` variable at this stage of analysis. The autogenerated code will 
apply annotations to cross-domain data annotations that contain GAPS tags,
and they will have a different label. So we cannot check whether the label 
of the arguments passed from the caller matches the argument taints allowed by
the called function, or if the return taints match the value to which the 
return value is assigned. A downstream verification tool will check this.


#### Constraints on the Cross-Domain Data Flow

Data can only leave an enclave through parameters or return of valid
cross-domain call invocations, as expressed in the following constraints.

Cross-domain returns must be allowed by the CDF, but the taints need not match
(can't enforce taint matching as the level must change). Cross-domain Points-To 
edges must be allowed by the CDF, but the taints need not match.

Note: The reason cross domain points-to edges are not disallowed completely
is because passing arrays necessitates cross-domain points-to edges.


```minizinc
constraint :: "EnclaveSafeDataEdges"
    forall (e in Data_EnclaveSafe) (xdedge(e) == false);

constraint :: "XDReturnDataAllowed"
    forall (e in Data_Return)
        (xdedge(e) -> allowOrRedact(esFunCdf(e)));

constraint :: "XDPointsToAllowed"
    forall (e in Data_PointsTo)
        (xdedge(e) -> (allowOrRedact(cdfForRemoteLevel[edTaint(e), hasLabelLevel[esTaint(e)]]) /\ not isFunction(hasDest[e])));
```


#### Taint Propagation

While the constraints on the control dependency and data dependency that
we discussed governed data sharing at the cross-domain cut, we still need
to perform taint checking to ensure that data annotated with different 
labels inside each enclave are managed correctly and only when the
mixing of the taints is explicitly allowed by the user.

Labels can be cooerced (i.e., nodes of a given PDG edge can be permitted to
have different label assigments) inside an enclave only through user annotated
functions.

Any data dependency or parameter edge that is intra-enclave (not in the
cross-domain cut) and with different CLE label taints assigned to the source
and destination nodes must be coerced (through an annotated function).

One may wonder whether a similar constraint must be added for control 
dependency edges at the entry block for completeness. Such a constraint is 
not necessary given our inclusion of the `UnannotatedFunContentTaintMatch` and
`AnnotatedFunContentCoercible` constraints discussed earlier. However, pointer 
dependencies are captured by a chain of points-to edges which may be intra-function 
edges. Therefore we restrict intra-function points-to edges to have the same taint, 
even in annotated functions.


```minizinc
predicate intraFunEdge(DataEdge: e) =
    (hasFunction[hasSource[e]] != 0 /\ hasFunction[hasDest[e]] != 0 /\
     hasFunction[hasSource[e]] == hasFunction[hasDest[e]]);
constraint :: "intraFunPointsToTaintsMatch"
    forall (e in Data_PointsTo) (intraFunEdge(e) -> esTaint(e) == edTaint(e));
```


For ANY data edge between two function-external nodes, the taints must match.

```minizinc
predicate globalGlobalEdge(DataEdge: e) = (isGlobal[hasSource[e]] /\ isGlobal[hasDest[e]]);
constraint :: "externExternDataEdgeTaintsMatch"
    forall (e in DataEdge) (globalGlobalEdge(e) -> (esTaint(e) == edTaint(e)));
```


For ANY data edge between data within a function and a function-external node, the taints must match.

```minizinc
predicate srcFunExternEdge(DataEdge: e)  = (hasFunction[hasSource[e]] != 0 /\ hasFunction[hasDest[e]]   == 0);
predicate destFunExternEdge(DataEdge: e) = (hasFunction[hasDest[e]]   != 0 /\ hasFunction[hasSource[e]] == 0);
predicate funExternEdge(DataEdge: e)     = (srcFunExternEdge(e) \/ destFunExternEdge(e));
constraint :: "externDataEdgeTaintsMatch"
    forall (e in DataEdge) (funExternEdge(e) -> esTaint(e) == edTaint(e));
```


This leaves taint propagation for inter-function data edges. For non-XD return edges 
from a callee function to a callsite, if the callee (source) function is un-annotated, 
the taints must match and if the callee (source) function is annotated, the taint on 
the dest node must be in the callee's rettaints.

```minizinc
constraint :: "retEdgeFromUnannotatedTaintsMatch"
    forall (e in Data_Return where not sourceAnnotFun(e))
        (esTaint(e) == edTaint(e));
constraint :: "returnNodeInRettaints"
    forall (e in Data_Return where sourceAnnotFun(e) /\ not xdedge(e))
        (hasRettaints[esFunCdf(e), edTaint(e)]);
```


For non-XD argument passing edges, if the destination function is un-annotated, the taint 
of the argument must match the taint of the destination function and if the destination 
function is annotated, the taint of the argument must be in the argtaints of the function 
at that parameter index.

```minizinc
constraint :: "argumentToUnannotatedTaintsMatch"
    forall (e in Control_Invocation where not destAnnotFun(e))
        (forall (arg_e in Data_ArgPass where hasSource[arg_e] == hasSource[e])
            (edTaint(arg_e) == edTaint(e)));
constraint :: "argumentInArgtaints"
    forall (e in Control_Invocation where destAnnotFun(e) /\ not xdedge(e))
        (forall (arg_e in Data_ArgPass where hasSource[arg_e] == hasSource[e])
            (hasArgtaints[edFunCdf(e), hasParamIdx[hasDest[arg_e]], taint[hasDest[arg_e]]]));
```


Latly, inter-function points-to edges should always have the same taint.

```minizinc
predicate interFunEdge(DataEdge: e) =
    (hasFunction[hasSource[e]] != 0 /\ hasFunction[hasDest[e]] != 0 /\
     hasFunction[hasSource[e]] != hasFunction[hasDest[e]]);
constraint :: "interFunPointsToTaintsMatch"
    forall (e in Data_PointsTo)
        ((not xdedge(e) /\ interFunEdge(e)) -> esTaint(e) == edTaint(e));
```


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
