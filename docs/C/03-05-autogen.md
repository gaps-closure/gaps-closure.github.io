## Autogeneration **XXX: Ready for review**

** For where we do not have text, write two sentences on what it does, how it works, then document usage plus forward references to input/output in appendix"

### GEDL {#gedl}

The GEDL is a json document specifying all the cross domain calls, and associated data such as
the types of arguments/return for each cross domain function, and whether that function parameter
is an input, output or both. If the argument or return is an array, it will list the size of the parameter.

This gedl is generated in an llvm `opt` pass which analyzes the code. Whether a parameter is an input or output is
given by heuristics which dictates whether certain function calls involving function parameters, 
such as `memset`, determine whether a given parameter is a input and output. If the `opt` pass is unable
to infer whether a parameter is an input or output, then it will leave placeholders in the gedl json, given
by `user_input`. 

The gedl file format is described in `gedl_schema.json` which can be found in the [appendix](#gedl-appendix)

The usage of the gedl pass is as follows:

```text
opt -load libgedl.so
-prog <programName>    Name of partitioned program
-schema <schemaPath>   Relative path to gedl schema
-prefix <prefix>       Specify prefix for output
-he <heuristicPath>    Path to heuristics directory
-l <level>             Parameter tree expand level
-d <debugInfo>         use debug information
-u <uprefix>           Specify prefix for untrusted side
-t <tprefix>           Specify prefix for trusted side
-defined <defined>     Specify defined functions file path
-suffix <suffix>       Specify suffix for code injection
```

### IDL 

The IDL is a text file with a set of C style struct data type definitions.
The IDL syntax is based on C; an IDL file contains one or more C struct datatypes. Two structs are
generated for each TAG request and response pair, with the in arguments in the request and the out arguments in the response.

Datatype tags are assigned numerically in the order the structs are found in the file. Not all valid C struct declarations are supported.

Currently we support the following atomic types: 

1. char (8b) 
2. unsigned char (8b)
3. short (16b)
4. unsigned short (16b)
5. int (32b)
6. unsigned int (32b)
7. long (64b)
8. unsigned long (64b)
9. float (4B)
10. double (8B). 

Fixed-size arrays of any supported primitive type are also supported.

The `idl_generator` script takes a gedl json and produces the idl. The usage is as follows:

```text
usage: idl_generator.py [-h] -g GEDL -o OFILE -i {Singlethreaded,Multithreaded} [-s SCHEMA] [-L]

CLOSURE IDL File Generator

optional arguments:
  -h, --help            show this help message and exit
  -g GEDL, --gedl GEDL  Input GEDL Filepath
  -o OFILE, --ofile OFILE
                        Output Filepath
  -i {Singlethreaded,Multithreaded}, --ipc {Singlethreaded,Multithreaded}
                        IPC Type
  -s SCHEMA, --schema SCHEMA
                        override the location of the of the schema if required
  -L, --liberal         Liberal mode: disable gedl schema check
```

Note: The schema is the gedl schema which validates the input gedl during the IDL generation. 
`-L` disables this check. `-i` refers to the ipc threading mode. See the [RPC](#rpc) section for more info.

A sample idl can be found in the [appendix](#idl-appendix).

### Codecs {#codecs}

For each struct in the IDL, the codecs for each are generated. The codecs consist of
encode, decode, print functions for each of the structs, which handle byte order 
conversions between host and network byte order. 

The codecs can be generated using `hal_autogen` which is described in the [DFDL section](#dfdl).

In addition to the codecs, DFDL description of each serialized request/response is generated
by the [DFDL writer](#dfdl).

The generated codecs are registered in the 
hal daemon. The generated rpc code registers these codecs for use of the xdcomms send/recv functions. It includes a rpc_wrapper/handler for each function called cross domain. 

### RPC {#rpc}

The `rpc_generator.py` is used to generate the `*_rpc.{c,h}` for compilation. The rpc code
coordinates cross domain function calls and replaces call invocations to cross domain functions
with ones which marshall and send the data across the network using the generated codecs and IDL. 

The rpc generator has as its input:
1. Partitioned application code including name of main program,
2. CLE annotations for each individual function
3. The generated gedl
4. Input/output ZMQ uris
5. Base values for `mux`, `sec`, `typ` parameters 
6. The cle user annotations for reliability parameters (retries, timeout and idempotence). 

It produces C and header files for CLE-annotated RPC code for each partition including the RPC wrapper and peer call handler. 
Additionally, a `xdconf.ini` is generated, which a [separate script](#halconf) uses to configure [HAL](#hal). 
The CLE-annotated RPC code contains the definitions for each `TAG_` request/response pair.
It also generates the input application code with the following modifications:

1. It adds HAL init and RPC headers to main program
2. It replaces cross domain calls foo() with _rpc_foo()
3. On the partition without the main, it will create a main program and a handler loop
             
Additionally, there are two IPC modes for the generated rpc code, which either can either generate
singlethreaded or multithreaded rpc handlers. The multithreaded mode provides one RPC handler thread per cross domain function, while the singlethreaded mode has one global rpc handler for all
cross domain calls.

The RPC generator usage is as follows:

```text
CLOSURE RPC File and Wrapper Generator

optional arguments:
  -h, --help            show this help message and exit
  -a HAL, --hal HAL     HAL Api Directory Path
  -e EDIR, --edir EDIR  Input Directory
  -c CLE, --cle CLE     Input Filepath for CLE user annotations
  -g GEDL, --gedl GEDL  Input GEDL Filepath
  -i IPC, --ipc IPC     IPC Type (Singlethreaded/Multithreaded)
  -m MAINPROG, --mainprog MAINPROG
                        Application program name, <mainprog>.c must exsit
  -n INURI, --inuri INURI
                        Input URI
  -o ODIR, --odir ODIR  Output Directory
  -s SCHEMA, --schema SCHEMA
                        override location of cle schema if required
  -t OUTURI, --outuri OUTURI
                        Output URI
  -v, --verbose
  -x XDCONF, --xdconf XDCONF
                        Hal Config Map Filename
  -E ENCLAVE_LIST [ENCLAVE_LIST ...], --enclave_list ENCLAVE_LIST [ENCLAVE_LIST ...]
                        List of enclaves
  -M MUX_BASE, --mux_base MUX_BASE
                        Application mux base index for tags
  -S SEC_BASE, --sec_base SEC_BASE
                        Application sec base index for tags
  -T TYP_BASE, --typ_base TYP_BASE
                        Application typ base index for tags
```

### DFDL {#dfdl}

[DFDL](https://daffodil.apache.org/docs/dfdl/) is an extension of XSD which provides
a way to describe binary formats and easily encode/decode from binary to an xml infoset.
CLOSURE has the ability to create DFDL schemas for each cross domain request/response pair
with use of the `hal_autogen`. 

The `hal_autogen` is additionally used to write the [codecs](#codecs) so it takes as input both
the idl and the a `typ` base (which must match the one given to the `rpc_generator.py`) and outputs
both the DFDL and the codecs.

The `hal_autogen` script can be used as follows:

```text
usage: autogen.py [-h] -i IDL_FILE -g GAPS_DEVTYP -d DFDL_OUTFILE [-e ENCODER_OUTFILE] [-T TYP_BASE] [-c CLANG_ARGS]

CLOSURE Autogeneration Utility

optional arguments:
  -h, --help            show this help message and exit
  -i IDL_FILE, --idl_file IDL_FILE
                        Input IDL file
  -g GAPS_DEVTYP, --gaps_devtyp GAPS_DEVTYP
                        GAPS device type [bw_v1 or be_v1]
  -d DFDL_OUTFILE, --dfdl_outfile DFDL_OUTFILE
                        Output DFDL file
  -e ENCODER_OUTFILE, --encoder_outfile ENCODER_OUTFILE
                        Output codec filename without .c/.h suffix
  -T TYP_BASE, --typ_base TYP_BASE
                        Application typ base index for tags (must match RPC Generator)
  -c CLANG_ARGS, --clang_args CLANG_ARGS
                        Arguments for clang
```

### HAL configuration forwarding rules {#halconf}

The `hal_autoconfig.py` script takes a [`xdconf.ini`](#xdconf) generated by the [rpc generator](#rpc) and a [`devices.json`](#devices-json) and combines them to produce a hal configuration, the format of which is described in the [next section](#Hal-Configuration). 

```text
usage: hal_autoconfig.py [-h] [-d JSON_DEVICES_FILE] [-o OUTPUT_DIR] [-p OUTPUT_FILE_PREFIX] [-v]
                         [-x JSON_API_FILE]

Create HAL configuration file

optional arguments:
  -h, --help            show this help message and exit
  -d JSON_DEVICES_FILE, --json_devices_file JSON_DEVICES_FILE
                        Input JSON file name of HAL device conig
  -o OUTPUT_DIR, --output_dir OUTPUT_DIR
                        Output directory path
  -p OUTPUT_FILE_PREFIX, --output_file_prefix OUTPUT_FILE_PREFIX
                        Output HAL configuration file name prefix
  -v, --verbose         run in verbose mode
  -x JSON_API_FILE, --json_api_file JSON_API_FILE
                        Input JSON file name of HAL API and tag-maps
```

Here, the `-d` refers to the device config and the `-x` refers to the `xdconf.ini` file.
An example hal configuration can be found in the [appendix](#hal-orange).
