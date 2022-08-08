### Detailed MiniZinc constraint model {#constraints}

The following assumes some familiarity with MiniZinc syntax. More
about MiniZinc, it's usage and syntax can be found [here](https://www.minizinc.org/).

In the model below, the `nodeEnclave` decision variable stores the enclave
assignment for each node, the `taint` decision variable stores the label
assignment for each node, and the `xdedge` decision variable stores whether a
given edge is in the enclave cut (i.e., the source and destination nodes of the
edge are in different enclaves. Several other auxiliary decision variables are
used in the constraint model to express the constraints or for efficient
compilation. They are described later in the model.

The solver will attempt to assign a node annotation label to all nodes except a user annotated function. Only user annotated functions may have a function annotation. Functions lacking a function annotation cannot be invoked cross-domain and can only have exactly one taint accross all invocations. This ensures that the arguments, return and function body only touch the same taint. 

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
decision variable must match:
 * the level of the label (taint) assigned to the node
 * the level of the enclave the node is assigned to 

```minizinc
constraint :: "NodeLevelAtTaintLevel"           forall (n in NonAnnotation)      (nodeLevel[n]==hasLabelLevel[taint[n]]);
constraint :: "NodeLevelAtEnclaveLevel"         forall (n in NonAnnotation)      (nodeLevel[n]==hasEnclaveLevel[nodeEnclave[n]]);
```

Only function entry nodes can be assigned a function annotation label.
Furthermore, only the user can bless a function with a function annotation 
(that gets be passed to the solver through the input).  

```minizinc
constraint :: "FnAnnotationForFnOnly"           forall (n in NonAnnotation)      (isFunctionAnnotation[taint[n]] -> isFunctionEntry(n));
constraint :: "FnAnnotationByUserOnly"          forall (n in FunctionEntry)      (isFunctionAnnotation[taint[n]] -> userAnnotatedFunction[n]);
```

Set up a number of auxiliary decision variables:
 * `ftaint[n]`: CLE label taint of the function containing node `n`
 * `esEnclave[e]`: enclave assigned to the source node of edge `e`
 * `edEnclave[e]`: enclave assigned to the destination node of edge `e`
 * `xdedge[e]`: source and destination nodes of `e` are in different enclaves
 * `esTaint[e]`: CLE label taint of the source node of edge `e`
 * `edTaint[e]`: CLE label taint of the destination node of edge `e`
 * `tcedge[e]`: source and destination nodes of `e` have different CLE label taints
 * `esFunTaint[e]`: CLE label taint of the function containing source node of edge `e`, `nullCleLabel` if not applicable
 * `edFunTaint[e]`: CLE label taint of the function containing destination node of edge `e`, `nullCleLabel` if not applicable
 * `esFunCdf[e]`: if the source node of the edge `e` is an annotated function, then this variable stores the CDF with the remotelevel equal to the level of the taint of the destination node; `nullCdf` if a valid CDF does not exist
 * `edFunCdf[e]`: if the destination node of the edge `e` is an annotated function, then this variable stores the CDF with the remotelevel equal to the level of the taint of the source node; `nullCdf` if a valid CDF does not exist


```minizinc
constraint :: "MyFunctionTaint"                 forall (n in PDGNodeIdx)         (ftaint[n] == (if hasFunction[n]!=0 then taint[hasFunction[n]] else nullCleLabel endif));
constraint :: "EdgeSourceEnclave"               forall (e in PDGEdgeIdx)         (esEnclave[e]==nodeEnclave[hasSource[e]]);
constraint :: "EdgeDestEnclave"                 forall (e in PDGEdgeIdx)         (edEnclave[e]==nodeEnclave[hasDest[e]]);
constraint :: "EdgeInEnclaveCut"                forall (e in PDGEdgeIdx)         (xdedge[e]==(esEnclave[e]!=edEnclave[e]));
constraint :: "EdgeSourceTaint"                 forall (e in PDGEdgeIdx)         (esTaint[e]==taint[hasSource[e]]);
constraint :: "EdgeDestTaint"                   forall (e in PDGEdgeIdx)         (edTaint[e]==taint[hasDest[e]]);
constraint :: "EdgeTaintMismatch"               forall (e in PDGEdgeIdx)         (tcedge[e]==(esTaint[e]!=edTaint[e]));
constraint :: "SourceFunctionAnnotation"        forall (e in PDGEdgeIdx)         (esFunTaint[e] == (if sourceAnnotFun(e) then taint[hasFunction[hasSource[e]]] else nullCleLabel endif));
constraint :: "DestFunctionAnnotation"          forall (e in PDGEdgeIdx)         (edFunTaint[e] == (if destAnnotFun(e) then taint[hasFunction[hasDest[e]]] else nullCleLabel endif));
constraint :: "SourceCdfForDestLevel"           forall (e in PDGEdgeIdx)         (esFunCdf[e] == (if sourceAnnotFun(e) then cdfForRemoteLevel[esFunTaint[e], hasLabelLevel[edTaint[e]]] else nullCdf endif));
constraint :: "DestCdfForSourceLevel"           forall (e in PDGEdgeIdx)         (edFunCdf[e] == (if destAnnotFun(e) then cdfForRemoteLevel[edFunTaint[e], hasLabelLevel[esTaint[e]]] else nullCdf endif));
```

If a node `n` is contained in an unannotated function then the CLE label taint
assigned to the node must match that of the containing function. In other
words, since unannotated functions must be singly tainted, all noded contained
within the function must have the same taint as the function.

```minizinc
constraint :: "UnannotatedFunContentTaintMatch" forall (n in NonAnnotation where hasFunction[n]!=0) (userAnnotatedFunction[hasFunction[n]]==false -> taint[n]==ftaint[n]);
```

If the node `n` is contained in an user annotated function, then the CLE label
taint assigned to the node must be allowed by the CLE JSON of the function
annotation in the argument taints, return taints, or code body taints. In other
words, any node contained within a function blessed with a function-annotation
by the user can only contain nodes with taints that are explicitly permitted
(to be coerced) by the function annotation.

```minizinc
constraint :: "AnnotatedFunContentCoercible"    forall (n in NonAnnotation where hasFunction[n]!=0 /\ isFunctionEntry(n)==false) (userAnnotatedFunction[hasFunction[n]] -> isInArctaint(ftaint[n], taint[n], hasLabelLevel[taint[n]]));
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
constraint :: "NonCallControlEnclaveSafe"      forall (e in ControlDep_NonCall where isAnnotation(hasDest[e])==false) (xdedge[e]==false);
constraint :: "XDCallBlest"                    forall (e in ControlDep_CallInv) (xdedge[e] -> userAnnotatedFunction[hasDest[e]]);
constraint :: "XDCallAllowed"                  forall (e in ControlDep_CallInv) (xdedge[e] -> allowOrRedact(cdfForRemoteLevel[edTaint[e], hasLabelLevel[esTaint[e]]]));
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
   `xdedge` variable at this stage of analysis. The autogenerated code will 
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
constraint :: "NonRetNonParmDataEnclaveSafe"   forall (e in DataEdgeNoRet)      (xdedge[e]==false);
constraint :: "XDCDataReturnAllowed"           forall (e in DataDepEdge_Ret)    (xdedge[e] -> allowOrRedact(cdfForRemoteLevel[esTaint[e], hasLabelLevel[edTaint[e]]]));
constraint :: "XDCParmAllowed"                 forall (e in Parameter)          (xdedge[e] -> allowOrRedact(cdfForRemoteLevel[esTaint[e], hasLabelLevel[edTaint[e]]]));
```

#### Constraints on Taint Coercion Within Each Enclave

While the constraints on the control dependency and data depdendency that
we discussed governed data sharing at the cross-domain cut, we still need
to perform taint checking to ensure that data annotated with different 
labels inside each enclave are managed correctly and only when the
mixing of the taints is explcitly allowed by the user.

Labels can be cooerced (i.e., nodes of a given PDG edge can be permitted to
have different label assigments) inside an enclave only through user annotated
functions.  To track valid label coercion across a PDG edge `e`, the model uses
an additional auxiliary decision variable called `coerced[e]`.

Any data dependency or parameter edge that is intra-enclave (not in the
cross-domain cut) and with different CLE label taints assigned to the source
and destination nodes must be coerced (through an annotated function).

Note: one may wonder whether a similar constraint must be added for control 
dependency edges at the entry block for completeness. Such a constraint is 
not necessary given our inclusion of the `UnannotatedFunContentTaintMatch` and
`AnnotatedFunContentCoercible` constraints discussed earlier. 
```minizinc
constraint :: "TaintsSafeOrCoerced"            forall (e in DataEdgeParam)      ((tcedge[e] /\ (xdedge[e]==false)) -> coerced[e]);

```

If the edge is a paremeter in or parameter out edege, then it can be coerced if
and only if the associated function annotation has the taint of the other node
in the argument taints for the corresponding parameter index. In other words,
what is passed in through this parameter has a taint allowed by the function
annotation.

```minizinc
constraint :: "ArgumentTaintCoerced"
 forall (e in Parameter_In union Parameter_Out)
  (if     destAnnotFun(e)   /\ isParam_ActualIn(hasDest[e])    /\ (hasParamIdx[hasDest[e]]>0)
   then coerced[e] == hasArgtaints[edFunCdf[e], hasParamIdx[hasDest[e]], esTaint[e]]
   elseif sourceAnnotFun(e) /\ isParam_ActualOut(hasSource[e]) /\ (hasParamIdx[hasSource[e]]>0)
   then coerced[e] == hasArgtaints[esFunCdf[e], hasParamIdx[hasSource[e]], edTaint[e]]
   else true 
   endif);
```

If the edge is a data return edge, then it can be coerced if and only if the
associated function annotation has the taint of the other node in the return
taints.

```minizinc
constraint :: "ReturnTaintCoerced"            forall (e in DataDepEdge_Ret)     (coerced[e] == (if sourceAnnotFun(e) then hasRettaints[esFunCdf[e], edTaint[e]] else false endif));
```

If the edge is a data dependency edge (and not a return or parameter edge),
then it can be coerced if and only if the associated function annotation allows
the taint of the other node in the argument taints of any parameter, 

Note that this constraint might appear seem redundant given the
`AnnotatedFunContentCoercible` constraint discussed earlier. On closer
inspection we can see that the following constraint also includes edges 
between nodes in the function and global/static variables; the earlier 
constraint dows not. There is overlap between the constraints, so some
refinement is possible, which may make the model a little harder to understand.

```minizinc
constraint :: "DataTaintCoerced"
 forall (e in DataEdgeNoRetParam)
  (if (hasFunction[hasSource[e]]!=0 /\ hasFunction[hasDest[e]]!=0 /\ hasFunction[hasSource[e]]==hasFunction[hasDest[e]])
   then coerced[e] == (isInArctaint(esFunTaint[e], edTaint[e], hasLabelLevel[edTaint[e]]) /\
                       isInArctaint(esFunTaint[e], esTaint[e], hasLabelLevel[esTaint[e]]))     % source and dest taints okay
   elseif (isVarNode(hasDest[e]) /\ hasFunction[hasSource[e]]!=0)
   then coerced[e] == (isInArctaint(esFunTaint[e], edTaint[e], hasLabelLevel[edTaint[e]]) /\
                       isInArctaint(esFunTaint[e], esTaint[e], hasLabelLevel[esTaint[e]]))
   elseif (isVarNode(hasSource[e]) /\ hasFunction[hasDest[e]]!=0)
   then coerced[e] == (isInArctaint(edFunTaint[e], esTaint[e], hasLabelLevel[esTaint[e]]) /\
                       isInArctaint(edFunTaint[e], edTaint[e], hasLabelLevel[edTaint[e]]))
   else coerced[e] == false
   endif);
```

#### Solution Objective

In this model, we require the solver to provide a satisfying assignment that
minimizes the total number of call invocation that are in the cross-domain cut.
Other objectives could be used instead.

```minizinc
var int: objective = sum(e in ControlDep_CallInv where xdedge[e])(1);
solve minimize objective;
```
