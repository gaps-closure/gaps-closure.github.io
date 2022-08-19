# Instructions for Containerized CLOSURE Toolchain Deployment
## Prerequisites
1. [Docker](https://www.docker.com/) (version 18.06+) 
2. [VSCode](https://code.visualstudio.com/) with [Remote - Containers Extension](https://code.visualstudio.com/docs/remote/containers)

## CLOSURE Docker Images
Obtain CLOSURE docker images:
```
docker pull gapsclosure/closuredev:latest
```
### Obtain CLOSURE Sources
```
mkdir ~/gaps
cd ~/gaps
gits clone https://github.com/gaps-closure/build.git --recurse-submodules
```

## CLOSURE Emulator (Optional) -- Ubuntu 20.04 only

CLOSURE emulator can be utilized to test CLOSURE-compiled applications when physical hardware is not preferred (e.g. rapid T&E). If using the emulator, additional steps are required to prepare the emulated VM instances using QEMU. <b> These commands should be run once to provision the machine </b>. Once `/IMAGES` is populated it can be left alone.
```
sudo mkdir /IMAGES
cd ~/gaps/build/emu/scripts/qemu
./qemu-build-vm-images.sh -a amd64 -d focal -k focal -s 20G -o /IMAGES
./qemu-build-vm-images.sh -a amd64 -d focal -k focal -s 20G -o /IMAGES -u
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

## Demo: ERI 2020 Examples 1-3
Navigate to the desired example and launch VSCode. VSCode will prompt user to load the `closuredev` containerized environment:

For example1:
```
cd ~/gaps/build/apps/examples/example1
code .
<click VSCode prompts to reload in container>
run VSCode Build tasks and follow ERI guidelines for CLE annotations
```

## Demo: End-of-Phase 1
Navigate to the desired EoP Case (1-3) and launch VSCode. VSCode will prompt user to load a containerized environment:

For case1:
```
cd ~/gaps/build/apps/eop1/case1
code .
<click VSCode prompts to reload in container>
Follow EoP instructions per videos on Confluence (essential steps are A6 and BUILD)
```