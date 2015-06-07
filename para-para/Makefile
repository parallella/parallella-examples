CC = gcc
MPICC=mpicc
CCFLAGS = -Wall
OPENCLFLAGS = -I/usr/local/browndeer/include -L/usr/local/browndeer/lib -lcoprthr_opencl
OPENMPFLAGS = -fopenmp

all: hello-mpi hello-opencl hello-openmp

hello-mpi:
	$(MPICC) src/hello-mpi.c -o hello-mpi.elf $(CCFLAGS)

hello-opencl:
	$(CC) src/hello-opencl.c -o hello-opencl.elf $(CFLAGS) $(OPENCLFLAGS)

hello-openmp:
	$(CC) src/hello-openmp.c -o hello-openmp.elf $(CCFLAGS) $(OPENMPFLAGS)

clean:
	@rm *.elf

.PHONY: clean
