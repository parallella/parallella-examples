ESDK=$(EPIPHANY_HOME)
ELIBS=$(ESDK)/tools/host/lib
EINCS=$(ESDK)/tools/host/include
ELDF=$(ESDK)/bsps/current/internal.ldf
EXES=main epiphany.srec
OBJS=epiphany.elf

all: $(EXES)


main: host.c shared_data.h
	gcc -O3 host.c -o main -I $(EINCS) -L $(ELIBS) -le-hal -lrt -le-loader

epiphany.elf: epiphany.c shared_data.h
	e-gcc -O3 -funroll-loops -ffast-math -T $(ELDF) epiphany.c -o epiphany.elf -le-lib

epiphany.srec: epiphany.elf
	e-objcopy --srec-forceS3 --output-target srec epiphany.elf epiphany.srec

clean:
	rm $(EXES) $(OBJS)
