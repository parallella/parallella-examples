ESDK=$(EPIPHANY_HOME)
ELIBS=$(ESDK)/tools/host/lib
EINCS=$(ESDK)/tools/host/include
ELDF=$(ESDK)/bsps/current/internal.ldf
CFLAGA=-Ofast -funroll-loops -ffast-math
CFLAGE=-Ofast -funroll-loops -ffast-math
EXES=main epiphany.elf hostonly
OBJS=epiphany.elf

all: $(EXES)

main: host.c common.h keymap.h
	gcc $(CFLAGA) host.c -o main -I $(EINCS) -L $(ELIBS) -le-hal -le-loader -lrt -lfluidsynth

hostonly: hostonly.c common.h
	gcc $(CFLAGA) hostonly.c -o hostonly -lrt -lfluidsynth

epiphany.elf: epiphany.c common.h
	e-gcc $(CFLAGE) -T $(ELDF) epiphany.c -o epiphany.elf -le-lib

clean:
	rm -f $(EXES) $(OBJS)
