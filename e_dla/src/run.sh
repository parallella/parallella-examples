#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS=${ESDK}/tools/host/lib:${LD_LIBRARY_PATH}
EHDF=${EPIPHANY_HDF}
MPIRUN=/usr/local/bin/mpirun
PROCESSES=1

setterm -cursor off
setterm -blank 0
while :
do
	clear
	./dla 3 16 G 3000
done

