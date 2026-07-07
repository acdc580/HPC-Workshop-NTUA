program hello_mpi
    ! 1. Load the MPI module (The modern Fortran way)
    use mpi
    
    ! Prevents accidental typos by forcing variable declaration
    implicit none

    ! 2. Declare variables clearly
    integer :: process_rank
    integer :: total_processes
    integer :: error_code

    ! 3. Initialize the MPI environment
    call MPI_INIT(error_code)

    ! 4. Find out who this specific process is (its rank ID)
    call MPI_COMM_RANK(MPI_COMM_WORLD, process_rank, error_code)
    
    ! 5. Find out the total number of processes running
    call MPI_COMM_SIZE(MPI_COMM_WORLD, total_processes, error_code)

    ! 6. Print the output
    print *, 'Hello world! I am process', process_rank, 'out of', total_processes

    ! 7. Clean up and securely shut down the MPI environment
    call MPI_FINALIZE(error_code)

end program hello_mpi