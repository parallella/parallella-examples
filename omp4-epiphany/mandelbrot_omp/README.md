# Mandelbrot set using OpenMP

This application calculates the mandelbrot set and renders it to the frame buffer in realtime.

It was taken from the original parallella-examples repository and has been rewritten
to utilize OpenMP 4.0 constructs. The host part offloads one kernel which spawns a parallel
team of OpenMP threads within the device (Epiphany). Modifications to the original code
were as few as possible.

Original code: [Mandelbrot](https://github.com/parallella/parallella-examples/tree/master/mandelbrot)

# Building

You need to have [OMPi v2.0.0](http://paragroup.cse.uoi.gr/wpsite/software/ompi) or later installed.
In order to build this application, simply execute:

```Shell
ompicc mandelbrot_omp4.c
```

# Usage

Note that this application can not be executed on headless systems. To run it on e-SDK `5.13.09.10`,
execute the following command:

```Shell
./run.sh
```

Remember that in order to run the program you have to switch to TTY by pressing
```Ctrl + Alt + F2```, then login. (Return to X Window: ```Ctrl + Alt + F7```)

# License

[GNU GENERAL PUBLIC LICENSE // Version 2, June 1991](../GPLv2) <br>
Original program is licensed under the BSD 3-clause License.

# Author

The OMPi Team, [Parallel Processing Group](http://paragroup.cse.uoi.gr/), University of Ioannina

