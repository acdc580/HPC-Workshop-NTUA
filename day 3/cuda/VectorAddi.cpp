#include <iostream>
#include <cmath>

int main() { 
    constexpr long size = 10;

    double *a = new double[size];
    double *b = new double[size];
    double *c = new double[size];

    for(auto i = 0; i < size; i++) { 
        a[i] = (double)i;
    }
    for(auto i = 0; i < size; i++) { 
        b[i] = (double)i;
    }
    for(auto i = 0; i < size; i++) { 
        c[i] = NAN;
    }
    for(auto i = 0; i < size; i++) { 
        c[i] = a[i] + b[i];
    }
    
    for(auto i = 0; i < size; i++) { 
        std::cout << a[i] << " + " << b[i] << " = " << c[i]
                    << std::endl;
    }

    if(a != nullptr) delete[] a; a = nullptr;
    if(b != nullptr) delete[] b; b = nullptr;
    if(c != nullptr) delete[] c; c = nullptr;

    return 0; 
}