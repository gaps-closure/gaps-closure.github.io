# CLOSURE Toolchain Overview

## What is CLOSURE and what does it do? **XXX: Ready for Review**

DARPA Guaranteed Architecture for Physical Systems (GAPS) is a research program 
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

### The Problem **XXX: Ready for Review**

The machinery required to verifiably and securely establish communication between cross-domain systems (CDS) without jeopardizing data spillage is too complex to implement for many software platforms where such communication would otherwise be desired. To regulate data exchanges between domains, network architects rely on several risk mitigation strategies including human fusion of data, diodes, and hypervisors which are insufficient for future commercial and government needs as they are high overhead, customized to specific setups, prone to misconfiguration, and vulnerable to software/hardware security flaws. To streamline the design, development, and deployment of provably secure CDSs, new hardware and software co-design tools are needed to more effectively build cross-domain support directly into applications and associated hardware early in the development lifecycle.

### Solution **XXX: Ready for Review **

Peraton Labs is developing CLOSURE (Cross-domain Language-extensions for Optimal SecUre Refactoring and Execution) to address the challenges associated with building cross-domain applications in software. CLOSURE extends existing programming languages by enabling developers the ability to express security intent through overlay annotations and security policies such that an application can be compiled to separable binaries for concurrent execution on physically isolated platforms.
The CLOSURE compiler toolchain interprets annotation directives to facilitate this process which consist of: 

1. Verification of source via cross-domain lint-checking and data-flow analysis
2. Program partitioning of the application using source level annotations to break the application into separate executables to be run in physically isolated memory spaces
3. Automated insertion of remote procedure calls (RPCs) utilizing novel GAPS hardware to enforce redaction, validation, encryption, etc. across levels, and iv) optimization of partitioning decisions to meet programmer objectives (e.g. tradeoffs for partition sizes vs RPC overhead). CLOSURE provides a set of novel co-design tools that extend current software development environments to ease adoption by the development community.

## Architecture **XXX: Needs writeup around figure **

**vspells briefing/poster**

![arch](docs/C/images/arch.png)

- **llvm stack image and add text to describe**

** A sentence on each component (MULES, CAPO, etc.) **

## Workflow **XXX: Needs writeup **

1. Annotation-driven development for correct-by-construction partitions with interactive feedback for guided refactoring
2. Automated generation of ​
cross-domain artifacts, compilation, and verification of partitioned program
3. Seamless support for heterogeneous GAPS hardware architectures and emulation for pre-deployment testing​​

![workflow](docs/C/images/workflow.png)

**vspells briefing/poster**

### C generation from Message-flow models **XXX: paraphrase to single paragraph, move text and merge with main section in 03-02-* **

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

## Limitations and language coverage

- two enclaves??
- message flow is primarily for json messages over amqp
- divider is not syntax aware

Most of c99 is covered 
- function pointers (might work, not tested) 
- module static functions
- macro generated functions
- any fn called xd can only have arguments be primitives or fixed size arrays of primitives
