ESDK=$(EPIPHANY_HOME)
ELIBS=$(ESDK)/tools/host/lib
EINCS=$(ESDK)/tools/host/include
ELDF=$(ESDK)/bsps/current/internal.ldf
EXES=main epiphany.srec
OBJS=epiphany.elf
CFLAGS=-O3 -Wall
LIBS=-lpthread -lfreenect -lm -le-hal -lrt
CFLAGS_E=-O3 -ffast-math -funroll-loops -Wall
LIBS_E=-le-lib
INCDIR=/usr/local/include
LIBDIR=/usr/local/lib

all: $(EXES)

main: host.c common.h
	gcc host.c $(CFLAGS) -I$(INCDIR) -I$(EINCS) -L$(LIBDIR) -L$(ELIBS) $(LIBS) -o main

epiphany.elf: epiphany.c common.h
	e-gcc epiphany.c $(CFLAGS_E) -T$(ELDF) $(LIBS_E) -o epiphany.elf

epiphany.srec: epiphany.elf
	e-objcopy --srec-forceS3 --output-target srec epiphany.elf epiphany.srec

clean:
	rm $(EXES) $(OBJS)
