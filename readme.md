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

### Day 3: TBA
*Details coming soon.*

### Day 4: TBA
*Details coming soon.*