## Emulator (EMU)
The CLOSURE project provides a general purpose emulation tool for instantiating virtual cross domain architectures and running partitioned applications within them. The Emulator supports Multi-ISA and has been tested with x86 (Ubuntu focal kernel) and ARM64 (Ubuntu Xenial kernel) Linux. Built on top of QEMU, the emulator is flexible and can easily incoporate a QEMU instance of the target platform if need be. Integrated with the CLOSURE toolchain, the emulator can also be used stand-alone and is not limited to CLOSURE-partitioned applications (though this is the common usage).
### Topology configuration, Generation and Plumbing using CORE and qemu
![emu](docs/C/images/emu.png)
Upon running the emulator, several enclaves (indicateed by color) are instantiated per the configuration file. Within each enclave are two types of nodes: i) enclave-gateway node (e.g., orange-enclave-gw-P) which is co-located with emulated cross-domain hardware used for cross-domain communication to a peer enclave, and ii) a local enclave host (e.g., orange-1) within the enclave but without emulated GAPS hardware. Enclave gateways are named using the following convention: ```<local color>-enclave-gw-<first letter of peer enclave in capital letter>```. Between enclave gateways are  cross-domain gateway nodes ```<color1>-<color2>-xd-gw```. The cross-domain gateways faciliate bump-in-the-wire guard configuration described in subsequent sections. The Emulator has been tested with up to 4 enclaves. Note the enclave limit is attributed to the processing capcity of the underlying machine running the emulator (there is no fundamental limit to number of nodes and enclaves otherwise). A node can be accessed by double clicking its icon in the GUI to obtain a terminal to the node.

Each enclave-gateway node runs an instance of QEMU to model the node. The QEMU is configured using socat and netcat such that there is a device (/dev/vcom) with with the node reads/writes to communicate cross domain. Data written to /dev/vcom is passed to the corresponding xd-gw node which either passes the data through or applies redaction (see guard discussion below). The data is then available for reading at the remote enclave-gw QEMU instance upon reading from /dev/vcom. This configuration emulates reading/writing to the guard in the real deployment - no IP-based communication is occuring between the applications (even though under the hood the emulator uses IP transport to move the data). From the applications' perspective they are reading/writing directly to the guard device driver. Note that when double-clicking the enclave-gw node, you are immediately within the QEMU instance (rather than the CORE BSD container wrapping it).

To start the emulator (stand-alone), cd into the emu directory and run ./start [scenario name] where scenario name is that of a directory name in emu/config. Within a scenario configuration are three files:
- settings.json: basic settings that typically do not need to be modified. `instdir` should be the absolute path of the parent to which emu is located (e.g., /home/user/gaps/build/)
- enclaves.json: the scenario specification that describes the nodes, connectivity, and attributes
- layout.json: the graphical layout of the nodes as they will appear on the emulator GUI

The emulator comes with configuration for 2,3, and 4 enclave scenarios which can be used as a basis for most projects.

Upon running a scenario, perform a basic testing of the cross-domain communication pathway. Use `echo` and `cat` to test reading/writing to the device. On the orange-enclave-gw-P, run `cat /dev/vcom` and on purple-enclave-gw-O, run `echo "abc" > /dev/vcom`. You will see "abc" appear on the terminal of orange-enclave-gw-P.

### Building QEMU images for Different Architectures
EMU uses QEMU instances to represent enclave gateways, the nodes designated for cross-domain transactions via a character device to the SDH. This allows us to model multi-domain, multi-ISA environments on which the partitioned software will execute. As a prerequisite to executing the emulator, it is necessary to build clean VM instances (referred to as the "golden images") from which EMU will generate runtime snapshots per experiment. The snapshots allow EMU to quickly spawn clean VM instances for each experiment as well as support multiple experiments in parallel without interfering among users.

VM images can be automatically built using `qemu-build-vm-images.sh`. The script fetches the kernel, builds and minimally configures the VM disk images, and saves a golden copy of the kernels and images. 

```
cd scripts/qemu
./qemu-build-vm-images.sh -h
# Usage: ./qemu-build-vm-images.sh [ -h ] [ -p ] [ -c ] \
#           [ -a QARCH ] [ -d UDIST ] [-s SIZE ] [-k KDIST ] [-o OUTDIR]
# -h        Help
# -p        Install pre-requisites on build server
# -c        Intall NRL CORE on build server
# -a QARCH  Architecture [arm64(default), amd64]
# -d UDIST  Ubuntu distro [focal(default)]
# -s SIZE   Image size [20G(default),<any>]
# -k KDIST  Ubuntu distro for kernel [xenial(default),<any>]
# -o OUTDIR Directory to output images [./build(default)]
```
We recommend storing the built images in a common directory accessible to all users (this README assumes that directory is `/IMAGES`). Ensure sudo group is allowed to work without passwords, otherwise expect scripting to fail on sudo attempts. <b>Note: Pre-built VMs and kernels available under assets in EMU releases. Consider downloading and placing in your image directory to skip the VM build process.</b>

If building your own images, create a virgin image for each architecture for the supported distro (currently eoan): 

```
# AMD64
./qemu-build-vm-images.sh -a amd64 -d focal -k focal -s 20G -o /IMAGES
# ARM64
./qemu-build-vm-images.sh -a arm64 -d focal -k xenial -s 20G -o /IMAGES
```
This will fetch the kernel (e.g., linux-kernel-amd64-eoan), initrd (linux-initrd-amd64-eoan.gz), and build the virgin qemu vm image (e.g., ubuntu-amd64-eoan-qemu.qcow2.virgin) using debootstrap.

Now configure the virgin image to make it usable generally with user networking support (allows host-based NAT-ted access to Internet):
```
# AMD64
./qemu-build-vm-images.sh -a amd64 -d focal -k focal -s 20G -o /IMAGES -u 
# ARM64
./qemu-build-vm-images.sh -a arm64 -d focal -k xenial -s 20G -o /IMAGES -u
```
You should find the golden copy (e.g., ubuntu-amd64-eoan-qemu.qcow2) created in the directory specified by the `-o` argument (e.g. `/IMAGES`). Note that the [Emulator Configuration](https://github.com/gaps-closure/gaps-emulator#configuration) settings.json file requires you to specify the images directory if not using `/IMAGES`.

### Guard Models
EMU supports both Bump-In-The-Wire (BITW) and Book-Ends (BE) deployments. In BITW configuration, redaction occurs on the xd-gw node. A 'flowspec' can be loaded -- essentiall a python program that performs the redaction function on data passing through the node. In BE configuration, the 'flowspec' is invoked at the enclave-gateway before releasing it to the xd-gw (which is merely passthrough in this case). Note the 'flowspec' is a future feature and not general purpose at this time. 

<b> Bump-In-The-Wire Configuration </b>
![BITW](docs/C/images/socat-bidirectional-filter-BITW.png)
<b> Bookends Configuration </b>
![BE](docs/C/images/socat-bidirectional-filter-BOOKEND.png)

### Scenario Generation: Various Input and Generated Configuration Files
To generate a scenario, create a directory within emu/config and name it accordingly. Then copy the template configuration files from 2enclave, 3enclave, or 4enclave (depending on which scenario closely matches your intended topology). 

Modify your enclaves.json as needed. For example, you may want to adjust the CPU architecture or toggle Bookends (BE) vs Bump-in-the-Wire (BITW). 

#### Selecting the ISA for Enclave Gateways/Cross-Domain Hosts (xdhost)
Consider the following snippet from `config/2enclave/enclave.json`:
```json
"hostname": "orange-enclave-gw-P",
"hwconf":{"arch": "amd64"},
"swconf":{"os": "ubuntu", "distro": "focal", "kernel": "focal",
```
To change orange-enclave-gw-P to use ARM64, modify the configuration as follows:
```json
"hostname": "orange-enclave-gw-P",
"hwconf":{"arch": "arm64"},
"swconf":{"os": "ubuntu", "distro": "focal", "kernel": "xenial",
```
EMU has been tested using AMD64(eoan) and ARM64(xenial) images. Other architecture/OS instances can be built by following the above provisioning steps, but has not been tested.

#### Selecting the SDH Model for Cross-Domain Links (xdlink)
EMU supports Bookends (BKND) and Bump-In-The-Wire (BITW) SDH deployments. Selection of the model is specified in the `xdlink` section of enclaves.json:
```json
"xdlink": 
  [
    { "model":  "BITW",
      "left":   {"f": "orange-enclave-gw-P", "t":"orange-purple-xd-gw",
                 "egress":   {"filterspec": "left-egress-spec", "bandwidth":"100000000", "delay": 0},
                 "ingress":  {"filterspec": "left-ingress-spec", "bandwidth":"100000000", "delay": 0}},
      "right":  {"f": "orange-purple-xd-gw", "t":"purple-enclave-gw-O",
                 "egress":   {"filterspec": "right-egress-spec", "bandwidth":"100000000", "delay": 0},
                 "ingress":   {"filterspec": "right-ingress-spec", "bandwidth":"100000000", "delay": 0}}
    }
  ]
```
The above specifies a BITW model. Simply change to the following to use BKND:
```json
"model": "BKND"
```

### Running Scenarios

### Deploying on objective hardware

**Talk to Tony about what we did for mercury testbed**
- **describe script that combines xdconf.ini and device.json**
- **Copy and build each partition on respective hardware**
- **Install xdcomms/hal on each enclave**
- **Configure and start hal for each enclave**
- **Bring up application on each side**
