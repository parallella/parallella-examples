ESDK=$(EPIPHANY_HOME)
ELIBS=$(ESDK)/tools/host/lib
EINCS=$(ESDK)/tools/host/include
ELDF=$(ESDK)/bsps/current/fast.ldf
EXES=ao epiphany.srec
OBJS=epiphany.elf

all: $(EXES)


ao: host.c shared_data.h
		gcc -O3 host.c -o ao -I $(EINCS) -L $(ELIBS) -le-hal -le-loader -lrt

epiphany.elf: epiphany.c shared_data.h
		e-gcc -O2 -funroll-loops -ffast-math -fsingle-precision-constant -T $(ELDF) epiphany.c -o epiphany.elf -lm -le-lib
#		e-gcc -Os -ffast-math -fsingle-precision-constant -T $(ELDF) epiphany.c -o epiphany.elf -le-lib -lm

epiphany.srec: epiphany.elf
		e-objcopy --srec-forceS3 --output-target srec epiphany.elf epiphany.srec

clean:
		rm $(EXES) $(OBJS)
