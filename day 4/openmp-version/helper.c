/*
 * Copyright (C) 2026, Computing Systems Laboratory (CSLab), NTUA.
 * Copyright (C) 2026, Athena Elafrou
 * All rights reserved.
 *
 * This file is distributed under the BSD License.
 */
#include "helper.h"

void *malloc_internal(size_t x)
{
    void *ret;
    ret = malloc(x);
    if (!ret) {
        printf("malloc failed\n");
        exit(1);
    }

    return ret;
}

matrix_t *mat_alloc(int dim)
{
    matrix_t *A = NULL;
    A = safe_malloc(matrix_t, 1);
    A->diag = safe_malloc(double, dim);
    A->n = dim;
    return A;
}

void copy(const int n, const double * restrict x, double * restrict y)
{
    memcpy(y, x, n*sizeof(double));
}

double dtime()
{
  double tseconds = 0.0;
  struct timeval tt;
  gettimeofday(&tt, NULL);
  tseconds = (double) (tt.tv_sec + tt.tv_usec*1.0e-6);
  return tseconds;
}