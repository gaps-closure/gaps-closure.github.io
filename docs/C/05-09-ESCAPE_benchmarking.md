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


If a process A on ESCAPE host0 and a process B on ESCAPE host1 memory-maps the shared FPGA memory (e.g., using the mmap() call in a C program) then, as shown below, the virtual address space of each process will include the same shared FPGA memory. The process A on host0 and the process B on host1 can thus both access the same FPGA memory using memory copy instructions allowing inter-Host communication. 

![ESCAPE host virtual memory](docs/C/images/ESCAPE_host_virtual_memory.png)

### Inter-Process Communication using Shared Memory 

To measure raw shared memory performance without the ESCAPE board, we also benchmarked shared memory performance between two processes on the same host. If a process A and process B both on host0 memory-map part of host0's physical memory, then, as shown below, the virtual address space of each process will include the same portion of shared FPGA memory. 

![Inter-process Virtual Memory](docs/C/images/inter-process_virtual_memory.png)

### Benchmarking Program

#### Benchmarking Program Parameters

The benchmarking program is a C program consisting of two main parts:  

- The main program that runs through all the [testing parameter combinations](@benchmarking-program-variables): 
[memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c).
- The worker thread pool that creates and manages all the worker threads:
[thread_pool.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/thread_pool.c).

The parameter options available to the benchmarking program can be discovered using the
help option as shown below:

```
amcauley@jaga:~/gaps/build/hal/escape/perftests$ ./memcpy_test -h
Shared Memory speed/function test for GAPS CLOSURE project
Usage: ./escape_test [OPTIONS]... [Experiment ID List]
OPTIONS: are one of the following:
 -h : print this message
 -i : which source data is initialized
   0 = all sources (default) - both application or shared memory as source of data
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


#### Benchmarking Program Variables

The [Benchmarking program](https://github.com/gaps-closure/hal/tree/multi-threaded/escape/perftests)
runs a series of throughput performance measurements for combinations of four variables:
memory type, payload length, copy function, and number of worker threads.

##### **Variable 1)** Memory Types

The Benchmarking program copies data between its local heap memory created using malloc() and one of three types of memory:

- **Host heap**: Allocates memory from the host using malloc(). This memory only allows a single process to write then read the memory, but measures raw memory bandwidth. 
- **Host mmap**: Allocates memory by opening /dev/mem followed by an mmap() of host memory. The resultant mapped memory can be used to communicate data between two processes on the same host.
- **ESCAPE mmap**: Allocates memory by opening /dev/mem followed by an mmap() of FPGA memory. For the ESCAPE system this starts at address 130 GB = 0x2080000000 (as described above), though this address can be changed by modifying the MMAP_ADDR_ESCAPE definition in [memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c).

In one run of the benchmark program, it reads and writes to each of the three types of memory, creating a total of 2 x 3 = 6 different experiments. Each experiment has an ID from 0 to 5, allowing the user to specify a list of experiment types to run as program [parameters](#benchmarking-program-parameters)

##### **Variable 2)** Payload Lengths

For each of the six memory write/read types in a run, the benchmark program tests throughput with a series of increasing payload lengths (number of bytes of data that are written or read). 
It's default is to test with 10 different payload lengths from 16 bytes up to 16 MB 
(except for *host mmap* memory, which linux limits up to 512K).
However, the number of lengths test can be reduced using the '-n' [parameter option](#benchmarking-program-parameters) when calling the program 
(e.g., '-n 3' will run just the first 3 payload lengths). 
The payload values themselves can be modified by changing the definitions of the 
global array *copy_size_list* in [memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c). 

##### **Variable 3)** Copy Functions

For each payload length in a run, the benchmarking program tests with three different copy functions,
which read or write data between the program and the memory:

- **glibc memory copy**: memcpy().
- **naive memory copy**: using incrementing unsigned long C pointers that point to the destination and source (*d++ = *s++).
- **Apex memory copy**: A fast memory copy function whose [source code is available](https://www.codeproject.com/Articles/1110153/Apex-memmove-the-fastest-memcpy-memmove-on-x-x-EVE)

The benchmark script runs the test multiple times for each copy function tested. 
The default number of tests is 5, but the value can be changed by specifying the
'-r' [parameter option](#benchmarking-program-parameters) when calling the benchmark program.

##### **Variable 4)** Number of Worker Threads

The each run the user can specify the number of parallel worker threads that copy the data
using the '-t' [parameter option](#benchmarking-program-parameters) when calling the program.
For example, '-t 16' will run just with 16 parallel worker threads.  


#### Clone, Compile and Run Benchmarking Program

The benchmarking program is part of the HAL branch (as is the plotting script), 
with the latest version (including the multi-threaded option) found in the git multi-threaded branch:

```
git clone git@github.com:gaps-closure/hal.git
cd hal/escape/perftests
git checkout multi-threaded
git branch --set-upstream-to=origin/multi-threaded
```

To compile the benchmarking program we run make:

```
make
  gcc -c -o apex_memmove.o apex_memmove.c -g -Iinclude -O3 -Wall -Werror -std=gnu99
  gcc -c -o thread_pool.o thread_pool.c -g -Iinclude -O3 -Wall -Werror -std=gnu99
  gcc -o memcpy_test memcpy_test.c apex_memmove.o thread_pool.o -g -Iinclude -O3 -Wall -Werror -std=gnu99 -lpthread
```

A few examples of running with  run the benchmarking program:

```
To run with default parameters:
  sudo ./memcpy_test  

To run at a higher priority:
  sudo nice --20 ./memcpy_test  

To run only the first two memory types (write and read to heap memory)
  sudo ./memcpy_test 0 1

To run test with greater sampling (average over 1000 runs instead of 5)
  sudo ./memcpy_test -r 1000

To run just for smaller lengths
  sudo ./memcpy_test -n 3
```

The results for each input variable are printed on the terminal. For example:

```
sudo ./memcpy_test 0 1 -r 1000 -n 2

$ sudo ./memcpy_test 0 1 -r 1000 -n 2
PAGE_MASK=0x00000fff data_off=0 source_init=0 payload_len_num=2 runs=1000 thread count=0 sleep=0 num_mem_pairs=2 [ 0 1 ]
App Memory uses host Heap [len=0x10000000 Bytes] at virtual address 0x7fb55c46c010
--------------------------------------------------------------------------------------
    sour data [len=0x10000000 bytes]: 0x fffefdfcfbfaf9f8 f7f6f5f4f3f2f1f0 ... 1716151413121110 f0e0d0c0b0a0908 706050403020100
0) App writes to host-heap (fd=-1, vir-addr=0x7fb54c46b010, phy-addr=0x0, len=268.435456 MB)
      16 bytes using glibc_memcpy =   5.785 GB/s (1000 runs: ave delta = 0.000000003 secs)
      16 bytes using naive_memcpy =   9.473 GB/s (1000 runs: ave delta = 0.000000002 secs)
      16 bytes using  apex_memcpy =   5.382 GB/s (1000 runs: ave delta = 0.000000003 secs)
     256 bytes using glibc_memcpy =  49.089 GB/s (1000 runs: ave delta = 0.000000005 secs)
     256 bytes using naive_memcpy =  23.610 GB/s (1000 runs: ave delta = 0.000000011 secs)
     256 bytes using  apex_memcpy =  29.190 GB/s (1000 runs: ave delta = 0.000000009 secs)
    dest data [len=0x100 bytes]: 0x fffefdfcfbfaf9f8 f7f6f5f4f3f2f1f0 ... 1716151413121110 f0e0d0c0b0a0908 706050403020100
Deallocating memory: fd=-1 pa_virt_addr=0x7fb54c46b010 pa_map_len=0x10000000 mem_typ_pair_indexM=0
run_per_mem_type_pair Done
--------------------------------------------------------------------------------------
    sour data [len=0x10000000 bytes]: 0x fffefdfcfbfaf9f8 f7f6f5f4f3f2f1f0 ... 1716151413121110 f0e0d0c0b0a0908 706050403020100
1) App reads from host-heap (fd=-1, vir-addr=0x7fb54c46b010, phy-addr=0x0, len=268.435456 MB)
      16 bytes using glibc_memcpy =   5.440 GB/s (1000 runs: ave delta = 0.000000003 secs)
      16 bytes using naive_memcpy =   8.879 GB/s (1000 runs: ave delta = 0.000000002 secs)
      16 bytes using  apex_memcpy =   6.159 GB/s (1000 runs: ave delta = 0.000000003 secs)
     256 bytes using glibc_memcpy =  48.688 GB/s (1000 runs: ave delta = 0.000000005 secs)
     256 bytes using naive_memcpy =  23.878 GB/s (1000 runs: ave delta = 0.000000011 secs)
     256 bytes using  apex_memcpy =  29.314 GB/s (1000 runs: ave delta = 0.000000009 secs)
    dest data [len=0x100 bytes]: 0x fffefdfcfbfaf9f8 f7f6f5f4f3f2f1f0 ... 1716151413121110 f0e0d0c0b0a0908 706050403020100
Deallocating memory: fd=-1 pa_virt_addr=0x7fb54c46b010 pa_map_len=0x10000000 mem_typ_pair_indexM=1
```

The tabulated results (used by the plotting program) are put into a single file: by default *results.csv*
The first line describes the content of each of the six columns 
and the remaining lines gives the variable values and performance for each run.
Below shows an example of initial lines of a run:

```
$ head -5 results.csv 
  Experiment Description, Copy length (Bytes), Copy Type, Throughput (GBps), Number of Runs, Number of Threads
  App writes to host-heap,16,glibc_memcpy,5.785,1000,0
  App writes to host-heap,16,naive_memcpy,9.473,1000,0
  App writes to host-heap,16, apex_memcpy,5.382,1000,0
  App writes to host-heap,256,glibc_memcpy,49.089,1000,0
```

### RUN PLOTTING PROGRAM

The benchmarking plotting script, 
[plot_xy.py](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/plot_xy.py)
, uses the csv file output of the benchmarking program (see above),

The plotting script is located in the same directory as the benchmarking program:
[see above](#clone,-compile-and-run-benchmarking-program]


The script plots 3-dimensional plots with different x, y and z variables. 
It defaults to plotting:
- x-axis: Number worker threads.
- y-axis: Throughput.
- z-axis: Data copy length.

However, the script can aldo plot other combinations of variables, including:
- x-axis: Number worker threads.
- y-axis: Throughput.
- z-axis: Type of memory copy function.

and
- x-axis: Data copy length.
- y-axis: Throughput.
- z-axis: Type of memory copy Function.

To add these two alternative plots, the final three lines in 
[plot_xy.py](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/plot_xy.py)
can be uncommented.
Alternative plots with different x, y and z variables can also be added by adding other lines 
at the end of the script. 

### RESULTS



