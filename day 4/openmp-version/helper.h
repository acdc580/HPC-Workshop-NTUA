/*
 * Copyright (C) 2026, Computing Systems Laboratory (CSLab), NTUA.
 * Copyright (C) 2026, Athena Elafrou
 * All rights reserved.
 *
 * This file is distributed under the BSD License.
 */
#ifndef HELPER_H
#define HELPER_H

#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <string.h>
#include <sys/time.h>

struct matrix {
    int n;          // number of rows/columns
    double *diag;   // main diagonal
};
typedef struct matrix matrix_t;

void *malloc_internal(size_t x);
#define safe_malloc(type, size) \
  (type *) malloc_internal(size*sizeof(type))
#define vec_alloc(dim) safe_malloc(double, dim)
matrix_t *mat_alloc(int dim);

double dtime();

/**
 *  Copies a vector to another vector
 *   
 *  y := x
 *   
 *  where:
 *      x and y are vectors each with a number of elements that equals n
 **/
void copy(const int n, const double * restrict x, double * restrict y);

#endif  /* HELPER_H */
