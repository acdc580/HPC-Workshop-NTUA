#include <cuda.h>
#include <string>
#include <iostream>
#include <iomanip>
#include <fstream>

#include "main.cuh"
#include "conjugateGradient.cuh"
#include "helper.cuh"
// ... INCLUDE REST HEADERS ... 

#define systemSize 1000 // The order of linear system
#define nthreads_reduction 128

//
// **************************************************************************************
int main()
// **************************************************************************************
{
      // host/device allocations :
      ConjugateGradientDataPtrs ptr;

      ptr.hostPtr    = NULL; allocHostMemorySpace  (ptr.hostPtr   );
      ptr.deviceData = NULL; allocDeviceMemorySpace(ptr.deviceData);
      ptr.devicePtr  = NULL; createDevicePtr(ptr.devicePtr, ptr.deviceData);

      // Generate a linear system (Ax=b) with known solution :
      formEqSystem(ptr);

      // Solve with Conjugate Gradient :
      const int    maximum_iterations = 10000;
      const double stopping_criterior =-16;
      conjugatGradientSolver(ptr, maximum_iterations,stopping_criterior);

      // host/device deallocations :
      freeHostMemory  (ptr.hostPtr   );
      freeDeviceMemory(ptr.deviceData);
      destroyDevicePtr(ptr.devicePtr );
}

//
// --------------------------------------------------------------------------------------
//                             H O S T  -  F U N C T I O N S
// --------------------------------------------------------------------------------------
//

void allocHostMemorySpace(ConjugateGradientData*& hostPtr)
{
      const int nbThreads = nthreads_reduction;
      const int nbBlocks  = getBlocks(nbThreads,systemSize);

      hostPtr = new ConjugateGradientData();

      hostPtr->mult1 = (double*)malloc(sizeof(double)); *hostPtr->mult1 = 0.;
      hostPtr->mult2 = (double*)malloc(sizeof(double)); *hostPtr->mult2 = 0.;

      hostPtr->alpha = (double*)malloc(sizeof(double)); *hostPtr->alpha = 0.;
      hostPtr->beta  = (double*)malloc(sizeof(double)); *hostPtr->beta  = 0.;

      hostPtr->projection = NULL;
      hostPtr->direction  = NULL;
      hostPtr->residual   = NULL;

      hostPtr->rhs        = NULL;
      hostPtr->diag       = NULL;
      hostPtr->offDiag    = NULL;

      hostPtr->solution   = (double*)malloc(systemSize*sizeof(double));
      hostPtr->aux        = (double*)malloc(nbBlocks  *sizeof(double));

      for (int i=0; i<systemSize; i++)
      {
            hostPtr->solution[i] = 0.;
      }
}

void allocDeviceMemorySpace(ConjugateGradientData*& deviceData)
{
      deviceData = new ConjugateGradientData();

      // Scalars
      cudaMalloc((void**)&deviceData->mult1, sizeof(double));
      cudaMalloc((void**)&deviceData->mult2, sizeof(double));
      cudaMalloc((void**)&deviceData->alpha, sizeof(double));
      cudaMalloc((void**)&deviceData->beta,  sizeof(double));

      // Vectors
      cudaMalloc((void**)&deviceData->solution,   systemSize * sizeof(double));
      cudaMalloc((void**)&deviceData->projection, systemSize * sizeof(double));
      cudaMalloc((void**)&deviceData->direction,  systemSize * sizeof(double));
      cudaMalloc((void**)&deviceData->residual,   systemSize * sizeof(double));
      
      cudaMalloc((void**)&deviceData->rhs,        systemSize * sizeof(double));
      cudaMalloc((void**)&deviceData->diag,       systemSize * sizeof(double));
      cudaMalloc((void**)&deviceData->offDiag,    systemSize * sizeof(double));

      // Auxiliary array for parallel reduction (dot product)
      const int nbBlocks = getBlocks(nthreads_reduction, systemSize);
      cudaMalloc((void**)&deviceData->aux, nbBlocks * sizeof(double));
}

void createDevicePtr(ConjugateGradientData*& devicePtr, ConjugateGradientData*& deviceData)
{
      devicePtr = (ConjugateGradientData*)GPUalloc(deviceData,sizeof(ConjugateGradientData),"devicePtr");
}

void freeHostMemory(ConjugateGradientData*& hostPtr)
{
      if (!hostPtr) return;
      free(hostPtr->mult1);
      free(hostPtr->mult2);
      free(hostPtr->alpha);
      free(hostPtr->beta);
      free(hostPtr->solution);
      free(hostPtr->aux);
      delete hostPtr; 
      hostPtr = NULL;
}

void freeDeviceMemory(ConjugateGradientData*& deviceData)
{
      if (!deviceData) return;
      cudaFree(deviceData->mult1);
      cudaFree(deviceData->mult2);
      cudaFree(deviceData->alpha);
      cudaFree(deviceData->beta);
      cudaFree(deviceData->solution);
      cudaFree(deviceData->projection);
      cudaFree(deviceData->direction);
      cudaFree(deviceData->residual);
      cudaFree(deviceData->rhs);
      cudaFree(deviceData->diag);
      cudaFree(deviceData->offDiag);
      cudaFree(deviceData->aux);
      delete deviceData; 
      deviceData = NULL;
}

void destroyDevicePtr(ConjugateGradientData*& devicePtr)
{
      if (devicePtr) cudaFree(devicePtr); devicePtr = NULL;
}

void formEqSystem(ConjugateGradientDataPtrs& ptr)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);

      getSPD_GPU<<<nblck,nthr>>>(ptr.devicePtr);
      check("getSPD_GPU failed");
}

void conjugatGradientSolver(ConjugateGradientDataPtrs& ptr, const int maximum_iterations, const double stopping_criterior)
{
      std::ofstream file("cg.conv", std::ios::out | std::ios::trunc);

      initSolution          (ptr);
      computeResidual       (ptr);
      initConjugateDirection(ptr);

      for (int iter=0; iter<maximum_iterations; iter++)
      {
            matVec    (ptr, _Direction_, _Projection_);
            dotProduct(ptr, _Direction_, _Projection_, _Mult2_);
            dotProduct(ptr, _Residual_ , _Residual_  , _Mult1_);
            computeAlpha(ptr);

            const double residual = log10( sqrt(*ptr.hostPtr->mult1) + 1.E-21 );

            if (residual < stopping_criterior || iter%10 == 0 || iter == maximum_iterations-1)
            {
                  std::cout << std::setw( 8) << iter     << " "
                            << std::setw(15) << residual << std::endl;
            }

            file << std::setw( 8) << iter     << " "
                 << std::setw(15) << residual << "\n";

            if (residual < stopping_criterior)
            {
                  std::cout << "# Conjugate Gradient converged !!! \n"; break;
            }

            updateSolution(ptr);
            updateResidual(ptr);

            dotProduct (ptr, _Residual_, _Residual_, _Mult2_);
            computeBeta(ptr);

            updateConjugateDirection(ptr);
      }
      file.close();
      writeSolution(ptr);
}

void initSolution(ConjugateGradientDataPtrs& ptr)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);
      
      initSolutionGPU<<<nblck,nthr>>>(ptr.devicePtr);
      check("initSolutionGPU failed");
}

void computeResidual(ConjugateGradientDataPtrs& ptr)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);

      computeResidualGPU<<<nblck,nthr>>>(ptr.devicePtr);
      check("computeResidualGPU failed");
}

void initConjugateDirection(ConjugateGradientDataPtrs& ptr)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);

      initConjugateDirectionGPU<<<nblck,nthr>>>(ptr.devicePtr);
      check("initConjugateDirectionGPU failed");
}

void dotProduct(ConjugateGradientDataPtrs& ptr, ConjugateGradientEnum A, ConjugateGradientEnum B, ConjugateGradientEnum C)
{
      double* dA = ptr.deviceData->get(A);
      double* dB = ptr.deviceData->get(B);
      double* dC = ptr.deviceData->get(C);

      const int nthr  = nthreads_reduction;
      const int nblck = getBlocks(nthr, systemSize);

      // Launch reduction kernel
      dotProductGPU<<<nblck, nthr>>>(dA, dB, ptr.deviceData->aux, systemSize);
      check("dotProductGPU failed");

      // Copy partial block sums back to CPU
      cudaMemcpy(ptr.hostPtr->aux, ptr.deviceData->aux, nblck * sizeof(double), cudaMemcpyDeviceToHost);

      // CPU finishes the sum
      double final_sum = 0.0;
      for (int i = 0; i < nblck; i++) {
            final_sum += ptr.hostPtr->aux[i];
      }

      // Store result in CPU and copy back to GPU
      *ptr.hostPtr->get(C) = final_sum;
      cudaMemcpy(dC, &final_sum, sizeof(double), cudaMemcpyHostToDevice);
}

void matVec(ConjugateGradientDataPtrs& ptr, ConjugateGradientEnum A, ConjugateGradientEnum B)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);

      matVecGPU<<<nblck,nthr>>>
      (
            ptr.deviceData->get(_Diag_   ),
            ptr.deviceData->get(_OffDiag_),
            ptr.deviceData->get(A),
            ptr.deviceData->get(B)
      );
      check("matVecGPU failed");
}

void computeAlpha(ConjugateGradientDataPtrs& ptr)
{
      *ptr.hostPtr->alpha = *ptr.hostPtr->mult1 / *ptr.hostPtr->mult2;
}

void computeBeta(ConjugateGradientDataPtrs& ptr)
{
      *ptr.hostPtr->beta = *ptr.hostPtr->mult2 / *ptr.hostPtr->mult1;
}

void updateSolution(ConjugateGradientDataPtrs& ptr)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);

      updateSolutionGPU<<<nblck,nthr>>>(ptr.devicePtr, *ptr.hostPtr->alpha);
      check("updateSolutionGPU failed");
}

void updateResidual(ConjugateGradientDataPtrs& ptr)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);

      updateResidualGPU<<<nblck,nthr>>>(ptr.devicePtr, *ptr.hostPtr->alpha);
      check("updateResidualGPU failed");
}

void updateConjugateDirection(ConjugateGradientDataPtrs& ptr)
{
      const int nthr  = 128;
      const int nblck = getBlocks(nthr,systemSize);

      updateConjugateDirectionGPU<<<nblck,nthr>>>(ptr.devicePtr, *ptr.hostPtr->beta);
      check("updateConjugateDirectionGPU failed");
}

void writeSolution(ConjugateGradientDataPtrs& ptr)
{
      std::ofstream file;
      file.open("cg.res",std::ios::out | std::ios::trunc);

      cudaError_t err = cudaMemcpy
                        (
                              ptr.hostPtr   ->solution, 
                              ptr.deviceData->solution, systemSize*sizeof(double), cudaMemcpyDeviceToHost
                        );
      if (err != cudaSuccess) Stop("memory copy failed");

      for (int i=0; i<systemSize; i++)
      {
            file << std::setw(15) << ptr.hostPtr->solution[i] << "\n";
      }
      file.close();
}


//
// --------------------------------------------------------------------------------------
//                                    K E R N E L S
// --------------------------------------------------------------------------------------
//

__global__ void dotProductGPU(double* A, double* B, double* aux, int n)
{
      __shared__ double cache[nthreads_reduction];
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      int tid = threadIdx.x;

      double temp = 0.0;
      if (i < n) temp = A[i] * B[i];
      
      cache[tid] = temp;
      __syncthreads();

      // Parallel reduction within the block
      for (int s = blockDim.x / 2; s > 0; s >>= 1) {
            if (tid < s) {
                  cache[tid] += cache[tid + s];
            }
            __syncthreads();
      }

      // Thread 0 writes the block's sum to global memory
      if (tid == 0) aux[blockIdx.x] = cache[0];
}

__global__ void getSPD_GPU(ConjugateGradientData* data)
{
      const int index = blockIdx.x*blockDim.x + threadIdx.x;
      if (index >= systemSize) return;

      const double h    = 0.05;
      const double T0   = 300.0;
      const double Tinf = 200.0;
      const double Tend = 400.0;
      const double len  =  10.0;

      const double dx   = len / double(systemSize-1);
      const double fac  = h*dx*dx;

      // initialize solution :
      double sol = 0.;
      if (index == 0           ) sol = T0;   // Dirichlet condition
      if (index == systemSize-1) sol = Tend; // Dirichlet condition

      data->solution[index] = sol;

      // LHS / RHS :
      double rhs     = Tinf* fac;
      double diag    = 2.  + fac;
      double offDiag =-1.;

      if (index == 0           ) { rhs = T0;   diag = 1.; }
      if (index == systemSize-1) { rhs = Tend; diag = 1.; }

      data->rhs [index] = rhs;
      data->diag[index] = diag;

      if (index < systemSize-1) data->offDiag[index] = offDiag;
}

__global__ void initSolutionGPU(ConjugateGradientData* data)
{
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      if (i > 0 && i < systemSize - 1) {
            data->solution[i] = 0.0;
      }
}

__global__ void initConjugateDirectionGPU(ConjugateGradientData* data)
{
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      if (i < systemSize) {
            data->direction[i] = data->residual[i];
      }
}

__global__ void computeResidualGPU(ConjugateGradientData* data)
{
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      if (i < systemSize) {
            double ax = data->diag[i] * data->solution[i];
            if (i > 0 && i < systemSize - 1) {
                  ax += data->offDiag[i-1] * data->solution[i-1];
                  ax += data->offDiag[i]   * data->solution[i+1];
            }
            data->residual[i] = data->rhs[i] - ax;
      }
}

__global__ void matVecGPU(double* diag, double* offDiag, double* x, double* y)
{
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      if (i < systemSize) {
            double val = diag[i] * x[i];
            if (i > 0 && i < systemSize - 1) {
                  val += offDiag[i-1] * x[i-1];
                  val += offDiag[i]   * x[i+1];
            }
            y[i] = val;
      }
}

__global__ void updateSolutionGPU(ConjugateGradientData* data, const double alpha)
{
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      if (i < systemSize) {
            data->solution[i] += alpha * data->direction[i];
      }
}

__global__ void updateResidualGPU(ConjugateGradientData* data, const double alpha)
{
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      if (i < systemSize) {
            data->residual[i] -= alpha * data->projection[i];
      }
}

__global__ void updateConjugateDirectionGPU(ConjugateGradientData* data, const double beta)
{
      int i = blockIdx.x * blockDim.x + threadIdx.x;
      if (i < systemSize) {
            data->direction[i] = data->residual[i] + beta * data->direction[i];
      }
}