# CLOSURE Instructions for Containerized Toolchain Deployment
## Prerequisites
1. Docker (version 18.06+) 
2. VSCode with Remote-Containers Extension
3. Gitslave (http://gitslave.sourceforge.net)

## CLOSURE Docker Images
Obtain CLOSURE Dockerfiles from our repository:
```
mkdir ~/gaps
cd ~/gaps
git clone https://github.com/gaps-closure/dockerfiles
```

Availabile images include:
Image  | Description 
---------- | ----------------- 
CLOSURE    | includes CLOSURE toolchain and related dependencies. Use this image for general application development. 
EOP1DEV    | additionally adds libraries for EoP1 Mission App (i.e., ActiveMQ, OpenCV, activemq-cpp, etc.). This image should be used if intending to run CLOSURE MDD with VSCode for End of Phase 1 demos. (requires CLOSURE image)
EOP1       | additionally builds EoP1 cases 1-3 for Perspecta demos using CLOSURE toolchain from command line. This image can be used to rapidly deploy and execute EoP1 in a target environment (does not depend on above images). <b>TA1 has independently verified PL's EoP demos using this image</b>. 

Build desired images:
```
cd ~/gaps/dockerfiles
./build.sh closure 
./build.sh eop1dev
./build.sh eop1
```
<b>Note:</b> Docker images can be exported/imported using `docker save` and `docker load`. Consider this mechanism to copy CLOSURE images to unconnected environments.

## Obtain CLOSURE Sources
```
cd ~/gaps
gits clone https://github.com/gaps-closure/build
```

## CLOSURE Emulator (Optional) -- Ubuntu 20.04 only
CLOSURE emulator can be utilized to test CLOSURE-compiled applications when physical hardware is not preferred (e.g. rapid T&E). If using the emulator, additional steps are required to prepare the emulated VM instances using QEMU.
```
sudo mkdir /IMAGES
cd ~/gaps/build/src/emu/scripts/qemu
./qemu-build-vm-images.sh -a amd64 -d focal-k focal-s 20G -o /IMAGES
./qemu-build-vm-images.sh -a amd64 -d focal-k focal-s 20G -o /IMAGES -u
```

## Notes on VSCode Remote-Container Support
Each CLOSURE project includes a file `.devcontainer/devcontainer.json` which configures the containerized development enviornment. 
<b> If you will not be installing the emulator</b> the configuration will fail to find `/IMAGES` on your physical server. Either run `sudo mkdir /IMAGES` or manually remove the emulator mount points from the `devcontainer.json`:
``` 
  "mounts": [
		"source=/tmp/.X11-unix,target=/tmp/.X11-unix,type=bind"
	]
  # 2 lines mounting /IMAGES and ~/gaps/build/src/emu have been removed in above
```
For more information on remote-container development using VSCode, see https://code.visualstudio.com/docs/remote/containers.

## Demo: ERI 2020 Examples 1-3
Navigate to the desired example and launch VSCode. VSCode will prompt user to load the `CLOSURE` containerized environment:

For example1:
```
cd ~/gaps/build/apps/examples/example1
code .
<click VSCode prompts to reload in container>
run VSCode Build tasks and follow ERI guidelines for CLE annotations
```

## Demo: End-of-Phase 1
Navigate to the desired EoP Case (1-3) and launch VSCode. VSCode will prompt user to load the `EOP1DEV` containerized environment:

For case1:
```
cd ~/gaps/build/apps/eop1/case1
code .
<click VSCode prompts to reload in container>
Follow EoP instructions per videos on Confluence (essential steps are A6 and BUILD)
