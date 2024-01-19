## RPC Generation [TODO: TA]
Discuss what/how you manually generated the RPCs. Discuss how this can be automated in code generation.

The CLOSURE C toolchain generates several artifacts, including 

- GEDL, a JSON document specifying all the cross domain calls and their associated data including the arguments and return type. This gedl is generated in an llvm `opt` pass which analyzes the divvied code.

- IDL, a text file with a set of C style struct data type definitions, used to facilitate subsequent serialization and marshaling of data types.
The IDL syntax is based on C; an IDL file contains one or more C struct datatypes. Two structs are
generated for each TAG request and response pair, with the in arguments in the request and the out arguments in the response. The `idl_generator` script takes a gedl JSON and produces the idl. 

- CODEC. For each struct in the IDL, a codecs is generated to facilitate serialization to the remote enclave. The codecs consist of
encode, decode, print functions for each of the structs, which handle byte order conversions between host and network byte order. The codecs can be generated using `hal_autogen`.

- RPC, remote procedure code that
automates cross domain function invocation and replaces calls to those functions
with ones that additionally marshall and send the data across the network using the generated codecs and IDL. 
The `rpc_generator.py` is used to generate the `*_rpc.{c,h}` 

- DFDL, is an extension of XSD which provides
a way to describe binary formats and easily encode/decode from binary to an xml infoset.
CLOSURE has the ability to create DFDL schemas for each cross domain request/response pair
with use of the `hal_autogen`. 

- HAL Configurations. 
The `hal_autoconfig.py` produces a *HAL-Daemon* configuration.

All of these, with enhancements, are expected to be used in the C++ toolchain, which
is under active development. Before they become fully available, a few manual steps are taken
to faciliate the development. In particular, GEDL and IDL files are manually written for 
a sample C++ program. From that IDL, codec functions are produced using the existing `hal_autogen`.
Furthermore, RPC code and HAL configurations are also manually written, according to the needs of 
the sample program to work in the usual CLOSURE environment.



## Marshalling/Serialization of Data Types [TODO: TA]
Discuss what/how you manually generated the data formats. Discuss steps that can be automated in the toolchain. Discuss how we might deal with more complex data types (classes, structs, typdefs)
