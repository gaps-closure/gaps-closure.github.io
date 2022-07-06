## Annotations

**capo/C/constraints/design.md**
**mules/preprocessor**
**forward pointer to cle schema in appendix**
**add examples**



The CLOSURE toolchain relies on source level annotations to specify
the cross domain constraints. Developers annotate programs using CLOSURE Language Extensions (CLE) 
to specifycross-domain security constraints. Each CLE annotation definition associates
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

### A simple annotation  

We can associate a _label_ with some json which describes constraints
the cross domain properties of program elements, forming 
a CLE definition. This is done using a custom `#pragma cle` 
within the C source:

```c
#pragma cle def FOO { "level": "orange" } 
```

The example above provides a minimal cle definition which can 
constraint a global variable. In order to apply such a definition
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

Now look at the json in the label definition more closely:

```c
#pragma cle def FOO { "level": "orange" } 
```

The json specifies a `"level"` field set to `"orange"`. The level is like 
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

### An annotation with cdf

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

**TODO: Remove "direction" field?**

Here, the `"remotelevel"` field specifies that the 
program element the label is applied to can be shared with an enclave
so long as its level is `"purple"`. The `"guarddirective": { "operation": "allow"}}`
defines how data gets transformed as it goes across enclaves. 
In this case, `{ "operation": "allow" }` simply allows the data to pass uninhibited.

The `cdf` is an array, and data can be released into more than one enclave. 
Each object within the `cdf` array is called a `cdf`.

### Function annotations  

Broadly there are two types of annotations, which are node annotations and function
annotations. The previous examples showcased node annotations, but function annotations
allows for functions to be called cross domain, and data to be passed between them.  

Function annotations look similar to node annotations, but contain three extra fields
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

A function annotation works similarly to a node annotation, except now, the `cdf` field
specifies levels in which enclaves of that level can call a given function. 
Function annotations are also different than node annotations as they contain the 
three `taints` fields.

**Question: guarddirective on function/node annotations**

A taint simply refers to a label or an assigned label by the conflict analyzer. There are
three different constraints involving taints in functions, `argtaints`, `codtaints` and `rettaints`.
`rettaints` constrains which labels the return value of a function may be assigned. Similarly, 
`argtaints` constrains the assigned labels for each argument. This field is a 2D-array, mapping each argument of the function to a list of assignable labels. 
`codtaints` includes any other additional labels that may appear in the body. 

Note: Function annotations can coerce between labels of the same level, so it is
expected that these functions are to be audited by the developer.

- taint = label or assigned label
- explain that function annotation is needed for both callee and in many cases the caller too for xd calls
- what each taint means and how they are applied
- non-intuitive weirdness about needing cdf for remotelevel == level
- explain why taints are specified under cdf 
- pointer to cle schema in appendix 
- explanation for mux/sec/typ

**TODO: ask Tony/Rajesh about ARQ params**

### TAGs

In the `XDLINKAGE_GET_A` label, there is `TAG_RESPONSE_GET_A` label. This is a specialized label
name which does not have a definition. 
The definitions for these `TAG_` labels are generated automatically with the autogenerated code, and assign mux/sec/typ parameters to the data before it's sent cross domain. 
For every cross domain call there are two `TAG_` labels generated for receiving and transmitting data, called `TAG_REQUEST_` and `TAG_RESPONSE_`. Each generated tag label has a suffix which is the name of the function it is being applied to in capital letters.  



- explain what tags are and how they are generated
- explain why they are needed

