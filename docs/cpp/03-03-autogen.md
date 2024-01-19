## RPC Generation
Discuss what/how you manually generated the RPCs. Discuss how this can be automated in code generation.

The CLOSURE C++ RPC generation is expected to be built as an extention of 
the C toolchain, which generates the following artifacts.

- GEDL, a JSON document specifying all the cross domain calls and their associated data including the arguments and return type. This gedl is generated in an llvm `opt` pass which analyzes the divvied code.

- IDL, a text file with a set of C style struct data type definitions, used to facilitate subsequent serialization and marshaling of data types.
The IDL syntax is based on C; an IDL file contains one or more C struct datatypes. Two structs are
generated for each TAG request and response pair, with the in arguments in the request and the out arguments in the response. The `idl_generator` script takes a gedl JSON and produces the idl. 

- CODEC. For each struct in the IDL, a set of coding and decoding functions is generated to facilitate serialization to the remote enclave. The codecs consist of
encode, decode, print functions for each of the structs, which handle byte order conversions between host and network byte order. The codecs can be generated using `hal_autogen`.

- RPC, remote procedure code that
automates cross domain function invocation and replaces calls to those functions
with ones that additionally marshall and send the data across the network using the generated codecs and IDL. 
The `rpc_generator.py` is used to generate the `*_rpc.{c,h}` 

- DFDL, is an extension of XSD which provides
a way to describe binary formats and easily encode/decode from binary to an xml infoset.
CLOSURE has the ability to create DFDL schemas for each cross domain request/response pair
with use of the `hal_autogen`. 

- HAL Configurations. The `hal_autoconfig.py` produces a *HAL-Daemon* configuration.

All of these, with enhancements, are expected to be used in the C++ toolchain, which
is under active development. Before they become fully available, a few manual steps are taken
to faciliate the development. In particular, GEDL and IDL files are manually written for 
a sample C++ program. From that IDL, codec functions are produced using the existing `hal_autogen`.
Furthermore, RPC code and HAL configurations are also manually written, according to the needs of 
the sample program to work in the usual CLOSURE environment.

To work with the richer language contructs in C++, the RPC generator needs to be enhanced. 
It is expected that it needs to play the role of the AspectJ compiler in the Java toolchain.
In addition, the CLOSURE library classes such as HalZmq and ClosureShadow and others will need
to be implemented correspondingly in the C++ toolchain.

## Marshalling/Serialization of Data Types

The general idea of marshalling/unmarshalling and serialization/deserialization of cross domain constructs remains 
the same as in the C toolchain.
However, the current `idl_generator` and the `hal_autogen` scripts can handle a flattened structure containing primitive types. They need to be extended to handle complex data types such as classes and nested structures. A depth-first tree traversal algorithm needs to be implemented to serialize and deserialize nested structures. 
For typedefs, the toolchain needs to take advantage of type information in llvm opt, and makes 
the actual types available to in gedl. Tools in the later phase are not expected to deal with typedefs directly.