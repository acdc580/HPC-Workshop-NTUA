#include <mpi.h>
#include <cstdio>

int main(int argc, char** argv) {
    int rank, size;
    int root = 0;
    int local_data, reduced_data;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    local_data = rank;

    MPI_Reduce(&local_data, &reduced_data, 1, MPI_INT, MPI_SUM, root, MPI_COMM_WORLD);

    if (rank == root) {
        printf("Reduced sum is: %d\n", reduced_data);
    }

    MPI_Finalize();
    return 0;
}
