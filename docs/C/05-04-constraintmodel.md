## Additional files for Constraint Model in MiniZinc {#constraint-appendix}

The following contains type declarations 
for the MiniZinc model used within the [conflict analyzer](#conflict-analyzer).
These type declarations, along with a model instance generated in python
are inputted to MiniZinc along with the [constraints](#constraints) to either produce
a satisfiable assignment or some minimally unsatisfiable set of constraints.

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

### PDG instance

The following is the MiniZinc representation of the PDG for example 1.

```minizinc
Inst_FunCall_start = 1;
Inst_FunCall_end = 14;
Inst_Ret_start = 15;
Inst_Ret_end = 19;
Inst_Br_start = 20;
Inst_Br_end = 23;
Inst_Other_start = 24;
Inst_Other_end = 71;
Inst_start = 1;
Inst_end = 71;
VarNode_StaticGlobal_start = 0;
VarNode_StaticGlobal_end = -1;
VarNode_StaticModule_start = 0;
VarNode_StaticModule_end = -1;
VarNode_StaticFunction_start = 72;
VarNode_StaticFunction_end = 74;
VarNode_StaticOther_start = 0;
VarNode_StaticOther_end = -1;
VarNode_start = 72;
VarNode_end = 74;
FunctionEntry_start = 75;
FunctionEntry_end = 79;
Param_FormalIn_start = 80;
Param_FormalIn_end = 84;
Param_FormalOut_start = 85;
Param_FormalOut_end = 89;
Param_ActualIn_start = 90;
Param_ActualIn_end = 91;
Param_ActualOut_start = 92;
Param_ActualOut_end = 93;
Param_start = 80;
Param_end = 93;
Annotation_Var_start = 94;
Annotation_Var_end = 95;
Annotation_Global_start = 96;
Annotation_Global_end = 96;
Annotation_Other_start = 0;
Annotation_Other_end = -1;
Annotation_start = 94;
Annotation_end = 96;
PDGNode_start = 1;
PDGNode_end = 96;
ControlDep_CallInv_start = 1;
ControlDep_CallInv_end = 4;
ControlDep_CallRet_start = 5;
ControlDep_CallRet_end = 8;
ControlDep_Entry_start = 9;
ControlDep_Entry_end = 70;
ControlDep_Br_start = 71;
ControlDep_Br_end = 85;
ControlDep_Other_start = 0;
ControlDep_Other_end = -1;
ControlDep_start = 1;
ControlDep_end = 85;
DataDepEdge_DefUse_start = 86;
DataDepEdge_DefUse_end = 141;
DataDepEdge_RAW_start = 142;
DataDepEdge_RAW_end = 148;
DataDepEdge_Ret_start = 149;
DataDepEdge_Ret_end = 152;
DataDepEdge_Alias_start = 153;
DataDepEdge_Alias_end = 154;
DataDepEdge_start = 86;
DataDepEdge_end = 154;
Parameter_In_start = 155;
Parameter_In_end = 166;
Parameter_Out_start = 167;
Parameter_Out_end = 174;
Parameter_Field_start = 175;
Parameter_Field_end = 176;
Parameter_start = 155;
Parameter_end = 176;
Anno_Global_start = 177;
Anno_Global_end = 180;
Anno_Var_start = 181;
Anno_Var_end = 184;
Anno_Other_start = 0;
Anno_Other_end = -1;
Anno_start = 177;
Anno_end = 184;
PDGEdge_start = 1;
PDGEdge_end = 184;
hasFunction = [
76,76,76,76,79,76,76,76,76,78,78,78,79,79,75,76,77,78,79,76,
76,76,76,75,75,75,75,76,76,76,76,76,76,76,76,76,76,76,76,76,
76,76,76,76,76,77,77,77,77,77,78,78,78,78,78,78,78,78,78,78,
78,78,78,78,78,79,79,79,79,79,79,0,0,0,75,76,77,78,79,78,
78,79,79,79,78,78,79,79,79,78,78,78,78,76,76,0
];
hasSource = [
1,2,3,5,15,16,17,18,75,75,75,75,75,76,76,76,76,76,76,76,
76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,
77,77,77,77,77,77,78,78,78,78,78,78,78,78,78,78,78,78,78,78,
78,78,79,79,79,79,79,79,79,79,21,21,21,21,21,21,21,21,21,21,
21,21,21,21,21,72,72,72,73,73,73,73,74,74,74,24,25,27,28,28,
28,29,29,30,30,30,31,31,31,31,32,36,37,1,2,40,3,42,43,44,
46,47,48,50,51,51,52,52,53,57,58,59,60,61,62,63,65,66,67,68,
5,26,39,41,49,54,55,64,15,16,17,18,33,34,32,40,3,3,78,78,
80,81,79,79,90,91,3,3,78,78,79,79,92,93,83,88,72,73,75,76,
76,76,33,34
];
hasDest = [
75,77,78,76,1,5,2,3,25,26,27,15,24,28,29,30,31,33,34,35,
20,36,37,21,1,38,2,39,32,40,3,41,42,4,22,43,44,45,23,16,
47,48,49,50,17,46,51,52,53,54,55,56,57,58,59,60,61,62,63,64,
65,18,67,68,69,70,71,5,19,66,1,38,2,39,32,40,3,41,42,4,
22,43,44,45,23,27,26,24,50,49,47,46,65,64,61,25,26,15,32,38,
33,40,39,42,41,34,45,43,36,35,3,37,21,38,39,3,41,4,44,45,
48,48,49,17,57,54,58,55,56,59,59,60,63,62,63,64,18,69,70,71,
19,27,40,42,50,57,58,65,1,5,2,3,28,30,90,91,90,91,80,81,
57,58,82,83,80,81,92,93,85,86,87,88,32,40,84,89,96,96,96,96,
94,95,94,95
];
hasParamIdx = array1d(Param, [
1,2,1,2,-1,1,2,1,2,-1,1,2,1,2
]);
userAnnotatedFunction = array1d(FunctionEntry, [
 true,true,false,false,false
]);
MaxFuncParms = 3;
constraint ::  "TaintOnNodeIdx33" taint[33]=ORANGE;
constraint ::  "TaintOnNodeIdx34" taint[34]=PURPLE;
constraint ::  "TaintOnNodeIdx72" taint[72]=ORANGE;
constraint ::  "TaintOnNodeIdx73" taint[73]=PURPLE;
constraint ::  "TaintOnNodeIdx75" taint[75]=XDLINKAGE_GET_A;
constraint ::  "TaintOnNodeIdx76" taint[76]=EWMA_MAIN;
```

### cle instance

The following is a representation of the annotations in example 1 in MiniZinc:

```minizinc
cleLabel = {nullCleLabel, XDLINKAGE_GET_A , TAG_RESPONSE_GET_A , EWMA_MAIN , PURPLE , ORANGE , orangeDFLT , purpleDFLT }; 
hasLabelLevel = [nullLevel, orange , nullLevel , purple , purple , orange , orange , purple ]; 
isFunctionAnnotation = [false, true , false , true , false , false , false , false ]; 
cdf = {nullCdf, XDLINKAGE_GET_A_cdf_0 , XDLINKAGE_GET_A_cdf_1 , EWMA_MAIN_cdf_0 , ORANGE_cdf_0 }; 
fromCleLabel = [nullCleLabel, XDLINKAGE_GET_A , XDLINKAGE_GET_A , EWMA_MAIN , ORANGE ]; 
hasRemotelevel = [nullLevel, purple , orange , purple , purple ]; 
hasDirection = [nullDirection, bidirectional , bidirectional , bidirectional , egress ]; 
hasGuardOperation = [nullGuardOperation, allow , allow , allow , allow ]; 
isOneway = [false, false , false , false , false ]; 
cdfForRemoteLevel = [|
 nullCdf, nullCdf , nullCdf 
|nullCdf, XDLINKAGE_GET_A_cdf_1 , XDLINKAGE_GET_A_cdf_0 
|nullCdf, nullCdf , nullCdf 
|nullCdf, nullCdf , EWMA_MAIN_cdf_0 
|nullCdf, nullCdf , nullCdf 
|nullCdf, nullCdf , ORANGE_cdf_0 
|nullCdf, nullCdf , nullCdf 
|nullCdf, nullCdf , nullCdf 
|]; 
hasRettaints = array2d(functionCdf, cleLabel, [
  false , false , true  , false , false , false , false , false 
, false , false , true  , false , false , false , false , false 
, false , false , false , false , true  , false , false , false 
 ]); 
hasCodtaints = array2d(functionCdf, cleLabel, [
  false , false , false , false , false , true  , false , false 
, false , false , false , false , false , true  , false , false 
, false , false , true  , false , true  , false , false , false 
 ]); 
hasArgtaints = array3d(functionCdf, parmIdx, cleLabel, [
  false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		
, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		
, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		, false , false , false 		
 ]); 
hasARCtaints = array2d(functionCdf, cleLabel, [
  false , true  , true  , false , false , true  , false , false 
, false , true  , true  , false , false , true  , false , false 
, false , false , true  , true  , true  , false , false , false 
 ]); 
```

### enclave instance

The following is the MiniZinc representation of the mapping between enclaves and levels:  

```minizinc
Level = {nullLevel,orange,purple};
Enclave = {nullEnclave, orange_E,purple_E};
hasEnclaveLevel = [nullLevel,orange,purple];
```
