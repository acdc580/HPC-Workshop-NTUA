/*
 * Copyright (C) 2026, Computing Systems Laboratory (CSLab), NTUA.
 * Copyright (C) 2026, Athena Elafrou
 * All rights reserved.
 *
 * This file is distributed under the BSD License.
 */
 
#include "helper.h"
#include "problem.h"
#include "kernels.h"

char *program_name = NULL;

static void print_usage()
{
  printf("Usage: %s <N>\n", program_name);
}

int main(int argc, char **argv)
{
  const double tolerance = 1e-20;
  int N;
  int j, ITER_MAX;
  matrix_t *A;
  double *b, *x, *Ax, *r, *p, *Ap;
  double alpha, beta, rr_old, rr_new, App, rnorm2, bnorm2;
  double tstart, tend;

  program_name = argv[0];
  if (argc < 2) {
    fprintf(stderr, "Error in number of arguments!\n");
    print_usage();
    exit(1);
  }

  N = atoi(argv[1]);
  if(N==100){
    ITER_MAX=100000; // so that it runs until convergence
  }
  else if(N<=10000){
    ITER_MAX = N;
  }
  else if(N<=100000){
    ITER_MAX=10000;
  }
  else{ // for greater than 1E6 elements
    ITER_MAX=1000;
  }
  printf("Running CG with %d thread(s). Problem dimension: %d\n", omp_get_max_threads(), N);
    
  // 1. Data allocation phase
  A = mat_alloc(N);
  b = vec_alloc(N);
  x = vec_alloc(N);
  Ax = vec_alloc(N);
  r = vec_alloc(N);
  p = vec_alloc(N);
  Ap = vec_alloc(N);
    
  // 2. Data initialization phase
  init(N, A->diag, gen_diag);
  init(N, b, gen_beta);
  init(N, x, gen_zero);
  x[0] = T0;
  x[N-1] = TL;
  init(N, r, gen_zero);
  init(N, p, gen_zero);
  matvec(N, A, x, Ax);            // Ax := A*x
  axpyz(N, -1, Ax, b, r);         // r := -Ax + b     
  copy(N, r, p);                  // p := r
  rr_old = dot(N, r, r);          // rr := r*r
  bnorm2 = sqrt(dot(N, b, b));

  // 3. Computation phase
  tstart = dtime();
  for (j = 0; j < ITER_MAX; j++) {
    matvec(N, A, p, Ap);        // Ap := A*p
    App = dot(N, Ap, p);        // App := Ap*p
    alpha = rr_old / App;       // a := rr/App
    axpy(N, alpha, p, x);       // x := alpha*p + x 
    axpy(N, -alpha, Ap, r);     // r := -alpha*Ap + r
    rr_new = dot(N, r, r);      // rr_new := r*r
        
    // Convergence test
    rnorm2 = sqrt(rr_new);
    //printf("Error in iteration %d: %e\n", j, rnorm2/bnorm2);
    if (rnorm2/bnorm2 <= tolerance) {
      break;    
    }
		
    beta = rr_new / rr_old;     // b := rr_new/rr_old
    axpyz(N, beta, p, r, p);    // p = beta*p + r
    rr_old = rr_new;
  }
  tend = dtime();
  
  printf("CG execution time: %f s (iterations ; %d)\n", tend-tstart, j);
  if(N==100){
    FILE *file = fopen("res_omp.dat", "w");
    if (file == NULL) {
      perror("Error opening file");
      return 1;
    }
    for(j=0; j<N; j++){
      fprintf(file, "%12d   %.12f     \n", j+1, x[j]);
    }
    fclose(file);
  }

  return 0;
}   