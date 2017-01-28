#!/bin/bash

set -e

BENCH_INDEX=""

if [ $# -lt 1 ]; then
	echo "Usage:  ./run.sh numberic-value"
	exit 1
else
	if [[ ! "$1" =~ ^[0-9]+$ ]]; then
		echo "ERROR:  value must be numeric"
		echo "Usage:  ./run.sh numberic-value"
		exit 1
	else
		BENCH_INDEX=$1
	fi
fi

time bin/e2g.elf ${BENCH_INDEX}

