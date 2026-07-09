# OpenMP Conjugate Gradient Solver
## 1D Heat Conduction Simulation

This repository contains a parallelized Conjugate Gradient (CG) solver written in C. It utilizes OpenMP to efficiently compute the temperature distribution across a 1D cylindrical rod subjected to conduction and convection by solving the linear system $Ax = b$.

### Project Structure

* **`main.c`**: The core driver of the application. It orchestrates the CG algorithm, tracks the iteration loop, checks for convergence tolerance, and outputs the final temperature distribution.
* **`kernels.c` & `kernels.h`**: The computational heart of the solver. Contains the OpenMP-parallelized linear algebra operations required by the CG algorithm, including vector updates (`axpy`, `axpyz`), dot products (`dot`), and matrix-vector multiplication (`matvec`).
* **`problem.c` & `problem.h`**: Manages the mathematical initialization of the physical problem. The `init` function applies specific generation routines (`gen_zero`, `gen_beta`, `gen_diag`) to correctly set up the Dirichlet boundary conditions and initial vectors.
* **`helper.c` & `helper.h`**: Utility functions for memory management and execution timing. Crucially, the custom `matrix_t` struct is defined here, which optimizes memory usage by only storing the main diagonal elements of the sparse matrix $A$.
* **`Makefile`**: Automates the compilation and cleanup process.

### Compilation & Execution

**1. Build the project**
Compile the source code and link the OpenMP libraries using the provided Makefile.
```bash
make all
```
*To wipe the directory of compiled object files and the executable, run `make clean`.*

**2. Set OpenMP Threads**
Specify the number of threads you want to allocate to the parallel regions by exporting the environment variable.
```bash
export OMP_NUM_THREADS=12
```

**3. Run the Solver**
Execute the program by passing the target problem size (number of nodes, $N$) as a single command-line argument.
```bash
./cg 100
```

### Output and Validation
For a specific problem size of $N=100$, the program will automatically generate a `res_omp.dat` file containing the calculated temperature at each individual node. This file is formatted so it can be directly compared against the baseline `res.dat` output (e.g., from an MPI implementation) to verify the mathematical accuracy of the OpenMP parallelization and boundary condition handling.