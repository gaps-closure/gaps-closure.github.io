# CLOSURE Toolchain Overview **XXX: Rob rough import then Rajesh Review/Refactor**

## What is CLOSURE? **XXX: Can be largely reused**

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

## Architecture **Requires rewrite for java**



## Workflow **Requires rewrite for java**
The CLOSURE workflow for building cross-domain applications shown in [the figure below](#fig-workflow).

![Java Closure Workflow](docs/Java/images/JavaWorkFlow.png){#fig-workflow}

In the first stage, the developer either writes a new application or imports
existing source which must be tooled for cross-domain operation. The developer
must have knowledge of the intended cross-domain policy. CLOSURE provides
means to express this policy in code, but it is the requirements
analyst/developer who determines the policy in advance. The developer then 
uses CLE to annotate the program as such. From there, we use the Java compiler to generated a jar file that we can feed to a tool called Joana which builds a system dependency graph(SDG). Using the model produced from the SDG, our
constraint analysis determines if the partitioning of the annotated program is 
feasible. If not, feedback is provided back to the developer 
for refactoring to get a compliant program. Once the program 
is deemed compliant (via the conflict analyzer), CLOSURE proceeds with automated 
tooling in which CAPO and associated tools divide the code, generate code for 
cross-domain remote procedure calls (RPCs), describe the formats of the cross-domain 
data types via DFDL and codec/serialization code, and generate all required 
configurations for interfacing to the GAPS hardware via the Hardware Abstraction 
Layer (HAL). 

## Limitations and language coverage **Needs to be rewritten for java** {#limitations} 
CLOSURE currently supports subset Java version 8. Notable current limitations are a lack of support for multi-threading applications and annotating lambda functions. Additionally, some underlying toolchains used have limited support for large program. Lastly, we currently do not support Android applications. These language limitations are currently being addressed and we plan on supporting them in future releases. The CLOSURE Java tool chain has been demonstrated to support up to 3 enclaves, and can conceptually reason about an arbitrary number of enclaves. 
