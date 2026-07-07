# MPI Fortran Examples - HPC Workshop

This repository contains introductory MPI (Message Passing Interface) programs written in Fortran. These examples demonstrate basic distributed memory parallelization concepts, including environment initialization, rank identification, and collective communication.

## Prerequisites
Ensure you have the GNU Fortran compiler and OpenMPI installed on your Ubuntu environment. If you haven't installed them yet, you can do so via:
```bash
sudo apt update
sudo apt install gfortran openmpi-bin libopenmpi-dev
```

## The Programs

### 1. Basic Hello World (`example1.f90` & `example.f90`)
A foundational MPI program that initializes the MPI environment. Each spawned process determines its unique ID (`rank`) and the total number of processes in the communicator (`size`), then prints a greeting. 

### 2. Root Process Logic (`example2.f90`)
Builds upon the first example by introducing execution control based on the process rank. While all processes print their individual greetings, only the "root" process (Rank 0) is tasked with printing the total number of active processes. This demonstrates how specific tasks can be isolated to a single coordinating process.

### 3. Parallel Dot Product (`dot_product.f90`)
*(Upcoming workshop exercise)*
A more advanced example demonstrating data partitioning and collective communication. The program:
* Divides a large vector among the available processes.
* Computes the local sum of squares (dot product) on each process using local memory arrays.
* Uses the `MPI_REDUCE` operation to combine all local sums into a single global total, storing the final result on the root process.

## How to Compile
Use the MPI Fortran wrapper (`mpif90`) to compile the source code. This wrapper automatically links the necessary MPI libraries so you don't have to specify them manually.

```bash
mpif90 example.f90 -o example
mpif90 example1.f90 -o example1
mpif90 example2.f90 -o example2
```

## How to Run
Execute the compiled programs using `mpirun`. Since local environments might have fewer physical CPU cores than the requested processes, the `--oversubscribe` flag is used to force OpenMPI to run multiple processes on the same core without throwing a slot availability error.

```bash
mpirun --oversubscribe -np 4 ./example2
```
*(Replace `4` with the desired number of processes, and `./example2` with the specific executable you wish to run).*