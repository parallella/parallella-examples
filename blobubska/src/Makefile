ESDK=$(EPIPHANY_HOME)
ELIBS=$(ESDK)/tools/host/lib
EINCS=$(ESDK)/tools/host/include
ELDF=$(ESDK)/bsps/current/fast.ldf
CFLAGA=-Ofast -funroll-loops -ffast-math
CFLAGE=-Ofast -funroll-loops -ffast-math
EXES=main epiphany.srec hostonly
OBJS=epiphany.elf

all: $(EXES)

main: host.c common.h
	gcc $(CFLAGA) host.c -o main -I $(EINCS) -L $(ELIBS) -le-hal -lrt -lfluidsynth

hostonly: hostonly.c common.h
	gcc $(CFLAGA) hostonly.c -o hostonly -lrt -lfluidsynth

epiphany.elf: epiphany.c common.h
	e-gcc $(CFLAGE) -T $(ELDF) epiphany.c -o epiphany.elf -le-lib

epiphany.srec: epiphany.elf
	e-objcopy --srec-forceS3 --output-target srec epiphany.elf epiphany.srec

clean:
	rm $(EXES) $(OBJS)
