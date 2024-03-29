## CLE JSON example and schema {#cle-extra}

With [CLE annotations for Java](#annot-java), we use the same CLE-JSON schema as with the C toolchain @CDoc.
We describe an example CLE-JSON used with an annotation and the CLE-JSON schema below.

### Example 

Below is an example of `cle-json`. From the source code,
the [preprocessor](#preprocessor) produces a json with an array of 
label-json pairs, which are objects with two fields 
`"cle-label"` and `"cle-json"` for the label name
and label definition/json respectively. 

```json
[
  {
    "cle-label": "PURPLE",
    "cle-json": {
      "level": "purple"
    }
  },
  {
    "cle-label": "ORANGE",
    "cle-json": {
      "level": "orange",
      "cdf": [
        {
          "remotelevel": "purple",
          "direction": "egress",
          "guarddirective": {
            "operation": "allow"
          }
        }
      ]
    }
  }
]
```

### Schema {#cle-schema} 

The preprocessor validates cle-json 
produced from the source code using [jsonschema](http://json-schema.org/draft-07/schema). 
The schema for cle-json is shown in detail below: 

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

