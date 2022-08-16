### Detailed MiniZinc constraint model **XXX: Ready for Review** {#constraints}


In this section, we present an informal statement of constraints to be enforced by our conflict analyzer. We then present the main constraints coded in minizinc used by our model to achieve these constraints.More
about minizinc, it's usage and syntax can be found [here](https://www.minizinc.org/). 

In the model below, the `nodeEnclave` decision variable stores the enclave
assignment for each node, the `taint` decision variable stores the label
assignment for each node, and the `xdedge` decision variable stores whether a
given edge is in the enclave cut (i.e., the source and destination nodes of the
edge are in different enclaves. Several other auxiliary decision variables are
used in the constraint model to express the constraints or for efficient
compilation. 

The solver will attempt to assign a node annotation label to all nodes except a user annotated function. Only user annotated functions may have a function annotation. Functions lacking a function annotation cannot be invoked cross-domain and can only have exactly one taint accross all invocations. This ensures that the arguments, return and function body only touch the same taint. 


### General Constraints

* Instance and class fields can be annotated by the user with node annotations.
* Instance and class methods can be annotated by the user with method annotations.
* Constructors can be annotated by the user with constructor annotations.
* Only node annotations can be assigned by the solver to unannotated fields, methods or constructors.
* Method or constructor annotations cannot be assigned by the solver (these can only be assigned by the user). 
* Each class containing one or more annotated elements (constructor, method, or field) must be assigned to exactly one enclave. 
* Each class containing no annotated elements must be assigned to at least one enclave and at most every enclave.
* Across all accesses/invocations of an unannotated element, it may touch at most one label at each level.
* All elements (constructor, method, or field) of a class instance must be assigned the same enclave as the instance itself. This entails separate constraints for constructors, instance methods, instance fields, static methods and static fields.
* Contained nodes and parameters are assigned the same enclave(s) as their containing methods.  
* Annotations can not be assigned to a valid enclave and they must be assigned to `nullEnclave`.


* Each (node,level) pair is assigned at most one valid label with that level.

* Only method entry nodes can be assigned a method annotation label.
* Only constructor entry nodes can be assigned a constructor annotation label.

```minizinc
constraint :: "NodeLevelAtTaintLevel"         
forall (n in NonAnnotation)      
( forall(l in nonNullEnclave) 
( nodeLevel[n,l]==hasLabelLevel[taint[n,l]]));

constraint :: "NodeLevelAtEnclaveLevel"       
forall (n in NonAnnotation)      
( forall(l in nonNullEnclave) 
( nodeLevel[n,l]==hasEnclaveLevel[nodeEnclave[n,l]]));

constraint :: "CannotBeNullEnclave"       
forall (n in NonAnnotation)      
( forall(l in nonNullEnclave) 
( nullEnclave != nodeEnclave[n,l]));

constraint :: "FnAnnotationForFnOnly"         
forall (n in NonAnnotation)      
( forall(l in nonNullEnclave)
(isFunctionAnnotation[taint[n,l]] -> isFunctionEntry(n)));

constraint :: "FnAnnotationByUserOnly"        
forall (n in FunctionEntry)      
( forall(l in nonNullEnclave)
(isFunctionAnnotation[taint[n,l]] == userAnnotatedFunction[n]));

constraint :: "NodesHaveClassEnclave"
 forall (n in PDGNodeIdx) 
 (forall (e in nonNullEnclave) 
 ((classEnclave[hasClass[n],e]) == true -> nodeEnclave[n,e] == e));

constraint :: "UnannotatedFunContentTaintMatch"
 forall (n in PDGNodeIdx) 
 (forall (l in nonNullEnclave) 
 (userAnnotatedFunction[hasFunction[n]]==false -> taint[n,l]==ftaint[n,l]));


constraint :: "ForceAnnotFuncToAnnoLvl"
forall (n in FunctionEntry) 
(forall (l in nonNullEnclave) 
(userAnnotatedFunction[hasFunction[n]] -> hasLabelLevel[taint[n,l]]==hasLabelLevel[ftaint[n,l]]));


constraint :: "AnnotatedFunContentCoercible"
 forall (n in PDGNodeIdx where  isFunctionEntry(n)==false)  
 (forall (l in nonNullEnclave)
  (userAnnotatedFunction[hasFunction[n]] -> isInArctaint(ftaint[n,l], taint[n,l], hasLabelLevel[taint[n,l]])));
```

### 2.2 Constraints on the Cross-Domain Control Flow

The control flow can never leave an enclave, unless it is done through an
approved cross-domain call, as expressed in the following constraints.

1) The only control edges allowed in the cross-domain cut are either call
invocations or returns. 

2) For any call invocation edge in the cut, the method annotation of the method entry being called must have a CDF that allows (with or without redaction) the level of the label assigned to the callsite (caller).  

```minizinc
constraint :: "EdgeSourceEnclave"             
forall (e in PDGEdgeIdx)        
(forall (l in nonNullEnclave) 
(esEnclave[e,l]==nodeEnclave[hasSource[e],l]));

constraint :: "EdgeDestEnclave"               
forall (e in PDGEdgeIdx)        
(forall (l in nonNullEnclave) 
(edEnclave[e,l]==nodeEnclave[hasDest[e],l]));


constraint :: "EdgeInEnclaveCut"              
forall (e in ControlDep_CallInv)         
(
  if (isClassAnnotated[hasClass[hasDest[e]]] == true)
  then
  (
    forall (l in nonNullEnclave) 
      (xdedge[e,l]==(esEnclave[e,l]!=edEnclave[e,l]))
  )
  else
  (
    forall (l in nonNullEnclave) 
    (xdedge[e,l]==false)
  )
  endif
);


constraint :: "OnlyCallsParamsAndRetsInCut"              
forall (e in ControlDep_NonCall)         
(forall (l in nonNullEnclave) 
(xdedge[e,l]==false));

constraint :: "SourceFunctionAnnotation"
 forall (e in ControlDep_CallInv union ControlDep_CallRet) 
 (forall (l in nonNullEnclave) 
 (esFunTaint[e,l] == 
 (if sourceAnnotFun(e) 
 then taint[hasFunction[hasSource[e]],l] 
 else nullCleLabel endif)));

constraint :: "DestFunctionAnnotation"
 forall (e in ControlDep_CallInv union ControlDep_CallRet) 
 (forall (l in nonNullEnclave)(edFunTaint[e,l] == 
 (if destAnnotFun(e) 
 then taint[hasFunction[hasDest[e]],l] 
 else nullCleLabel endif)));

constraint :: "SourceCdfForDestLevel"
 forall (e in ControlDep_CallInv union ControlDep_CallRet) 
 (forall (l in nonNullEnclave)(esFunCdf[e,l] == 
 (if sourceAnnotFun(e) 
 then cdfForRemoteLevel[esFunTaint[e,l], hasLabelLevel[taint[hasDest[e],l]]] 
 else nullCdf endif)));

constraint :: "DestCdfForSourceLevel"
 forall (e in ControlDep_CallInv union ControlDep_CallRet) 
 (forall (l in nonNullEnclave) (edFunCdf[e,l] == 
 (if destAnnotFun(e) then 
 cdfForRemoteLevel[edFunTaint[e,l], hasLabelLevel[taint[hasSource[e],l]]] 
 else nullCdf endif)));


constraint :: "XDCallBlest"                   
forall (e in ControlDep_CallInv) 
(forall (l in nonNullEnclave) ( ( xdedge[e,l]) -> userAnnotatedFunction[hasDest[e]]));



constraint :: "XDCallAllowed"
 forall (e in ControlDep_CallInv) 
 (forall (l in nonNullEnclave) (
 xdedge[e,l] -> allowOrRedact(cdfForRemoteLevel[edTaint[e,l], hasLabelLevel[esTaint[e,l]]])));


```


### 2.3 Constraints on the Cross-Domain Data Flow

Data can only leave an enclave through parameters or return of valid
cross-domain call invocations, as expressed in the following three constraints. 

1) Any data dependency edge that is not a parameter or data return cannot be in the
cross-domain cut.  

2) For any data return edge in the cut, the taint of the source
node (the returned value in the callee) must have a CDF that allows the data to
be shared with the level of the taint of the destination node (the return site 
in the caller). 

3) For any parameter passing edge in the cut, the taint of the source
node must have a CDF that allows the data to be shared with the level of the taint of the destination node. This applies to the input parameters going from caller to callee and output parameters going from callee back to the caller.

Note: For cross domain calls, the callee is assigned to a fixed enclave level. The caller may be unannotated and the label to be considered (e.g. for argument passing checks) would corrsepond to the label applicable at the level of the caller (instance).

```minizinc
constraint :: "XDCDataReturnAllowed"
 forall (e in DataDepEdge_Ret) 
 (forall (l in nonNullEnclave)  (
  xdedge[e,l] -> allowOrRedact(cdfForRemoteLevel[esFunTaint[e,l], hasLabelLevel[edTaint[e,l]]])));

constraint :: "XDCParmAllowed"
 forall (e in Parameter)     
 (forall (l in nonNullEnclave)  
 (xdedge[e,l] -> allowOrRedact(cdfForRemoteLevel[esFunTaint[e,l], hasLabelLevel[edTaint[e,l]]])));
```


### 2.4 Constraints on Taint Coercion Within Each Enclave

For each level, each node in an unannotated method or constructor must have the same taint as the containing unannotated method or constructor itself.

For each level, for each parameter or data dependency (including returns) edges with at least one end point in an unannotated method or constructor, both end points must have the same taint.

Unannotated methods can be assigned to multiple enclaves as long as they touch only one taint within that enclave. Annotated methods, on the other hand, can only be assigned to a single enclave/level.

Each node in an annotated method or constructor must have a taint that is allowed by the argument taints (argtaints), code taints (codtaints), or the return taints (rettaints) of the corresponding method/constructor annotation.

For each parameter-in or parameter-out edge connected to an argument of an annotated method or constructor, the taint of the remote (caller side) endpoint must be allowed by the argument taints (argtaints) for that argument in the annotation applied to the method or constructor.

For each data return edge of an annotated method or constructor, the taint of remote (caller side) endpoint must be allowed by the return taints (rettaints) of the annotation applied to the method or constructor.

For each data dependency edge (that is not a return or parameter edge) of an annotated method or constructor, the taint of both endpoints must be allowed by at least one of the following: argument taints (argtaints), code taints (codtaints), or return taints (rettaints) of the annotation applied to the method or constructor.


```minizinc
constraint :: "ArgumentTaintCoerced"
 forall (e in Parameter_In union Parameter_Out)
 (forall (l in nonNullEnclave)
  (if sourceAnnotFun(e) /\ xdedge[e,l] /\ isParam_ActualOut(hasSource[e]) /\ (hasParamIdx[hasSource[e]]>0)
   then hasArgtaints[esFunCdf[e,l], hasParamIdx[hasSource[e]], taint[hasDest[e],l]]
   else true 
   endif));


constraint :: "ReturnTaintCoerced"
 forall (e in DataDepEdge_Ret) 
 (forall (l in nonNullEnclave) 
 ((if sourceAnnotFun(e) /\ xdedge[e,l] 
 then hasRettaints[esFunCdf[e,l], taint[hasDest[e],l]]
 else true endif)));

constraint :: "DataTaintCoercedData"
 forall (e in DataEdgeNoRet)
(forall (l in nonNullEnclave)
  (if ( sourceAnnotFun(e))
   then (isInArctaint(esFunTaint[e,l], taint[hasDest[e],l], hasLabelLevel[taint[hasDest[e],l]]) /\
                       isInArctaint(esFunTaint[e,l], taint[hasSource[e],l], hasLabelLevel[taint[hasSource[e],l]]))
   else true
   endif));

```

### 2.5 Class Constraints


* For each level, all elements of a class that contains no annotated elements must have the same taint.

* All taints on a static field must be at the same level. Unfortunately this means that a class with a static field can only be assigned to a single enclave. This can be relaxed for final static variables because they will not change.

* The taint(s) of the object reference (this) must be allowed by the code taints (codtaints) of annotated methods. (If the object reference can take multiple labels, then unannotated methods are not possible within that class.)

* The taints of all elements of a class that contains an annotated element must have the same level, and the class is assigned to that enclave/level.


``` minizinc
constraint :: "ClassEnclaveNonNull" 
forall (cl in ClassNames)
  (exists (e in nonNullEnclave)
    (true == classEnclave[cl,e])
  );


constraint :: "BindClassLevelToEnclave" 
forall (cl in ClassNames)
  (forall (e in nonNullEnclave)
    (classTaintedAtLevel[cl, hasEnclaveLevel[e]] == classEnclave[cl,e])
  );

constraint :: "BindClassTaintedAtLevel" 
forall (n in PDGNodeIdx)
(
  (forall (e in nonNullEnclave)
    (classTaintedAtLevel[hasClass[n], hasLabelLevel[taint[n,e]]] == true)
  )
);


constraint :: "BindAnnoClassToEnclaveLevel"
forall (cl in ClassNames)
(
(isClassAnnotated[cl])-> exactlyone(l in nonNullEnclave)(classEnclave[cl,l]));

constraint :: "CheckFieldTaint"
forall (method in FunctionEntry)
(
  forall(field in methodsFieldAccess[method])
  (
    forall (l in nonNullEnclave) 
    (
      % Label level for fields of annotated classes is set by annotation
      % This constraint should be reviewed
       (not isClassAnnotated[hasClass[method]])-> 
       hasLabelLevel[fieldTaint[field,l]] == hasLabelLevel[ctaint[hasClass[method],l]] /\
      (
      if userAnnotatedFunction[method]==false
      then
        (fieldTaint[field,l] == ftaint[method,l])
      else
      % This may be an issue for demo
        (if field in ClassFields_Static
        then
        % static field can become multiply tainted at this point since inside annotated function
          false
          %true (demo requires this to be true since it uses several static fields)
        else
          true
        endif)
      endif
      )
    )
  )
);



```

#### Solution Objective

In this model, we require the solver to provide a satisfying assignment that
minimizes the total number of call invocation that are in the cross-domain cut.
Other objectives could be used instead.

```minizinc
var int: objective = sum(e in ControlDep_CallInv, l in nonNullEnclave where xdedge[e,l])(1);
solve minimize objective;
```


### Remarks and Limitations

* A limitation of the current model is that it supports at most one enclave per level.
 
* Class annotations are currently not used by CLE, but this can change in the future.

* Class static fields are handled imprecisely

* No mechanism exists to apply user-defined function annotations to a lambda function