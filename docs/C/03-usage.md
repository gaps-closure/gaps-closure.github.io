# Detailed Usage and Reference Manual

**For every subsection, cover purpose, what it does, how it works, how to invoke, inputs/outputs + forward pointers to appendix** 

## CLE, Annotation Methodology

**capo/C/constraints/design.md**
**mules/preprocessor**
**forward pointer to cle schema in appendix**
**add examples**

### also for models, model checking, and include C generation

**describe message flow model.json from eop1, needs to be written**
**README in ect/flowspec**
**examples in appendix**

## Conflict Analysis and Feasible Partition Identification

**whatever readme available in all repos, but will need to be written**

### preprocessor

### opt pass for PDG

**PSU documentation for PDG**

### input generation and constraint solving using Minizinc

### diagnostics using findMUS

## Code Dividing and -Refactoring

### dividing

### opt pass for GEDL and configuring heuristics

## Autogeneration

### IDL 

### codecs

### RPC

### DFDL

### HAL configuration forwarding rules

## HAL and XDCOMMS API

### Architecture based on 0MQ 

### Supported GAPS devices

### XD send/recv API

## Verifier

### LLVM->Haskell, Haskell model, Z3 model gen, conflict analyzer downstream, proof checking 

## Emulator

### topology configuration, generation ang plumbing using CORE and qemu

### building qemu images for different architectures

### guard models

### scenario generation: various input and generated configuration files

### running scenarios

### Deploying on objective hardware

**Talk to Tony about what we did for mercury testbed**
- **describe script that combines xdconf.ini and device.json**
- **Copy and build each partition on respective hardware**
- **Install xdcomms/hal on each enclave**
- **Configure and start hal for each enclave**
- **Bring up application on each side**

## CVI 

### Startup and usage

### CLE plugin and language server

### Setting up a new project (Makefiles and VScode tasks)

## Example applications

### Examples 1-3

**Look at partitioning intent for each**
**Look at ERI summit slides**

### Test cases for solver

### EOP1 Cases 1-3 ??

**EOP1 slides**

