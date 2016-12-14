# Heat Stencil

Implementation of a 5-point star shaped stencil for solving the heat equation on a structured 2 dimensional rectangular grid. The value of the temperature of a particular grid point is updated based on the current values of the temperature at the four surrounding grid points in an iterative fashion with the temperatures at the grid boundary kept constant.

## Implementation

Host side:
* Initializes the input grid and distributes it among the device side cores
* When device signals completion of execution, host reads the output grid from each core and creates the final result

Device side:
* Receives the input grid from the host and performs a 5-point stencil computation
* Stencil computation written in hand-tuned assembly code using the Epiphany Instruction set
* The computation is performed for a fixed number of iterations
* Boundary grid points are transferred to each of the 4 neighbouring cores using DMA in each iteration

Further details of implementation can be found in: http://arxiv.org/abs/1410.8772

Tested on the Epiphany-IV evaluation module

## Building

Configure the parameters (defaults are for Epiphany-III) accordingly in src/defs.h and run:

```bash
$ ./build.sh
```

## Usage

```bash
$ ./run.sh
```

Output grid will be written to output/

## License

GPL v3

## Author

Contributed by Anish Varghese, Bob Edwards
