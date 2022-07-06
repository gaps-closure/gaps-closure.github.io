## Code Dividing and Refactoring

Once the CAPO partitioning conflict analyzer has analyzed the CLE-annotated application code, and determined that all remaining conflicts are resolvable by RPC-wrapping to result in a security compliant cross-domain partitioned  code, the conflict analyzer will save the code in the refactored directory along with a a topology file (JSON) containing the assignment of every  function and global variable to an enclave/level. A sample topology JSON is provided below.

```
{
   "levels": ["orange", "purple"],
   "source_path": ["./refactored"],
   "functions": [
      {"name": "get_a", "level": "orange", "file": "test1_refactored.c", "line": 29},
      {"name": "main",  "level": "purple", "file": "test1_refactored.c", "line": 35},
      ...
    ],
   "global_scoped_vars": [
      {"name": "globalScopeVarNotFunctionStatic", "level": "purple", "file": "test1_refactored.c", "line": 5},
      ...
    ],
}
```

Given the refactored, annotated application, and the topology, the divider creates a `divvied` directory, divides the code into files in separate subdirectories (one per enclave), such that the source code for each function or global variable is placed in its respective enclave. Furthermore, all related code like type, variable, and function declarations, macro definitions, header includes, and pragmas are handled, so that the source in each directory has all the relevant code, ready for automated partitioning and code generation for RPC-wrapping of functions, and marshalling, tagging, serialization, and DFDL description of cross-domain data types.

This `divvied` source becomes the input to the GAPS Enclave Definition Language (GEDL) generator tool. The GEDL drives further code generation and modification needed to build the application binaries for each enclave.

### dividing

**Whoever wrote the divider should document this section**

### opt pass for GEDL and configuring heuristics

GEDL will be produced in JSON format as a file named "Enclaves.gedl"
An example GEDL file would look like:
{"gedl": [
	{
		"caller": "enclave1",
		"callee": "enclave2",
		"calls": [
			{
				"func":		"sampleFunc",
				"return":	{"type": "double"},
				"clelabel":	"enclave1",
				"params": [
					{"type": "int", "name": "sampleInt", "dir": "in"}, 
					{"type": "double", "name": "sampleDoubleArray", "dir": "inout", "sz":15} 
				],
				"occurs": [
					{"file": "/sample/Enclave1/Path/Enclave1File.c", "lines": [44]},
                                        {"file": "/sample/Enclave1/Path/Enclave1File2.c", "lines": [15,205]}

				]
			},
        {
				"func":		"sampleFunc2",
				"return":	{"type": "int"},
				"clelabel":	enclave1Extra,
				"params": [
				],
				"occurs": [
					{"file": "/sample/Enclave1/Path/Enclave1File.c", "lines": 45}
				]
			}
		]
	},
        {
		"caller": "enclave2",
		"callee": "enclave3",
		"calls": [
			{
				"func":		"sampleFunc3",
				"return":	{"type": "void"},
				"clelabel":	enclave2,
				"params": [
					{"type": "uint8", "name": "sampleUInt8", "dir": "in"} 
				],
				"occurs": [
                    {"file": "/sample/Enclave1/Path/Enclave2File.c", "lines": [55,87]}
				]
			}
		]
	}
]}

