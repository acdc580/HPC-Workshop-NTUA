program hello_mpi
    use mpi
    implicit none

    integer :: rank, size, error

    call MPI_INIT(error)

    ! Get the rank of the current process
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, error)

    ! Get the total number of processes
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, error)

    print *, 'Hello world from rank', rank, 'out of', size

    call MPI_FINALIZE(error)

end program hello_mpi