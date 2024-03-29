## Code Dividing and Refactoring {#divider} 

Once the CAPO partitioning conflict analyzer has analyzed the CLE-annotated application code, and determined that all remaining conflicts are resolvable by RPC-wrapping to result in a security compliant cross-domain partitioned  code, the conflict analyzer will save the code in the refactored directory along with a a topology file (JSON) containing the assignment of every  function and global variable to an enclave/level. A sample topology JSON is provided below. 

```json
{
   "levels": ["orange", "purple"],
   "enclaves": ["purple_E", "orange_E"],
   "source_path": ["./refactored"],
   "functions": [
      {"name": "get_a", "level": "orange", "enclave": "orange_E", "file": "test1_refactored.c", "line": 29},
      {"name": "main",  "level": "purple", "enclave": "orange_E", "file": "test1_refactored.c", "line": 35},
      // ...
    ],
   "global_scoped_vars": [
      {"name": "globalScopeVarNotFunctionStatic", "level": "purple", "file": "test1_refactored.c", "line": 5},
      // ...
    ],
}
```

Given the refactored, annotated application, and the topology, the divider creates a `divvied` directory, divides the code into files in separate subdirectories (one per enclave), such that the source code for each function or global variable is placed in its respective enclave. Furthermore, all related code like type, variable, and function declarations, macro definitions, header includes, and pragmas are handled, so that the source in each directory has all the relevant code, ready for automated partitioning and code generation for RPC-wrapping of functions, and marshaling, tagging, serialization, and DFDL description of cross-domain data types.

This `divvied` source becomes the input to the GAPS Enclave Definition Language (GEDL) generator tool. The GEDL drives further code generation and modification needed to build the application binaries for each enclave.


The usage of the program divider is straightforward:

```bash
divider [-h] -f TOPOLOGYJSON [-o OUTPUT_DIR] [-m] [-c CLANG_ARGS]
```

The divider will always look in a directory called `refactored` under the working directory for
any `*.c` or `*.h` files that may comprise the program. The `-m` produces a debug mapping and
`-c` can be useful because the divider uses clang internally to parse each file.


