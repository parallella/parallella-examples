# Matrix Multiplication

Parallel Matrix multiplication of two matrices following Cannon's algorithm

## Implementation

Implementation is based on the examples provided by Adapteva

Host side:
* Initializes the operand matrices and transfers it to the shared memory
* When device signals completion of execution, host reads the result matrix from shared memory 

Device side:
* Reads the operand matrices from the shared memory and distributes it among all the device side cores
* Per-core matrix multiplication code written in hand-tuned assembly code using the Epiphany Instruction set
* Cannon's algorithm is used for allocation of blocks of operand matrices to the cores and the blocks are rotated around rows and columns of cores
* For block sizes less than 32 x 32, double buffering is used. For blocks of size 32 x 32, an alternate buffering scheme is implemented due to limited per-core memory

Further details of implementation can be found in: http://arxiv.org/abs/1410.8772

Tested on the Epiphany-IV evaluation module

## Building

Single-core version

Configure the parameters accordingly in src/defs.h and run:

```bash
$ make single
```
Multi-core version

Configure the parameters accordingly in src/defs_multi.h and run:

```bash
$ make multi
```

## Usage

Single-core version

```bash
$ ./run.sh
```
Multi-core version

```bash
$ ./run_multi.sh
```

Result matrix will be written to output/

## License

GPL v3

## Author

Contributed by Anish Varghese
(Built upon example code by Yaniv Sapir)
