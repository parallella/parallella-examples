#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS="-L ${ESDK}/tools/host/lib"
EINCS="-I ${ESDK}/tools/host/include"
ELDF=${ESDK}/bsps/current/fast.ldf

# Create the binaries directory
mkdir -p bin/

# Build host side test application
gcc -c -Wall -Wextra -O3 -fomit-frame-pointer  -g -std=gnu99 src/rh_riecoin.c -o bin/rh_riecoin.o ${EINCS}
g++ -std=c++0x -O3 -fomit-frame-pointer src/testharness.cpp src/riecoinMiner.cpp bin/rh_riecoin.o src/sha2.cpp -o bin/test.elf -g -Wall -lpthread -le-hal -le-loader -lgmp ${ELIBS}

# Build device side
e-gcc -O3 -g -T ${ELDF} -std=gnu99 src/e_modp.c -o bin/e_modp.elf -le-lib -lm -ffast-math -Wall -mfp-mode=int
#e-gcc -O3 -S -T ${ELDF} -std=gnu99 src/e_modp.c -o bin/e_modp.s -le-lib -lm -ffast-math -mfp-mode=int
e-gcc -O3 -g -T ${ELDF} -std=gnu99 src/e_primetest.c -o bin/e_primetest.elf -le-lib -lm -ffast-math -Wall -mfp-mode=int -fno-tree-loop-distribute-patterns
#e-gcc -O3 -S -T ${ELDF} -std=gnu99 src/e_primetest.c -o bin/e_primetest.s -le-lib -lm -ffast-math -mfp-mode=int -fno-tree-loop-distribute-patterns

# Convert ebinary to SREC file
e-objcopy --srec-forceS3 --output-target srec bin/e_modp.elf bin/e_modp.srec
e-objcopy --srec-forceS3 --output-target srec bin/e_primetest.elf bin/e_primetest.srec

