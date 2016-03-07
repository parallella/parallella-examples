#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS=${ESDK}/tools/host/lib
EINCS=${ESDK}/tools/host/include
ELDF=${ESDK}/bsps/current/internal.ldf

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
${CROSS_PREFIX}gcc src/prime.c -o bin/prime.elf -I ${EINCS} -L ${ELIBS} -le-hal -le-loader

# Build DEVICE side program
e-gcc -O2 -T ${ELDF} src/isprime.c src/e_prime.c -o bin/e_prime.elf -le-lib -lm

# Convert ebinary to SREC file
e-objcopy --srec-forceS3 --output-target srec bin/e_prime.elf bin/e_prime.srec
