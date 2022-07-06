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

## minizinc files -- constraint type declarations and constraints

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

## xdcomms.c/h reference

## codec.c/h reference

## RPC

## DFDL

## HAL configuration (and its input files for device and forwarding rules)

## EMU configuration
