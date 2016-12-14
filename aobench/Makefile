ESDK=$(EPIPHANY_HOME)
ELIBS=$(ESDK)/tools/host/lib
EINCS=$(ESDK)/tools/host/include
ELDF=$(ESDK)/bsps/current/internal.ldf
EXES=ao epiphany.elf

AO_CFLAGS =

# When OH FPGA elink has configurable RX MMU
#AO_CFLAGS += "-DFB_DIRECT_COPY"

all: $(EXES)



ao: host.c shared_data.h
		gcc -O3 host.c -o ao $(AO_CFLAGS)-I $(EINCS) -L $(ELIBS) -le-hal -le-loader -lrt

epiphany.elf: epiphany.c shared_data.h
		e-gcc $(AO_CFLAGS) -g -O2 -funroll-loops -ffast-math -fsingle-precision-constant -T $(ELDF) epiphany.c -o epiphany.elf -lm -le-lib
#		e-gcc -Os -ffast-math -fsingle-precision-constant -T $(ELDF) epiphany.c -o epiphany.elf -le-lib -lm

clean:
		rm $(EXES) $(OBJS)
