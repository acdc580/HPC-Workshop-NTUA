program reduce
  use mpi
  implicit none
  integer :: rank, size, error, root
  integer :: local_data, reduced_data

  call MPI_Init(error)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, error)
  call MPI_Comm_size(MPI_COMM_WORLD, size, error)

  local_data = rank
  root = 0

  call MPI_Reduce(local_data, reduced_data, 1, MPI_INTEGER, MPI_SUM, &
                   root, MPI_COMM_WORLD, error)

  if (rank == root) then
    print *, "Reduced sum is: ", reduced_data
  end if

  call MPI_Finalize(error)
end program reduce