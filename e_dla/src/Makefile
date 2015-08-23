DEFS = -DMPI_BUF_SIZE=1024
CC=/usr/bin/gcc
CCFLAGS += -O3 $(DEFS)

INCS = -I. -I/usr/local/browndeer/include -I/usr/local/browndeer/include/coprthr
LIBS = -L/usr/local/browndeer/lib -lcoprthrcc -lcoprthr

TARGET = dla e_dla.cbin.3.e32

all: $(TARGET)

.PHONY: clean install uninstall $(SUBDIRS)

.SUFFIXES:
.SUFFIXES: .c .o .x .cbin.3.e32

dla: dla.o
	$(CC) -o dla dla.o $(LIBS)

.c.cbin.3.e32:
	clcc --coprthr-cc -mtarget=e32 -D__link_mpi__ --dump-bin -I ./ $(DEFS) -DCOPRTHR_MPI_COMPAT $<
	chmod a+r $@

.c.o:
	$(CC) $(CCFLAGS) $(INCS) -c $<

clean: $(SUBDIRS)
	rm -f *.o 
	rm -f $(TARGET)

distclean: clean 


