# Appendices: format documentation and examples

## CLE Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "com.perspectalabs.gaps-closure.cle",
    "$comment": "JSON schema for GAPS-Closure CLE json definition",
    
    "oneOf":[
        {
            "description": "List of CLE entries",
            "type": "array",
            "default": [],
            "items": { "$ref": "#/definitions/cleLabel" }
        },
        {
          "$ref": "#/definitions/rootNode"
        }
    ],

    "definitions": {
        "guarddirectiveOperationTypes": {
            "$comment": "the guarddirective type enum",
            "description": "[ENUM] Guard Directive",
            "enum": [
                "allow",
                "block",
                "redact"
            ]
        },
        "directionTypes": {
            "$comment": "the direction type enum",
            "description": "[ENUM] traffic direction",
            "type": "string",
            "enum": [
                "egress",
                "ingress",
                "bidirectional"
            ]
        },
        
        "guarddirectiveTypes":{
            "description": "Guard Directive parameters",
            "type": "object",
            "properties": {
                "operation":{
                    "$ref": "#/definitions/guarddirectiveOperationTypes"
                },
                "oneway": {
                    "description": "Communication only in one direction",
                    "type": "boolean",
                    "default": false
                    
                },
                "gapstag": {
                    "description": "Gaps tag to link remote CLE data [mux,sec,type]",
                    "type": "array",
                    "maxLength": 3,
                    "minLength": 3,
                    "items":[
                        {
                            "type": "number",
                            "minimum": 0,
                            "description": "mux value"
                        },
                        {
                            "type": "number",
                            "minimum": 0,
                            "description": "sec value"
                        },
                        {
                            "type": "number",
                            "minimum": 0,
                            "description": "type value"
                        }
                    ]
                }
            }
        },
        
        "argtaintsTypes":{
            "description": "argument taints",
            "type": "array",
            "default": [],
            "uniqueItems": false,
            "items": {
                "description": "Taint levels of each argument",
                "type": "array",
                "default": [],
                "items":{
                    "type": "string",
                    "description": "CLE Definition Name"
                }
            }
        },
        
        "cdfType": {
            "description": "Cross Domain Flow",
            "type": "object",
            "properties": {
                "remotelevel":{
                    "description": "The remote side's Enclave",
                    "type": "string"
                },
                "direction":{
                    "$ref": "#/definitions/directionTypes"
                },
                "guarddirective":{
                    "$comment": "active version guarddirective",
                    "$ref": "#/definitions/guarddirectiveTypes"
                },
                "guardhint":{
                    "$comment": "deprecated version of guarddirective",
                    "$ref": "#/definitions/guarddirectiveTypes"
                },
                "argtaints":{
                    "$ref": "#/definitions/argtaintsTypes"
                },
                "codtaints":{
                    "description": "Taint level",
                    "type": "array",
                    "default": [],
                    "items":{
                        "type": "string",
                        "description": "CLE Definition Name"
                    }
                },
                "rettaints":{
                    "description": "Return level",
                    "type": "array",
                    "default": [],
                    "items":{
                        "type": "string",
                        "description": "CLE Definition Name"
                    }
                },
                "idempotent":{
                    "description": "Idempotent Function",
                    "type": "boolean",
                    "default": true
                },
                "num_tries":{
                    "description": "Num tries",
                    "type": "number",
                    "default": 5
                },
                "timeout":{
                    "description": "Timeout",
                    "type": "number",
                    "default": 1000
                },
                "pure":{
                    "description": "Pure Function",
                    "type": "boolean",
                    "default": false
                }
            },
            "dependencies": {
                "argtaints": {
                    "required": ["argtaints", "codtaints", "rettaints"]
                },
                "codtaints": {
                    "required": ["argtaints", "codtaints", "rettaints"]
                },
                "rettaints": {
                    "required": ["argtaints", "codtaints", "rettaints"]
                }
            },
            "oneOf":[
                {
                    "required": ["remotelevel", "direction", "guarddirective"]
                },
                {
                    "required": ["remotelevel", "direction", "guardhint"]
                }
            ]
        },
        
        "cleLabel":{
            "type": "object",
            "required": ["cle-label", "cle-json"],
            "description": "CLE Lable (in full clemap.json)",
            "additionalProperties": false,
            
            "properties": {
                "cle-label": {
                    "description": "Name of the CLE label",
                    "type": "string"
                },
                "cle-json":{
                    "$ref": "#/definitions/rootNode"
                }
            }
        },
        
        "rootNode":{
            "type": "object",
            "required": ["level"],
            "description": "CLE Definition",
            "additionalProperties": false,
            "properties": {
                "$schema":{
                    "description": "The cle-schema reference (for standalone json files)",
                    "type": "string"
                },
                "$comment":{
                    "description": "Optional comment entry",
                    "type": "string"
                },
                "level":{
                    "description": "The enclave level",
                    "type":"string"
                },
                "cdf": {
                    "description": "List of cross domain flows",
                    "type": "array",
                    "uniqueItems": true,
                    "default": [],
                    "items": { "$ref": "#/definitions/cdfType" }
                }
            }
        }
    }
}
```

## PDG

## topology.json

The `topology.json` generated for example1 is as follows:

```json
{
  "source_path": "/workspaces/build/apps/examples/example1/refactored",
  "enclaves": [
    "purple_E",
    "orange_E"
  ],
  "levels": [
    "purple",
    "orange"
  ],
  "functions": [
    {
      "name": "get_a",
      "level": "orange",
      "enclave": "orange_E",
      "line": 47
    },
    {
      "name": "ewma_main",
      "level": "purple",
      "enclave": "purple_E",
      "line": 69
    },
    {
      "name": "get_b",
      "level": "purple",
      "enclave": "purple_E",
      "line": 58
    },
    {
      "name": "calc_ewma",
      "level": "purple",
      "enclave": "purple_E",
      "line": 39
    },
    {
      "name": "main",
      "level": "purple",
      "enclave": "purple_E",
      "line": 87
    }
  ],
  "global_scoped_vars": []
}
```

## minizinc files -- constraint type declarations and constraints

### Type declarations  

```minizinc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PDG Nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: Inst_FunCall_start;
int: Inst_FunCall_end;
int: Inst_Ret_start;
int: Inst_Ret_end;
int: Inst_Br_start;
int: Inst_Br_end;
int: Inst_Other_start;
int: Inst_Other_end;
int: Inst_start;
int: Inst_end;

int: VarNode_StaticGlobal_start;
int: VarNode_StaticGlobal_end;
int: VarNode_StaticModule_start;
int: VarNode_StaticModule_end;
int: VarNode_StaticFunction_start;
int: VarNode_StaticFunction_end;
int: VarNode_StaticOther_start;
int: VarNode_StaticOther_end;
int: VarNode_start;
int: VarNode_end;

int: FunctionEntry_start;
int: FunctionEntry_end;

int: Param_FormalIn_start;
int: Param_FormalIn_end;
int: Param_FormalOut_start;
int: Param_FormalOut_end;
int: Param_ActualIn_start;
int: Param_ActualIn_end;
int: Param_ActualOut_start;
int: Param_ActualOut_end;
int: Param_start;
int: Param_end;

int: Annotation_Var_start;
int: Annotation_Var_end;
int: Annotation_Global_start;
int: Annotation_Global_end;
int: Annotation_Other_start;
int: Annotation_Other_end;
int: Annotation_start;
int: Annotation_end;

int: PDGNode_start;
int: PDGNode_end;

set of int: Inst = Inst_start .. Inst_end;

set of int: VarNode_StaticGlobal = VarNode_StaticGlobal_start .. VarNode_StaticGlobal_end;
set of int: VarNode_StaticModule = VarNode_StaticModule_start .. VarNode_StaticModule_end;
set of int: VarNode_StaticFunction = VarNode_StaticFunction_start .. VarNode_StaticFunction_end;
set of int: VarNode_StaticOther = VarNode_StaticOther_start .. VarNode_StaticOther_end;
set of int: VarNode = VarNode_start .. VarNode_end;

set of int: FunctionEntry = FunctionEntry_start .. FunctionEntry_end;

set of int: Param_FormalIn = Param_FormalIn_start .. Param_FormalIn_end;
set of int: Param_FormalOut = Param_FormalOut_start .. Param_FormalOut_end;
set of int: Param_ActualIn = Param_ActualIn_start .. Param_ActualIn_end;
set of int: Param_ActualOut = Param_ActualOut_start .. Param_ActualOut_end;
set of int: Param = Param_start .. Param_end;

set of int: Annotation_Var = Annotation_Var_start .. Annotation_Var_end;
set of int: Annotation_Global = Annotation_Global_start .. Annotation_Global_end;
set of int: Annotation_Other = Annotation_Other_start .. Annotation_Other_end;
set of int: Annotation  = Annotation_start .. Annotation_end;

set of int: PDGNodeIdx  = PDGNode_start .. PDGNode_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PDG Edges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: ControlDep_CallInv_start;
int: ControlDep_CallInv_end;
int: ControlDep_CallRet_start;
int: ControlDep_CallRet_end;
int: ControlDep_Entry_start;
int: ControlDep_Entry_end;
int: ControlDep_Br_start;
int: ControlDep_Br_end;
int: ControlDep_Other_start;
int: ControlDep_Other_end;
int: ControlDep_start;
int: ControlDep_end;

int: DataDepEdge_DefUse_start;
int: DataDepEdge_DefUse_end;
int: DataDepEdge_RAW_start;
int: DataDepEdge_RAW_end;
int: DataDepEdge_Ret_start;
int: DataDepEdge_Ret_end;
int: DataDepEdge_Alias_start;
int: DataDepEdge_Alias_end;
int: DataDepEdge_start;
int: DataDepEdge_end;

int: Parameter_In_start;
int: Parameter_In_end;
int: Parameter_Out_start;
int: Parameter_Out_end;
int: Parameter_Field_start;
int: Parameter_Field_end;
int: Parameter_start;
int: Parameter_end;

int: Anno_Global_start;
int: Anno_Global_end;
int: Anno_Var_start;
int: Anno_Var_end;
int: Anno_Other_start;
int: Anno_Other_end;
int: Anno_start;
int: Anno_end;

int: PDGEdge_start;
int: PDGEdge_end;

set of int: ControlDep_CallInv = ControlDep_CallInv_start .. ControlDep_CallInv_end;
set of int: ControlDep_CallRet = ControlDep_CallRet_start .. ControlDep_CallRet_end;
set of int: ControlDep_Entry = ControlDep_Entry_start .. ControlDep_Entry_end;
set of int: ControlDep_Br = ControlDep_Br_start .. ControlDep_Br_end;
set of int: ControlDep_Other = ControlDep_Other_start .. ControlDep_Other_end;
set of int: ControlDep = ControlDep_start .. ControlDep_end;

set of int: DataDepEdge_DefUse = DataDepEdge_DefUse_start .. DataDepEdge_DefUse_end;
set of int: DataDepEdge_RAW  = DataDepEdge_RAW_start .. DataDepEdge_RAW_end;
set of int: DataDepEdge_Ret  = DataDepEdge_Ret_start .. DataDepEdge_Ret_end;
set of int: DataDepEdge_Alias = DataDepEdge_Alias_start .. DataDepEdge_Alias_end;
set of int: DataDepEdge = DataDepEdge_start .. DataDepEdge_end;

set of int: Parameter_In = Parameter_In_start .. Parameter_In_end;
set of int: Parameter_Out = Parameter_Out_start .. Parameter_Out_end;
set of int: Parameter_Field = Parameter_Field_start .. Parameter_Field_end;
set of int: Parameter = Parameter_start .. Parameter_end;

set of int: Anno_Global = Anno_Global_start .. Anno_Global_end;
set of int: Anno_Var = Anno_Var_start .. Anno_Var_end;
set of int: Anno_Other = Anno_Other_start .. Anno_Other_end;
set of int: Anno = Anno_start .. Anno_end;

set of int: PDGEdgeIdx = PDGEdge_start .. PDGEdge_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Containing Function for PDG Nodes, Endpoints for PDG Edges, Indices of Fucntion Formal Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

array[PDGNodeIdx]     of int:  hasFunction;
array[PDGEdgeIdx]     of int:  hasSource;
array[PDGEdgeIdx]     of int:  hasDest;
array[Param]          of int:  hasParamIdx;
array[FunctionEntry]  of bool: userAnnotatedFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convenience Aggregations of PDG Nodes and Edges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set of int: Global              = VarNode_StaticGlobal union VarNode_StaticModule;
set of int: NonAnnotation       = Inst union VarNode union FunctionEntry union Param;
set of int: ControlDep_Call     = ControlDep_CallInv union ControlDep_CallRet;
set of int: ControlDep_NonCall  = ControlDep_Entry union ControlDep_Br union ControlDep_Other;
set of int: DataEdgeNoRet       = DataDepEdge_DefUse union DataDepEdge_RAW union DataDepEdge_Alias;
set of int: DataEdgeNoRetParam  = DataEdgeNoRet union Parameter;
set of int: DataEdgeParam       = DataDepEdge union Parameter;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Security Levels and Enclaves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enum Level;
enum Enclave;
array[Enclave] of Level: hasEnclaveLevel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLE Input Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enum cleLabel;
enum cdf;
enum GuardOperation = {nullGuardOperation, allow, deny, redact};
enum Direction      = {nullDirection, bidirectional, egress, ingress};

int: MaxFuncParms;  % Max number of function parameters in the program (C<128, C++<256)
set of int: parmIdx = 1..MaxFuncParms;

array[cleLabel]                       of Level:          hasLabelLevel;
array[cleLabel]                       of bool:           isFunctionAnnotation;

array[cdf]                            of cleLabel:       fromCleLabel;
array[cdf]                            of Level:          hasRemotelevel;
array[cdf]                            of GuardOperation: hasGuardOperation;
array[cdf]                            of Direction:      hasDirection;
array[cdf]                            of bool:           isOneway;
array[cleLabel, Level]                of cdf:            cdfForRemoteLevel;

set of cdf: functionCdf = { x | x in cdf where isFunctionAnnotation[fromCleLabel[x]]==true };

array[functionCdf, cleLabel]          of bool:           hasRettaints;
array[functionCdf, cleLabel]          of bool:           hasCodtaints;
array[functionCdf, parmIdx, cleLabel] of bool:           hasArgtaints;
array[functionCdf, cleLabel]          of bool:           hasARCtaints;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Debug flag and decision variables for the solver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bool:                                                    debug;

array[PDGNodeIdx]                     of var Enclave:    nodeEnclave;
array[PDGNodeIdx]                     of var Level:      nodeLevel;
array[PDGNodeIdx]                     of var cleLabel:   taint;
array[PDGNodeIdx]                     of var cleLabel:   ftaint;

array[PDGEdgeIdx]                     of var Enclave:    esEnclave;
array[PDGEdgeIdx]                     of var Enclave:    edEnclave;

array[PDGEdgeIdx]                     of var cleLabel:   esTaint;
array[PDGEdgeIdx]                     of var cleLabel:   edTaint;

array[PDGEdgeIdx]                     of var cleLabel:   esFunTaint;
array[PDGEdgeIdx]                     of var cleLabel:   edFunTaint;

array[PDGEdgeIdx]                     of var cdf:        esFunCdf;
array[PDGEdgeIdx]                     of var cdf:        edFunCdf;

array[PDGEdgeIdx]                     of var bool:       xdedge;
array[PDGEdgeIdx]                     of var bool:       tcedge;

array[PDGEdgeIdx]                     of var bool:       coerced;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```

### Constraints

```minizinc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flag to include/exclude debug output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

debug = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utility functions and predicates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

predicate isVarNode(var PDGNodeIdx: n)         = (n>=VarNode_start /\ n<=VarNode_end);
predicate isFunctionEntry(var PDGNodeIdx: n)   = (n>=FunctionEntry_start /\ n<=FunctionEntry_end);
predicate isAnnotation(var PDGNodeIdx: n)      = (n>=Annotation_start /\ n<=Annotation_end);
predicate isParam_ActualIn(var PDGNodeIdx: n)  = (n>=Param_ActualIn_start /\ n<=Param_ActualIn_end);
predicate isParam_ActualOut(var PDGNodeIdx: n) = (n>=Param_ActualOut_start /\ n<=Param_ActualOut_end);
predicate allowOrRedact(var cdf: c)            = (hasGuardOperation[c]==allow \/ hasGuardOperation[c]==redact);

predicate sourceAnnotFun(var PDGEdgeIdx: e) =
 (if hasFunction[hasSource[e]]!=0 then userAnnotatedFunction[hasFunction[hasSource[e]]] else false endif);

predicate destAnnotFun(var PDGEdgeIdx: e) =
 (if hasFunction[hasDest[e]]!=0 then userAnnotatedFunction[hasFunction[hasDest[e]]] else false endif);

predicate isInArctaint(var cleLabel: fan, var cleLabel: tnt, var Level: lvl) =
 (if isFunctionAnnotation[fan] then hasARCtaints[cdfForRemoteLevel[fan, lvl], tnt] else false endif);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic constraints on output decision variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

constraint :: "VarNodeHasEnclave"             forall (n in VarNode)            (nodeEnclave[n]!=nullEnclave);
constraint :: "FunctionHasEnclave"            forall (n in FunctionEntry)      (nodeEnclave[n]!=nullEnclave);
constraint :: "InstHasEnclave"                forall (n in Inst)               (nodeEnclave[n]==nodeEnclave[hasFunction[n]]);
constraint :: "ParamHasEnclave"               forall (n in Param)              (nodeEnclave[n]==nodeEnclave[hasFunction[n]]);
constraint :: "AnnotationHasNoEnclave"        forall (n in Annotation)         (nodeEnclave[n]==nullEnclave);

constraint :: "NodeLevelAtTaintLevel"         forall (n in NonAnnotation)      (nodeLevel[n]==hasLabelLevel[taint[n]]);
constraint :: "NodeLevelAtEnclaveLevel"       forall (n in NonAnnotation)      (nodeLevel[n]==hasEnclaveLevel[nodeEnclave[n]]);
constraint :: "FnAnnotationForFnOnly"         forall (n in NonAnnotation)      (isFunctionAnnotation[taint[n]] -> isFunctionEntry(n));
constraint :: "FnAnnotationByUserOnly"        forall (n in FunctionEntry)      (isFunctionAnnotation[taint[n]] -> userAnnotatedFunction[n]);

constraint :: "MyFunctionTaint"
 forall (n in PDGNodeIdx) (ftaint[n] == (if hasFunction[n]!=0 then taint[hasFunction[n]] else nullCleLabel endif));

constraint :: "UnannotatedFunContentTaintMatch"
 forall (n in NonAnnotation where hasFunction[n]!=0) (userAnnotatedFunction[hasFunction[n]]==false -> taint[n]==ftaint[n]);

constraint :: "AnnotatedFunContentCoercible"
 forall (n in NonAnnotation where hasFunction[n]!=0 /\ isFunctionEntry(n)==false) 
  (userAnnotatedFunction[hasFunction[n]] -> isInArctaint(ftaint[n], taint[n], hasLabelLevel[taint[n]]));

constraint :: "EdgeSourceEnclave"             forall (e in PDGEdgeIdx)         (esEnclave[e]==nodeEnclave[hasSource[e]]);
constraint :: "EdgeDestEnclave"               forall (e in PDGEdgeIdx)         (edEnclave[e]==nodeEnclave[hasDest[e]]);
constraint :: "EdgeInEnclaveCut"              forall (e in PDGEdgeIdx)         (xdedge[e]==(esEnclave[e]!=edEnclave[e]));

constraint :: "EdgeSourceTaint"               forall (e in PDGEdgeIdx)         (esTaint[e]==taint[hasSource[e]]);
constraint :: "EdgeDestTaint"                 forall (e in PDGEdgeIdx)         (edTaint[e]==taint[hasDest[e]]);
constraint :: "EdgeTaintMismatch"             forall (e in PDGEdgeIdx)         (tcedge[e]==(esTaint[e]!=edTaint[e]));

constraint :: "SourceFunctionAnnotation"
 forall (e in PDGEdgeIdx) (esFunTaint[e] == (if sourceAnnotFun(e) then taint[hasFunction[hasSource[e]]] else nullCleLabel endif));

constraint :: "DestFunctionAnnotation"
 forall (e in PDGEdgeIdx) (edFunTaint[e] == (if destAnnotFun(e) then taint[hasFunction[hasDest[e]]] else nullCleLabel endif));

constraint :: "SourceCdfForDestLevel"
 forall (e in PDGEdgeIdx) (esFunCdf[e] == (if sourceAnnotFun(e) then cdfForRemoteLevel[esFunTaint[e], hasLabelLevel[edTaint[e]]] else nullCdf endif));

constraint :: "DestCdfForSourceLevel"
 forall (e in PDGEdgeIdx) (edFunCdf[e] == (if destAnnotFun(e) then cdfForRemoteLevel[edFunTaint[e], hasLabelLevel[esTaint[e]]] else nullCdf endif));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control never leaves enclave except via valid XDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% XXX: broken input, annotations in controldep entry edge
constraint :: "NonCallControlEnclaveSafe"     forall (e in ControlDep_NonCall where isAnnotation(hasDest[e])==false) (xdedge[e]==false);
constraint :: "XDCallBlest"                   forall (e in ControlDep_CallInv) (xdedge[e] -> userAnnotatedFunction[hasDest[e]]);

constraint :: "XDCallAllowed"
 forall (e in ControlDep_CallInv) (xdedge[e] -> allowOrRedact(cdfForRemoteLevel[edTaint[e], hasLabelLevel[esTaint[e]]]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data never leaves enclave except via parameters or return for valid XDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

constraint :: "NonRetNonParmDataEnclaveSafe"  forall (e in DataEdgeNoRet)      (xdedge[e]==false);

constraint :: "XDCDataReturnAllowed"
 forall (e in DataDepEdge_Ret) (xdedge[e] -> allowOrRedact(cdfForRemoteLevel[esTaint[e], hasLabelLevel[edTaint[e]]]));

constraint :: "XDCParmAllowed"
 forall (e in Parameter)       (xdedge[e] -> allowOrRedact(cdfForRemoteLevel[esTaint[e], hasLabelLevel[edTaint[e]]]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Labels can only be cooerced inside enclave via parameters or return by noblest functions that are so blest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

constraint :: "TaintsSafeOrCoerced"           forall (e in DataEdgeParam)      ((tcedge[e] /\ (xdedge[e]==false)) -> coerced[e]);

% XXX: do we need something special for Parameter_Field?
constraint :: "ArgumentTaintCoerced"
 forall (e in Parameter_In union Parameter_Out)
  (if     destAnnotFun(e)   /\ isParam_ActualIn(hasDest[e])    /\ (hasParamIdx[hasDest[e]]>0)
   then coerced[e] == hasArgtaints[edFunCdf[e], hasParamIdx[hasDest[e]], esTaint[e]]
   elseif sourceAnnotFun(e) /\ isParam_ActualOut(hasSource[e]) /\ (hasParamIdx[hasSource[e]]>0)
   then coerced[e] == hasArgtaints[esFunCdf[e], hasParamIdx[hasSource[e]], edTaint[e]]
   else true 
   endif);

constraint :: "ReturnTaintCoerced"
 forall (e in DataDepEdge_Ret) (coerced[e] == (if sourceAnnotFun(e) then hasRettaints[esFunCdf[e], edTaint[e]] else false endif));

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solver objective
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var int: objective = sum(e in ControlDep_CallInv where xdedge[e])(1);
solve minimize objective;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solver output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output ["Domain assignments for globals:" ++ "\n"];
output [" GLOBAL   : " ++ show(x) ++ " -> " ++ show(nodeEnclave[x]) ++ "::" ++ show(taint[x]) ++ "::" ++ show(nodeLevel[x]) ++ "\n" | x in Global] ;
output ["Domain assignments for functions:" ++ "\n"];
output [" FUNCTION : " ++ show(x) ++ " -> " ++ show(nodeEnclave[x]) ++ "::" ++ show(taint[x]) ++ "::" ++ show(nodeLevel[x]) ++ "\n" | x in FunctionEntry ] ;
output ["Cross-domain cut:" ++ "\n"];
output [" XDCALL   : " ++ "(" ++ show(hasSource[e]) ++ ":" ++ show(taint[hasSource[e]]) ++ ")"
                       ++ "--[" ++ show(nodeEnclave[hasFunction[hasSource[e]]]) ++ "]"
                       ++ "--||-->"
                       ++ "[" ++ show(nodeEnclave[hasDest[e]]) ++ "]--"
                       ++ "(" ++ show(hasDest[e]) ++ ":" ++ show(taint[hasDest[e]]) ++ ")"
                       ++ "\n"
        | e in ControlDep_CallInv where fix(xdedge[e]==true)] ;

output [if debug then "Label and Enclave assignments to non-annotation nodes:\n" else "" endif];
output [" ASSIGN   : " ++
 show(n) ++ " " ++
 (if     (n>=VarNode_start       /\ n<=VarNode_end)       then "VarNode       "
  elseif (n>=FunctionEntry_start /\ n<=FunctionEntry_end) then "FunctionEntry "
  elseif (n>=Inst_start          /\ n<=Inst_end)          then "Inst          "
  elseif (n>=Param_start         /\ n<=Param_end)         then "Param         "
  else                                                         "Annotation    "
  endif)
 ++ "[" ++
 show(nodeEnclave[n])
 ++ "]::" ++ show(taint[n]) ++ "::" ++ show(nodeLevel[n]) ++ "\n"
 | n in PDGNodeIdx where debug];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```

**Should we put constraint_model_explanation.md here?** 

## solver and findMUS output -- text and JSON 

## GEDL.json

### gedl   

The top level key, contains one object for each unique ordered
pair of enclaves with cross-domain calls. This is determined by
checking which importedFunctions from an imported_func.txt file
are also present in a defined_func.txt of a different enclave.
These files are generated by compiling the contents of the indicated
directories into .ll files with names matching the directories, then
running opt with -llvm-test and -prefix flags on each file.

Represented by a JSON array of objects of arbitrary size.

### caller 
The name of the enclave making the cross-domain call. 
This will match the name of the directory containing the
imported_func.txt file for the considered importedFunction.

Represented by a double quote (") enclosed string that conforms
to linux filename restrictions and in all lowercase.

### callee
The name of the enclave where the cross-domain call is 
defined. This will match the name of the directory containing
the defined_func.txt file for the considered importedFuncion.

Represented by a double quote (") enclosed string that conforms
to linux filename restrictions and in all lowercase.

### calls

An array containing one object for each cross-domain function 
called from "caller" and defined in "callee". This is determined
by creating an entry for each unique function in the "caller" 
imported_func.txt file that is present in "callee" defined_func.txt


#### func:

The function name of the cross-domain call. Determined by name in
imported_func.txt.

Represented by a double quote (") enclosed string conforming to
c/c++ function name restrictions.

#### return:

An object defining the type of the function's return. 
Represented by a JSON object with a single key type

##### type   

A variable type representing the type of the function's return
value. Determined by querying DIUtils.getDITypeName(), which 
uses debug information to check the return type of the function. 

Represented by a double quote (") enclosed string that is one of
IDL's supported C types [double, ffloat, int8, uint8, int16, uint16,
int32, uint32, int64, uint64] and not a pointer (no *)

#### clelabel  

String value denoting the CLE labels that are tainting the function. This
is determined by checking the CLE labels present in the LLVM IR in the function
definition.

Represented as a string value, with plaintext labels separated by commas.

#### params 

Array containing one object for each argument passed to the function.
Determined by querying PDGUtils for the list of arguments for the 
current function name.

Represented as a JSON array of objects, each with keys type, name, dir,
and optionally sz.

##### type

A variable type representing the type of a function's argument.
Determined by querying DIUtils.getArgTypeName(), which uses
debug information to check the argument type of the function. 

Represented by a double quote (") enclosed string that is one of
IDL's supported C types [double, ffloat, int8, uint8, int16, uint16,
int32, uint32, int64, uint64] and not a pointer (no *).

##### name

The argument name of the current argument. Determined by calling
DIUtils.getArgName() which uses debug information to retrieve 
argument name.

Represented by a double quote (") enclosed string conforming to
c/c++ argument name restrictions.

##### dir

A string determining if read from or written to by the function
to decide if it needs to be copied in/out.  Determined by using 
arg.getAttribute() and checking if in, out, or both are attributes 
for arg.

Represented by a double quote (") enclosed string that is one of three values 
"in", "out", "inout".

##### sz

A number or word detailing the size of an array argument. Determined by 
using arg.getAttribute() and checking if count, size, string, or user_check
are attributes for arg.

Represented by an unsigned integer or a string that is 
either [string] or [user_check].

##### occurs

Array containing one object for each callsite of function in "caller".
Determined by checking callsiteMap, a Map object created at beginning of 
AccessInfoTracker.cpp that maps every imported function to a Set of the files
in the "caller" enclave where it is called. This is done by a module pass that
examines the instructions of every function.

Represented as a JSON array of objects, each with keys file and line.

##### file

The path to a file in "caller" enclave containing calls to function.
Determined by checking value of the current iterator on the Set 
returned by callsiteMap.

Represented by a double quote (") enclosed string that conforms to 
linux path restrictions and refers to a valid c/c++ file on the system.

##### lines

The line numbers of lines where calls to the function are made in the 
current file. Determined by querying callsiteLines Map object created
in the same manner as callsiteMap but recording lines.

Represented by an array of unsigned integers which must not exceed the
line count of the current file.


### Input

A number of directories containing the *.c/h files for each enclave,
These must be defined in the "enclaves" variable at the top of the Makefile.

### Criteria

- No functions may have a pointer return type. Any functions with pointer returns must be refactored
to instead return void and pass a new argument by reference that will act as the return
- No duplicate functions across domains, except for multithreaded programs where "main" can be duplicated
- Variables should not have any implicit casting to allow for automatic direction and size detection
- Arguments and return types must be be of IDL supported types {"double","ffloat","int8","uint8","int16","uint16","int32","uint32","int64","uint64"} 

#### Warnings List
- Warning and terminating error if return type is a pointer or unsupported
- Warning if direction for an argument is undetermined 
- Warning if size of an argument is undetermined
- Warning and if argument or type is not supported by IDL 
- Warning and terminating error if function is defined in more than one domain (potentially more expensive than its worth)
- Warning if cross domain function does not have CLE label

## IDL

The IDL syntax is based on C; an IDL file contains one or more C struct datatypes. See sample.idl for an example.

Datatype tags are assigned numerically in the order the structs are found in the file. Not all valid C struct declarations are supported.

Currently we support the following atomic types: char (8b), unsigned char (8b), short (16b), unsigned short (16b), int (32b), unsigned int (32b), long (64b), unsigned long (64b), float (4B), double (8B). We also support fixed-size arrays of any supported atomic type.

Support for null-terminated C-strings, and C++ datatypes such as std::string, std::array, and std::vector is future work.

## xdcomms.c/h reference

## codec.c/h reference

## RPC

## DFDL

## HAL configuration (and its input files for device and forwarding rules)

## EMU configuration
