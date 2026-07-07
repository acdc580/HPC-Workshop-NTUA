program hello2
    implicit NONE 
    include 'mpif.h'
    
    ! 1. Explicitly declare variables
    integer :: rank, size, error

    call MPI_INIT(error)

    ! 2. Fix 'cal' to 'call'
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, error)
    
    ! 3. Pass 'size' to get the total number of processes
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, error)

    print *, 'Hello world from', rank

    if (rank == 0) then 
       ! 4. Print the 'size' variable, not the subroutine name
       print *, 'Number of processes: ', size
    endif

    call MPI_FINALIZE(error)

end program hello2