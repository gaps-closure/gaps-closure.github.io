## Example applications **XXX: Review: Ta** {#examples} 

### Pedagogical Examples (examples 1-3)
The [pedagoical examples](https://github.com/gaps-closure/build/blob/develop/apps/examples/) are available for basic understanding of the CLOSURE workflow, annotations, and testing via emulation. Each example uses the same [plain source](https://github.com/gaps-closure/build/blob/develop/apps/examples/example1/plain/example1.c), however, the **partitioning objectives** differ for each:

- Example1 
    - variable a in get_a() is in ORANGE and can be shared with PURPLE 
    - variable b in get_b() is in PURPLE and cannot be shared
    - calculated ewma must be availbale on PURPLE side (for printing)
- Example2
    - variable a in get_a() is in ORANGE and can be shared with PURPLE
    - Variable b in get_b() is in PURPLE and cannot be shared
    - calculated ewma must be available on nORANGE side (for printing)
- Example3 
    - variable a in get_a() is in ORANGE and cannot be shared
    - variable b in get_b() is in ORANGE and cannot be shared
    - ewma must therefore be computed on ORANGE; EWMA is shareable to PURPLE
    - calculated ewma must be available on PURPLE side (for printing)

Example 1 is an exercise in applying annotations, example 2 and example 3 are exercises in applying annotations with code refactoring.

[Example1 Solution](https://github.com/gaps-closure/build/blob/develop/apps/examples/example1/.solution)

[Example2 Solution](https://github.com/gaps-closure/build/blob/develop/apps/examples/example2/.solution)

[Example3 Solution](https://github.com/gaps-closure/build/blob/develop/apps/examples/example3/.solution)

### EoP1 Applications (F2T2EA-inspired) {#eop1}
The EoP1 application is a toy application, loosely based on F2T2EA missions. The application source was provided by the TA4 Integration Partners. It consists of a pre-partitioned C++ message-based application using ActiveMQ to send a variety of messages to coordinate the simulated mission.  The components include:
- MPU: Mission Planner
- MPX: Mission Executor
- ISRM: Intelligence Surveillance Recon Manager
- RDR: Radar Sensor
- EOIR: Video Sensor
- External: GPS simulator

High-level architecture of the application and message flows shown in the following figures. Salient messages can be tracked using [transcript viewer](https://github.com/gaps-closure/build/tree/develop/apps/eop1/transcriptview) at runtime.
![Mission Application](docs/C/images/ma.png)

![Salient Messages](docs/C/images/salient.png)

Three cases were evaluated during the end-of-phase demonstration:

- [Case 1](https://github.com/gaps-closure/build/tree/develop/apps/eop1/case1): Normative policy provided by TA4 
    - MPU, MPX, ISRM, RDR (orange)
    - EOIR, External (green)

- [Case 2](https://github.com/gaps-closure/build/tree/develop/apps/eop1/case2): Coalition partner concept (e.g., planners on orange, sensors on green)
    - MPU, MPX (orange)
    - ISRM, RDR, EOIR, External (green)

- [Case 3](https://github.com/gaps-closure/build/tree/develop/apps/eop1/case3): Incorporates manual code partitioning, ISRM functionality manually divided between planning and sensor reading w/ redaction)
    - MPU, MPX, ISRM (orange)
    - ISRMshadow, EOIR, RDR, External (green)