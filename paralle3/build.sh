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

# Create output dir
mkdir -p bin

# Build HOST side application
${CROSS_PREFIX}gcc src/e2g.c -o bin/e2g.elf -I ${EINCS} -L ${ELIBS} -le-hal -le-loader

# Build DEVICE side program
# -msmall16 still does not work with 2016.11 ESDK and gcc 5.4
#-mshort-calls still works :D  

#e-gcc -Ofast -T ${ELDF} -msmall16 src/e_e2g.c -o bin/e_e2g.elf -le-lib
#e-gcc 5.4 makes poor use of the option -mfp-mode=int
#  the option -mfp-iarith slows DOWN my program -- more than 20 % :/ 

 e-gcc -Ofast -T ${ELDF} -mfp-mode=int -mshort-calls -m1reg-r63 src/e_e2g.c -o bin/e_e2g.elf -le-lib

# trick to get the spare room usage: epiphany-elf-size your_program.elf ; with internal.ldf the value of 'dec' cannot be beyond 32767
#
#parallella@parallella:~/parallella-examples/tmp$ epiphany-elf-size bin/e_e2g.elf 
#   text	   data	    bss	    dec	    hex	filename
#  18730	   2148	   2808	  23686	   5c86	bin/e_e2g.elf
#
