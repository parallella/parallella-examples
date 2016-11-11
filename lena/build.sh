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

	pushd device/${Config} >& /dev/null
	popd >& /dev/null
fi


mkdir -p ./host/${Config}
rm -f ./host/${Config}/fft2d_host.elf

if [ -z "${CROSS_COMPILE+xxx}" ]; then
case $(uname -p) in
    arm*)
        # Use native arm compiler (no cross prefix)
        CROSS_COMPILE=
        ;;
       *)
        # Use cross compiler
        CROSS_COMPILE="arm-linux-gnueabihf-"
        ;;
esac
fi

# Build HOST side application
${CROSS_COMPILE}g++ \
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
	-le-loader \
	-lIL \
	-lILU \
	-lILUT \
	-ljpeg \
	-lpthread \
	-lrt


#echo "=== Building FFTW bemchmark program ==="
#
#gcc \
#	-O0 \
#	host/src/fftw.c \
#	-o host/Release/fftw.elf \
#	-L /usr/local/lib \
#	-lfftw3f \
#	-lm


