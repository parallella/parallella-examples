# Makefile for compiling the MPI 2D FFT code for Epiphany

DEFS = -DMPI_BUF_SIZE=128 

CCFLAGS += -O2 $(DEFS)

INCS = -I. -I/usr/local/browndeer/include -I/usr/local/browndeer/include/coprthr
LIBS = -L/usr/local/browndeer/lib -lcoprthr -lcoprthrcc -lm

TARGET = mpi_fft2d_host.x mpi_fft2d_tfunc.cbin.3.e32 

all: $(TARGET)

.PHONY: clean install uninstall $(SUBDIRS)

.SUFFIXES:
.SUFFIXES: .c .o .x

mpi_fft2d_tfunc.cbin.3.e32: mpi_fft2d_tfunc.c
	clcc --coprthr-cc -mtarget=e32 -D__link_mpi__ --dump-bin -I. $(DEFS) \
	-DCOPRTHR_MPI_COMPAT mpi_fft2d_tfunc.c

mpi_fft2d_host.x: mpi_fft2d_host.o
	$(CC) -o mpi_fft2d_host.x mpi_fft2d_host.o $(LIBS)

.c.o:
	$(CC) $(CCFLAGS) $(DEFS) $(INCS) -c $<

clean: $(SUBDIRS)
	rm -f *.o *.x *.cbin.3.e32

distclean: clean 


