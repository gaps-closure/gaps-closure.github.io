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

## Architecture **XXX: Review**
CLOSURE has a modular and layered architecture as shown in the figure. The architecture supports multiple languages including and employs a common LLVM IR format (the thin “waist” of the architecture), where key CLOSURE partitioning and optimization is performed. The architecture simplifies adding source languages, and reuse of well-engineered front-ends, linkers, optimizers, and back-ends. Binaries are generated for multiple target hardware platforms. 

Shown on the left of the figure is the Global Security Policy Specification (GSPS), which localizes mission security constraints and global security policy, including existing security levels, available hardware systems, allowable cross-level communication, and standard pre-formed cross-domain components including encryption, one-way channels, and downgrade functionality. The GSPS abstracts global security constraints, and allows the user to easily make per-mission or per environmental changes.  The developer uses the CLOSURE Visual Interface and associated tools to annotate source code with CLOSURE Language Extensions (CLE).  A standard linker and general-purpose program optimizer is invoked to link the GAPS-aware application libraries, the CLOSURE libraries for concurrency and hardware abstraction, and the rewritten legacy libraries into a set of platform specific executables. 

![CLOSURE architecture](docs/C/images/arch.png){#fig-arch}

The key submodules of the toolchain include:

- **CVI**: CLOSURE Visual Interface. The editor built on top of VSCode. Provides the IDE and co-design tools for cross-domain software development.
- **MULES**: Multi-Level Security Source Tools. Source tools containing the CLOSURE Language extensions and CLE schema. Includes a preprocessor which converts CLE annotations to LLVM attributes for clang processing.
- **CAPO**: Conflict Analyzer Partition Optimizor. CAPO includes the constraint-based conflict analysis tools to determine if a partitioning is feasible. Additional tools in CAPO auto-generate the additional logic needed to make a program cross-domain enabled (i.e., data type marshalling/serialization, RPCs for cross-domain data exchange, interfacing to the device drivers of cross-domain guards, DFDL and rule generation, among others).
- **MBIG**: Multi-Target Binary Generation. Supports compilation to x86 and ARM targets as well as packaging of applications.
- **HAL**: Hardware-Abstraction-layer. 0MQ based middleware for interopperating with the cross-domain guards.
- **EMU**: Emulator. Enables test and evaluation of cross-domain applications utilizing QEMU.


## Workflow **XXX: Ready for Review**
The CLOSURE workflow for building cross-domain applications shown in (#fig-workflow) can be viewed at a high-level as three toolchain stages: 1) Annotation-driven development for for correct-by-construction partitions with interactive feedback for guided refactoring, 2) Automated generation of ​cross-domain artifacts, compilation, and verification of partitioned program, and 3) seamless support for heterogeneous GAPS hardware architectures and emulation for pre-deployment testing​​.

![CLOSURE Workflow](docs/C/images/workflow.png)

In the first stage, the developer either writes a new application or imports existing source which must be tooled for cross-domain operation. The developer must have knowledge of the intended cross-domain policy - CLOSURE provides means to express this policy in code, but it is the requirements analyst/developer who determines the policy in advance and uses CLE to annotate the program as such. The CLOSURE pre-processor, PDG model, and constraint analysis determine if the annotated partitiong is feasible. If not, feedback and diagnostics are provided back to the developer for guided refactoring towards making the program compliant. Once the program is deemed compliant (via the conflict analyzer), CLOSURE proceeds with automated tooling in which CAPO and associated tools divide the code, generate code for cross-domain Remote Procedure Calls (RPCs), describe the cross-domain data types via DFDL and codec/serialization code, and generates all required configurations for interfacing to the GAPS hardware via the Hardware Abstraction Layer (HAL). In the final stage, the partitioned source trees are compiled for the target host (e.g., x86 or ARM64) and prepared for deployment. 

### C generation from Message-flow models **XXX: Ready for Review**
CLOSURE can also be used to support partitioning of message-flow based applications, that is, applications that have already been partitioned into components, but use a messaging service such as ActiveMQ to exchange messages via publish/subscribe blackboard. An application of this type was evaluated during the [EoP1](#eop1) exercises. CLOSURE enables message-flow partitioning by generating a cross-domain communication component (XDCC) from a [message flow specification](https://github.com/gaps-closure/build/blob/develop/apps/eop1/case1/design/design_spec.json). Using the spec, CLOSURE tools generate a C program that subscribes to those messages that will be cross-domain and facilitates their transfer over the guard. When a cross-domain message is received on the remote XDCC, the message is reconstructed and published to ActiveMQ for consumption by the remote enclave components. 
![XDCC concept](docs/C/images/xdcc.png) See [model-driven analysis](#modeldriven) for more details on how the specification is processed.

The model-driven approach is part of a larger workflow shown in the figure. Rapid capture of message flow data through use of sniffer, wildcard-subscriber, or other instrumentation provides listing of message types and field contents (types can be inferred and tweaked by developer if need be). A design-tool can bthen be used to annotate the message flows, structures, and ross-domain security intent in language-agnostic fashion. Automated generation of CLE annotated XDCC in C language is performered. XDCC program isolates per-message code paths facilitating annotationa and compliant cross-domain partitioning, covering a large class of message-based cross-domain applications. We consider this technique releveant and transitionable to REHL AMQ Interconnect for which it could enable cross-domain message routing.

![Concept for Design-Level Workflow of Message-Based Applications](docs/C/images/modelworkflow.png) 

**Challenges addressed by CLOSURE Model-Driven Design:**

- Abstraction moved up from partitioning control/data flow of a single program to partitioning message flows of a distributed application​
- Shifts problem from compilers to design tools​
- Considers complex application data structures (nested JSON) vs. flat fixed-formats suitable for hardware guards​
- Increases formatting and marshalling complexity testing flexibility of current GAPS hardware capability​

## Limitations and language coverage **XXX: Ready for Review** {#limitations} 
CLOSURE toolchain supports most of the c99 standard with the exception of function pointers, module static functions, macro generated functions, and functions called cross-domain that have arguments other than primitives or fixed size arrays of primitives. Each of these exceptions will be lifted in subsequent releases as we expand our PDG analysis and make the divider syntax-aware. Additionally, CLOSURE  message-flow toolchain supports strictly ActiveMQ-based communication, though the approch is general and can easily be extended to other messaging middlewares as needed. Presently, the CLOSURE C toolchain has been exhaustively tested with 2-enclaves, less so with 3-enclaves (manual involvement required in certain stages otherwise automated - to be resolved in future releases).
