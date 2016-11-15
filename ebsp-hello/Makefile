ESDK=${EPIPHANY_HOME}
ELDF=epiphany-bsp/ebsp_fast.ldf

CFLAGS=-std=c99 -O3 -ffast-math -Wall

INCLUDES = -Iepiphany-bsp/include \
		   -I${ESDK}/tools/host/include

HOST_LIBS = -Lepiphany-bsp/lib \
			-L${ESDK}/tools/host/lib \
			-L/usr/arm-linux-gnueabihf/lib

E_LIBS = -Lepiphany-bsp/lib \
		 -L${ESDK}/tools/host/lib

HOST_LIB_NAMES = -lhost-bsp -le-hal -le-loader

E_LIB_NAMES = -le-bsp -le-lib

########################################################

all: ebsp_source ebsp example

########################################################

ebsp_source:
	[ -d epiphany-bsp ] || git clone https://github.com/coduin/epiphany-bsp

ebsp:
	cd epiphany-bsp && make

########################################################

example: bin bin/host_hello bin/ecore_hello.elf

bin:
	@mkdir -p bin

bin/host_hello: src/host_hello.c
	@echo "CC $<"
	@gcc $(CFLAGS) $(INCLUDES) -o $@ $< $(HOST_LIBS) $(HOST_LIB_NAMES)

bin/ecore_hello.elf: src/ecore_hello.c
	@echo "CC $<"
	@e-gcc $(CFLAGS) -T ${ELDF} $(INCLUDES) -o $@ $< $(E_LIBS) $(E_LIB_NAMES)

########################################################

clean:
	rm -r bin
