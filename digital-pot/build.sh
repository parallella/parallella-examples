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


GPIO=./parallella-utils/gpio_dir

GPIOSRCS="$GPIO/para_spi.cpp $GPIO/para_gpio.cpp $GPIO/para_gpio.c"

# Build HOST side applications
[ -e parallella-utils ] || git clone https://github.com/parallella/parallella-utils

${CROSS_PREFIX}g++ -o digital-pot -I$GPIO  digital-pot.cpp $GPIOSRCS
${CROSS_PREFIX}g++ -o digital-pot-ledfade -I$GPIO digital-pot-ledfade.cpp $GPIOSRCS
