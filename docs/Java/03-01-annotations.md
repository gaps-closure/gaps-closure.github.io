## Annotations {#annot-java}

The CLOSURE toolchain relies on source-level annotations to specify the cross-domain constraints. Developers annotate programs using CLOSURE Language Extensions (CLE) 
to specify cross-domain security constraints. Each CLE annotation definition associates
a _CLE label_ (a symbol) with a _CLE JSON_ which provides a detailed specification
for cross-domain data sharing and function invocation constraints.
These source-level annotations determine the following:

1. The assignments of classes to enclaves  
2. The confidentiality of data between enclaves
3. Which functions can be called cross-domain
4. Guard rules that transform data as it crosses domains   

These annotations are only applied to a subset of the program
and then passed to a separate tool called the _conflict _analyzer_ that can infer the CLE labels 
of the rest of the program elements.

The rest of this section will introduce examples of Java program features with CLE annotations.


### Defining CLE Annotations
First, we define a custom java annotation shown below called _Cledef_. A _Cledef_ annotation will be applied to 
each application-specific annotation that we will define and apply to fields, constructors, and methods.
The Cledef annotation enables us to associate a CLE JSON with the application-specific annotation.

```java
@Target(ElementType.ANNOTATION_TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface Cledef 
{
    String clejson() default "";
    boolean isFile() default false;
}

```


### Field Annotations  
In the example below, we show how we can apply a CLE annotation to a field in a Java program.
First, we define our annotation in a java source file.

```java
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Cledef(clejson = "{" + 
                  "  \"level\":\"green\"" + 
                  "}")
public @interface Green {}
```

Together the `Green` custom annotation and the `Cledef` applied to it are equivalent to the
`#pragma cle def <LABEL> <JSON>` that we use with the C toolchain @CDoc.

The above annotation can be applied to any field (static or non-static) in a
class. The retention policy ensures that the annotation is accessible
throughout compilation and at runtime. 

The `clejson` specifies a `"level"` field set to `"green"`. The level is similar to a security level, but there is no requirement for ordering among the levels.
A single level may correspond to many enclaves, but in most cases, they will
be in a bijection with the enclaves. The level names can be any string.

_Enclaves_ are isolated compartments with computation and memory resources. Each enclave operates at a specified level. Enclaves at the same
level may be connected by a network, but enclaves at different levels must be
connected through a cross-domain guard (also known as SDH or TA-1 hardware
within the GAPS program).

The following is an example application of the Green annotation to variable test.

```java
@Green
int test;
```

The following is an example field annotation that allows a cross-domain flow (CDF)

```java
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Cledef(clejson = "{" + 
                  "  \"level\":\"green\"," + 
                  "  \"cdf\":[" + 
                  "    {" + 
                  "      \"remotelevel\":\"purple\"," + 
                  "      \"direction\":\"egress\"," + 
                  "      \"guarddirective\":{" + 
                  "        \"operation\":\"allow\"" + 
                  "      }" + 
                  "    }" + 
                  "  ]" + 
                  "}")
public @interface GreenShareable {}
```

In the above example, the `"remotelevel"` field specifies that the 
program element the label is applied to can be shared with an enclave
so long as its level is `"purple"`. The `"guarddirective": { "operation": "allow"}}`
defines how data gets transformed as it goes across enclaves. 
In this case, `{ "operation": "allow" }` simply allows the data to pass uninhibited.
The `"direction"` field is currently not used and is ignored by the CLOSURE toolchain (may be removed in a future release).

The `cdf` is an array, and data can be released into more than one enclave. 
Each object within the `cdf` array is called a `cdf`.


### Method and Constructor Annotations  

The following shows an example of a constructor annotation.

```java
@Target(ElementType.CONSTRUCTOR)
@Retention(RetentionPolicy.RUNTIME)
@Cledef(clejson = "{" + 
                  "  \"level\":\"purple\"," + 
                  "  \"cdf\":[" + 
                  "    {" + 
                  "      \"remotelevel\":\"green\"," + 
                  "      \"direction\":\"bidirectional\"," + 
                  "      \"guarddirective\":{" + 
                  "        \"operation\":\"allow\"" + 
                  "      }," + 
                  "      \"argtaints\":[]," +
                  "      \"rettaints\":[\"TAG_RESPONSE_EXTRA\"]," +
                  "      \"codtaints\":[\"Purple\"]" +
                  "    }," + 
                  "    {" + 
                  "      \"remotelevel\":\"purple\"," + 
                  "      \"direction\":\"bidirectional\"," + 
                  "      \"guarddirective\":{" + 
                  "        \"operation\":\"allow\"" + 
                  "      }," + 
                  "      \"argtaints\":[]," +
                  "      \"rettaints\":[\"TAG_RESPONSE_EXTRA\"]," +
                  "      \"codtaints\":[\"Purple\"]" +
                  "    }" + 
                  "  ]" +
                  "}")
public @interface PurpleGreenConstructable {}
```

Similarly, the following example shows a method annotation. The only difference
between a constructor and method annotation in Java is the Target. 

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Cledef(clejson = "{" + 
                  "  \"level\":\"orange\"," + 
                  "  \"cdf\":[" + 
                  "    {" + 
                  "      \"remotelevel\":\"purple\"," + 
                  "      \"direction\":\"bidirectional\"," + 
                  "      \"guarddirective\":{" + 
                  "        \"operation\":\"allow\"" + 
                  "      }," + 
                  "      \"argtaints\":[]," +
                  "      \"rettaints\":[\"TAG_RESPONSE_GETVALUE\"]," +
                  "      \"codtaints\":[\"Orange\"]" +
                  "    }," + 
                  "    {" + 
                  "      \"remotelevel\":\"orange\"," + 
                  "      \"direction\":\"bidirectional\"," + 
                  "      \"guarddirective\":{" + 
                  "        \"operation\":\"allow\"" + 
                  "      }," + 
                  "      \"argtaints\":[]," +
                  "      \"rettaints\":[\"TAG_RESPONSE_GETVALUE\"]," +
                  "      \"codtaints\":[\"Orange\"]" +
                  "    }" +
                  "  ]" +
                  "}")
public @interface OrangePurpleCallable {}
```

The following is an example showing how a method or constructor annotation can be applied.
```java
@OrangePurpleCallable
void foo() {

}
```

In a method or constructor annotation, the `cdf` field
specifies remote levels permitted to call the annotated function. 
Method and constructor annotations are also different from data annotations as they contain  
`taints` fields.

A taint refers to a label or an assigned label by the conflict analyzer for a
given data element. There are three different taint types to describe the
inputs, body, and outputs of a function: `argtaints`, `codtaints` and
`rettaints` respectively. Each portion of the method or constructor may only
touch data tainted with the label(s) specified by the annotation:

- `rettaints` constrains which labels the return value of a function may be assigned
- `argtaints` constrains the assigned labels for each argument. This field is a 2D-array, mapping each argument of the method or constructor to a list of assignable labels.
- `codtaints` includes any other additional labels that may appear in the body

Method and constructor annotations can coerce between labels of the same level
(that is, they can allow the annotated method to touch data at a level with
different sharing constraints), so it is expected that these methods and
constructors are to be audited by the developer. The developer must add
a `cdf` where the `remotelevel` is the same as the `level` specified in
the annotation, to perform coercion. The other `cdf` blocks signify that
the method can be called from the `remotelevel` specified.

### TAGs

In the constructor and method annotations, there is `TAG_RESPONSE_GETVALUE` and
`TAG_RESPONSE_EXTRA` label. These are special labels that do not require users
to define them. The definitions for these `TAG_` labels are generated
automatically by the toolchain; for every cross-domain call, there are two
`TAG_` labels generated for receiving and transmitting data, called
`TAG_REQUEST_` and `TAG_RESPONSE_`. Each generated tag label has a suffix which
is the name of the method or constructor it is being applied to in capital
letters. The label indicates that associated data is the result of incoming or
outgoing data specific to the RPC logic. This supports verification of data
types involved in the cross-domain cut and that only intended data crosses the
associated RPC. 

