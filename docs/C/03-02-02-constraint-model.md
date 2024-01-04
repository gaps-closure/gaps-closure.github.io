### Detailed MiniZinc constraint model {#constraints}

The following assumes some familiarity with MiniZinc syntax. More
about MiniZinc, it's usage and syntax can be found [here](https://www.minizinc.org/).

In the model below, the `nodeEnclave` decision variable stores the enclave
assignment for each node, the `taint` decision variable stores the label
assignment for each node.

There are also many auxiliary predicates and functions which are generally used as shorthands
for longer expressions. These are described at the end of this section.

The solver will attempt to assign a node annotation label to all nodes except a user annotated functions. Only user annotated functions may have a function annotation. Functions lacking a function annotation cannot be invoked cross-domain and can only have exactly one taint across all invocations. This ensures that the arguments, return and function body only touch the same taint. 

#### General Constraints on Output and Setup of Auxiliary Decision Variables

Every global variable and function entry must be assigned to a valid enclave.
Instructions and parameters are assigned the same enclave as their containing
functions.  Annotations can not assigned to a valid enclave and they must be
assigned to `nullEnclave`.

```minizinc
constraint :: "VarNodeHasEnclave"               forall (n in VarNode)            (nodeEnclave[n]!=nullEnclave);
constraint :: "FunctionHasEnclave"              forall (n in FunctionEntry)      (nodeEnclave[n]!=nullEnclave);
constraint :: "InstHasEnclave"                  forall (n in Inst)               (nodeEnclave[n]==nodeEnclave[hasFunction[n]]);
constraint :: "ParamHasEnclave"                 forall (n in Param)              (nodeEnclave[n]==nodeEnclave[hasFunction[n]]);
constraint :: "AnnotationHasNoEnclave"          forall (n in Annotation)         (nodeEnclave[n]==nullEnclave);
```

The level of every node that is not an annotation stored in the `nodeLevel`
decision variable must match the level of the enclave the node is assigned to 

```minizinc
constraint :: "NodeLevelAtEnclaveLevel"       forall (n in NonAnnotation)      (hasLabelLevel[taint[n]] == hasEnclaveLevel[nodeEnclave[n]]);
```

Only function entry nodes can be assigned a function annotation label.
Furthermore, only the user can bless a function with a function annotation 
(that gets be passed to the solver through the input).  

```minizinc
constraint :: "FnAnnotationForFnOnly"         forall (n in NonAnnotation)      (isFunctionAnnotation[taint[n]] -> isFunctionEntry(n));
constraint :: "FnAnnotationByUserOnly"        forall (n in FunctionEntry)      (isFunctionAnnotation[taint[n]] -> userAnnotatedFunction[n]);
```

If a node `n` is contained in an unannotated function then the CLE label taint
assigned to the node must match that of the containing function. In other
words, since unannotated functions must be singly tainted, all noded contained
within the function must have the same taint as the function.

```minizinc
constraint :: "UnannotatedFunContentTaintMatch"
 forall (n in NonAnnotation where hasFunction[n]!=0) (userAnnotatedFunction[hasFunction[n]] == false -> taint[n] == ftaint(n));
```

If the node `n` is contained in an user annotated function, then the CLE label
taint assigned to the node must be allowed by the CLE JSON of the function
annotation in the argument taints, return taints, or code body taints. In other
words, any node contained within a function blessed with a function-annotation
by the user can only contain nodes with taints that are explicitly permitted
(to be coerced) by the function annotation.

```minizinc
constraint :: "AnnotatedFunContentCoercible"
 forall (n in NonAnnotation where hasFunction[n]!=0 /\ isFunctionEntry(n)==false) 
  (userAnnotatedFunction[hasFunction[n]] -> isInArctaint(ftaint(n), taint[n], hasLabelLevel[taint[n]]));
```

#### Constraints on the Cross-Domain Control Flow

The control flow can never leave an enclave, unless it is done through an
approved cross-domain call, as expressed in the following three constraints.
The only control edges allowed in the cross-domain cut are either call
invocations or returns. For any call invocation edge in the cut, the function
annotation of the function entry being called must have a CDF that allows (with
or without redaction) the level of the label assigned to the callsite.  The
label assigned to the callsite must have a node annotation with a CDF that
allows the data to be shared with the level of the (taint of the) function
entry being called.

```minizinc
constraint :: "NonCallControlEnclaveSafe"     forall (e in ControlDep_NonCall where isAnnotation(hasDest[e])==false) (xdedge(e)==false);
constraint :: "XDCallBlest"                   forall (e in ControlDep_CallInv) (xdedge(e) -> userAnnotatedFunction[hasDest[e]]);
constraint :: "XDCallAllowed"
 forall (e in ControlDep_CallInv) (xdedge(e) -> allowOrRedact(cdfForRemoteLevel[edTaint(e), hasLabelLevel[esTaint(e)]]));
```

Notes: 

1. No additional constraint is needed for control call return edges; checking
   the corresponding call invocation suffices, however, later on we will check the
   data return edge when checking label coercion.  
2. The conflict analyzer is working with the annotated unpartitioned
   code and not the fully partitioned code which will includes autogenerated
   code. The actual cut in the partitioned code with autogenerated code to
   handle cross-domain communications will be between the cross-domain send 
   and receive functions that are several steps removed from the cut in the
   `xdedge` function at this stage of analysis. The autogenerated code will 
   apply annotations to cross-domain data annotations that contain GAPS tags,
   and they will have a different label. So we cannot check whether the label 
   of the arguments passed from the caller matches the argument taints allowed by
   the called function, or if the return taints match the value to which the 
   return value is assigned. A downstream verification tool will check this.

#### Constraints on the Cross-Domain Data Flow

Data can only leave an enclave through parameters or return of valid
cross-domain call invocations, as expressed in the following three constraints. 

Any data dependency edge that is not a data return cannot be in the
cross-domain cut.  For any data return edge in the cut, the taint of the source
node (the returned value in the callee) must have a CDF that allows the data to
be shared with the level of the taint of the destination node (the return site 
in the caller). For any parameter passing edge in the cut, the taint of the source
node (what is passed by the callee) must have a CDF that allows the data to be
shared with the level of the taint of the destination node (the corresponding
actual parameter node of the callee function).

```minizinc
constraint :: "NonRetNonParmDataEnclaveSafe"
 forall (e in DataEdgeEnclaveSafe) (xdedge(e) == false);
constraint :: "XDCDataReturnAllowed"
 forall (e in DataDepEdge_Ret) (xdedge(e) -> allowOrRedact(cdfForRemoteLevel[esTaint(e), hasLabelLevel[edTaint(e)]]));
constraint :: "XDCParmAllowed"
 forall (e in DataDepEdge_ArgPass_In union DataDepEdge_ArgPass_Out)
   (xdedge(e) -> allowOrRedact(cdfForRemoteLevel[esTaint(e), hasLabelLevel[edTaint(e)]]));
```

#### Constraints on Taint Coercion Within Each Enclave {#coercion}

While the constraints on the control dependency and data dependency that
we discussed governed data sharing at the cross-domain cut, we still need
to perform taint checking to ensure that data annotated with different 
labels inside each enclave are managed correctly and only when the
mixing of the taints is explicitly allowed by the user.

Labels can be coerced (i.e., nodes of a given PDG edge can be permitted to
have different label assigments) inside an enclave only through user annotated
functions.  

All data dependencies where one node is contained in an unannotated function and the other is in the function must have the same taint.

```minizinc
constraint :: "UnannotatedExternDataEdgeTaintsMatch"
  forall (e in DataDepEdge)
    (externUnannotated(e) -> esTaint(e) == edTaint(e));
```

In all data dependency edges into an annotated function where one node lies outside the function
and the other inside the function, the node outside the function must have a taint which is listed in the function's argument, body or return taints.

```minizinc
constraint :: "AnnotatedExternDataEdgeInArctaints"
  forall (e in DataDepEdge)
    ((srcFunExternAnnotated(e) ->
       isInArctaint(esFunTaint(e), edTaint(e), hasLabelLevel[edTaint(e)])) /\
     (destFunExternAnnotated(e) ->
       isInArctaint(edFunTaint(e), esTaint(e), hasLabelLevel[esTaint(e)])));
```

If a return edge comes from an unnannotated function, then the sources and 
destinations of the edge must have the same taint.

```minizinc
constraint :: "retEdgeFromUnannotatedTaintsMatch"
  forall (e in DataDepEdge_Ret union DataDepEdge_Indirect_Ret)
    (not sourceAnnotFun(e)
      -> esTaint(e) == edTaint(e));
```

If a return edge comes from an annotated function, then the source must
be in the rettaints for that function, or that edge must be cross-domain.

```minizinc
constraint :: "returnNodeInRettaints"
  forall (e in DataDepEdge_Ret union DataDepEdge_Indirect_Ret)
    (sourceAnnotFun(e)
      -> (hasRettaints[esFunCdf(e), edTaint(e)] \/ xdedge(e)));
```

For parameter passing edges into unannotated functions, the source and destination 
nodes must have the same taint.

For parameter passing edges into annotated functions, the source must be in the corresponding argtaint for that argument's position, or it must be a cross-domain edge.

```minizinc
constraint :: "argPassInEdgeToUnannotatedTaintsMatch"
  forall (e in DataDepEdge_ArgPass_In union DataDepEdge_ArgPass_Indirect_In)
    (not destAnnotFun(e)
      -> esTaint(e) == edTaint(e));
constraint :: "argPassInSourceInArgtaints"
  forall (e in DataDepEdge_ArgPass_In union DataDepEdge_ArgPass_Indirect_In)
    (destAnnotFun(e)
      -> hasArgtaints[edFunCdf(e), hasParamIdx[hasDest[e]], esTaint(e)] \/ xdedge(e));
```

All indirect calls (calls through a function pointer) must not be cross-domain.
Note: ArgPass and Ret edges of indirect calls must satisfy the same constraints as their direct call counter-parts. They are included in the unions above for inter-function edges.

```minizinc 
constraint :: "IndirectCallSameEnclave"
  forall (e in ControlDep_Indirect_CallInv)
    (xdedge(e) == false);
```

If two global variables are connected by a def-use edge, they must have the same taint.

```minizinc 
constraint :: "GlobalDefUseTaintsMatch"
  forall (e in DataDepEdge_GlobalDefUse)
    (esTaint(e) == edTaint(e));
```

Any function whose address is taken in the program cannot have a function annotation. Indirect callees, as a consequence, cannot have a function annotation, but we include the constraint separately for completeness.

```minizinc 
constraint :: "FunctionPtrSinglyTainted"
  forall (e in DataDepEdge_PointsTo)
    (isFunctionEntry(hasDest[e]) -> not userAnnotatedFunction[hasDest[e]]);
constraint :: "IndirectCalleeSinglyTainted"
  forall (e in ControlDep_Indirect_CallInv)
    (not userAnnotatedFunction[hasDest[e]]);
```

Note: For every indirect call edge, we should have a corresponding points to edge for the function pointer at the call site.   

#### points-to edge constraints

Cross-domain points to edges must have compatible taints, meaning the destination taint
must be allowed to be shared to the remote.

```minizinc
constraint :: "PointsToXD"
  forall (e in DataDepEdge_PointsTo)
    (xdedge(e) -> (allowOrRedact(cdfForRemoteLevel[edTaint(e), hasLabelLevel[esTaint(e)]]) /\ not isFunctionEntry(hasDest[e]))); 
```

Note: the reason that points-to edges cannot be wholesale eliminated from the cut is because CLOSURE allows arrays of primitives to be passed cross-domain. The extra `not isFunctionEntry(hasDest[e])` is not strictly needed, but included so that function pointers passed cross domain are caught by the solver and not at a downstream step. 

Points-to edges must match in taint. Note that this is true despite whether that edge's source and destination is contained within an annotated function. Sometimes pointer dependencies are captured by a chain of points-to edges which may be intra-function edges. Therefore we restrict intra-function points-to edges to have the same taint, even in annotated functions. This puts a limit on what can be coerced within an annotated function to only include initialized non-pointer data. If pointers must be coerced, then the data at those pointers needs to be copied. 

```minizinc 
constraint :: "PointsToTaintsMatch"
  forall (e in DataDepEdge_PointsTo)
    ((not xdedge(e)) -> esTaint(e) == edTaint(e));
```

#### Solution Objective

In this model, we require the solver to provide a satisfying assignment that
minimizes the total number of call invocation that are in the cross-domain cut.
Other objectives could be used instead.

```minizinc
var int: objective = sum(e in ControlDep_CallInv where xdedge[e])(1);
solve minimize objective;
```
