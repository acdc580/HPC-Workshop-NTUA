#include <mpi.h>
#include <iostream>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    int next_rank = (world_rank + 1) % world_size;
    int prev_rank = (world_rank - 1 + world_size) % world_size;

    int send_data = world_rank;
    int recv_data;

    MPI_Sendrecv(&send_data, 1, MPI_INT, next_rank, 0,
                 &recv_data, 1, MPI_INT, prev_rank, 0,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);

    std::cout << "Process " << world_rank << " received data " << recv_data
              << " from process " << prev_rank << std::endl;

    MPI_Finalize();
    return 0;
}