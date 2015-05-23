# Makefile for compiling the MPI 2D FFT code for Epiphany

# Which implementation, either coprthr or fftw (TODO)
# If you want to build both you have to run make twice.
IMPL ?= coprthr

INCS_coprthr	= -I. -I/usr/local/browndeer/include \
		  -I/usr/local/browndeer/include/coprthr
LIBS_coprthr	= -L/usr/local/browndeer/lib -lcoprthr -lcoprthrcc
TARGET_coprthr	= device.cbin.3.e32
DEFS_coprthr	= -DMPI_BUF_SIZE=128 -DDEVICE_BINARY=\"$(TARGET_coprthr)\"

LIBS_fftw	= -lfftw3f

LIBS		= -lm -ljpeg
CFLAGS		= -O2
INCS		= -I.
DEFS		=
TARGET		= test-$(IMPL) test-dataset-$(IMPL) libfft-demo-$(IMPL).so

LIBS		+= $(LIBS_$(IMPL))
CFLAGS		+= $(CFLAGS_$(IMPL))
INCS		+= $(INCS_$(IMPL))
DEFS		+= $(DEFS_$(IMPL))
TARGET		+= $(TARGET_$(IMPL))

all: $(TARGET)

.PHONY: clean install uninstall

device.cbin.3.e32: device.c
	clcc --coprthr-cc -mtarget=e32 -D__link_mpi__ --dump-bin \
	-I. -I/opt/adapteva/esdk/tools/e-gnu/epiphany-elf/include $(DEFS) \
	-DCOPRTHR_MPI_COMPAT $<
	# clcc1 bug workaround.
	chmod 644 $@

test-$(IMPL): main.c $(IMPL).c jpeg.c
	$(CC) $(CFLAGS) $(DEFS) $(INCS) $^ -o $@ $(LIBS)

test-dataset-$(IMPL): test-dataset.c $(IMPL).c jpeg.c
	$(CC) $(CFLAGS) $(DEFS) $(INCS) $^ -o $@ $(LIBS)

libfft-demo-$(IMPL).so: main.c $(IMPL).c jpeg.c
	$(CC) -fvisibility=hidden -shared -fPIC $(CFLAGS) $(DEFS) $(INCS) $^ \
		-o $@ $(LIBS)

clean:
	rm -f *.o test-coprthr test-fftw \
	    test-dataset-coprthr test-dataset-fftw \
	    libfft-demo-coprthr.so libfft-demo-fftw.so \
	    $(TARGET_coprthr) $(TARGET_fftw)

distclean: clean
