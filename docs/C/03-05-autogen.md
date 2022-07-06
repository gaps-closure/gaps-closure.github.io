## Autogeneration

### IDL 

- idl_generator.py is used to generate $(PROG).idl for use with HAL Autogen CLOSURE Tool
- schema/gedl-schema.json describes the JSON schema that the output .gedl file will be validated against during IDL generation

**autogen dir in hal repo forward ref to idl example in appendix**

### codecs

**Where is this documented?**

- From gedl, we get the signatures of functions that will be called cross domain
  - in an opt pass inputting divvied code and producing `gedl.json`
  - Additional metadata about args determined by heuristics (configuration file input into opt pass, with forward pointer to heuristics json) 
    - in/out or both
    - array args
    - array size
- If the opt pass is unable to infer, then the user has to edit `gedl.json` whereever
it say `user_input`
- For each xd function, two structures are generated
  - request, and response idl
    - request has all the in and in/out args 
    - response has all the out, in/out args and return
  - for each struct in the idl
    - an encode, decode and print function is also generated
      - encode/decode functions take care of host/network ordering
- In addition to the codecs, DFDL description of each serialized request/response is generated
by the dfdl writer **Forward pointer to DFDL section**
- The generated codecs are registered in the hal daemon
- The generated rpc code registers these codecs for use of the xdcomms send/recv functions   
  - includes a rpc_wrapper/handler for each function called cross domain  


```
divvied code --opt pass-> gedl.json --idl_generator--> idl --codecwriter-> codecs.c/h

idl, gedl.json,  

```

**Update above based on tasks.json/makefiles**

### RPC

- rpc_generator.py is used to generate *_rpc.c, *_rpc.h, and *.c files for compilation by MBIG CLOSURE tool

**TODO: Have Tony edit below**

RPC Generator Notes (2/22/2022)
 -- located in build/capo/C/gedl
 -- inputs: 
    CODE:    Partitioned application code including name of main program
             Also contains CLE annotations for each individual function
             (e.g, Not oneway or bidirection uniformly to all functions
    GEDL:    JSON with function signatures of functions to be wrapped 
             in cross-domain RPC plus information about which parameters
             are inputs/outputs/both, and size of arrays etc.
             currently function arguments must be primitive types or 
             fixed size arrays of primitive types
    Base:    Value for mux, sec, and typ assignments for this progam
    ENCLAVE: List and their levels
    URIs:    To use for HAL configuration
    CLE:     JSON file with reliability default values 
    
    (note: separately an IDL is generated from the GEDL for the
     cross-domain data types, and from the IDL serialization codecs
     are genreated for use with HAL API. RPCGenerator must be consistent
     with the sequence and naming conventions used in the IDL generator 
     and codec generator. DFDL is also generated from the IDL separately.)

 -- outputs:
    1. C and header files for CLE-annotated RPC code for each partition 
       (includes ithe RPC wrapper and peer call handler)
    2. Modifications to the partitioned application code (heuristic, brittle)
     - add HAL init and RPC headers to main program
     - replace cross domain calls foo() with _rpc_foo()
     - on side without the main, create a main program and a handler loop
    Additionally proto-HAL config is generated (lacks device specific config)

    (note: separate script takes the proto-HAL config plus a user-provided 
     device.json to generate complete HAL config for each side)
  
 -- modes 
     ***********************************************************************
     1. Receiver uses singlethreaded vs. multithreaded (default)
     ***********************************************************************
      - latter provides one RPC listener/subscriber thread per XD function 
        RPC protocol is simply get request, run function, send response
      - former special case for completely singlethreaded programs;
        Currently adds extra message exchange (NEXT/OKAY) for single listener thread:
          callee (listener thread) waits for nextrpc message
          caller first sends nextrpc type
          callee (listener thread) sends okay
          callee (listener thread) waits for message specified in prev nextrpc 
          caller sends actual request
          callee gets requests, runs function, send response
          continue looping
     (note: here because Columbia requested this for ease of analysis, sees 
      little usage currently, but support for single-threaded apps is nice to
      have. The oneAPI generated binary may also need)

     ***********************************************************************
     2. Receive Sockets are 1/APP (legacy) vs. 1/function (my_xdc)
     ***********************************************************************
      - original design was based on one persistent listener that handled
        cross-domain messages -- this thread opened a zeromq socket once
        and reused it for the life of the program: 0MQ sockets are not
        thread-safe (0MQ contexts are thread-safe)
      - original design did not work in the case of secdesk, which used
        a web application framework that assigned each HTTP request to
        an arbitrary thread, which had to XD calls. So we needed an 
        alternative where the socket is opened and closed just in time
        within the thread in question -- less efficent, but thread-safe

      (note: legacy put the code in hal/api/xdcomms.[ch], however my_xdc 
       includes a complete alternative thread-safe implementation if
       xdcomms within the genereated <foo>_rpc[.ch].  Somewhat asymmetric.
       xdcomms.[ch] is also used by the Java toolchain. Perhaps the best
       thing is to move my_xdc with conditional compilation into xdcomms.[ch]
       If this done then RPCGenerator will be simplified. When building the
       XDCOMMS library build two versions -- one for legacy one for myxdc)

     ***********************************************************************
      3. Reliability (one vs UPenn ARQ)
     ***********************************************************************
      - Integrates UPenn code in 'rpc_merge' branch
      - Phase 1 RPC genereator is not tolerant to delay/loss -- upon
        loss, the RPC call will hang forever -- we added a variant of
        xdc_blocking_recv which allowed timeouts. UPenn uses this and
        modified each generated RPC wrapper and handler to include 
        retries. CLE annotations specify timeout value and number of
        retries.
      - changes affect the CLE schema used by CLE preprocessor (additional
        fields in CLE)
      - additional code in the RPC generator to implement timeout and retry
      - annotated example application which exercises UPenn features
      - additional input to RPC generator, namely CLE json
      - change in invocation syntax in .vscode/build scripts to include 
        pass the additional input param

     ***********************************************************************
    4. Request-Response vs One-way RPC 
     ***********************************************************************
      - Requestor can send call (with parameters) and either: a) wait for a 
        response (with results) or b) continue without waiting for a response
      - In both cases the responder will run the cross-domain function and 
        will either: a) send the result back to the requestor (for the former 
        Request-Response mode) or will not send any response (for the latter
        One way True Diode).

    The modes are currently all instantiated using C preprocessor macros for 
    conditional compilation (e.g,, Makefile CFLAGS, CLAG_FLAGS or IPC_MODE) or
    by setting the default value (for the ARQ options) in the cle_schema.json 


### DFDL



**Where is this documented?**

### HAL configuration forwarding rules

**Where is this documented?**