#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS="-L ${ESDK}/tools/host/lib"
EINCS="-I ${ESDK}/tools/host/include"
ELDF=${ESDK}/bsps/current/internal.ldf

SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")
cd $EXEPATH

# Create the binaries directory
mkdir -p bin/

CROSS_PREFIX=
case $(uname -p) in
	arm*)
		# Use native arm compiler (no cross prefix)
		CROSS_PREFIX=
		;;
	   *)
		# Use cross compiler
		CROSS_PREFIX="arm-linux-gnueabihf-"
		;;
esac

# Build HOST side application
${CROSS_PREFIX}gcc src/fft.c -o bin/fft.elf ${EINCS} ${ELIBS} -le-hal -le-loader -lpthread -lm -lfftw3f

# Build DEVICE side program
e-gcc -O3 -T ${ELDF} src/e_fft_asm.S src/e_fft_buf.S src/e_fft.c -o bin/e_fft.elf -le-lib -lm -std=c99 -ffast-math

## Convert ebinary to SREC file
#e-objcopy --srec-forceS3 --output-target srec bin/e_fft.elf bin/e_fft.srec
