## What Is GAPS-CLOSURE

The GAPS-CLOSURE toolchain is a utility to aid in the development of cross domain systems (CDS) by providing a set of language extensions to specify the domain requirements of a block of code or variable and verify transitioning between domains is done without leaking data between the domains.

When combined with Specialized Gaps hardware this allows for splitting the program from one monolithic binary into separate binaries to be physically separated between difference silicon with CDS guards mediating (and possibly redacting) the communication between the domains.

## Getting CLOSURE

* [Containerized Toolchain Installation (recommended)](./container_deployment.md) 
* [Baremetal (Linux server) Toolchain Installation](./binary_install.md) 
* Github: <https://github.com/gaps-closure> (The github project page)
     * Start with the [build](https://github.com/gaps-closure/build) project

## Background

### The Problem

The machinery required to verifiably and securely establish communication between cross-domain systems (CDS) without jeopardizing data spillage is too complex to implement for many software platforms where such communication would otherwise be desired. To regulate data exchanges between domains, network architects rely on several risk mitigation strategies including human fusion of data, diodes, and hypervisors which are insufficient for future commercial and government needs as they are high overhead, customized to specific setups, prone to misconfiguration, and vulnerable to software/hardware security flaws. To streamline the design, development, and deployment of provably secure CDSs, new hardware and software co-design tools are needed to more effectively build cross-domain support directly into applications and associated hardware early in the development lifecycle. 

### Solution

Perspecta Labs is developing CLOSURE (Cross-domain Language-extensions for Optimal SecUre Refactoring and Execution) to address the challenges associated with building cross-domain applications in software. CLOSURE extends existing programming languages by enabling developers the ability to express security intent through overlay annotations and security policies such that an application can be compiled to separable binaries for concurrent execution on physically isolated platforms. The CLOSURE compiler toolchain interprets annotation directives to facilitate this process which consist of: i) verification of source via cross-domain lint-checking and data-flow analysis, ii) program partitioning of the application using the annotation hints to break the application into separate executables to be run in physically isolated memory spaces, iii) automated insertion of remote procedure calls (RPCs) utilizing novel GAPS hardware to enforce redaction, validation, encryption, etc. across levels, and iv) optimization of partitioning decisions to meet programmer objectives (e.g. tradeoffs for partition sizes vs RPC overhead). CLOSURE provides a set of novel co-design tools that extend current software development environments to ease adoption by the development community.

<!--## Research-->

<!--## Contacting Us-->

