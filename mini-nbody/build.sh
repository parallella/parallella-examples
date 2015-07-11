#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELDF=${ESDK}/bsps/current/fast.ldf

SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")
cd $EXEPATH

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
${CROSS_PREFIX}gcc src/nbody.c -funroll-loops -o Debug/nbody.elf -I${ESDK}/tools/host/include -I/usr/local/browndeer/include -I/usr/local/browndeer/include/coprthr  -L${ESDK}/tools/host/lib -L/usr/local/browndeer/lib -le-hal -lcoprthrcc -lcoprthr -lm #-le-loader

# Build DEVICE side program
e-gcc -T ${ELDF} src/e_nbody.c -funroll-loops -o Debug/e_nbody.elf -le-lib -lm

# Convert ebinary to SREC file
e-objcopy --srec-forceS3 --output-target srec Debug/e_nbody.elf Debug/e_nbody.srec

