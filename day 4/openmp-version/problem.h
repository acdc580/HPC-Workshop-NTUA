/*
 * Copyright (C) 2026, Computing Systems Laboratory (CSLab), NTUA.
 * Copyright (C) 2026, Athena Elafrou
 * All rights reserved.
 *
 * This file is distributed under the BSD License.
 */
#ifndef PROBLEM_H
#define PROBLEM_H

#include <math.h>

#define h       0.05
#define L       10.0
#define T0      300.0
#define TL      400.0
#define Tinf    200.0

typedef double (*gen_fn_t)(const int, const int);

double gen_zero(const int n, const int index);
double gen_beta(const int n, const int index);
double gen_diag(const int n, const int index);

/**
 *  Initializes a vector by applying the provided data generation function
 *   
 *  x[i] = fn(i), for i = 0...n-1
 *   
 *  where:
 *      x is a vector with a number of elements that equals n
 **/
void init(const int n, double *v, gen_fn_t fn);

#endif  /* PROBLEM_H */
