## ESCAPE BENCHMARKING

This section describes the benchmarking of the Intel ESCAPE (Extended Secure Capabilities Architecture Platform and Evaluation) GAPS Security Engine. In particular, it investigates the fundamental throughput capability of using the ESCAPE Shared Memory to communicate among applications partitioned by the CLOSURE tool into separate security enclaves.

### Extended Secure Capabilities Architecture Platform and Evaluation (ESCAPE)

The Intel ESCAPE GAPS Security Engine evaluation system consists of two Xeon CPU hosts (host0 and host1) connected over Intel Ultra Path Interconnect (UPI) links to a Stratix 10 FPGA. The FPGA uses an address-filtering mechanism, similar to virtual memory page tables, to allow or disallow reads and writes from either host to a mediated DDR3 memory pool of 16 GB. Each host also has 130 GB of local DDR4 memory. 

Each Xeon host maps the FPGA physical memory so it appears after its 130 GB of local physical memory. For the experiments the 16GB FPGA memory was also split into 14 GB of shared memory and 1 GB of private memory for each host. Thus, each host has 146 GB of physical memory map, whose physical addresses are as shown in the figure below.
 
![ESCAPE host physical memory](docs/C/images/ESCAPE_host_physical_memory.png)

If a process A on host0 and a process B on host1 memory-maps the shared FPGA memory (e.g., using the mmap() call in a C program) then, as shown below, the virtual address space of each process will include the same shared FPGA memory. The process A on host0 and the process B on host1 can thus both access the same FPGA memory using memory copy instructions.

![ESCAPE host virtual memory](docs/C/images/ESCAPE_host_virtual_memory.png)

To allow experimentation without the ESCAPE board, we also 
benchmarked performance using shared memory between two processes on the same host. If a process A on host0 and a process B also on host0 memory-maps part of host0's physical memory, then, as shown below, the virtual address space of each process will again include a portion of shared FPGA memory. 

![Inter process virtual memory](docs/C/images/inter-process_virtual_memory.png)



xxxxx

[appgen/6month-demo/gma.h](https://github.com/gaps-closure/hal/blob/91eb29f27181589357b76eeb361e23849c70fa62/appgen/6month-demo/gma.h).
[HAL daemon listening 0MQ sockets](#hal-interfaces)

```
xxx
```

