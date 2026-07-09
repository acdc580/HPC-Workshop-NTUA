/*
 * Copyright (C) 2026, Computing Systems Laboratory (CSLab), NTUA.
 * Copyright (C) 2026, Athena Elafrou
 * All rights reserved.
 *
 * This file is distributed under the BSD License.
 */

#include "problem.h"

double gen_zero(const int n, const int index)
{
    return 0.0;
}

double gen_beta(const int n, const int index)
{
    if (index == 0) {
        return T0;
    } else if (index == (n - 1)) {
        return TL;
    } else {
      return h * Tinf * pow((double)L/(n-1), 2.0);
    }
}

double gen_diag(const int n, const int index)
{
    if (index == 0 || index == (n - 1)) {
        return 1.0;
    } else {
      return 2 + h * pow((double)L/(n-1), 2.0);
    }
}

void init(const int n, double *v, gen_fn_t fn)
{
    int i;
 
    #pragma omp parallel for private(i) schedule(static)
    for (i = 0; i < n; i++) {
        v[i] = fn(n, i);
    }
}