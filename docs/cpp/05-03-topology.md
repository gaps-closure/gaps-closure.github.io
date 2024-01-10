## The cross-domain cut specification: topology.json [TODO: TA] {#topology.json}

XXX: put a C++ topology json here

The `topology.json` file is a description of level and enclave assignments produced
by the [conflict analyzer](#conflict-analyzer) and is used as input for the
[code generator](#autogen). It also contains information about the callee
and caller that will be in the cut.  

The `topology.json` contains:

1. the set of enclaves and levels relevant to the program 
2. an assignment from each class to a level and an enclave 
3. Callee and caller info for cross-domain calls

The `topology.json` manually generated for example2 is as follows:

```json
{
  "source_path": "example2/plain/example2",
  "enclaves": [
    {
      "name": "Purple_E",
      "level":"purple",
      "assignedClasses": [
        "Parent",
        "Extra"
      ]
    },
    {
      "name": "Orange_E",
      "level":"orange",
      "assignedClasses": [
        "Parent",
        "Example2"
      ]
    }
  ],
  "levels": [
    "orange",
    "purple"
  ],
  "entry": {
    "mainClass": "",
    "filepath": "./example2/plain/Example2.cpp"
  },  
  "functions": [
    {
      "name": "main",
      "level": "orange",
      "enclave": "Orange_E",
      "line": 540
    }
  ],
  "global_scoped_vars": [
    {
      "name": "",
      "level": "",
      "enclave": "",
      "line": 173
    }
  ],
  "cuts":[
     {
        "callee":{
           "level":"purple",
           "type":"Extra"
        },
        "allowedCallers":[
           {
              "level":"orange",
              "type":"Example1"
           }
        ],
        "methodSignature":{
           "parameterTypes":[
           ],
           "fqcn":"Extra",
           "name":"getValue",
           "returnType":"int"
        }
     },
     {
        "callee":{
           "level":"purple",
           "type":"Extra"
        },
        "allowedCallers":[
           {
              "level":"orange",
              "type":"Example1"
           }
        ],
        "methodSignature":{
           "parameterTypes":[
           ],
           "fqcn":"Extra",
           "name":"Extra",
           "returnType":"Extra"
        }
     }
  ]
}
```