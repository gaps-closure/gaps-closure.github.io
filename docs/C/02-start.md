# Installation and Quick Start **XXX: Review: Mike**

## Prerequisites

To run the CLOSURE C toolchain @gaps_github, you will need the following prerequisites:

1. Ubuntu Linux 20.04 Desktop
2. Docker verion 20.10 
3. Visual Studio Code with Remote Containers Extension

The dockerfile @Docker we publish provisions all other dependencies needed for  
the CLOSURE toolchain, such as clang, python, and llvm.

## Installation For CLOSURE Users
The fastest way to get started with the CLOSURE toolchain
is to pull the published docker image from dockerhub:

```bash
docker pull gapsclosure/closuredev:latest
```

Then, to get a shell with closure installed, enter the following:

```bash
docker run -it gapsclosure/closuredev:latest 
```

## Running example applications

To run the example applications you will need to clone the
CLOSURE build repository:

```bash
git clone https://github.com/gaps-closure/build.git --recurse-submodules
```

This will create a new directory called build within your current directory.
Under `apps/examples` there are three examples demonstrating basic usage of
the CLOSURE toolchain. For instance, you can open `example1` with vscode as follows:

```bash
code build/apps/examples/example1
```

VSCode should prompt you with reopening within a container. If not, hit `Ctrl+Shift+P`
and type `Reopen in Container` and click the corresponding menu item in the dropdown.

Then you can proceed with the steps in the CLOSURE workflow. If you hit `Ctrl+Shift+B`,
you should get a tasks dropdown with a list of build steps which should look like the following:

![CLOSURE workflow in VSCode](docs/C/images/cvi.png)

The workflow begins by annotating the original source, which can be found under `plain`.
Hitting `1 Annotate` under the dropdown will copy from `plain` into `annotated`. You can
now annotate the program with CLE labels and their definitions. If you are not comfortable
yet with CLE annotations, or are stuck, there is a solution provided in `.solution/refactored` 

After annotating, you can start `2 Conflicts` under the tasks dropdown which will start the conflict analyzer. If the conflict analyzer finds no issues, it will produce a `topology.json` file. Otherwise, it will print out
diagnostics.

Then, you can start the `3 Automagic` task, which will partition and build the application, as well
as start running the application within the emulator.

## Notes For CLOSURE Toolchain Developers

### Building the Docker container

For developers of the CLOSURE toolchain, it may be useful to
understand how to build the closure container:

If within the build directory, all that needs to be done to build
CLOSURE dockerfile is:

```
docker build -f Dockerfile.dev -t gapsclosure/closuredev:latest .
```

### Switching out environment variables in projects

When testing a new feature of some part of the closure toolchain
within a project, it's faster to change environment variables to point
to a local version of a given tool.

For example, a CLOSURE toolchain developer may want to test out a new feature
of the `rpc_generator.py` script. In `closure_env.sh` the `RPC_GENERATOR`
variable can be switched out to point to their own version of the script. Invocation of
the script through the build process will be identical as before. 
Here's an excerpt of a `closure_env.sh` where `rpc_generator.py` is switched out for a 
development version.

```bash
#!/bin/bash

# ...

CLOSURE_TOOLS=/opt/closure
source /opt/closure/etc/closureenv
export CLOSURE_BINS=${CLOSURE_TOOLS}/bin
export CLOSURE_INCLUDES=${CLOSURE_TOOLS}/include
export CLOSURE_LIBS=${CLOSURE_TOOLS}/lib

# ...

# export RPCGENERATOR=rpc_generator
export RPC_GENERATOR=path/to/my/rpc_generator
# ... 
```

### Dockerfile notes

A list of the dependencies can be found in the Dockerfile in `build`.
Most of these dependencies are given by their corresponding apt/python package,
and others are installed manually, such as minizinc, haskell and core.

The Dockerfile uses a `COPY` command to copy over the `build` directory
into the image and builds/installs CLOSURE from within the container. 

### Installing locally

A build can be made locally if the dependencies specified in the dockerfile
are installed on a local machine. 

To install locally, enter the following into the shell within the `build` directory:

```bash
./install.sh -o <install_dir, e.g. /opt/closure>
```

Many of the submodules within `build` repository can be installed similarly, only building
and installing the relevant packages for each repository.

Note that you will need to include `<install_prefix>/etc/closureenv` to your path,
e.g. in your `.bashrc` in order to have command line access to the closure tools.

### Emulator  

The emulator (EMU) uses QEMU instances to represent enclave gateways, the nodes designated for cross-domain transactions via a character device. This allows us to model multi-domain, multi-ISA environments on which the partitioned software will execute. 

As a prerequisite to executing the emulator, it is necessary to build clean VM instances (referred to as the "golden images") from which EMU will generate runtime snapshots per experiment. The snapshots allow EMU to quickly spawn clean VM instances for each experiment as well as support multiple experiments in parallel without interfering among users.

Usually these QEMU images are mounted in the docker container, so that they can be used across containers without rebuilds. 
By default it mounted from and to `/IMAGES` but can be changed in each project's `.devcontainer/devcontainer.json`

VM images can be automatically built using `qemu-build-vm-images.sh` which is mounted in `/opt/closure/emu` by default in the `.devcontainer/devcontainer.json`. The script fetches the kernel, builds and minimally configures the VM disk images, and saves a golden copy of the kernels and images. This script is run by default if needed in the supported applications during the VSCode task 9E.
