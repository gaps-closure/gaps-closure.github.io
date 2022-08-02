## Example applications **Update with EoP2 instructions** {#examples} 


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