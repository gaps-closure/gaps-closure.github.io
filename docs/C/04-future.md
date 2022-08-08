# Future Work {#future-work}

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

