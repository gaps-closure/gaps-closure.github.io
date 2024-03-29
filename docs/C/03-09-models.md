## Partitioning of Message-Flow Model {#message-model-analysis}

CLOSURE supports the partitioning of models of message-flow based applications, that is, applications that have already been partitioned into components, but use a messaging service such as ActiveMQ to exchange messages via publish/subscribe blackboard. 

The process begins with the developer specifying a topological model of components and messages along with 
the schema of the messages. The developer also specifies cross-domain concerns using CLE annotations.
We describe the subsequent steps involved including the model specification and model format details, 
analysis and partitioning of the annotated model, and auto generation of CLE-annotated C code from 
the partitioned model. The generated C code is then processed using the CLOSURE toolchain for C as described earlier.

The model-driven approach is part of a larger workflow shown in the figure.
Rapid capture of message flow data through use of sniffer, wildcard-subscriber,
or other instrumentation provides listing of message types and field contents
(types can be inferred and tweaked by developer if need be). A design-tool can
then be used to annotate the message flows, structures, and cross-domain
security intent in language-agnostic fashion. Automated generation of CLE
annotated XDCC in C language is performed. XDCC program isolates per-message
code paths facilitating annotations and compliant cross-domain partitioning,
covering a large class of message-based cross-domain applications. We consider
this technique relevant and transitionable to RHEL AMQ Interconnect for which
it could enable cross-domain message routing.

![Concept for Design-Level Workflow of Message-Based Applications](docs/C/images/modelworkflow.png) 

An application of this type was evaluated during the [EoP1](#eop1) exercises.
CLOSURE enables message-flow partitioning by generating a cross-domain
communication component (XDCC) from a [message flow
specification](https://github.com/gaps-closure/build/blob/develop/apps/eop1/case1/design/design_spec.json).
Using the specification, CLOSURE tools generate a C program that subscribes to those
messages that will be cross-domain and facilitates their transfer over the
guard. When a cross-domain message is received on the remote XDCC, the message
is reconstructed and published to ActiveMQ for consumption by the remote
enclave components. See [partitioning of message-flow model](#modeldriven) for 
more details on how the specification is processed. 

![XDCC concept](docs/C/images/xdcc.png) 


### Specification Format
A snippet of [EoP1 Message Specification](https://github.com/gaps-closure/build/blob/develop/apps/eop1/case1/design/design_spec.json) is reproduced below. The structure of the specification is as follows:

- **comments**: for human readable purposes, the component, and message types are listed with their unique numbers for easy identification in rest of the file. FlowIDs are formed by combining src/dst component identifiers with message id
- **topology**: lists the application components, CLE label for the component, and the inflows and outflows.
- **flows**: listing of all flows, message that traverses the flow, and associated label
- **messages**: listing of all message types and associated schema
- **cles**: definition of all CLE labels in the model

```json
{
    "comment": [
      "Case 1: TA3-proposed PEST",
      "Components [MPU:1,MPX:2,ISRM:3,RDR:5] in orange:1",
      "Components [EOIR:4, External:6] in green:2",
      "Messages: ",
      "component_heartbeats:01",
      "updateMissionPlan:02",
      "pnt:03",
      "requestISRMDetections:04",
      "recieveISRMDetections:05",
      "requestEOIRDetections:06",
      "recieveEOIRDetections:07",
      "requestRDRDetections:08",
      "recieveRDRDetections:09",
      "groundMovers:10",
      "FlowID (encodes mux and typ): PQMM component P->Q, message MM"
    ],
    "topology": [
        {
            "component": "MPU",
            "label": "MPU_CLE_LABEL",
            "inFlows":  [ 2101, 3101, 4101, 5101 ],
            "outFlows": [ 1201, 1301, 1401, 1501, 
                          1202, 1302, 1402, 1502 ]
        }
        
    ],
    "flows": [
        {"flowId": 1201,"message":"component_heartbeats","label":"ALLOW_ORANGE_ORANGE"},
        {"flowId": 1301,"message":"component_heartbeats","label":"ALLOW_ORANGE_ORANGE"},
        {"flowId": 1401,"message":"component_heartbeats","label":"ALLOW_ORANGE_GREEN"}
    ],
    "messages": [
        {
            "name": "component_heartbeats",
            "topic": true,
            "schemaType": "JSONSchema",
            "schemaFile": "schema/component_heartbeats_schema.json"
        },
        {
            "name": "updateMissionPlan",
            "topic": true,
            "schemaType": "JSONSchema",
            "schemaFile": "schema/updateMissionPlan_schema.json"
        }
        
    ],    
    "cles": [
        {
            "cle-label": "MPU_CLE_LABEL",
            "cle-json": {
                "level": "orange",
                "cdf": [
                    {
                        "remotelevel": "green",
                        "direction": "egress",
                        "guarddirective": {
                            "operation": "allow"
                        },
                        "argtaints": [
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_GREEN_ORANGE" ],
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_ORANGE_GREEN" ],
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_ORANGE_ORANGE" ],
                            [ "ALLOW_ORANGE_GREEN" ],
                            [ "ALLOW_ORANGE_ORANGE" ]
                        ],
                        "codtaints": [
                        ],
                        "rettaints": [
                        ]
                    }
                ]
            }
        }        
        {
            "cle-label": "ALLOW_ORANGE_ORANGE",
            "cle-json": {
               "level":"orange",
               "cdf":[
                  {
                     "remotelevel":"orange",
                     "direction":"egress",
                     "guarddirective":{
                        "operation":"allow",
                        "oneway":true
                     }
                  }
               ]
            }
        }
    ]
}
```

### Analyzing the Specification {#modeldriven}

The Flow Solver is a z3-backed solver/verifier for GAPS-CLOSURE application design
specifications. It verifies that specifications are self-consistent and can
find satisfying values for fields which are omitted from the specification,
such as component levels or flow labels. It automatically derives and outputs
a minimal cross-domain message flow policy for the specification.

![Flow Solver Workflow](docs/C/images/flowsolver.png)

If the command-line option is specified, it will also constrain the solution to
a provided cross-domain message policy, and report on whether the policy is
overly permissive.

If there is a problem with the provided specification such that it is not
consistent with itself or the provided policy, the solver will output a simple
English explanation of what went wrong.

### Assumptions

The solver currently makes a number of simplifying assumptions about the
specification, as it is currently in development. We document those assumptions
here.

The simplified specification, explained below, has the following form:

```
Component
    id:          Int
    inflows:     [Flow]
    outflows:    [Flow]
    argtaints:   [FlowLabel]
    level:       Enum("orange" | "green")
    remotelevel: Enum("orange" | "green")

Flow:
    id:        Int
    msg:       Int
    label:     FlowLabel

FlowLabel:
    id:        Int
    local:     Enum("orange" | "green")
    remote:    Enum("orange" | "green")
```

CLE labels are split between labels for components and labels for flows - it
is assumed that no CLE label is used for both a flow and a component.

Further, the solver assumes that each component has one unique CLE label -
thus, the label information is merged with the component information, and the
only CLE labels the solver tracks explicitly are flow labels.

Message data beyond the name (`topic`, `schemaType`, and `schemaFile`) is
ignored, so the solver does not track message objects, only the message string
used by each flow.

A number of fields are omitted: `codtaints`, `rettaints`, `direction`, `oneway`,
and `guarddirective`. All directions are assumed to be `egress`, and all
operations are assumed to be `allow`.

It is assumed that the `cdf` field in each CLE label is a singleton list, and
that each argtaint is a singleton list. Finally, the solver assumes that there
are exactly two levels, `orange` and `green`.

Internally, the solver passes integer IDs to z3 and converts between IDs and
component/flow/label/message names, because z3 works far more quickly with
integers. Thus each component, flow, flow label, and message has an ID. The
strings "orange" and "green" are also tied to integer IDs.

These assumptions will be gradually phased out as the solver matures.

### Constraint formulas

Relationships between Components, Flows, and FlowLabels, and their fields, are
modeled as integers and functions mapping integers to other integers. The solver
gets a partial interpretation of each function from the provided spec/rules,
and uses the constraints to assign a full interpretation to each mapping
function.

Integer IDs are constrained to valid values in context. For example, the `label`
function maps a flow to its corresponding label, so `label`'s domain is
technically `Int` x `Int` (`id` -> `id`), but it is bounded such that the input
must be an integer which corresponds to a flow ID, and the output must
be an integer which corresponds to a label ID.

Beyond these boundary conditions, the main constraints are given below:

#### Inflows and outflows must match flow levels and component levels

`f` is a flow, `c` is a component, `i` is an index.

1. `Forall f c i, c.outflows[i] == f => c.level == f.label.local`
2. `Forall f c i, c.inflows[i] == f => c.level == f.label.remote`

#### Argtaints must match component inflows, outflows, level, and remotelevel

`c` is a component, `i` is an index.

1. `Forall c i, c.inflows[i].label == c.argtaints[i]`
2. `Forall c i, c.outflows[i].label == c.argtaints[len(c.inflows) + i]`
3. `Forall c i, i < len(c.inflows) => c.argtaints[i].remote == c.level && (c.argtaints[i].local == c.level || c.argtaints[i].local == c.remotelevel)`
4. `Forall c i, i >= len(c.inflows) => c.argtaints[i].local == c.level && (c.argtaints[i].remote == c.level || c.argtaints[i].remote == c.remotelevel)`

#### Deriving a cross-domain message flow policy

A function `cdf_allowed` is used to track whether a cross-domain message flow is
a.) needed by the application and b.) allowed by the given policy (if a policy
was given). During solving, if the constraints imply a CDF which was already
denied by the provided policy, `cdf_allowed` is unsatisfiable. After solving,
`cdf_allowed` is queried for each message and cross-domain flow to determine
what policy the application needs.

The function is defined in the solver as follows:

`cdf_allowed(MessageID m, ColorID c1, ColorID c2) ==
Exists (Flow f), f.label.local == c1 && f.label.remote == c2 && f.msg == m`

### Testing the Model Partitioner

Several example application design specs, and the results given by the solver,
are provided in the `examples` folder, with descriptions in the respective
`README.md` files.

This solver requires z3. To install z3 for python, run:

`pip3 install z3-solver`

To use the solver, in the `flowspec` directory run:

`python3 FlowSolver.py examples/valid/case1.json`

To add a cross-domain message policy, use the `--rules` option:

`python3 FlowSolver.py examples/valid/case1.json --rules examples/rules/case1.json`

To see all options, use:

`python3 FlowSolver.py -h`

### Auto-generating Annotated C code 

From the output of the model partitioner (`FlowSolver.py`), the `xdcc_gen` tool generates CLE-annotated 
C programs on which the rest of the CLOSURE toolchain for the C language can be applied to get partitioned
binary executables.

The `xdcc_gen` tool produces two programs per pair of enclaves, one each per message flow direction. Each
program when partitioned acts in a "pitcher-catcher" pair, with the pitcher subscribing to the ActiveMQ 
broker on its side to message types that must be sent to the other side, and generates an RPC invocation 
for each such message instance.  The catcher receives the message and sends it to the local message broker.
In order to prevent loops (due to the same message type being generated both locally as well as being
received from the remote side), the catcher adds a field to mark the message as received from remote side.
The RPC is one-way and no response is expected. 

The usage summary of 'xdcc_gen' is provided below.


```
$ ./xdcc_gen --help
./xdcc_gen
  -e/--egress 	 egress output directory
  -i/--ingress 	 ingress output directory
  -k/--echo 	 echo output directory
  -f/--design 	 design JSON file
  -n/--enclave 	 enclave (e.g. purple)
  -c/--config 	 configuration file
  -h/--help 	 print this message and exit
```

For more information about its usage, see one of the included [EoP1 examples](https://github.com/gaps-closure/build/tree/develop/apps/eop1).
