#!/bin/bash

set -e

BUILD_DEVICE="yes"
MK_CLEAN="no"
MK_ALL="yes"

Config="Release"

if [[ "${BUILD_DEVICE}" == "yes" ]]; then


	pushd device/${Config} >& /dev/null
	if [[ "${MK_CLEAN}" == "yes" ]]; then
		echo "*** Cleaning device library"
		make clean
	fi
	if [[ "${MK_ALL}" == "yes" ]]; then

		make --warn-undefined-variables BuildConfig=${Config} all
	fi
	popd >& /dev/null

	echo "*** Creating srec file"
	rm -rf device/${Config}/e_fft2d.*.srec
	pushd device/${Config} >& /dev/null
	e-objcopy --srec-forceS3 --output-target srec e_fft2d.elf e_fft2d.srec
	popd >& /dev/null
fi



rm -f ./host/${Config}/fft2d_host.elf

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
${CROSS_PREFIX}g++ \
	-Ofast -Wall -g0 \
	-D__HOST__ \
	-Dasm=__asm__ \
	-Drestrict= \
	-I/usr/include \
	-I./device/src \
	-I ${EPIPHANY_HOME}/tools/host/include \
	-L ${EPIPHANY_HOME}/tools/host/lib \
	-falign-loops=8 \
	-funroll-loops \
	-ffast-math \
	-o "./host/${Config}/fft2d_host.elf" \
	"./host/src/fft2d_host.c" \
	-le-hal \
	-lIL \
	-lILU \
	-lILUT \
	-ljpeg


#echo "=== Building FFTW bemchmark program ==="
#
#gcc \
#	-O0 \
#	host/src/fftw.c \
#	-o host/Release/fftw.elf \
#	-L /usr/local/lib \
#	-lfftw3f \
#	-lm


