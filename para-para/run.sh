#!/bin/bash
export PATH=/usr/local/browndeer/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/browndeer/lib:/usr/local/lib:$LD_LIBRARY_PATH
#OpenMP
MPIRUN=/usr/local/bin/mpirun
HOST=`hostname`
echo -------------------------
echo Running OpenMP Example
echo -------------------------
./hello-openmp.elf

#MPI
echo -------------------------
echo Running OpenMP Example
echo -------------------------
$MPIRUN -np 4 --host $HOST ./hello-mpi.elf

#OpenCL
echo -------------------------
echo Running OpenCL Example
echo -------------------------
sudo -s <<EOF
./hello-opencl.elf
EOF

