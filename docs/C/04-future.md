# Limitations and Future Work {#limit-future}

## Current Limitations and C Language Coverage {#limitations} 

The CLOSURE toolchain supports most of the c99 standard. Our solution is based on
LLVM, and in particular, the Program Dependency Graph abstraction @ptrsplit of 
a the LLVM IR representation of a C program. The [constraint model](#constraints) 
is straight-forward and can be studied for more details on coverage.

Some C language and pre-processor features not currently supported include: (i)
module static functions for which the compiler creates synthetic names are not
handled, (ii) inlined functions, macro generated functions and conditionally
compiled code that are not visible in the LLVM IR and are not handled, (iii)
functions to be wrapped in cross-domain RPC must have arguments that are
primitive types or fixed size arrays of primitive types. 

In our current solution, every global variable and function must be assigned to
a separate enclave. Any functions called from multiple enclaves must be in an 
external library (and not subject to program analysis), and currently we do not 
provide a sandboxing mechanism for external library functions. Our program
divider has limited awareness of C language syntax. The solution supports at 
most one enclave at each security level.

Currently the constraint model is a single pass that requires functions to be 
called cross-domain to be annotated by the developer. It may be desirable to do 
constraint solving in two passes: the first pass can allow the locus of the cut 
to be moved for optimization, and the second pass can check that all functions 
ultimately involved in cross-domain cuts have been inspected and correctly annotated 
by the developer.

The CLOSURE C toolchain has been exhaustively tested with 2-enclave scenarios, 
but not with scenarios involving more than 2 enclaves.  The largest program we
have analyzed is about 25KLoC and it takes several minutes to analyze.

CLOSURE message-flow toolchain currently supports ActiveMQ-based communication, though 
the approach is general and can be extended to other messaging middleware if needed. 

Subsequent releases may address some of these limitations and add features as discussed 
in our roadmap below.

## Roadmap for Future Work {#future-work}

We plan to continue to refine and enhance the CLOSURE C toolchain beyond this
release. The enhancements will include relaxing [known limitations](#limitations) 
as well as adding new features, and will be prioritized based on the needs of 
the ongoing DARPA GAPS program. Our current research and development roadmap
includes:
  
1. More complete coverage of the C language along with more extensive testing for language coverage
2. Support for the analysis and partitioning of distributed applications, namely, the analysis of message flows between components and program partitioning of components themselves
3. Support for analysis and partitioning of concurrent (multi-threaded) program
4. Support for handling both cross-domain and high-performance concerns in application partitioning, for example, through the integration of CLOSURE and oneAPI toolchains 
5. Support for additional cross-domain communication modalities as well as RPC mechanisms
6. Support for non-Linux platforms included embedded RTOS and bare-metal targets 
7. Support for additional languages, in particular, C++ and Java 
8. Integration with other formal verification tools and increasing the scope of verification
9. Annotation hints, refactoring guidance, and diagnostics to the developer that are friendlier than what is currently provided based on the output of the constraint solver
10. Enhanced support for the provisioning of cross-domain guards through user-friendly specification of data formats and filter/transform rules, with traceability to application source 
11. Scalability to larger programs and increased performance
12. More examples, application use cases, and user stories as they become available

