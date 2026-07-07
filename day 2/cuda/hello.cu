#include <iostream>

__global__ void helloGPU();

int main() { 
    helloGPU<<<1, 1>>>();
    return 0;
}

__global__ void helloGPU() {
    printf("# Hello world from thread %d in block %d\n",
        threadIdx.x,blockIdx.x);
}