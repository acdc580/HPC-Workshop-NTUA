#include <mpi.h>
#include <cstdio>
#include <vector>

int main(int argc, char** argv) {
    const int A = 10000;

    int rank, size, error;
    int N_local, start_index;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    N_local = A / size;
    start_index = rank * N_local;

    std::vector<double> x_local(N_local);

    for (int i = 1; i <= N_local; i++) {
        x_local[i - 1] = static_cast<double>(start_index + i) /
                          static_cast<double>(start_index + i + 1.0);
    }

    double sum_local = 0.0;
    for (int i = 0; i < N_local; i++) {
        sum_local += x_local[i] * x_local[i];
    }

    double sum_total = 0.0;
    MPI_Allreduce(&sum_local, &sum_total, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Dot product is: %.10f\n", sum_total);
    }

    MPI_Finalize();
    return 0;
}
