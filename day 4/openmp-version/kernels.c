/*
 * Copyright (C) 2026, Computing Systems Laboratory (CSLab), NTUA.
 * Copyright (C) 2026, Athena Elafrou
 * All rights reserved.
 *
 * This file is distributed under the BSD License.
 */

#include "kernels.h"

void axpy(const int n, const double a, const double * restrict x, 
          double * restrict y)
{
    /***** TODO *****/
    #pragma omp parallel for
    for (int i = 0; i < n; i++) {
        y[i] += a * x[i];
    }
}

void axpyz(const int n, const double a, const double * restrict x,
           const double * restrict y, double * restrict z)
{
    /***** TODO *****/
    #pragma omp parallel for
    for (int i = 0; i < n; i++) {
        z[i] = a * x[i] + y[i];
    }
}

double dot(const int n, const double * restrict x, const double * restrict y)
{
    /***** TODO *****/
    double sum = 0.0;
    #pragma omp parallel for reduction(+:sum)
    for (int i = 0; i < n; i++) {
        sum += x[i] * y[i];
    }
    return sum;
}

void matvec(const int n, const matrix_t *A, const double * restrict x,
            double * restrict y)
{
    #pragma omp parallel for
    for (int i = 0; i < n; i++) {
        // 1. Multiply the main diagonal (this applies to every row)
        y[i] = A->diag[i] * x[i];
        
        // 2. Subtract the neighboring nodes ONLY if it is an interior node
        if (i > 0 && i < n - 1) {
            y[i] -= x[i - 1]; // sub-diagonal
            y[i] -= x[i + 1]; // super-diagonal
        }
    }
}