## ESCAPE BENCHMARKING

This section describes performance benchmarking of the Intel ESCAPE GAPS Security Engine. In particular, it investigates the fundamental throughput capability of ESCAPE Shared Memory to communicate among applications partitioned into separate security enclaves by the CLOSURE tool. A benchmarking tool collects the throughput for different: a) types of memory, b) copy sizes, c) copy functions, and d) number of parallel threads, which are then collated by the plotting script to generate performance plots.

### ESCAPE GAPS Security Engine 

The Intel ESCAPE [1] GAPS Security Engine evaluation system consists of two Xeon CPU hosts (host0 and host1) connected over Intel Ultra Path Interconnect (UPI) links to a Stratix 10 FPGA. 
The two ESCAPE hosts run Ubuntu 20.04.1 OS with 130 GB of local DDR4 memory a connected over a 64-bit memory bus with a bandwidth of 2933 MegaTransfers per second (MT/s). Each laptop therefore has a local memory bandwidth of 2.933 x 8 = 23.46 GB/s. 

[1] Intel, "Extended Secure Capabilities Architecture Platform and Evaluation (ESCAPE) System Bring Up Document," February 17, 2022.

By editing the GRUB boot loader, each Xeon host maps the 16 GB of FPGA physical memory so it appears after its local physical memory. 
Thus, each host has 130 + 16 = 146 GB of physical memory map, whose physical addresses are as shown in the figure below:

![ESCAPE host physical memory](docs/C/images/ESCAPE_host_physical_memory.png)

To provide GAPS security between enclaves, the FPGA uses an address-filtering mechanism, similar to virtual memory page tables. The filtering rules allow or disallow reads and writes from either host to a mediated DDR3 memory pool of 16 GB.  
For the benchmarking the 16GB FPGA memory was also split into 14 GB of shared memory and 1 GB of private memory for each host. 


If a process A on ESCAPE host0 and a process B on ESCAPE host1 memory-maps the shared FPGA memory (e.g., using the mmap() call in a C program) then, as shown below, the virtual address space of each process will include the same shared FPGA memory. The process A on host0 and the process B on host1 can thus both access the same FPGA memory using memory copy instructions allowing inter-Host communicagtion. 

![ESCAPE host virtual memory](docs/C/images/ESCAPE_host_virtual_memory.png)

### Inter-Process Communication using Shared Memory 

To measure raw shared memory performance without the ESCAPE board, we also benchmarked shared memory performance between two processes on the same host. If a process A and process B both on host0 memory-map part of host0's physical memory, then, as shown below, the virtual address space of each process will include the same portion of shared FPGA memory. 

![Inter-process Virtual Memory](docs/C/images/inter-process_virtual_memory.png)

### Benchmarking Program

The [Benchmarking program](https://github.com/gaps-closure/hal/tree/multi-threaded/escape/perftests)
runs a series of throughput performance measurements for combinations of four variables:
memory type, payload length, copy function, and number of worker threads.

#### Variable 1) Memory Types

The Benchmarking program copies data between its local heap memory created using malloc() and one of three types of memory:

- **Host heap**: Allocates memory from the host using malloc(). This memory only allows a single process to write then read the memory, but measures raw memory bandwidth. 
- **Host mmap**: Allocates memory by opening /dev/mem followed by an mmap() of host memory. The resultant mapped memory can be used to communicate data between two processes on the same host.
- **ESCAPE mmap**: Allocates memory by opening /dev/mem followed by an mmap() of FPGA memory. For the ESCAPE system this starts at address 130 GB = 0x2080000000 (as described above), though this address can be changed by modifying the MMAP_ADDR_ESCAPE definition in [memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c).

In one run of the benchmark program, it reads and writes to each of the three types of memory, creating a total of 2 x 3 = 6 different experiments. Each experiment has an ID from 0 to 5, allowing the user to specify a from- to to-list of experiment types to run [see parameter description](#benchmarking-program-parameters)

#### Variable 2) Payload Lengths

For each of the six memory write/read types in a run, the benchmark program tests thoughput with a series of increasing payload lengths (number of bytes of data that are written or read). 
It's defulat is to test with 10 different payload lengths from 16 bytes up to 16 MB 
(except for *host mmap* memory, which linux limits up to 512K).
However, the number of lengths test can be reduced using the '-n' option when calling the program 
(e.g., '-n 3' will run just the first 3 payload lengths). 
The payload values themselves can be modified by changing the definitions of the 
global array *copy_size_list* in [memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c). 

#### Variable 3) Copy Functions

For each payload length in a run, the benchmarking program tests with three different copy functions,
which read or write data between the program and the memory:

- **glibc memory copy**: memcpy().
- **naive memory copy**: using incrementing unsigned long C pointers that point to the destinatiion and source (*d++ = *s++).
- **Apex memory copy**: A fast memory copy fuunction whose [source code is available](https://www.codeproject.com/Articles/1110153/Apex-memmove-the-fastest-memcpy-memmove-on-x-x-EVE)

The banchmark script runs the test multiple times for each copy function tested. 
The default number of tests is 5, but the value can be changed by specifying the
'-r' [parameter option](#test-program-parameters) when calling the benchmmark program.

#### Variable 4) Number of Worker Threads

The each run the user can specify the number of parallel worker threads that copy the data
using the '-t' option when calling the program.
For example, '-t 16' will run just with 16 paralel worker threads  


### ESCAPE Testbed Setup 

(escape-green and escape-orange)




xxxxx


[HAL daemon listening 0MQ sockets](#hal-interfaces)



amcauley@jaga:~/gaps/build/hal/escape/perftests$ make
make clean

apex_
gcc -c -o thread_pool.o thread_pool.c -g -Iinclude -O3 -Wall -Werror -std=gnu99
gcc -o memcpy_test memcpy_test.c apex_memmove.o thread_pool.o -g -Iinclude -O3 -Wall -Werror -std=gnu99 -lpthread



## RUN TEST PROGRAM
The ESCAPE test program is in a singlefile: [memcpy_test.c](memcpy_test.c)
It links with the apex memory copy files: [apex_memmove.c](apex_memmove.c) [apex_memmove.h](apex_memmove.h)
It outputs results into a single file: by default *results.csv*
To run the test program:
```
make && sudo ./memcpy_test  

# Run test with greater sampling
make && sudo ./memcpy_test -r 1000

# Run quick tests on just Escape Memory (write and read) with lower sampling
make && sudo ./memcpy_test -r 2 4 5
```

### Benchmarking Program Parameters

The options available to the benchmarking program can be discovered using the
help option as shown below:

```
amcauley@jaga:~/gaps/build/hal/escape/perftests$ ./memcpy_test -h
Shared Memory speed/function test for GAPS CLOSURE project
Usage: ./escape_test [OPTIONS]... [Experiment ID List]
OPTIONS: are one of the following:
 -h : print this message
 -i : which source data is initialized
   0 = all sources (default) - both applicaiton or shared memory as source of data
   1 = only if source is application - use current shared memory content as source (so can read on different node/process than writer)
 -n : number of length tests (default=9, maximum = 10)
 -o : source data initialization offset value (before writing)
 -r : number of test runs per a) memory pair type, b) payload length and c) copy function (default=5)
memory pair type IDs (default = all) for application (using host heap) to:
   0 = write to host heap
   1 = read from host heap
   2 = write to host mmap
   3 = read from host mmap
   4 = write to shared escape mmap
   5 = read from shared escape mmap
 -t : number of worker threads in thread pool (default=0)
 -z : read/write with given number of second sleep between each (default z=0)
```

Set nice level...
