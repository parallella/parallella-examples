# Makefile for compiling the MPI 2D FFT code for Epiphany

CFLAGS += -O2 $(DEFS)

INCS = -I. -I/usr/local/browndeer/include -I/usr/local/browndeer/include/coprthr
LIBS = -L/usr/local/browndeer/lib -lcoprthr -lcoprthrcc -lm -ljpeg

DEVICE_BINARY = device.cbin.3.e32

TARGET = host $(DEVICE_BINARY) libfft-demo.so

DEFS = -DMPI_BUF_SIZE=128 -DDEVICE_BINARY=\"$(DEVICE_BINARY)\"

all: $(TARGET)

.PHONY: clean install uninstall $(SUBDIRS)

.SUFFIXES:
.SUFFIXES: .c .o .x

device.cbin.3.e32: device.c
	clcc --coprthr-cc -mtarget=e32 -D__link_mpi__ --dump-bin \
	-I. -I/opt/adapteva/esdk/tools/e-gnu/epiphany-elf/include $(DEFS) \
	-DCOPRTHR_MPI_COMPAT $<
	# clcc1 bug workaround.
	chmod 644 $@

host: host.c jpeg.c
	$(CC) $(CFLAGS) $(DEFS) $(INCS) $^ -o $@ $(LIBS)

libfft-demo.so: host.c jpeg.c
	$(CC) -fvisibility=hidden -shared -fPIC $(CFLAGS) $(DEFS) $(INCS) $^ \
		-o $@ $(LIBS)

.c.o:
	$(CC) $(CFLAGS) $(DEFS) $(INCS) -c $<

clean: $(SUBDIRS)
	rm -f *.o $(TARGET)

distclean: clean
