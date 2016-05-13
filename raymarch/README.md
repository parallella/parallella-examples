# README #

### What is raymarch? ###

RayMarch is a WIP framework to create raymarching OpenCL code that runs with the COPRTHR library on x86(_64) Linux PC and the Parallella board (ARMv7 & Epiphany 16-core accellerator).

### How to use? ###

It's pretty simple actually; just copy an example from the examples directory to the 'raymarch_kern.cl' file, and do a 'make'.


```
#!bash

# cp examples/hollowcubes.cl ./raymarch_kern.cl
# make clean; make
# ./raymarch -h
RayMarch, a WIP raymarching example framework using COPRTHR and OpenCL.
(C) Copyright 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
Released under GPLv3, see file LICENSE for details.
Error. Unrecognized option: -h

Usage: ./raymarch [options]
	-c		Use CPUs (COPRTHR) as OpenCL target.
	-a		Use accellerator (Epiphany) as OpenCL target.
	-g		Use GPU as OpenCL target.
	-nthreads X	Use X number of threads/compute units.
# ./raymarch -a -nthreads 16

```

That's it basically.

Check out the examples, many are reworked versions from Shadertoy.com website.

If you want to contribute your own examples, just start with the gradientsquare.cl example and implement your own 'render_pixel' function.

### TODO ###

 * Optimize the speed of the kernels & functions.
 * Figure out why some examples create an Alignment Trap on the ARM CPU.
 * More (and better) examples.
