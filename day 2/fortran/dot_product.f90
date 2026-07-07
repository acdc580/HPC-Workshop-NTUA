program dot_product
  use mpi
  implicit none
  integer, parameter :: A = 10000
  integer :: rank, size, error, N_local, i, start_index
  real(8), allocatable, dimension(:) :: x_local
  real(8) :: sum_local, sum_total

  call MPI_Init(error)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, error)
  call MPI_Comm_size(MPI_COMM_WORLD, size, error)

  N_local = A / size
  allocate(x_local(N_local))
  start_index = rank * N_local

  do i = 1, N_local
    x_local(i) = dble(start_index + i) / dble(start_index + i + 1.d0)
  end do

  sum_local = 0.0d0
  do i = 1, N_local
    sum_local = sum_local + x_local(i) ** 2
  end do

  call MPI_Allreduce(sum_local, sum_total, 1, MPI_DOUBLE_PRECISION, &
       MPI_SUM, MPI_COMM_WORLD, error)

  if (rank == 0) then
    print *, "Dot product is: ", sum_total
  end if

  call MPI_Finalize(error)
end program dot_product