## Auto Generation of Aspects for Partition Enforcement and Cross Domain Communications **XXX: Ta => Rajesh Review** {#AspectJ} 

** Rip out everything below and rewrite for java **
** What it does, how it works (including design and diagrams), usage, input/output with pointers to examples described in appendix **

Once the CAPO partitioning conflict analyzer has analyzed the CLE-annotated application code, and determined that all remaining conflicts are resolvable by RPC-wrapping to result in a security compliant cross-domain partitioned  code, the conflict analyzer will produce a topology file (JSON) containing the assignment of every  class and global variable to an enclave/level. An abbreviated sample topology JSON is provided below. 

```json
{
    "enclaves": [
        {
            "level": "green", 
            "assignedClasses": [
                "com.peratonlabs.closure.eop2.level.normal.VideoEndpointNormal", 
                "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal", 
                "com.peratonlabs.closure.eop2.level.normal.VideoServerNormal"
            ], 
            "name": "green_E"
        }, 
        {
            "level": "purple", 
            "assignedClasses": [
                "com.peratonlabs.closure.eop2.transcoder.Transcoder", 
                "com.peratonlabs.closure.eop2.video.manager.VideoManager"
            ], 
            "name": "purple_E"
        }, 
        {
            "level": "orange", 
            "assignedClasses": [
                "com.peratonlabs.closure.eop2.level.high.VideoEndpointHigh", 
                "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh", 
                "com.peratonlabs.closure.eop2.level.high.VideoServerHigh"
            ], 
            "name": "orange_E"
        }
    ], 
    "entry": {
        "mainClass": "com.peratonlabs.closure.eop2.video.manager.VideoManager", 
        "enclave": "purple_E", 
        "filepath": "./examples/eop2-demo/src/com/peratonlabs/closure/eop2/video/manager/VideoManager.java"
    }, 
    "cuts": [
        {
            "callee": {
                "level": "orange", 
                "type": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh"
            }, 
            "allowedCallers": [
                {
                    "level": "purple", 
                    "type": "com.peratonlabs.closure.eop2.video.manager.VideoManager"
                }
            ], 
            "methodSignature": {
                "parameterTypes": [
                    "int", 
                    "java.lang.String"
                ], 
                "fqcn": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh", 
                "name": "start", 
                "returnType": "void"
            }
        }, 
        {
            "callee": {
                "level": "green", 
                "type": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal"
            }, 
            "allowedCallers": [
                {
                    "level": "purple", 
                    "type": "com.peratonlabs.closure.eop2.video.manager.VideoManager"
                }
            ], 
            "methodSignature": {
                "parameterTypes": [
                    "int", 
                    "java.lang.String"
                ], 
                "fqcn": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal", 
                "name": "start", 
                "returnType": "void"
            }
        }, 
        {
            "callee": {
                "level": "orange", 
                "type": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh"
            }, 
            "allowedCallers": [
                {
                    "level": "purple", 
                    "type": "com.peratonlabs.closure.eop2.video.manager.VideoManager"
                }
            ], 
            "methodSignature": {
                "parameterTypes": [], 
                "fqcn": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh", 
                "name": "getRequest", 
                "returnType": "com.peratonlabs.closure.eop2.video.requester.RequestHigh"
            }
        }, 
        {
            "callee": {
                "level": "green", 
                "type": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal"
            }, 
            "allowedCallers": [
                {
                    "level": "purple", 
                    "type": "com.peratonlabs.closure.eop2.video.manager.VideoManager"
                }
            ], 
            "methodSignature": {
                "parameterTypes": [], 
                "fqcn": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal", 
                "name": "getRequest", 
                "returnType": "com.peratonlabs.closure.eop2.video.requester.Request"
            }
        }, 
        {
            "callee": {
                "level": "orange", 
                "type": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh"
            }, 
            "allowedCallers": [
                {
                    "level": "purple", 
                    "type": "com.peratonlabs.closure.eop2.transcoder.Transcoder"
                }
            ], 
            "methodSignature": {
                "parameterTypes": [
                    "java.lang.String", 
                    "byte[]"
                ], 
                "fqcn": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh", 
                "name": "send", 
                "returnType": "void"
            }
        }, 
        {
            "callee": {
                "level": "green", 
                "type": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal"
            }, 
            "allowedCallers": [
                {
                    "level": "purple", 
                    "type": "com.peratonlabs.closure.eop2.transcoder.Transcoder"
                }
            ], 
            "methodSignature": {
                "parameterTypes": [
                    "java.lang.String", 
                    "byte[]"
                ], 
                "fqcn": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal", 
                "name": "send", 
                "returnType": "void"
            }
        }
    ]
}
```

Given the annotated application and the topology, the Java code generation tool, CodeGenJava, does the following

- creates a directory for each partition and copies the original app code into it; (xdcc/purple_E/)
- generates AspectJ definitions for each partition; (xdcc/purple_E/aspect/VideoRequesterHighClosureAspect.aj)
- generates cross-domain tags and HAL configurations; (xdcc/xdconf.ini and xdcc/hal_purple_E.cfg)
- generates remote procedure call handlers; (xdcc/green_E/aspect/VideoManagerMainAspect.aj)
- generates an ant build script for each enclave (xdcc/purple_E/build-closure.xml) and
- compiles and aspect weaves the resulting code.

The generated artifacts on the list is straightforward. Examples of the output files are listed inside the parentheses above and can be found in the appendix. We only briefly describe below the AspectJ definitions.
Aspect-oriented programming (AOP) is a programming paradigm that aims to increase modularity by allowing the separation of cross-cutting concerns. It does so by adding behavior to existing code ("advice") without modifying the code itself, instead separately specifying which code is modified (a "pointcut" specification). For example, log all function calls when the function name begins with 'set‘.

Aspect-oriented programming has the benefits of clean modularization of cross-cutting concerns,
unmodified annotated source code with aspects being woven in by the compiler when generating the executable.
The following diagram gives a high level explanation of the concept.

![CLOSURE architecture](docs/Java/images/aopArch.png){#aopArch}

CLOSURE's approach to AOP is the following.
A developer annotates Java application code using CLE and perform cross-domain analysis at the Java/Dalvik bytecode level. 
AspectJ code is auto-generated by CLOSURE, so programmer need not learn AOP concepts.
CVI takes care of invocation of the AspectJ compiler.

Based on the 'cuts' in the topology JSON file, CodeGenJava generates the necessary Aspect definitions to intercept cross-domain calls and forward it to the remote enclave via the the HAL layer.
For example, for cross-domain object instantiation, the generated AspectJ pointcut corresponding to the constructor intercepts the invocation, generates a shadow object and assigns an object id (oid).
The constructor invocation and oid are then serialized to the remote enclave through RPC over HAL.
The remote handler deserializes the call, instantiates and stores a local instance.

Cross-domain method invocations are handled similarly. If it is to invoke an instance method, the Aspect definition looks up the oid corresponding to the object and 
serialize the method request along with and oid to the remote enclave through RPC over HAL.
The remote handler deserializes the call, looks up the object corresponding to the oid and invokes the specified method.
The return value is serialized and passed back along the reverse path. Upon receving the return value, the AspectJ provides it to the application, which proceeds normally.

The following diagram depicts both the process of object instantiation and method invocation.

![CLOSURE architecture](docs/Java/images/methodInvoke.png){#invoke}


The usage of the program CodeGenJava is straightforward:

```bash
$ java -jar code-gen.jar -h
GAPS/Closure Java Code Generator
  -h/--help                    this help
  -c/--cutJson <cut.json>      cut JSON file (test/cut.json)
  -d/--dstDir  <pathname>      destination directory of the generated code (/home/closure/gaps/xdcc)
  -f/--config  <config.json>   config JSON file
  -i/--codeDir <source code>   code directory relative to srcDir (.)
  -j/--jar     <jar name>      name of the application jar file (TESTPROGRAM)
  -p/--compile <true|false>    Compile the code after partition (true)
  -s/--srcDir  <app src dir>   application source code (/home/closure/gaps/capo/Java/examples/eop2-demo)
```

Without arguments, CodeGenJava uses the default arguments within the parentheses at the end of the options above. A JSON config file can also be provided. An excerpt of the config is given below. A full sample config.json is given in the appendix.

```json
{
  "dstDir": "/home/closure/xdcc",
  "cut": "test/cut.json",
  
  "srcDir": "/home/closure/gaps/capo/Java/examples/eop2-demo",
  "codeDir": ".",
  "jar": "TESTPROGRAM",
  "compile": true,
}
```

