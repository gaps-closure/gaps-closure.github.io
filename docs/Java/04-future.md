# Limitations and Future Work 

## Limitations and language coverage {#limitations} 
CLOSURE currently supports subset of the Java language version 8. Notable
current limitations are a lack of support for multi-threading applications and
annotating lambda functions. Additionally, some underlying toolchains used have
limited support for large program. Lastly, we currently do not support Android
applications.  These language limitations are currently being addressed and we
plan on supporting them in future releases. The CLOSURE Java tool chain has
been demonstrated to support up to 3 enclaves, and can conceptually reason
about an arbitrary number of enclaves. 

## Future Work

In future work, we will work on relaxing the [known limitations](#limitations).
Also in the research pipeline are:
  
1. Support for Android applications
2. Support for analysis and partitioning of large applications
3. More complete coverage of the Java language
   
