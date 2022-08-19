# CLOSURE Toolchain Overview {#toolchain-overview}

## What is CLOSURE? 

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

**Problem:** The machinery required to verifiable and securely establish
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
partition if feasible. CLOSURE automatically generates and inserts serialization, marshaling, and remote-procedure call code for cross-domain interactions
between the program partitions.

In this document, we describe the CLOSURE toolchain for Java programs. 

## Architecture 

The CLOSURE architecture for Java is shown in [the figure below](#fig-arch).
The architecture builds on existing open-source ecosystems including the Java
Development Kit and the AspectJ compiler. 

![CLOSURE architecture](docs/Java/images/arch.png){#fig-arch}

There are three main layers in the architecture:

* MULES: This layer includes support for annotating source code with CLOSURE language
extensions (CLE). The annotated code added by the developer is then compiled using an
unmodified Java language compiler to produce JVM bytecode.
* CAPO: This layer deals with program analysis and partitioning. A System Dependency 
Graph model of the compiled Java program is constructed, and analyzed by the CLOSURE
conflict analyzer based on a constraint solver. If a feasible partitioning is found,
aspect-oriented program code to handle the cross-domain isolation and communication
concerns is generated, and these aspects are woven into the application code, one
for each enclave.
* HAL: This layer provides applications with a 0MQ-based interface for cross-domain 
communications and abstracts out the details of heterogeneous cross-domain guards
(GAPS hardware) that it manages.

Some key differences between the C toolchain @CDoc and the Java toolchain are: 
(i) the use of aspects for partitioning rather than physically dividing and 
modifying the application source code; (ii) the use of reflection in the serialization and marshaling; (iii) lack of a multi-target binary 
generation (MBIG) layer, as the Java VM supports a write-once run anywhere
paradigm; and (iv) autogeneration of HAL interface code as part of the aspects
rather than the use of a separate XDCOMMS API library.

## Workflow 
The CLOSURE workflow for building cross-domain applications in Java is shown in
[the figure below](#fig-workflow).

![CLOSURE Workflow for Java](docs/Java/images/workflow.png){#fig-workflow width=100%}

In the first stage, the developer either writes a new application or imports an existing source which must be tooled for cross-domain operation. The developer
must have knowledge of the intended cross-domain policy. While CLOSURE provides
means to express this policy in code, the requirements analyst/developer 
determines the actual cross-domain data sharing policy. The developer then 
uses CLE to annotate the program as such. The developer can use the CLOSURE
Visual Interface (CVI) based on Visual Studio Code @VSCode. Additional plugins
to provide syntax hints (similar to the C toolchain @CDoc) are planned in future work.

From there, we use the Java compiler to generate a jar file that we can feed to a tool called JOANA @joana, which builds a 
system dependency graph (SDG) model of the annotated program. Using the model 
produced from the SDG, our conflict analysis based on the CLOSURE constraint 
model for Java (implemented using MiniZinc) determines if the partitioning of 
the annotated program is feasible. If not, feedback is provided back to the developer 
for refactoring needed to get a compliant program. Once the program 
is deemed compliant (via the conflict analyzer), CLOSURE proceeds with automated 
tooling in which CAPO and associated tools divide the code, generate code for 
cross-domain remote procedure calls (RPCs), describe the formats of the cross-domain 
data types via DFDL @DFDL and codec/serialization code, and generate all required 
configurations for interfacing to the GAPS hardware via the Hardware Abstraction 
Layer (HAL). 

## Document Roadmap

In the rest of this document, we first present a quick start guide followed by a detailed usage of 
the toolchain components. For each component, we describe what it does, provide some insight into
how it works, discuss inputs and outputs and provide invocation syntax for usage. We conclude with 
a discussion of the limitations of our current toolchain and a roadmap for future work. We provide 
samples of significant input and output files in the appendices and provide a list of bibliographic 
references at the end. 
