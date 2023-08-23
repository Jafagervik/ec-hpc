"""
Threaded/distributed version of running 
the algorithm.

In general, the parts that will be parallelized is the 
calculation of the cost funcs, and then do a partial 
argmax for each of them
"""


using MPI


# Fitness function to minimize
f(x) = x^2

function hpc_ec()
  MPI.Init()

  comm = MPI.COMM_WORLD
  rank = MPI.Comm_rank(comm)
  size = MPI.Comm_size(comm)

  n = 40

  root = 0
  @assert n % size


  xs = undef
  local_size::Integer = n / size


  # Init population
  if rank == root
    xs = rand(-20:20, n)

    # Split population into multiple subpopulations
    # NOTE: Scatter could be used here? or just send/recv
  else
    nothing
  end


  # For each subpopulation, calculate the best possible child,
  # or rather argmax/min and send this info back.


  best, best_x = argmin(xs)

  if rank == root
    println("The x value $(best_x) minimizes f(x) s.t the value becomes $(best)")
  end


  MPI.Finalize()
end
