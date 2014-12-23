#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS=${ESDK}/tools/host/lib
EINCS=${ESDK}/tools/host/include
ELDF="src/matmul_internal.ldf"

PARAM=$1
if [ $# -lt 1 ]
then
    PARAM="s"
fi

echo -e "Mode: "$PARAM"\n"

if [ "$PARAM" = "s" ]
then
    LIB_SRC_NAME="matmul_assembly"
    LIB_SRC_EXTN=".S"
fi
LIB_SRC_FILE="${LIB_SRC_NAME}${LIB_SRC_EXTN}"
LIB_OBJ_FILE="${LIB_SRC_NAME}.o"
OPT_FLAG="-O3 -std=c99 -mlong-calls -mfp-mode=round-nearest -ffp-contract=fast -ffast-math -funroll-loops"                                                                                                  
if [ "${LIB_SRC_EXTN}" = ".S" ]
then
    ASM_FLAG="-DASM"
fi

echo -e "\nBuild HOST side application"
COMMAND="gcc ${DEFINE_FLAG} src/host_main.c -o Debug/host_main.elf -I ${EINCS} -L ${ELIBS} -le-hal"
echo ${COMMAND}
eval ${COMMAND}

echo -e "\nBuild DEVICE side program"
COMMAND="e-gcc -c ${DEFINE_FLAG} src/e_dev_main.c -o Debug/e_dev_main.o -le-lib"
echo ${COMMAND}
eval ${COMMAND}

echo -e "\nBuilding device side libraries"
COMMAND="e-gcc -c -Wall ${ASM_FLAG} ${OPT_FLAG} -o Debug/matmul_main.o src/matmul_main.c -le-lib"
echo ${COMMAND}
eval ${COMMAND}

if [ "${LIB_SRC_EXTN}" = ".c" ]
then
    COMMAND="e-gcc -c -Wall ${OPT_FLAG} -o Debug/${LIB_OBJ_FILE} src/${LIB_SRC_FILE} -le-lib"
else
    COMMAND="e-as src/${LIB_SRC_FILE} -o Debug/${LIB_OBJ_FILE}"
fi
echo ${COMMAND}
eval ${COMMAND}

echo -e "\nLinking"
COMMAND="e-gcc -T ${ELDF} Debug/e_dev_main.o Debug/matmul_main.o Debug/${LIB_OBJ_FILE} -o Debug/e_dev_main.elf -le-lib"
echo ${COMMAND}
eval ${COMMAND}

echo -e "\nConvert ebinary to SREC file"
COMMAND="e-objcopy --srec-forceS3 --output-target srec Debug/e_dev_main.elf Debug/e_dev_main.srec"
echo ${COMMAND}
eval ${COMMAND}

echo -e "\nBuild complete\n"
#echo -e "\nGenerating assembly...."
#if [ "${LIB_SRC_EXTN}" = ".c" ]
#then
#    COMMAND="e-gcc -S -fverbose-asm -g ${OPT_FLAG} src/${LIB_SRC_FILE} -o Assembly/${LIB_SRC_NAME}.s -le-lib"
#    echo ${COMMAND}
#    eval ${COMMAND}
#
#    COMMAND="e-as -alhnd Assembly/${LIB_SRC_NAME}.s > Assembly/${LIB_SRC_NAME}_as.s"
#    echo ${COMMAND}
#    eval ${COMMAND}
#
#    rm a.out
#fi

#COMMAND="e-objdump -d -S Debug/matmul_op.o > Assembly/matmul_op_objdump.s"
#COMMAND="e-objdump -d -S Debug/${LIB_OBJ_FILE} > Assembly/${LIB_SRC_NAME}_objdump.s"
#echo ${COMMAND}
#eval ${COMMAND}
#
#COMMAND="e-objdump -d -S Debug/matmul_main.o > Assembly/matmul_main_objdump.s"
#echo ${COMMAND}
#eval ${COMMAND}


#echo -e "\n\nExecuting program"
#COMMAND="./run.sh"
#echo ${COMMAND}
#eval ${COMMAND}
