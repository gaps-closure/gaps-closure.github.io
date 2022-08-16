## Constraint Model in MiniZinc **XXX: Ready for Review**

The following contains type declarations
for the minizinc model used within the [conflict analyzer](#conflict-analyzer).
These type declarations, along with a model instance generated in python
are inputted to minizinc with the [constraints](#constraints) to either produce
a satisfiable assignment or some minimally unsatisfiable set of constraints.

### Type declarations  

```minizinc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SDG Nodes
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

% int: VarNode_StaticGlobal_start;
% int: VarNode_StaticGlobal_end;
% int: VarNode_StaticModule_start;
% int: VarNode_StaticModule_end;
% int: VarNode_StaticFunction_start;
% int: VarNode_StaticFunction_end;
% int: VarNode_StaticOther_start;
% int: VarNode_StaticOther_end;
% int: VarNode_start;
% int: VarNode_end;

int: FunctionEntry_start;
int: FunctionEntry_end;


% Need to check that there isn't an issue with non-contiguious arg indicies
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


int: PDGNode_start;
int: PDGNode_end;

set of int: Inst = Inst_start .. Inst_end;
set of int: FunCall = Inst_FunCall_start .. Inst_FunCall_end;


set of int: FunctionEntry = FunctionEntry_start .. FunctionEntry_end;

set of int: Param_FormalIn = Param_FormalIn_start .. Param_FormalIn_end;
set of int: Param_FormalOut = Param_FormalOut_start .. Param_FormalOut_end;
set of int: Param_ActualIn = Param_ActualIn_start .. Param_ActualIn_end;
set of int: Param_ActualOut = Param_ActualOut_start .. Param_ActualOut_end;
set of int: Param = Param_start .. Param_end;

set of int: PDGNodeIdx  = PDGNode_start .. PDGNode_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SDG Edges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: ControlDep_CallInv_start;
int: ControlDep_CallInv_end;
int: ControlDep_CallRet_start;
int: ControlDep_CallRet_end;
int: ControlDep_Other_start;
int: ControlDep_Other_end;
int: ControlDep_start;
int: ControlDep_end;

int: DataDepEdge_Ret_start;
int: DataDepEdge_Ret_end;
int: DataDepEdge_Alias_start;
int: DataDepEdge_Alias_end;

int: DataDepEdge_Other_start;
int: DataDepEdge_Other_end;
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

int: PDGEdge_start;
int: PDGEdge_end;

set of int: ControlDep_CallInv = ControlDep_CallInv_start .. ControlDep_CallInv_end;
set of int: ControlDep_CallRet = ControlDep_CallRet_start .. ControlDep_CallRet_end;
set of int: ControlDep_Other = ControlDep_Other_start .. ControlDep_Other_end;
set of int: ControlDep = ControlDep_start .. ControlDep_end;

set of int: DataDepEdge_Ret  = DataDepEdge_Ret_start .. DataDepEdge_Ret_end;
set of int: DataDepEdge_Alias = DataDepEdge_Alias_start .. DataDepEdge_Alias_end;
set of int: DataDepEdge_Other = DataDepEdge_Other_start .. DataDepEdge_Other_end;
set of int: DataDepEdge = DataDepEdge_start .. DataDepEdge_end;

set of int: Parameter_In = Parameter_In_start .. Parameter_In_end;
set of int: Parameter_Out = Parameter_Out_start .. Parameter_Out_end;
set of int: Parameter_Field = Parameter_Field_start .. Parameter_Field_end;
set of int: Parameter = Parameter_start .. Parameter_end;



set of int: PDGEdgeIdx = PDGEdge_start .. PDGEdge_end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Java OO Features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


int: ClassNames_start;
int: ClassNames_end;
int: ExternalClass;


int: ClassFields_Instance_start;
int: ClassFields_Instance_end;
int: ClassFields_Static_start;
int: ClassFields_Static_end;
int: ClassMethods_Instance_start;
int: ClassMethods_Instance_end;
int: ClassMethods_Static_start;
int: ClassMethods_Static_end;

set of int: ClassNames = ClassNames_start .. ClassNames_end;
set of int: AllClassNames = ClassNames_start .. ClassNames_end union {ExternalClass};

set of int: ClassFields_Instance = ClassFields_Instance_start .. ClassFields_Instance_end;
set of int: ClassFields_Static = ClassFields_Static_start .. ClassFields_Static_end;
set of int: ClassFields = ClassFields_Instance_start .. ClassFields_Static_end;

set of int: ClassMethods_Instance = ClassMethods_Instance_start .. ClassMethods_Instance_end;
set of int: ClassMethods_Static = ClassMethods_Static_start .. ClassMethods_Static_end;
set of int: ClassMethods = ClassMethods_Instance_start .. ClassMethods_Static_end;

set of int: ClassElements = ClassFields_Instance_start .. ClassMethods_Static_end;


array[ClassFields]     of ClassNames:  fieldOfClass;


array[ClassMethods]     of ClassNames:  methodOfClass;


array[ClassNames]     of AllClassNames:  immediateParent;
array[ClassNames]     of set of AllClassNames:  allParents;
array[ClassNames]     of set of AllClassNames:  implementsInterface;


array[FunctionEntry]     of set of ClassFields:  methodsFieldAccess;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Containing Class for PDG Nodes, Containing Function for PDG Nodes, Endpoints for PDG Edges, Indices of Fucntion Formal Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

array[PDGNodeIdx]     of ClassNames:  hasClass;
array[PDGNodeIdx]     of FunctionEntry:  hasFunction;
array[PDGEdgeIdx]     of int:  hasSource;
array[PDGEdgeIdx]     of int:  hasDest;
array[Param]          of int:  hasParamIdx;
array[FunctionEntry]  of bool: userAnnotatedFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convenience Aggregations of PDG Nodes and Edges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set of int: NonAnnotation       = Inst union FunctionEntry union Param;
set of int: ControlDep_Call     = ControlDep_CallInv union ControlDep_CallRet;
set of int: ControlDep_NonCall  = ControlDep_Other;
set of int: DataEdgeNoRet       = DataDepEdge_Other union DataDepEdge_Alias;
set of int: DataEdgeNoRetParam  = DataEdgeNoRet union Parameter_Field;
set of int: DataEdgeParam       = DataDepEdge union Parameter;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Security Levels and Enclaves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


enum Level;
set of Level: nonNullLevel = { x | x in Level where x!=nullLevel };
enum Enclave;
set of Enclave: nonNullEnclave = { x | x in Enclave where x!=nullEnclave };

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
array[ClassNames]                     of bool:           isClassAnnotated;
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
debug = true;


array[ClassNames,nonNullEnclave]                     of var bool: classEnclave;
array[ClassNames,Level]                              of var bool: classTaintedAtLevel;

array[PDGNodeIdx,nonNullEnclave]                     of var Enclave:    nodeEnclave;
array[PDGNodeIdx,nonNullEnclave]                     of var Level:      nodeLevel;
array[PDGNodeIdx,nonNullEnclave]                     of var cleLabel:   taint;
array[PDGNodeIdx,nonNullEnclave]                     of var cleLabel:   ftaint;
array[ClassNames,nonNullEnclave]                     of var cleLabel:   ctaint;

array[ClassFields,nonNullEnclave]                    of var cleLabel:   fieldTaint;


array[PDGEdgeIdx,nonNullEnclave]                     of var Enclave:    esEnclave;
array[PDGEdgeIdx,nonNullEnclave]                     of var Enclave:    edEnclave;

array[PDGEdgeIdx,nonNullEnclave]                     of var cleLabel:   esTaint;
array[PDGEdgeIdx,nonNullEnclave]                     of var cleLabel:   edTaint;

array[PDGEdgeIdx,nonNullEnclave]                     of var cleLabel:   esFunTaint;
array[PDGEdgeIdx,nonNullEnclave]                     of var cleLabel:   edFunTaint;


array[PDGEdgeIdx,nonNullEnclave]                     of var cdf:        esFunCdf;
array[PDGEdgeIdx,nonNullEnclave]                     of var cdf:        edFunCdf;

array[PDGEdgeIdx,nonNullEnclave]                     of var bool:       xdedge;
array[PDGEdgeIdx,nonNullEnclave]                     of var bool:       tcedge;

array[PDGEdgeIdx,nonNullEnclave]                     of var bool:       coerced;

```


