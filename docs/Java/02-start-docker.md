# Installation and Quick Start For CLOSURE Java Toolchain {#quicstart}

## Prerequisite
The CLOSURE Java toolchain is released as a Docker @Docker container based on
Ubuntu 20.04. See [Docker Installation](https://docs.docker.com/engine/install/ubuntu/) 
for instructions on installing Docker on a Ubuntu Linux system.

## Pre-built Releases
A pre-built source release is available at [source release](https://github.com/gaps-closure/capo/releases/download/T0.2/source-release) and a binary release at [binary release](https://github.com/gaps-closure/capo/releases/download/T0.2/binary-release). Using the source release docker, one can skip the next step (Build the Source Container) and proceeds to the rest, which builds a docker image equivalent to the binary release when completes successfully.

## Build the Source Container
Save the dockerfile in the appendix to a file, e.g. the default Dockerfile, and build the container as follows.

```bash
docker build -f Dockerfile -t closure:src  .
```

## Start the Docker Image

```bash
docker run -ti --device /dev/video0 closure:src
```
            
where `closure:src` is the docker repository and tag of the image and `/dev/video0` is the device file for 
the camera on the host.

### Build JOANA

You can build JOANA as follows:

```bash
rm -rf /tmp/smoke_main
cd $CAPO/joana
./setup_deps 
ant
ant doc-wala
```

### Compile the Demo Application

Next, compile the annotated source code for the unpartitioned demo application as follows:

```bash
cd $CAPO/examples/eop2-demo/
ant
```

### Run the Conflict Analyzer 

Run the CLOSURE conflict analyzer to check for feasible partitions. 

```bash
cd $CAPO
java -cp $CLASSPATH org.python.util.jython zincOutput.jy -m ./examples/eop2-demo/src/com/peratonlabs/closure/eop2/video/manager/VideoManager.java -c ./examples/eop2-demo/dist/TESTPROGRAM.jar -e com.peratonlabs.closure.eop2.video.manager.VideoManager -b com.peratonlabs.closure.eop2.
```

If the program is properly annotated, a `cut.json` file is produced showing the
class assignments to each enclave and the methods in the cut.

```bash
cp cut.json $HOME/gaps/CodeGenJava/test
```
  
### Build HAL

Build the HAL daemon as follows.

```bash
cd $HOME/gaps/hal
make   
```
      
### Build Code Generator

Build the code generator tool as follows.

```
cd $HOME/gaps/CodeGenJava
ant
```

### Partition the Demo Application

Generate aspects and weave into demo application to generate partitioned executable for each enclave.

```
cd $HOME/gaps/CodeGenJava
java -jar code-gen/code-gen.jar
```
  
### Run the Demo Application

Run the demonstration application.

```
cd $HOME/gaps
./run.sh
```
    
Once started, there will be three sets of terminals, from left to right, one
for each of the Purple, Orange and Green partitions. Within each partition, the
top terminal is the output for HAL and the bottom one for the Java app.  
Wait until the Purple enclave (the leftmost one) is ready and sending messages
to the other enclaves. Then on the host of the container, start a browser and
go to the URL `http://172.17.0.2:8080/`.

```bash
# On the host
firefox http://172.17.0.2:8080/
```

Click on the Play button. The camera image should appear in the browser at this point.

## Additional Notes for CLOSURE Developers

Developers who wish to extend the CLOSURE Java partitioner or visualize the
generated system dependency graph (SDG) will find the following steps useful.

Generate SDG and Dot files for test program as follows:

```bash
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH="joana/dist/*:testprog/dist/*:jython-standalone-2.7.2.jar:jscheme-7.2.jar:"
java -cp $CLASSPATH org.python.util.jython JoanaUsageExample.jy \
  -c './testprog/dist/TESTPROGRAM.jar' \
  -e 'com.peratonlabs.closure.testprog.example1.Example1' \
  -p -P 'out.pdg' \
  -d -D 'out.dot' \
  -j -J 'out.clemap.json' 

```

You can launch the SDG viewer, and visualize the SDG interactively:

```
java -cp $CLASSPATH edu.kit.joana.ui.ifc.sdg.graphviewer.GraphViewer 
```

You can produce the program partition next:

```bash
java -cp $CLASSPATH org.python.util.jython zincOutput.jy
 -m './example1/src/example1/Example1.java'
 -c './example1/dist/TESTPROGRAM.jar'   
 -e 'com.peratonlabs.closure.testprog.example1.Example1' 
 -b 'com.peratonlabs.closure.testprog' 
```

The command line parameters are as follows:

```usage
  -m option indicates what java file has the main class to analyze
  -c option indicates the jar file to analyze
  -e option indicates the class with the entry method
  -b option indicates the prefix for the classes that are of interest
```

Running this command will result in the following artifacts to be generated
  
  * `enclave_instance.mzn`
  * `pdg_instance.mzn`
  * `cle_instance.mzn`
  * `cut.json`
  * `dbg_edge.csv`
  * `dbg_node.csv`
  * `dbg_classinfo.csv`

The `dbg_edge.csv` and `dbg_node.csv` files report useful information about all of
the nodes and edges in the SDG being analyzed that can be useful to debug and
find issues with annotations.

The `dbg_classinfo.csv` file contains the class name, field, and method name to ID relationships.

The three `.mzn` files are what get fed to MiniZinc along with the fixed `.mzn` files in the `constraints/`
directory to run the constraint solver.  If the program is properly annotated,
a `cut.json` file is produced showing the class assingments to each enclave and
the methods in the cut.

Since the output of the constraint solver reports edge IDs, useful scripts
are available in the `capo/Java/scripts` directory. The `edgeDbg.py` script takes
an edge ID as input and produces the debug information for the associated
source and destination nodes. Similarly, `getclassName.py` takes a class ID and
produces the correspoinding class name for the ID. Note that these scripts
assume the `dbg_*.csv` files are in the same directory as the scripts.

Set classpath and java location and build the application to be partitioned.  
These commands assume you are in the `capo/Java` directory. 

```
export CLASSPATH="joana/dist/*:examples/eop2-demo//dist/*:jython-standalone-2.7.2.jar:jscheme-7.2.jar:"
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
```

Build the demo application:
```
cd examples/eop2-demo/
ant
cd ../..
```

**IMPORTANT** In file 
`capo/Java/examples/eop2-demo/src/com/peratonlabs/closure/eop2/video/manager/config.java`
ensure that webroot is initalized to `capo/Java/examples/eop2-demo/resources`

Run the conflict analyzer  from `capo/Java`:

```bash
java -cp $CLASSPATH org.python.util.jython zincOutput.jy -m './examples/eop2-demo/src/com/peratonlabs/closure/eop2/video/manager/VideoManager.java'   -c './examples/eop2-demo/dist/TESTPROGRAM.jar' -e 'com.peratonlabs.closure.eop2.video.manager.VideoManager' -b 'com.peratonlabs.closure.eop2.'
```

The resulting cut.json will be produced in the directory the above command is invoked from.
