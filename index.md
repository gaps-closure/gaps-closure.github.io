## What Is GAPS-CLOSURE?

DARPA's Guaranteed Architecture for Physical Systems (GAPS) is a research program 
that addresses software and hardware for compartmentalized applications where
multiple parties, each with strong physical isolation of their computational
environment, have specific constraints on the sharing of data (possibly including 
redaction requirements) with other parties, and any data exchange between the parties is
mediated through a guard that enforces the security requirements.

Peraton Labs' Cross-domain Language extensions for Optimal SecUre Refactoring
and Execution (CLOSURE) project is building a toolchain to support the
development, refactoring, and correct-by-construction partitioning of
applications and configuration of the guards. Using the CLOSURE approach and
toolchain, developers will express security intent through annotations applied
to the program, which drive the program analysis, partitioning, and code
auto-generation required by a GAPS application.

**Problem:** The machinery required to verifiably and securely establish
communication between cross-domain systems (CDS) without jeopardizing data
spillage is too complex to implement for many software platforms where such
communication would otherwise be desired. To regulate data exchanges between
domains, network architects rely on several risk mitigation strategies
including human fusion of data, data-diodes, and hypervisors which are insufficient
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
policies such that an application can be compiled to separate binaries for
concurrent execution on physically isolated platforms.

The CLOSURE compiler toolchain interprets annotation directives and performs
program analysis of the annotated program and produces a correct-by-construction 
partition if feasible. CLOSURE automatically generates and inserts serialization,
marshalling, and remote-procedure call code for cross-domain interactions
between the program partitions.

## Obtaining CLOSURE software and documentation

### CLOSURE for C Language

CLOSURE Toolchain User Manual for C Language, Peraton Labs, Release version 3.0, February 16, 2024 \[[PDF](./cdoc.pdf) [HTML](./cdoc.html)\]

Docker container with CLOSURE toolchain installed:

```
docker pull gapsclosure/closuredev:develop
```

Source Code Release, Peraton Labs, Release version 2.0, August 23, 2022: \[[Release](https://github.com/gaps-closure/build/releases/tag/v2.0)\] 
** Release 3 to be available later this month, see [github source](https://github.com/gaps-closure/build) for Phase 3 sources and models.

### CLOSURE for Java 

CLOSURE Toolchain User Manual for Java Language, Peraton Labs, Release version 2.0, August 23, 2022 \[[PDF](./jdoc.pdf) [HTML](./jdoc.html)\]

Docker container with CLOSURE toolchain installed:

```
docker pull gapsclosure/closure-java-src:latest
docker pull gapsclosure/closure-java-bin:latest
```

Source Code Release, Peraton Labs, Release version 2.0, August 23, 2022: \[[Release](https://github.com/gaps-closure/build/releases/download/v2.0/gaps-java-eop2-src.tgz)\] 

## CLOSURE Presentations and Publications 

1. Michael Kaplan and Rajesh Krishnan, "Program Insights from CLOSURE / DARPA GAPS," Presentation at the DARPA V-SPELLS Kick-Off Meeting, July 28, 2021 \[[PDF](./vspells.pdf)\]
2. Maxwell Levatich, Robert Brotzman, Benjamin Flin, Ta Chen, Rajesh Krishnan, Michael Kaplan, and Stephen A. Edwards, "C Program Partitioning with Fine-Grained Security Constraints and Post-Partition Verification," In Proceedings of the IEEE Military Communications Conference (MILCOM), pages 285-291, Rockville, Maryland, USA, November 2022. \[[PDF](./levatich2022c.pdf)\]
