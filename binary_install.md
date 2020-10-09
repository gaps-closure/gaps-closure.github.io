# Gaps-Closure Setup Guide

A basic guide to installing the gaps-closure toolchain binaries and scripts required to build projects utilizing gaps-closure

## System Requiremenst

* Ubuntu 19.10 (Eoan Ermine) (Currently supported/Tested)
* KVM (or nested KVM if a VM) required for the Emulator enviroment
* 40GB or more disk space (recommended)
* Passwordless sudo access, many scripts currently expect to be able to run sudo without a password

## Files Required (links tbd)

<a name="file-list"/>
The following files will be required for the following install

* *LLVM-10.0.1-Linux.sh* – LLVM 10.0.1 binary build (production)
* *opt-debug* – Debug build of opt
* *closure_bin.tar.gz* - Distribution of the closure binaries and scripts

## Installing the closure tools


The following instructions will install the gaps-closure project to run the ERI demo, and potential develop projects using gaps-closure

## 1. Download git slave

Get and install [git slave](http://gitslave.sourceforge.net/) tool (used to organize the multiple git repositories used by gaps-closure

<div>
```
wget https://sourceforge.net/projects/gitslave/files
gitslave-2.0.2.tar.gz
tar -xzvf gitslave-2.0.2.tar.gz
cd gitslave-2.0.2
sed 's/pod2man/pod2man --name gits/' -i Makefile
sed 's/pod2man/pod2man --name gits-checkup/' -i contrib/Makefile
make
sudo make install
```
</div>

## 2. Clone the toolchain with gits

Clone the entire project into the ~/gaps/build directory

```
cd ~
mkdir -p gaps
cd ~/gaps
gits clone https://github.com/gaps-closure/build
```

##3. Run the build script

This script prepares an older version of the toolchain, however includes automatically fetching most of the dependencies.

```
cd ~/gaps/build
./build.sh
```

Keep this build directory as it contains the example projects

##4. Get the provided files

Get the provided [files](#file-list)


Make a working directory (this document will prsume you are using /opt/tmp)

> `$ mkdir /opt/tmp`

Place the three files (LLVM-10.0.1-Linux.sh, opt-debug, closure_bin.tar.gz)

##5. Installing LLVM-10.0.1 (production build)

a. Enter the directory with LLVM-10.0.1-Linux.sh

> `cd /opt/tmp`

b. Run the self extractomg script

> `sudo chmod a+x ./LLVM-10.0.1-Linux.sh`

> `sudo ./LLVM-10.0.1-Linux.sh`

c. change into the extacted directory and move the LLVM files into /usr/local

> `cd LLVM-10.0.1-Linux`

> `cp -rv . /usr/local/`

d. Now you should be able to run clang

> <pre>
$ clang --version
clang version 10.0.1 (https://github.com/llvm/llvm-project.git d24d5c8e308e689dcd83cbafd2e8bd32aa845a15)
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /usr/local/bin
</pre>

If you recieve an error about libz3 run the following to ensure its installed

> <pre>
$ sudo apt install libz3-4 libz3-dev
$ sudo ln -s /usr/lib/x86_64-linux-gnu/libz3.so /usr/lib/x86_64-linux-gnu/libz3.so.4.8
</pre>

With this symlink now the `clang --version` should be able to find libz3

##6. Additional prerequisits

> <pre>
$ pip3 install lark-parser==0.7.8 jsonschema libconfig
</pre>

##7. Add symlink for Python libclang

To ensure libclang can be found by python3 you will need to update a symlink to clang install

> <pre>
sudo ln -s /usr/local/lib/python3.5/site-packages/clang /usr/local/lib/python3.7/dist-packages/clang
</pre>

##8. Extract Files to /opt/closure

closure_bin.tar.gz needs to be extracted to /opt/closure

> <pre>
sudo mkdir -p /opt/closure
cd /opt/closure
tar -xzvf /opt/tmp/closure_bin.tar.gz
</pre>

##9. Move opt-debug into the bin directory

> <pre>
sudo mv /opt/tmp/opt-debug /opt/closure/bin/opt-debug
chmod a+x /opt/closure/bin/opt-debug
</pre>

##10. Prepare the emulator

At this point you should be able to build the Gaps Closure examples and eri demo, to run it however in the emulator you will also need to run its preperation guide

See the emulators [README](https://github.com/gaps-closure/emu/blob/master/README.md) for details

## Additional Reference

If you run into dependenciey issues you may wish to check the [enviroment_setup](https://github.com/gaps-closure/build/blob/master/environment_setup.md) document for specific versions of various packages

The example projects can be found in ~/gaps/build/apps/
