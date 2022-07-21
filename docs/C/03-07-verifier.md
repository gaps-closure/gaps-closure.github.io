## Verifier **XXX: Include paragraphs from paper, then add usage, and document input/output formats in appendix"

### ECT 

ECT verifies the equivalence between the refactored program and
those in the various enclaves by checking, function-by-function, that
the generated code has been paritioned without undue modification and
will thus behave like the refactored code.  The tool, written in
[Haskell](https://www.haskell.org/), loads both programs then starts
establishing their equivalence.  As it proceeds, it construct a
modular, bottom-up proof in the
[Z3](https://github.com/Z3Prover/z3/wiki) theorem prover that is both
checked as the tool proceeds and written out in
[SMT-LIB](http://smtlib.cs.uiowa.edu/) format, a human- and
machine-readable format suitable for auditing.

** Old -- does not discuss security compliance **

### Downstream conflict analyzer 
