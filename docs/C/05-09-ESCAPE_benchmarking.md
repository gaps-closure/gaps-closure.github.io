## ESCAPE Benchmarking

This section describes performance benchmarking of the Intel ESCAPE GAPS Security Engine partitioned into separate security enclaves by the CLOSURE tool. It also investigates the fundamental throughput capability of Shared Memory to communicate among applications. It uses a benchmarking tool to collect throughput for different: a) types of memory, b) copy sizes, c) copy functions, and d) number of parallel threads. These results are then collated by a plotting script to generate performance plots.

### ESCAPE GAPS Security Engine 

The Intel ESCAPE [1] GAPS Security Engine evaluation system consists of two Xeon CPU hosts (host0 and host1) connected over Intel Ultra Path Interconnect (UPI) links to a Stratix 10 FPGA. 
The two ESCAPE hosts run Ubuntu 20.04.1 OS with 130 GB of local DDR4 memory, connected over a 64-bit memory bus with a bandwidth of 2933 MegaTransfers per second (MT/s). Each laptop therefore has a local memory bandwidth of 2.933 x 8 = 23.46 GB/s. 

[1] Intel, "Extended Secure Capabilities Architecture Platform and Evaluation (ESCAPE) System Bring Up Document," February 17, 2022.

By editing the GRUB boot loader, each Xeon host maps the 16 GB of FPGA physical memory so it appears after its own local physical memory. 
Thus, each host has 130 + 16 = 146 GB of physical memory, whose physical addresses are as shown in the figure below.
To provide GAPS security between enclaves, the FPGA uses an address-filtering mechanism similar to a virtual memory page table. The filtering rules allow or disallow reads and writes from either host to a mediated DDR3 memory pool of 16 GB.  
For the benchmarking, the 16GB FPGA memory was also split into 14 GB of shared memory and 1 GB of private memory for each host. 

![ESCAPE host physical memory](docs/C/images/ESCAPE_host_physical_memory.png)

If process A on ESCAPE host0 and process B on ESCAPE host1 memory-maps the shared FPGA memory (e.g., using the mmap() call in a C program) then, as shown below, the virtual address space of each process will include the same shared FPGA memory. The process A on host0 and the process B on host1 can thus both access the same FPGA memory using memory copy instructions allowing inter-Host communication. 

![ESCAPE host virtual memory of two local processes](docs/C/images/ESCAPE_host_virtual_memory.png)

### Inter-Process Communication using Shared Memory 

To measure raw shared memory performance without the ESCAPE board, we also benchmarked shared memory performance between two processes on the same host. If a process A and process B both on host0 memory-map part of host0's physical memory, then, as shown below, the virtual address space of each process will include the same portion of shared FPGA memory. 

![Inter-process Virtual Memory](docs/C/images/ESCAPE_inter-process_virtual_memory.png)

### Benchmarking Tool

The benchmarking tool is a C program with two main files:  

- The top-level program 
[memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c)
that runs through the [testing parameter combinations](#benchmarking-tool-variables).
- The worker thread pool 
[thread_pool.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/thread_pool.c)
that creates and manages all the worker threads.

#### Benchmarking Tool Parameters

The parameter options available to the benchmarking tool can be discovered using the
help option as shown below:
```
amcauley@jaga:~/gaps/build/hal/escape/perftests$ ./memcpy_test -h
Shared Memory performance test tool for GAPS CLOSURE project
Usage: [sudo] ./memcpy_test [OPTIONS]... [Experiment ID List]
'sudo' required if using shared memory: /dev/mem (Experiment ID 2, 3, 4, 5)
OPTIONS:
   -i : which source data is initialized
   0 = all sources (default) - both when application or shared memory is the source of data
   1 = only if source is application - use current shared memory content as source (so can read on different node/process than writer)
   -n : number of length tests (default=9, maximum = 10)
   -o : source data initialization offset value (before writing)
   -r : number of test runs per a) memory pair type, b) payload length and c) copy function (default=5)
   -t : number of worker threads in thread pool (default=0)
   -z : read/write with given number of second sleep between each (default z=0)
Experiment ID List (default = all):
   0 = tool writes to host heap
   1 = tool reads from host heap
   2 = tool writes to host mmap
   3 = tool reads from host mmap
   4 = tool writes to shared escape mmap
   5 = tool reads from shared escape mmap
EXAMPLES:
   sudo ./memcpy_test
   ./memcpy_test 0 1 -r 1000 -n 2
```

#### Benchmarking Tool Variables

The [Benchmarking tool](https://github.com/gaps-closure/hal/tree/multi-threaded/escape/perftests)
runs a series of throughput performance measurements for combinations of four variables:
1) memory type, 2) payload length, 3) copy function, and 4) number of worker threads.

##### **Variable 1)** Memory Types

The Benchmarking tool copies data between its local heap memory created using malloc() and one of three types of memory:

- **Host heap**: Allocates memory from the host using malloc(). This test allows measuring raw memory bandwidth, but  only allows a single process to write or read the memory. 
- **Host mmap**: Allocates memory by opening /dev/mem followed by an mmap() of host memory. The resultant mapped memory can be used to communicate data between two independent processes on the same host.
- **ESCAPE mmap**: Allocates memory by opening /dev/mem followed by an mmap() of FPGA memory. For the ESCAPE system this starts at address 130 GB = 0x2080000000 (as described above), though this address can be changed by modifying the MMAP_ADDR_ESCAPE definition in [memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c).

By default, in one run, the benchmark tool reads and writes to each of the three types of memory, creating a total of 2 x 3 = 6 different experiments. Each experiment has an ID from 0 to 5, allowing the user to specify a [list of experiment types](#benchmarking-tool-parameters) to run.

##### **Variable 2)** Payload Lengths

For each of the six memory write/read types in a run, the benchmark tool measures the throughput with a series of increasing payload lengths (number of bytes of data that are written or read). 
It's default is to test with 10 different payload lengths from 16 bytes up to 16 MB 
(except for *host mmap* memory, which linux limits to 512 KB).
However, the number of lengths test can be reduced using the '-n' [parameter option](#benchmarking-tool-parameters) when calling the tool. 
(e.g., *./memcpy_test -n 3* will run just the first 3 payload lengths). 
The payload length values themselves can be modified by changing the definitions of the 
global array *copy_size_list* in [memcpy_test.c](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/memcpy_test.c). 

##### **Variable 3)** Copy Functions

For each payload length in a run, the benchmarking tool tests with three different copy functions.
The tool uses the copy function to read or write data between the tool and memory:

- **glibc memory copy**: memcpy().
- **naive memory copy**: using incrementing unsigned long C pointers that point to the destination and source (*d++ = *s++).
- **Apex memory copy**: A [fast memory copy](https://www.codeproject.com/Articles/1110153/Apex-memmove-the-fastest-memcpy-memmove-on-x-x-EVE)
, with available source code.

The benchmark tool runs the test multiple times for each copy function tested. 
The default number of tests is 5, but the value can be changed by specifying the
'-r' [parameter option](#benchmarking-tool-parameters) when calling the benchmark tool
(larger values provide more reliable throughput measurements, but small values can run much
faster for initial testing.

##### **Variable 4)** Number of Worker Threads

The each run the user can specify the number of parallel worker threads that copy the data
using the '-t' [parameter option](#benchmarking-tool-parameters) when calling the tool.
For example, *./memcpy_test -t 16* will run just with 16 parallel worker threads.  


#### Clone, Compile and Run Benchmarking Tool

The benchmarking tool is part of the [HAL branch](https://github.com/gaps-closure/hal/tree/multi-threaded)
along with the [benchmark plotting script](#benchmark-plotting-script), 
with the latest version (including the multi-threaded option) found in the git multi-threaded branch:

```
git clone git@github.com:gaps-closure/hal.git
cd hal/escape/perftests
git checkout multi-threaded
```

To compile the benchmarking tool we run make:

```
make
```

Below are a few examples of running with the benchmarking tool:

```
Run with default parameters:
  sudo ./memcpy_test  

Run at a high priority:
  sudo nice --20 ./memcpy_test  

Run only the first two memory types (write and read to heap memory)
  sudo ./memcpy_test 0 1

Run test with greater sampling (average over 1000 runs instead of 5)
  sudo ./memcpy_test -r 1000

Run just for few smaller lengths
  sudo ./memcpy_test -n 3
```

The results for each input variable are printed on the terminal. For example:

```
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

The tabulated results (used by the plotting script) are put into a single csv file: by default *results.csv*
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

### Benchmark Plotting Script

The benchmark plotting script is located in the same directory as the benchmarking tool:
[see above](#clone,-compile-and-run-benchmarking-tool]
The script, 
[plot_xy.py](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/plot_xy.py)
, uses the csv file outputs of the benchmarking tool (see above). 

The script plots 3-dimensional plots with different x, y and z variables. 
The three plots in the results section below can be generated by uncommenting
the final three lines of the 
[plot_xy.py](https://github.com/gaps-closure/hal/blob/multi-threaded/escape/perftests/plot_xy.py)
script (by default the script only creates the first plot). 
More plots with different x, y and z variables can be generated by adding lines at the end of the script. 


### RESULTS

We used the  benchmarking script to test the performance of mmap() for reading/writing from ESCAPE FPGA:

- Using different memcpy: a) functions (glibc, naïve, apex), b) length of data, and c) number of worker threads
- Using different memory locations: a) ESCAPE FPGA mmap’ed, b) Host mmap’ed, and c) Host heap

This section summarizes these results on the ESCAPE testbed with the three x,y,z plots:

A) The first (default) plot has:

- x-axis: Number worker threads.
- y-axis: Throughput.
- z-axis: Data copy length.

It shows that writing to host-heap can achieve the server memory B/W limit 
even without threads, but ESCAPE is two order of magnitude slower even with 64 threads

![ESCAPE Throughput versus Threads for Different Data Lengths](docs/C/images/ESCAPE_plot_A_BW_v_threads_and_copy_leng.png)

B) An alternative plot has:
 
- x-axis: Number worker threads.
- y-axis: Throughput.
- z-axis: Type of memory copy function.

It shows that adding worker threads significantly helps mmapp'ed copy performance,
but does not help significantly above 8 threads.

![ESCAPE Throughput versus Threads for Different Copy Functions](docs/C/images/ESCAPE_plot_B_BW_v_threads_and_copy_func.png)

C) An final alternative plot has:
- x-axis: Data copy length.
- y-axis: Throughput.
- z-axis: Type of memory copy Function.

![ESCAPE Throughput versus Threads for Different Copy Functions](docs/C/images/ESCAPE_plot_C_BW_v_copy_len_and_copy_func.png)

It shows that copy function type can significantly impact performance. 
The winner between glibc and naïve/apex memcpy varies significantly based on the copy length

### CONCLUSION

We are able to achieve 150 MB/s to communicate 64 KB frames between two hosts using the ESCAPE shared memory.
Although fast, this was less than initially expected based on simply using memory copies.
Conventional wisdom holds mmap() should outperform traditional file I/O:

- Access pages via pointers using fast load/store (rather than read/write) as if file resided entirely in memory. 
- No user buffer pool: kernel transparently moves data between device and memory for page fault evicts old pages.
- mmap() removes the system call per I/O and pointers void extra copy between kernel and user space a buffer.
- Removes need to serialize/deserialize data using the same in-memory and persistent formats.

We were able to achieve the memory bandwidth limit only when not memory mapping the files (see graphs above).
The reason for the difference is explained by recent papers looking at memory-mapped I/O:

- Default memory-mapped I/O path does not scale well with the number of cores:
  - Transparent paging means OS can flush page to secondary storage at any time -causing blocking
  - Propose Fastpath to ameliorate problems with Linux’s mmap() 
  - [PAP20] A. Papagiannis, G. Xanthakis, G. Saloustros, M. Marazakis, A. Bilas, “Optimizing Memory-mapped I/O for Fast Storage Devices,” Proceedings of the USENIX Annual Technical Conference, July 2020.
  
- Even with additional complexity mmap() will not scale:
  - Slow and unpredictable page fault eviction, TLB shoot-downs and other hidden issues
  - Experiments shows that adding more threads ineffective beyond about 8 threads, which our results confirmed.
  - [CRO22] A. Crotty, V. Leis, A. Pavlo, “Are You Sure You Want to Use MMAP in Your Database Management System?” 12th Annual Conference on Innovative Data Systems Research (CIDR ’22) , Chaminade, USA, Jan 2022.
  
CRO22 argues that TLB shootdowns have the biggest impact. 
When evicting pages, OS removes mappings from both page table and each CPU’s TLB 
Flushing local TLB of the initiating core is straightforward, but the OS must ensure that no stale entries remain in the TLBs of remote cores. 
Unfortunately, current CPUs do not provide coherence for remote TLBs, the OS has to issue an expensive inter-processor interrupt to flush them, called a TLB shootdown.

- [BLA89] D. Black, R. Rashid, D. Golub, C. Hill, R. Baron, “Translation Lookaside Buffer Consistency: A Software Approach” In ASPLOS, pages 113–122, 1989.

