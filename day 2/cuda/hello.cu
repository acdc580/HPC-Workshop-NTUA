#include <iostream>
#include <stdio.h>

__global__ void helloGPU() {
    printf("# Hello world from thread %d in block %d\n",
        threadIdx.x,blockIdx.x);
}

int main() { 
    helloGPU<<<1, 1>>>();
    cudaDeviceSynchronize();

    return 0;
}
