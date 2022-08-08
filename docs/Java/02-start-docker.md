# Installation and Quick Start For Java Closure **XXX: Ta**

## Contents:

* [Prerequisite](#prerequisite)
* [Pre-built Releases](#pre-built-releases)
* [Build the Source Container](#build-the-source-container)
* [Pre-built Releases](#pre-built-releases)
* [Start the Docker Image](#start-the-docker-image)
* [Install and Build Joana](#install-and-build-joana)
* [Build the Demo Application](#build-the-demo-application)
* [Run the Conflict Analyzer](#run-the-conflict-analyzer)
* [Build HAL](#build-hal)
* [Build Code Generator](#build-code-generator)
* [Partition the Demo Application](#partition-the-demo-application)
* [Run the Demo Application](#run-the-demo-application)

## Prerequisite
The Closure Java is released as a docker container based on Ubuntu 20.04. See [Docker Installation]
(https://docs.docker.com/engine/install/ubuntu/) for instructions on installing docker on Ubuntu.

## Pre-built Releases
A pre-built source release is available at [source release] (https://github.com/gaps-closure/capo/releases/download/T0.2/source-release) and a binary release at [binary release] (https://github.com/gaps-closure/capo/releases/download/T0.2/binary-release). Using the source release docker, one can skip the next step (Build the Source Container) and proceeds to the rest, which builds a docker image equivalent to the binary release when completes successfully.

## Build the Source Container
Save the dockerfile in the appendix to a file, e.g. the default Dockerfile, and build the container as follows.

    $ docker build -f Dockerfile -t closure:src  .

## Start the Docker Image
    $ docker run -ti --device /dev/video0 closure:src
            
where closure:src is the docker repository and tag of the image and /dev/video0 is the device file for the camera on the host.

### Install and Build Joana

    $ rm -rf /tmp/smoke_main
    $ cd $CAPO/joana
    $ ./setup_deps 
    $ ant
    $ ant doc-wala

### Build the Demo Application

    $ cd $CAPO/examples/eop2-demo/
    $ ant

### Run the Conflict Analyzer 

    $ cd $CAPO
    $ java -cp $CLASSPATH org.python.util.jython zincOutput.jy -m ./examples/eop2-demo/src/com/peratonlabs/closure/eop2/video/manager/VideoManager.java -c ./examples/eop2-demo/dist/TESTPROGRAM.jar -e com.peratonlabs.closure.eop2.video.manager.VideoManager -b  com.peratonlabs.closure.eop2.

  If the program is properly annotated, a cut.json file is produced showing the class assignments to each enclave and the methods in the cut.

    $ cp cut.json $HOME/gaps/CodeGenJava/test
  
### Build HAL
    $ cd $HOME/gaps/hal
    $ make   
      
### Build Code Generator
    $ cd $HOME/gaps/CodeGenJava
    $ ant

### Partition the Demo Application
    $ cd $HOME/gaps/CodeGenJava
    $ java -jar code-gen/code-gen.jar
  
### Run the Demo Application
    $ cd $HOME/gaps
    $ ./run.sh
    
Once started, there will be three sets of terminals, from left to right, one for each of the Purple, Orange and Green partitions. Within each partition, the top terminal is the output for HAL and the bottom one for the Java app.  
Wait until the Purple enclave (the leftmost one) is ready and sending messages to the other enclaves. Then on the host of the container, start a browser and go to the URL http://172.17.0.2:8080/.

    host$ firefox http://172.17.0.2:8080/

Click on the Play button. The camera image should appear in the browser at this point.

