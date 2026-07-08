#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <omp.h>

// 1. The Kernel (runs on the GPU)
__global__ void myKernel(float *d_array, int N) {
    // Calculate global thread ID
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Always check boundaries!
    if (i < N) {
        d_array[i] = d_array[i] * 2.0f; // Example computation
    }
}

int main() {
    int N = 1024;
    size_t size = N * sizeof(float);
    
    // Host pointers
    float *h_array = (float*)malloc(size);
    // ... initialize h_array here ...

    // Device pointers
    float *d_array;

    // 2. Allocate Device Memory
    cudaMalloc((void**)&d_array, size);

    // 3. Copy from Host to Device
    cudaMemcpy(d_array, h_array, size, cudaMemcpyHostToDevice);

    // 4. Launch the Kernel
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    myKernel<<<blocksPerGrid, threadsPerBlock>>>(d_array, N);

    // 5. Copy from Device back to Host
    cudaMemcpy(h_array, d_array, size, cudaMemcpyDeviceToHost);

    // 6. Free Device Memory
    cudaFree(d_array);
    free(h_array);

    return 0;
}