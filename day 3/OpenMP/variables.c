#include <stdio.h>
#include <omp.h>

int main () {

	int x = 1;
	/*TODO: First execute as is, then change shared to private, then private to firstprivate*/
	#pragma omp parallel firstprivate(x) num_threads(2) 
    // #pragma omp parallel private(x) num_threads(2)
    // #pragma omp parallel shared(x) num_threads(2)
	{
		x = x + 1;
		printf( "x=%d for thread %d\n", x, omp_get_thread_num());
	}
	printf( "x=%d serial\n", x );
	return 0;
}