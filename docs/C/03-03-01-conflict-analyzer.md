## Phase 2 CLOSURE conflict analyzer based on minizinc constraint solver 

**whatever readme available in all repos, but will need to be written**

### preprocessor

The CLOSURE pre-processor is a source transformer that will:
* take C/C++ programs annotated with CLE pragmas as input 
* generate C/C++ programs annotated with toolchain-specific source annotations, specifically new LLVM __attribute__ annotations which we define for the project
* additionally generate a file containing mappings from each annotation label to the corresponding CLE-JSON specification which contains additional detail to be used by downstream CLOSURE tools

The output C/C++ of the pre-processor will go to a minimally modified LLVM clang that will support the CLOSURE-specific LLVM __attribute__ annotations and pass them down to the LLVM IR level.

The pre-processor requires a C/C++ source parser (but not a full-blown compiler) so that applicable functions, variables, structs, classes, and other language elements can be identified and annotated appropriately based on the pragma which may be specified for the next non-empty, non-comment line or for an entire block of code.  For this purpose, the parser could borrow C/C++ grammar and parsing code from another project ([see notes here](http://www.nobugs.org/developer/parsingcpp/)), or leverage code from an exiting toolchain (e.g., gcc, clang) if needed. 

The ICD for the pre-processor (which we will specify/refine as a team) will be the CLE specification and new annotations attributes we define along with where they need to be placed.  As a starting point, we have a [draft CLE spec](https://github.com/gaps-closure/cle-spec/blob/master/specification.md), and a toy example (we will need to add support for code blocks, structs, functions, classes, et cetera).

Intial source is C file containing:
```
int * secretvar = 0;
```
Developer annotates the C file as follows:
```
#pragma cle def HIGHONE { //CLE-JSON, possibly \-escaped multi-line with whole bunch of constraints } #pragma cle HIGHONE int * secretvar = 0;
```
After running the preprocessor, we should get a C file with pragmas removed but with __attribute__ inserted (in all applicable places), e.g.,:
```
int * __attribute__(type_annotate("HIGHONE")) secretvar = 0;
```

Additionally:
- preprocessor no longer uses lark/libclang, entirely done custom using regex, which is
fine because its very simple substitution
- single line `#pragma cle LABEL` now supported, was not previously
- can be called separately from command line, this functionality is used in later steps

### opt pass for PDG

- called via subprocess in python
- produces minizinc pdg instance and debug pdg csv
**PSU documentation for PDG?? How much do we want to include, this doc is huge**

### input generation and constraint solving using Minizinc

- cle/enclave instance should be a pure function 
from collated cle json to an encoded minizinc instance 
- inputs are put in temp files for reference/debugging
- minizinc called using Gecode solver, with pdg/cle/enclave instance and constraints
- output parsed and sent back to the console
- if unsat, then it will run findmus  

### diagnostics using findMUS

Diagnostic generation produces either commandline output
containing source and dest node and grouped by constraints 

```
<constraint_name>: 
  <source_node_type> @ <file>:<line> -> <dest_node_type> @ <file>:<line>
``` 

It should also produce a `conflicts.json` which can be ingested by CVI 

***NEEDS FIX: current CA does not produce a conflicts.json***

**Should I include the following?? or just what's in `03-03-02-constraint-mode.md`**
### Arguing Correctness of the Model in Partitioning CLE-Annotated C programs (using LLVM and PDG)

The conflict analyzer must provide a satisfying assignment of enclaves to each
global variable and function, and identify the call invocation edges in the
cut. A sketch of the arguments for correctness of the constraint model is below
(needs to be vetted).

#### OUTPUT CONSTRAINTS

 * All varnode and function node must be assigned an enclave
 * To be in the cut, endpoints of a call edge must be in different enclaves (control return can be safely ignored)
 * All non-annotation nodes must have their (derived) enclave level match their taint level
 * Only user can apply a function annotation to bless a function

#### ENCLAVE-LEVEL-CONSTRAINTS
 * No non-call edge can leave the enclave
 * No non-return non-param data edge can leave the enclave
 * For each call invocation in the cut, the destination function must be
   annotated and must have a cdf that accept calls from the source enclave
   level
 * For each data return over the cut, the taint of the variable returned must
   allow sharing with destination (caller) function's enclave level
 * For each argument passing in the cut, the taint of the variable going into
   actual-in must allow sharing with destination function's enclave level

#### LABEL-CONSTRAINTS

 * Inside an enclave non-data non-return data edge endpoints must have same
   taint or be coercible by an annotated function
 * If function is annotated, the taint of destination of the data return edge
   must be allowed by the rettaints, else the taints across the edge must match
 * If function is annotated, the taint of the variable connected to the actual
   parameter must be allowed by the argtaints for the parameter, else the
   taints across the edge must match  
 * All nodes contained in annotated functions must only have taints that are in
   argtaints, rettaints, and codtaints specified in the corresponding function
   annotation (as parameter and return edges are handled separately above, we 
   primarily need to worry about codtaints) 
 * Unannotated functions can handle at most one taint across all invocations
   that will become the label taint of the function 

Whether the annotations correctly and completely capture data sharing
constraints is out of scope.

Annotated functions must be audited for correctness and to ensure that the 
only information leaving can be shared to the output arguments and return values.
However the program analysis ensures that only these functions (and not the entire
codebase) needs to be scrutinised.

The input preparer prepares the PDG and CLE information for effcicient processing
within MinZinc. Nodes and Edges are grouped by subtype and type and laid out in
sequence so that continguous integer sequences rather than arbitrary sets of IDs
can be used. For convenience, the function that each instruction and parameter
is associated with is also computed and stored.  The parameter indices for formal
in and formal out are also computed and stored.

Note that the input preparer pulls all taints into cleLabel regardless of whether 
there is a JSON (this primarily includes the `TAG_REQUEST_*` and `TAG_RESPONSE_*`
labels that will be defined and used in autogenerated code). The input preparer
also creates a special default label for each enclave without and cdf elements,
and this is not a function blessing annotation. This allows the model to assign
every node a label (including data that has no interference with any cross 
domain interactions).

Only level checking is done on data flowing across the cross-domain functions; 
the downstream verifier will ensure labels are correctly preserved through the 
autogenerated code (not available to this analyzer).

Currently the model forces un-annotated functions to handle only a single
taint across all invocations. As a result, any functions that need to handle
multiple taints across invocations will either need to be annotated to allow
those taints (if safe to do so) or moved out to a library and be checked
separately. [Why: suppose we call an unannotated function with no body taints
with one LABEL1, it stores the value in an unannotated static variable and
could pass it later to a fure call with LABEL1 -- so if the function will
tainted differently across invocations, it needs to be annotated and audited.

