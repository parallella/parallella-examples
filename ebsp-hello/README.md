# Hello world using Epiphany BSP

This example shows how to write a simple "Hello world!" program using Epiphany BSP.

Epiphany BSP is a library for developing applications for the Parallella board. It is easy to setup and use, and provides powerful mechanisms for writing optimized parallel programs. Detailed documentation is provided at <http://www.codu.in/ebsp/docs>.

## Building

This example requires the Epiphany BSP library. Building the example consists of three
steps:

1. Obtaining the Epiphany BSP library by cloning the code from GitHub.
2. Building the library. This will compile the EBSP library, which is used for the example.
3. Building the example. This will compile the host program and a kernel.

These three steps can be performed by simply issuing:

    make

from the command line.

### Manually building

If instead you prefer to perform each steps separately, then issue:

    git clone https://github.com/coduin/epiphany-bsp

From the command line. To build the library issue:

    make ebsp

from this examples' directory. Finally to build the example run:

    make example

## Running

To run the example:

    ./bin/host_hello

It will load the kernel `ecore_hello` on each Epiphany core. You should see the following output:

    $08: Hello World from processor 8 / 16
    $01: Hello World from processor 1 / 16
    $07: Hello World from processor 7 / 16
    ...

## License

This example and the Epiphany BSP library are released under the LGPLv3.

## Authors

- Tom Bannink
- Jan-Willem Buurlage.
- Abe Wits

## Getting started with EBSP

- Read the [documentation of EBSP](http://www.codu.in/ebsp/docs) in which we explain step-by-step what you can do with the EBSP library.
- Look at the examples in the [EBSP repository](http://www.github.com/coduin/epiphany-bsp).
- If you find any issues please [open an issue on GitHub](http://www.github.com/coduin/epiphany-bsp/issues). If you have general comments or remarks please let us know!
