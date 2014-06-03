#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS=${ESDK}/tools/host/lib
EINCS=${ESDK}/tools/host/include
ELDF=${ESDK}/bsps/current/internal.ldf
export PATH=/usr/local/browndeer/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/browndeer/lib:/usr/local/lib:$LD_LIBRARY_PATH

MPICC=/usr/local/bin/mpicc

# Build OpenMP
gcc src/hello-openmp.c -fopenmp -o hello-openmp.elf

#Build MPI
$MPICC src/hello-mpi.c -o hello-mpi.elf

#Build OpenCL
gcc src/hello-opencl.c -o hello-opencl.elf -I/usr/local/browndeer/include -L/usr/local/browndeer/lib -lcoprthr_opencl
