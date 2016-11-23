#makefile for idct2d

RM := rm -rf
OBJS :=
C_DEPS :=
C_SRCS :=

EPIPHANY_HOME ?= /opt/adapteva/esdk

INCS := -I include \
-I device/include \
-I commonlib/include \
-I ${EPIPHANY_HOME}/tools/host.arm7l/include

LDF := ${EPIPHANY_HOME}/bsps/current/internal.ldf

OBJECTS := 	device/src/rowSort.o \
			device/src/scale.o \
			device/src/combineRow.o \
			device/src/shuffleFlyRow.o \
			device/src/shuffleRow.o \
			device/src/finalRow.o \
			device/src/scaleCol.o \
			device/src/combineCol.o \
			device/src/shuffleFlyCol.o \
			device/src/shuffleCol.o \
			device/src/finalCol.o \
			device/src/transpose.o \
			device/src/shift.o \
			device/src/reTrans.o \
			device/src/clip.o

EXECS :=	rowSort.elf \
			scale.elf \
			combineRow.elf \
			shuffleFlyRow.elf \
			shuffleRow.elf \
			finalRow.elf \
			scaleCol.elf \
			combineCol.elf \
			shuffleFlyCol.elf \
			shuffleCol.elf \
			finalCol.elf \
			transpose.elf \
			shift.elf \
			reTrans.elf \
			clip.elf

CFLAGS =  -DFULL -O3  -Wall -c -fmessage-length=0 -ffast-math -ftree-vectorize -funroll-loops -std=c99 -Wunused-variable -ffp-contract=fast -mlong-calls -mfp-mode=truncate -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)"

all: commonlibs host device

# Building the commonlib files

commonlibs: commonlib/src/common_buffers.o commonlib/src/communication.o libcommonlib.a

%.o: %.c
	@echo 'Building file: $<'
	@echo 'Invoking Epiphany compiler'
	e-gcc -Dasm=__asm__ $(INCS) $(CFLAGS) -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

libcommonlib.a:
	@echo 'Building target: $@'
	@echo 'Invoking: Epiphany archiver'
	e-ar -r "libcommonlib.a" ./commonlib/src/common_buffers.o ./commonlib/src/communication.o
	@echo 'Finished building target: $@'
##########################################################

# Building the host file

host: host/src/idct_host.o idct_host.elf

host/src/idct_host.o: host/src/idct_host.c
	@echo 'Building file: $<'
	@echo 'Invoking GCC arm Compiler'
	gcc  -DFULL -D__HOST__ -Dasm=__asm__ -Drestrict= $(INCS) -I ${EPIPHANY_HOME}/tools/host/include -I ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/sys-include -L ${EPIPHANY_HOME}/tools/host/lib  -O3 -Ofast -falign-loops=8 -funroll-loops  -Wall -c -Wno-unused-result -MMD -MD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<" 
	@echo 'Finished building $<'
	@echo ' '

idct_host.elf: host/src/idct_host.o
	@echo 'Building target: $@'
	@echo 'Invoking GCC arm Linker'
	gcc -L${EPIPHANY_HOME}/tools/host/lib  "$<" -o "$@" -le-loader -le-hal -lrt

##########################################################


# Building the device files

device: $(OBJECTS) $(EXECS)

%.o: %.c	
	@echo 'Building file: $<'
	e-gcc $(INCS) $(CFLAGS) -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '
# -I"commonlib

###########################################################################

# Building the elf files 

%.elf: ./device/src/%.o
	@echo 'Building target: $@'
	@echo 'Invoking Epiphany linker'
	e-gcc -L"/commonlib" -L/commonlib -T $(LDF)  "$<" -o "$@" libcommonlib.a -le-lib 

	@echo 'End of make'

###########################################################################

clean:
	@echo 'Cleaning the .o, .d, and .elf ...'
	-$(RM) ./commonlib/src/*.o commonlib/src/*.d ./host/src/*.o ./host/src/*.d ./device/src/*.o ./device/src/*.d libcommonlib.a *.elf
	@echo 'End of clean'



