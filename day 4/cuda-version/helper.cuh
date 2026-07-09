#ifndef HELPER_CUH
#define HELPER_CUH

#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

// Calculates the grid size (number of blocks) needed for the GPU
inline int getBlocks(int threads, int systemSize) {
    return (systemSize + threads - 1) / threads;
}

// Checks for CUDA errors after a kernel launch
inline void check(const char* msg) {
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("CUDA Error [%s]: %s\n", msg, cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }
}

// Halts the program on critical memory errors
inline void Stop(const char* msg) {
    printf("Fatal Error: %s\n", msg);
    exit(EXIT_FAILURE);
}

// Allocates device memory and copies host struct data over
inline void* GPUalloc(void* hostPtr, size_t size, const char* name) {
    void* devicePtr = NULL;
    cudaError_t err = cudaMalloc(&devicePtr, size);
    if (err != cudaSuccess) {
        printf("Failed to allocate device memory for %s\n", name);
        exit(EXIT_FAILURE);
    }
    err = cudaMemcpy(devicePtr, hostPtr, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        printf("Failed to copy data to device for %s\n", name);
        exit(EXIT_FAILURE);
    }
    return devicePtr;
}

#endif