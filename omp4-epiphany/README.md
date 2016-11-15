# omp4-epiphany

This directory contains OpenMP 4.x examples where Epiphany is treated as a device able to execute kernels containing OpenMP code.

You need to have [OMPi v2.0.0](http://paragroup.cse.uoi.gr/wpsite/software/ompi) or later installed.

## Check if OMPi is already installed

Newer Pubuntu / ESDK images ship with OMPi. Use this to check if you already have OMPi installed.

```sh
$ ompicc --version
2.0.0
```

# Included examples

NAME                             | DESCRIPTION                     |
-------------------------------- |-------------------------------- |
[demo1](demo1)                   | Simple OpemMP4 device demo
[demo2](demo2)                   | Another OpenMP4 device demo
[gol](gol)                       | Conway's Game of Life using OpenMP4
[mandelbrot_omp](mandelbrot_omp) | Parallella Mandelbrot example using OpenMP4
[nqueens](nqueens)               | Solving the N-Queens problem on Epiphany using OpenMP4
[pi_kernel](pi_kernel)           | Simple pi calculation using an OpenMP4 kernel

# Notes

The examples contained here have been tested on e-SDK versions ```5.13.09.10```, ```2015.1```, and ```2016.11```.

# Author

The OMPi Team, [Parallel Processing Group](http://paragroup.cse.uoi.gr/), University of Ioannina
