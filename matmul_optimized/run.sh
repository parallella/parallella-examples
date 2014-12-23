#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS=${ESDK}/tools/host/lib:${LD_LIBRARY_PATH}
EHDF=${EPIPHANY_HDF}

cd Debug

COMMAND="sudo -E LD_LIBRARY_PATH=${ELIBS} EPIPHANY_HDF=${EHDF} ./host_main.elf"
echo ${COMMAND}
eval ${COMMAND}

cd ..

#echo -e "\nVerifying Result:"
#COMMAND="diff output/optresult output/result.32 | wc -l"
#echo ${COMMAND}
#eval ${COMMAND}

echo -e ""
