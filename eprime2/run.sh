#!/bin/bash

set -e

PRIMES_PER_CORE=""

if [ $# -lt 1 ]; then
	echo "Usage:  ./run.sh numberic-value"
	exit 1
else
	if [[ ! "$1" =~ ^[0-9]+$ ]]; then
		echo "ERROR:  value must be numeric"
		echo "Usage:  ./run.sh numberic-value"
		exit 1
	else
		PRIMES_PER_CORE=$1
	fi
fi

time bin/prime.elf ${PRIMES_PER_CORE}

