# HPC Workshop: Large Scale Scientific Computations

This repository contains exercises, code, and notes from the 4-day High-Performance Computing workshop, focusing on distributed memory parallelization (MPI) and GPU acceleration (CUDA).

## 🚀 Quick Start: Running the Code
We use a `Makefile` to simplify compiling and running the programs.

* **Compile all programs:** Run `make all` in your terminal.
* **Run a specific program:** Use `make run-<target_name>`. For example: `make run-reduce_cpp`.
* **Change the number of processes:** Override the default (2) by passing the `NP` flag: `make run-dot_product NP=4`.
* **Clean up:** Run `make clean` to remove compiled executables.

---

## 📅 Daily Breakdown

### Day 1: Introduction to MPI (Fortran)
Explored foundational MPI concepts. Exercises covered initializing the MPI environment, identifying unique process IDs (`rank`), determining the total number of processes (`size`), and implementing basic execution control isolated to a "root" process.

**Manual Compilation & Execution:**
If you are running this on your local environment and prefer to compile manually without the Makefile, use the MPI Fortran wrapper:
```bash
mpif90 fortran/example1.f90 -o example1
mpirun --oversubscribe -np 4 ./example1
```

### Day 2: Advanced MPI & Intro to CUDA
* **Collective Communication:** Implemented `MPI_Reduce` and `MPI_Allreduce` in both C++ and Fortran to compute parallel dot products and distributed sums. 
* **Point-to-Point Communication:** Created a ring topology (`ring.cpp`) using `MPI_Sendrecv` to pass data sequentially between neighboring processes.
* **GPU Programming:** Introduced CUDA C++ (`hello.cu`), covering basic kernel execution, thread indices, and block hierarchies.

### Day 3: Shared-Memory Parallelization with OpenMP
Shifted from distributed-memory (MPI) to shared-memory parallelism using OpenMP. Covered parallel regions, data-sharing clauses (`shared`, `private`, `firstprivate`), loop parallelization with `#pragma omp for`, and reductions.
* **Parallel Regions & Threads:** Implemented a Hello World exercise (`HelloWorld.c`) using `#pragma omp parallel`, retrieving thread counts and IDs via `omp_get_num_threads()` and `omp_get_thread_num()`.
* **Data Sharing:** Explored the difference between `shared`, `private`, and `firstprivate` variables (`variables.c`) and how each affects value visibility across threads.
* **Loop Parallelization:** Parallelized vector addition (`VecAdd.c`) and dot product (`DotProduct.c`) using `#pragma omp for`, including use of the `reduction` clause for combining per-thread partial results.
* **Assignment:** Started the Conjugate Gradient (CG) OpenMP assignment — parallelizing `axpy`, `axpyz`, `dot`, and `matvec` kernels, and benchmarking speedup across N = 1e3–1e6 for 1, 3, 6, and 12 threads.

**Manual Compilation & Execution:**
```bash
gcc -fopenmp -O3 HelloWorld.c -o helloworld
export OMP_NUM_THREADS=8
./helloworld
```

### Day 4: 1D Heat Conduction & Conjugate Gradient (MPI & CUDA)
The final day focused on bringing everything together to solve a physical problem: simulating 1D heat conduction across a rod exposed to convection cooling. This required solving the linear system $Ax = b$ using the Conjugate Gradient (CG) method across two entirely different parallel architectures. 

**Note on Current Status:** Both the MPI and CUDA implementations are currently a Work in Progress (WIP). While the underlying thermodynamics math is mapped out, the architectural edge cases are proving tricky!

* **Distributed Memory (MPI in Fortran):** * **The Goal:** Chop the tridiagonal matrix $A$ into local chunks and solve them across separate processes.
  * **The Implementation:** Required setting up non-blocking communications (`MPI_Isend`, `MPI_Irecv`, `MPI_Waitall`) so neighboring processes could exchange their boundary "halo" cells (temperatures at the edges of their local arrays) without deadlocking. 
  * **Current State:** The code compiles and the math tries its best, but it is currently hitting iteration limits and failing to properly output the physical 300K -> 280K -> 400K temperature curve. Debugging message-passing boundaries.

* **GPU Acceleration (CUDA in C++):**
  * **The Goal:** Offload the heavy linear algebra of the CG solver to the GPU's SIMT architecture.
  * **The Implementation:** Involved writing custom kernels for matrix-vector multiplication (`matvec`) and vector updates, handling deep pointer structs, explicitly managing host/device memory (`cudaMalloc`, `cudaMemcpy`), and writing a custom block-wise parallel reduction kernel to safely compute the dot product across thousands of threads.
  * **Current State:** Struggling with missing cluster utility headers and some compilation/memory-linking hurdles. 

**Hypothetical Manual Compilation & Execution (When fixed):**

*For the MPI Fortran version:*
```bash
mpif90 project-mpi.f90 -o cg_mpi
mpirun --oversubscribe -np 4 ./cg_mpi