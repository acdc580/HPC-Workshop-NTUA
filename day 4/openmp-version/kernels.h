/*
 * Copyright (C) 2026, Computing Systems Laboratory (CSLab), NTUA.
 * Copyright (C) 2026, Athena Elafrou
 * All rights reserved.
 *
 * This file is distributed under the BSD License.
 */
#ifndef KERNELS_H
#define KERNELS_H

#include <omp.h>
#include "helper.h"

/**
 *  Computes a vector-scalar product and adds the result to a vector as
 *   
 *  y := a*x + y
 *  
 *  where:
 *      a is a scalar
 *      x and y are vectors each with a number of elements that equals n
 **/
void axpy(const int n, const double a, const double * restrict x, 
          double * restrict y);

/**
 *  Computes a vector-scalar product and adds the result to a vector as
 *  
 *  z := a*x + y
 *  
 *  where:
 *      a is a scalar
 *      x,y and z are vectors each with a number of elements that equals n
 **/
void axpyz(const int n, const double a, const double * restrict x,
           const double * restrict y, double * restrict z);

/**
 *  Computes a vector-vector dot product defined as
 *  
 *  res := x dot y
 *
 *  where:
 *      x and y are vectors each with a number of elements that equals n
 **/
double dot(const int n, const double * restrict x, const double * restrict y);

/**
 *  Computes a matrix-vector product defined as
 *
 *  y := A*x 
 *  
 *  where:
 *      x and y are vectors each with a number of elements that equals n
 *      A is a n-by-n matrix
 * 
 * hint : matrix A has special properties (as shown in hpc_project.pdf)
 *        See how it is stored in 'helpers.h'
 **/
void matvec(const int n, const matrix_t *A, const double * restrict x,
            double * restrict y);

#endif  /* KERNELS_H */
