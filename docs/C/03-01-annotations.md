## Annotations 

The CLOSURE toolchain relies on source level annotations to specify
the cross domain constraints. Developers annotate programs using CLOSURE Language Extensions (CLE) 
to specify cross-domain security constraints. Each CLE annotation definition associates
a _CLE label_ (a symbol) with a _CLE JSON_ which provides detailed specification
of cross-domain data sharing and function invocation constraints.

These source level annotations determine the following:

1. The assignments of functions and global variables to enclaves   
2. The confidentiality of data between enclaves
3. Which functions can be called cross domain
4. Guard rules which transform data as it crosses domains   

Typically, these annotations are only applied to a subset of the program
and a separate tool called the _conflict analyzer_ is able infer the CLE labels 
of the rest of the program elements given this subset.

### A Simple Annotation

We can associate a _label_ with some JSON which describes constraints
on the cross domain properties of program elements, forming 
a CLE definition. This is done using a custom `#pragma cle` 
within the C source:

```c
#pragma cle def FOO { "level": "orange" } 
```

The example above provides a minimal cle definition which can 
constrain a global variable. In order to apply such a definition
to some global variable you can use `#pragma cle begin/end`:

```c
#pragma cle begin FOO
int bar = 0;
#pragma cle end FOO
```

or more simply

```c
#pragma cle FOO
int bar = 0;
```

Now look at the JSON in the label definition more closely:

```c
#pragma cle def FOO { "level": "orange" } 
```

The JSON specifies a `"level"` field set to `"orange"`. The level is like 
security level, but there is no requirement for an ordering among the levels.
A single level may correspond to many enclaves, but in most cases they will
be in a bijection with the enclaves. The level names can be any string.

_Enclaves_ are isolated compartments with computation and memory
reources. Each enclave operates at a specified level. Enclaves at the same
level may be connected by a network, but enclaves at different levels must be
connected through a cross-domain guard (also known as SDH or TA-1 hardware
within the GAPS program).


When applying the `FOO` label to `int bar`, we effectively pin `bar`
to a single level `"orange"`.

### An Annotation with Cross-Domain Flow (cdf) Definition

The next example shows another label definition, this time with
a new field called `cdf`, standing for cross-domain flow.

```c
#pragma cle def ORANGE_SHAREABLE {"level":"orange",\
  "cdf": [\
    {"remotelevel":"purple", \
     "direction": "egress", \
     "guarddirective": { "operation": "allow"}}\
  ] }
```

Here, the `"remotelevel"` field specifies that the 
program element the label is applied to can be shared with an enclave
so long as its level is `"purple"`. The `"guarddirective": { "operation": "allow"}}`
defines how data gets transformed as it goes across enclaves. 
In this case, `{ "operation": "allow" }` simply allows the data to pass uninhibited. 
The `"direction"` field is currently not used and is ignored by the CLOSURE toolchain (may be removed in future release).

The `cdf` is an array, and data can be released into more than one enclave. 
Each object within the `cdf` array is called a `cdf`.




### Function Annotations  

Broadly there are two types of annotations: 1) data annotations and 2) function
annotations. The previous examples showcased data annotations, but function annotations
allow for functions to be called cross domain, and data to be passed between them.  

Function annotations look similar to data annotations, but contain three extra fields
within each cdf, `argtaints`, `codtaints` and `rettaints`.

```c
#pragma cle def XDLINKAGE_GET_A {"level":"orange",\
  "cdf": [\
    {"remotelevel":"purple", \
     "direction": "bidirectional", \
     "guarddirective": { "operation": "allow"}, \
     "argtaints": [], \
     "codtaints": ["ORANGE"], \
     "rettaints": ["TAG_RESPONSE_GET_A"], \
     "idempotent": true, \
     "num_tries": 30, \
     "timeout": 1000 \
    }, \
    {"remotelevel":"orange", \
     "direction": "bidirectional", \
     "guarddirective": { "operation": "allow"}, \
     "argtaints": [], \
     "codtaints": ["ORANGE"], \
     "rettaints": ["TAG_RESPONSE_GET_A"] \
    } \
  ] }
```

In a function annotation, the `cdf` field
specifies remote levels permitted to call the annotated function. 
Function annotations are also different from data annotations as they contain  
`taints` fields.

A taint refers to a label or an assigned label by the conflict analyzer for a given data element. There are
three different taint types to describe the inputs, body, and outputs of a function: `argtaints`, `codtaints` and `rettaints` respectively. Each portion of the function may only touch data tainted with the label(s) specified by the function annotation:
`rettaints` constrains which labels the return value of a function may be assigned. Similarly, 
`argtaints` constrains the assigned labels for each argument. This field is a 2D-array, mapping each argument of the function to a list of assignable labels. 
`codtaints` includes any other additional labels that may appear in the body. 
Function annotations can coerce between labels of the same level, so it is expected that 
these functions are to be audited by the developer. Often, the developer will add a cdf where the 
remotelevel is the same as the level of the annotation, just to perform some coercion.


Optional fields in function annotations include
- idempotent: indicates function can be called repeatedly (e.g., when messages are lost in the network, you RPC logic can reissue the request)
- num_tries: Upon failure, how many attempts to call a function cross domain before giving up 
- timeout: controls the timeout for the cross domain read function (see [`xdc_recv` function](#xdcomms-send-recv)).


### Label Coercion

Only an annotated function can accept data of one or more label and produce data with other labels as allowed by the annotation constraints on the function's arguments, return, and body. We call this label or taint coercion. See [label coercion](#coercion) for detailed discussion. Label coercion can happen within a single level when a function annotation is given
a cdf with a remotelevel the same as its level.


### TAGs

In the `XDLINKAGE_GET_A` label, there is `TAG_RESPONSE_GET_A` label. This is a reserved label
name which does not require a user-provided definition. The definitions for these `TAG_` labels are generated automatically by the toolchain; for every cross domain call there are two `TAG_` labels generated for receiving and transmitting data, called `TAG_REQUEST_` and `TAG_RESPONSE_`. Each generated tag label has a suffix which is the name of the function it is being applied to in capital letters. The label indicates associated data is the result if incoming or outgoing data specific to the RPC logic. This supports verification of data types involved in the cross-domain cut and that only intended data crosses the associated RPC. 

### Example cross domain function

Consider `double bar(double x, double y);` which resides in level `purple`
and `void foo()` which resides in level `orange`, and the intent is that `foo` will call `bar`
cross domain. A full specification of this interaction using CLE annotations is presented as follows:

```c
#pragma cle def ORANGE {"level":"orange",\
  "cdf": [\
    {"remotelevel":"purple", \
     "direction": "egress", \
     "guarddirective": { "operation": "allow"}}\
  ] }

#pragma cle def PURPLE { "level": "purple" } 

#pragma cle def FOO {"level":"orange",\
  "cdf": [\
    {"remotelevel":"orange", \
     "direction": "bidirectional", \
     "guarddirective": { "operation": "allow"}, \
     "argtaints": [], \
     "codtaints": ["ORANGE", "TAG_RESPONSE_BAR", "TAG_REQUEST_BAR"], \
     "rettaints": [] \
    } \
  ] }

#pragma cle def BAR {"level":"purple",\
  "cdf": [\
    {"remotelevel":"purple", \
     "direction": "bidirectional", \
     "guarddirective": { "operation": "allow"}, \
     "argtaints": [["TAG_REQUEST_BAR"], ["TAG_REQUEST_BAR"]], \
     "codtaints": ["PURPLE"], \
     "rettaints": ["TAG_RESPONSE_BAR"] \
    }, \
    {"remotelevel":"orange", \
     "direction": "bidirectional", \
     "guarddirective": { "operation": "allow"}, \
     "argtaints": [["TAG_REQUEST_BAR"], ["TAG_REQUEST_BAR"]], \
     "codtaints": ["PURPLE"], \
     "rettaints": ["TAG_RESPONSE_BAR"] \
    } \
  ] }

#pragma cle begin FOO 
void foo() {
#pragma cle end FOO 
  double result = bar(0, 1);
  // ...
}


#pragma cle begin BAR
double bar(double x, double y) {
#pragma cle end BAR 
  return (x + y) * (x * y);
}
```

In this example there are two label coercions. One from the caller side from `ORANGE` to the tags of `foo` 
and the other on the callee side from the tags of `bar` to `PURPLE` and back. These coercions
are needed because the autogenerated code only works on data cross domain with the tag labels.
Future releases may permit users to specify these tag labels, so that less coercion is needed.
