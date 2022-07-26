# CLOSURE Toolchain Overview

## What is CLOSURE? **XXX: Review**

DARPA's Guaranteed Architecture for Physical Systems (GAPS) is a research program 
that addresses software and hardware for compartmentalized applications where
multiple parties with strong physical isolation of their computational
environment, have specific constraints on data sharing (possibly with redaction
requirements) with other parties, and any data exchange between the parties is
mediated through a guard that enforces the security requirements.

Peraton Labs' Cross-domain Language extensions for Optimal SecUre Refactoring
and Execution (CLOSURE) project is building a toolchain to support the
development, refactoring, and correct-by-construction partitioning of
applications and configuration of the guards. Using the CLOSURE approach and
toolchain, developers will express security intent through annotations applied
to the program, which drive the program analysis, partitioning, and code
autogeneration required by a GAPS application.

**Problem:** The machinery required to verifiably and securely establish
communication between cross-domain systems (CDS) without jeopardizing data
spillage is too complex to implement for many software platforms where such
communication would otherwise be desired. To regulate data exchanges between
domains, network architects rely on several risk mitigation strategies
including human fusion of data, diodes, and hypervisors which are insufficient
for future commercial and government needs as they are high overhead,
customized to specific setups, prone to misconfiguration, and vulnerable to
software/hardware security flaws. To streamline the design, development, and
deployment of provably secure CDSs, new hardware and software co-design tools
are needed to more effectively build cross-domain support directly into
applications and associated hardware early in the development lifecycle.

**Solution:** Peraton Labs is developing CLOSURE (Cross-domain
Language-extensions for Optimal SecUre Refactoring and Execution) to address
the challenges associated with building cross-domain applications in software.
CLOSURE extends existing programming languages by enabling developers the
ability to express security intent through overlay annotations and security
policies such that an application can be compiled to separable binaries for
concurrent execution on physically isolated platforms.

The CLOSURE compiler toolchain interprets annotation directives and performs
program analysis of the annotated program and produces a correct-by-construction 
partition if feasible. CLOSURE automatically generates and inserts serialization,
marshalling, and remote-procedure call code for cross-domain interactions
between the program partitions.

## Architecture **XXX: Needs writeup around figure **
CLOSURE has a modular and layered architecture as shown in the figure. The architecture supports multiple languages including and employs a common LLVM IR format (the thin “waist” of the architecture), where key CLOSURE partitioning and optimization is performed. The architecture simplifies adding source languages, and reuse of well-engineered front-ends, linkers, optimizers, and back-ends. Binaries are generated for multiple target hardware platforms. 

Shown on the left of the figure is the Global Security Policy Specification (GSPS), which localizes mission security constraints and global security policy, including existing security levels, available hardware systems, allowable cross-level communication, and standard pre-formed cross-domain components including encryption, one-way channels, and downgrade functionality. The GSPS abstracts global security constraints, and allows the user to easily make per-mission or per environmental changes.  The developer uses the CLOSURE Visual Interface and associated tools to annotate source code with CLOSURE Language Extensions (CLE).  A standard linker and general-purpose program optimizer is invoked to link the GAPS-aware application libraries, the CLOSURE libraries for concurrency and hardware abstraction, and the rewritten legacy libraries into a set of platform specific executables. 

![arch](docs/C/images/arch.png)

The key submodules of the toolchain include:

**CVI**: CLOSURE Visual Interface. The editor built on top of VSCode. Provides the IDE and co-design tools for cross-domain software development.
**MULES**: Multi-Level Security Source Tools. Source tools containing the CLOSURE Language extensions and CLE schema. Includes a preprocessor which converts CLE annotations to LLVM attributes for clang processing.
**CAPO**: Conflict Analyzer Partition Optimizor. CAPO includes the constraint-based conflict analysis tools to determine if a partitioning is feasible. Additional tools in CAPO auto-generate the additional logic needed to make a program cross-domain enabled (i.e., data type marshalling/serialization, RPCs for cross-domain data exchange, interfacing to the device drivers of cross-domain guards, DFDL and rule generation, among others).
**MBIG**: Multi-Target Binary Generation. Supports compilation to x86 and ARM targets as well as packaging of applications.
**HAL**: Hardware-Abstraction-layer. 0MQ based middleware for interopperating with the cross-domain guards.
**EMU**: Emulator. Enables test and evaluation of cross-domain applications utilizing QEMU.


## Workflow **XXX: Needs writeup**

1. Annotation-driven development for correct-by-construction partitions with interactive feedback for guided refactoring
2. Automated generation of ​
cross-domain artifacts, compilation, and verification of partitioned program
3. Seamless support for heterogeneous GAPS hardware architectures and emulation for pre-deployment testing​​

![workflow](docs/C/images/workflow.png)

**vspells briefing/poster**

### C generation from Message-flow models **XXX: paraphrase to single paragraph, move text and merge with main section in 03-02-**

**eop1 briefing addendum (on teams)**

#### Challenges:​

- Abstraction moved up from partitioning control/data flow of a single program to partitioning message flows of a distributed application​
- Shifts problem from compilers to design tools​
- Complex application data structures (nested JSON) vs. flat fixed-formats suitable for hardware guards​
- Increases formatting and marshalling complexity to match current GAPS hardware capability​
- CLOSURE program analysis tools are currently more mature for C language, but application written in C++​

#### Capabilities:​

- Design tool for message-based applications that capture components, message flows, message structure, and cross-domain security intent in a language-agnostic fashion​
- Rapid capture of message flow data through use of sniffer, wildcard-subscriber, or other instrumentation​
- Automated generation of CLE annotated cross-domain communication component (XDCC) in C language ​
- XDCC program structure isolates per-message code paths facilitating annotation and compliant cross-domain partitioning​
- Covers large class of message-based cross-domain applications​
- Possible transition via mods to RHEL AMQ Interconnect code base

**needs updated message flow workflow figure** 

## Limitations and language coverage {#limitations}

- two enclaves??
- message flow is primarily for json messages over amqp
- divider is not syntax aware

Most of c99 is covered 
- function pointers (might work, not tested) 
- module static functions
- macro generated functions
- any fn called xd can only have arguments be primitives or fixed size arrays of primitives
