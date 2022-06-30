# CLOSURE Toolchain Overview

## What is CLOSURE and what does it do?

The GAPS-CLOSURE toolchain is a utility to aid in the development of cross domain systems (CDS) by providing a set of language extensions to specify the domain requirements of a block of code or variable and verify transitioning between domains is done without leaking data between the domains.

When combined with Specialized Gaps hardware this allows for splitting the program from one monolithic binary into separate binaries to be physically separated between difference silicon with CDS guards mediating (and possibly redacting) the communication between the domains.

**Replace above with slides**

### Background
### The Problem

The machinery required to verifiably and securely establish communication between cross-domain systems (CDS) without jeopardizing data spillage is too complex to implement for many software platforms where such communication would otherwise be desired. To regulate data exchanges between domains, network architects rely on several risk mitigation strategies including human fusion of data, diodes, and hypervisors which are insufficient for future commercial and government needs as they are high overhead, customized to specific setups, prone to misconfiguration, and vulnerable to software/hardware security flaws. To streamline the design, development, and deployment of provably secure CDSs, new hardware and software co-design tools are needed to more effectively build cross-domain support directly into applications and associated hardware early in the development lifecycle.

### Solution

Peraton Labs is developing CLOSURE (Cross-domain Language-extensions for Optimal SecUre Refactoring and Execution) to address the challenges associated with building cross-domain applications in software. CLOSURE extends existing programming languages by enabling developers the ability to express security intent through overlay annotations and security policies such that an application can be compiled to separable binaries for concurrent execution on physically isolated platforms. The CLOSURE compiler toolchain interprets annotation directives to facilitate this process which consist of: i) verification of source via cross-domain lint-checking and data-flow analysis, ii) program partitioning of the application using the annotation hints to break the application into separate executables to be run in physically isolated memory spaces, iii) automated insertion of remote procedure calls (RPCs) utilizing novel GAPS hardware to enforce redaction, validation, encryption, etc. across levels, and iv) optimization of partitioning decisions to meet programmer objectives (e.g. tradeoffs for partition sizes vs RPC overhead). CLOSURE provides a set of novel co-design tools that extend current software development environments to ease adoption by the development community.

**vspells briefing/poster**

## Architecture

**vspells briefing/poster**

![arch](docs/C/images/arch.png)

- **llvm stack image and add text to describe**

## Workflow

1. Annotation-driven development for correct-by-construction partitions with interactive feedback for guided refactoring
2. Automated generation of ​
cross-domain artifacts, compilation, and verification of partitioned program
3. Seamless support for heterogeneous GAPS hardware architectures and emulation for pre-deployment testing​​

![workflow](docs/C/images/workflow.png)

**vspells briefing/poster**

### C generation from Message-flow models

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

## Components

**intro and one-to-one mapping to usage section**

## Limitations and language coverage

- two enclaves??
- message flow is primarily for json messages over amqp
- divider is not syntax aware

Most of c99 is covered 
- function pointers (might work, not tested) 
- module static functions
- macro generated functions
- any fn called xd can only have arguments be primitives or fixed size arrays of primitives