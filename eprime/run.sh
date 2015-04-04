#!/bin/bash

set -e

PRIMES_PER_CORE=10000000000


./prime.elf ${PRIMES_PER_CORE}

