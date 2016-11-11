#!/bin/bash

set -e

if [[ "$1" == "-d" ]]; then
	Config='Debug'
else
	Config='Release'
fi

if [[ "$1" == "" ]]; then
	Img=../../lenna.jpg
else
	Ing=$@
fi


cd host/${Config}

./fft2d_host.elf ${Img} ../../device/Release/e_fft2d.elf

cd ../../

