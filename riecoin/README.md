# Riecoin miner test for parallella

Riecoin is an altcoin where the proof of work is finding a size 6 
constellation of prime numbers, that is 6 primes that are as close as possible.

This example is a test for the prime finder, suitable for stressing your
parallella.  If you actually want to find riecoins, take a look at
https://github.com/MichaelBell/fastrie

## Usage

Build with: ./build.sh

Single test: ./run.sh 

Range of tests: 

    ./run.sh <min trailing zeros> <max trailing zeros>

For example, "./run.sh 1200 1209" will run 10 tests, each test searching for 
primes one bit longer than the last.

## Notes

The prime sieve size should be suitable for 1000 or more trailing zeros.
Below that it still works fine, but it would be more efficient to reduce 
the size of the sieve so less time was spent in the sieving step.

Because the ARM cores start testing before the Epiphany has finished sieving,
the number of primes found will vary slightly from run to run.

## Attribution

Files from xptMiner are originally from jh00, with modifications by dga. 
Licensing for this is unclear.
The miner project is a fork of: https://github.com/dave-andersen/fastrie

Multiprecision arithmetic in the epiphany source is derived from GMP, so usage
is under the terms of the LGPL.

You are free to use the host to Epiphany interfacing code found in rh_riecoin.c
and the main functions of the e_*.c files for any purpose.
