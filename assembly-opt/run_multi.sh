#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS=${ESDK}/tools/host/lib:${LD_LIBRARY_PATH}
EHDF=${EPIPHANY_HDF}

cd Debug

./host_multi.elf

cd ..

#echo -e "\nVerifying Result:"
#COMMAND="diff output/optresult output/Result.256 | wc -l"
#echo ${COMMAND}
#eval ${COMMAND}

echo -e ""
