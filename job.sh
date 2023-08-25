#!/usr/bin/bash

# RUN MPI
mpiexecjl --project=./ -n 4 julia ./src/mpitest.jl
