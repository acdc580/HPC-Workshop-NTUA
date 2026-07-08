#include <cuda_runtime.h>
#include <iostream>
#include <string>
#include <cmath>

// A clean, single allocator for Unified Memory
void *alloc_managed_mem(const long bytes, const std::string& varname) {
    void* devptr = nullptr;
    cudaError_t err = cudaMallocManaged(&devptr, bytes);
    
    if (err != cudaSuccess) {
        std::cerr << "Invalid allocation of \"" << varname << "\": " << cudaGetErrorString(err) << std::endl;
        exit(1);
    }
    return devptr;
}

// Your GPU Kernel
__global__ void vectorAddGPU(const long size, double *A, double *B, double *C) {
    const long i = blockIdx.x * blockDim.x + threadIdx.x;

    if(i < size) {
        C[i] = A[i] + B[i];
    }
}

int main() { 
    constexpr long size = 10;
    const long bytes = size * sizeof(double);
    
    // 1. ALLOCATE UNIFIED MEMORY (No more 'new' keyword!)
    // These pointers can be read by BOTH the CPU and the GPU.
    double *A = (double*)alloc_managed_mem(bytes, "A");
    double *B = (double*)alloc_managed_mem(bytes, "B");
    double *C = (double*)alloc_managed_mem(bytes, "C");

    // 2. INITIALIZE ON CPU
    // The CPU safely writes to the managed pointers
    for (auto i = 0; i < size; i++) A[i] = (double)i;
    for (auto i = 0; i < size; i++) B[i] = (double)i;
    for (auto i = 0; i < size; i++) C[i] = NAN;

    // 3. LAUNCH ON GPU
    const int blockSize = 1024;
    const int gridSize = (size + blockSize - 1) / blockSize;
    
    // We pass the exact same A, B, C pointers directly to the kernel!
    vectorAddGPU <<< gridSize, blockSize >>> (size, A, B, C);

    // 4. SYNCHRONIZE & CHECK ERRORS
    // You MUST synchronize so the CPU waits for the GPU to finish 
    // before trying to read the results in the next step.
    cudaDeviceSynchronize();
    cudaError_t err = cudaGetLastError(); 
    if(err != cudaSuccess) {
        std::cerr << "Kernel launch failed: " << cudaGetErrorString(err) << std::endl;
        exit(1);
    }

    // Optional: Let the CPU read a value to prove it worked!
    std::cout << "Success! C[5] = " << C[5] << std::endl;

    // 5. CLEAN UP
    // Because we used Unified Memory, we only need cudaFree. 
    // No more delete[]!
    if(A != nullptr) { cudaFree(A); A = nullptr; }
    if(B != nullptr) { cudaFree(B); B = nullptr; }
    if(C != nullptr) { cudaFree(C); C = nullptr; }

    return 0;
}