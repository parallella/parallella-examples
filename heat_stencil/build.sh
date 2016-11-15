#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS=${ESDK}/tools/host/lib
EINCS=${ESDK}/tools/host/include
ELDF=${ESDK}/bsps/current/internal.ldf
#ELDF=${ESDK}/bsps/current/fast.ldf

PARAM=$1

if [ $# -eq "0" ]
then
    PARAM=3
fi

LINK_FLAG="-le-lib -lm -T "${ELDF}
LIB_O_FLAG="-ftree-vectorize -funroll-loops -mfp-mode=round-nearest -ffp-contract=fast -ffast-math -O"$PARAM
DEV_O_FLAG="-Dasm=__asm__ -funroll-loops -falign-loops=8 -falign-functions=8 -fmessage-length=0 -ffast-math -ftree-vectorize -std=c99 -Wunused-variable -ffp-contract=fast -mlong-calls -mfp-mode=round-nearest -MMD -MP -Wall -fgnu89-inline"

#ls -1 Debug/host_main.elf && rm Debug/host_main.elf
#ls -1 Debug/e_dev_main* && rm Debug/e_dev_main*

echo -e "\n***Start build***\n"
# Build HOST side application
echo "Building host program"
echo "gcc src/host_main.c -o Debug/host_main.elf -I ${EINCS} -L ${ELIBS} -le-hal -le-loader"
gcc src/host_main.c -o Debug/host_main.elf -I ${EINCS} -L ${ELIBS} -le-hal -le-loader

#Build device side application
echo -e "\nBuilding stencil_lib"
echo "e-gcc src/stencil20_5.S -defsym _righty=1 -c -o Debug/stencil20_lib.o"
e-gcc src/stencil20_5.S -Wa,-defsym -Wa,_righty=1 -c -o Debug/stencil20_lib.o

echo -e "\nBuilding e_dev_main"
echo "e-gcc -g -c src/e_dev_main.c -D_righty=1 -o Debug/e_dev_main.o" $DEV_O_FLAG 
e-gcc -g -c src/e_dev_main.c -D_righty=1 -o Debug/e_dev_main.o $DEV_O_FLAG 

echo -e "\nLinking"
echo "e-gcc Debug/e_dev_main.o Debug/stencil20_lib.o -o Debug/e_dev_main.elf" $LINK_FLAG
e-gcc Debug/e_dev_main.o Debug/stencil20_lib.o -o Debug/e_dev_main.elf $LINK_FLAG

# Convert ebinary to SREC file
echo -e "\nGenerating SREC file: ./Debug/e_dev_main.srec"
e-objcopy --srec-forceS3 --output-target srec Debug/e_dev_main.elf Debug/e_dev_main.srec

#echo -e "\nAssembly code written to ./Debug/assembly/"

##e-objdump -d -S Debug/util_lib.o > Debug/assembly/util_lib.s
#e-objdump -d -S Debug/stencil20_lib.o > Debug/assembly/stencil20_lib.s
#e-objdump -d -S Debug/e_dev_main.o > Debug/assembly/e_dev_main.s

echo -e "\n****Build complete***\n"
