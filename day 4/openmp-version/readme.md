Makefile: Provided to compile the program simply by typing "make all" in the terminal. 
	"make clean" removes all object files and the executable file.

main.c: The core of this program, calls all functions that are used in other source code files.
	For problem size 100, a result file is also produced (res_omp.dat) to compare with the res.dat that is produced by the MPI assignment.

helper.{c,h}: Some utility functions. (hint: in "helper.h", matrix is defined in a struct that stores only its diagonal elements)

problem.{c,h}: Includes initialization functions for vectors and matrices. 
	"init" function accepts a function name as  the last argument, in order to call the respective function for each vector/matrix:
		gen_zero for x,r,p  /  gen_beta for b  /  gen_diag for A

kernels.{c,h}: Contains definitions of computation functions. This is your assignment. "kernels.h" contains hints for each function.
