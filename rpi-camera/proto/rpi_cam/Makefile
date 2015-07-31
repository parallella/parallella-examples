CC=gcc
CFLAGS=-O2 -Wall -Wno-trigraphs -Wno-unused-result -march=armv7 -mfpu=neon
LDLIBS=
OBJS=rpi_cam

all: $(OBJS)

rpi_cam: rpi_cam.o para_gpio.o

clean:
	rm -f $(OBJS) *.o

