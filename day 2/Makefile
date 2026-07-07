FC = mpif90
FFLAGS = -O2 -Wall

CXX = mpicxx
CXXFLAGS = -O2 -Wall

NVCC = nvcc

# Source subfolders
FDIR = fortran
CDIR = c++
CUDA_DIR = cuda

# List of programs to build
TARGETS = dot_product reduce dot_product_cpp reduce_cpp ring_cpp hello_cuda

NP ?= 2

.PHONY: all clean run-dot_product run-reduce run-dot_product_cpp run-reduce_cpp run-ring_cpp

all: $(TARGETS)

# --- Fortran versions ---
dot_product: $(FDIR)/dot_product.f90
	$(FC) $(FFLAGS) $< -o $@

reduce: $(FDIR)/reduce.f90
	$(FC) $(FFLAGS) $< -o $@

run-dot_product: dot_product
	mpirun --use-hwthread-cpus -np $(NP) ./dot_product

run-reduce: reduce
	mpirun --use-hwthread-cpus -np $(NP) ./reduce

# --- C++ versions ---
dot_product_cpp: $(CDIR)/dot_product.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

reduce_cpp: $(CDIR)/reduce.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

ring_cpp: $(CDIR)/ring.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

run-dot_product_cpp: dot_product_cpp
	mpirun --use-hwthread-cpus -np $(NP) ./dot_product_cpp

run-reduce_cpp: reduce_cpp
	mpirun --use-hwthread-cpus -np $(NP) ./reduce_cpp

run-ring_cpp: ring_cpp
	mpirun --use-hwthread-cpus -np $(NP) ./ring_cpp

# --- CUDA version ---
hello_cuda: $(CUDA_DIR)/hello.cu
	$(NVCC) $< -o $@

clean:
	rm -f $(TARGETS)