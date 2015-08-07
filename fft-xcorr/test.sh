#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")

usage() {
	echo "Simple correlation test script"
	echo
	echo -e "\tUsage: $0 REFIMG DIRECTORY"
	echo
	echo -e "\tExample: $0 lfw/AJ_Cook/AJ_Cook_0001.jpg lfw"
	echo
	exit 1
}

test_one() {
	$EXEPATH/test-fftw $1 $2 | tail -n1 || exit 1
}

if ! [ -e $EXEPATH/test-fftw ]; then
	echo "You need to 'make IMPL=fftw'"
	exit 1
fi

if ! [ -e $EXEPATH/test-dataset-fftw ]; then
	echo "You need to 'make IMPL=fftw'"
	exit 1
fi

[ $# = 2 ] || usage

ref=$1
dir=$2

if ! [ -e $ref ]; then
	echo "$ref: No such file"
	exit 1
fi

if ! [ -d $dir ]; then
	echo "$dir: No such directory"
	exit 1
fi


tmpfile=$(mktemp)
find $dir -type f -iname "*.jpg" | sort > $tmpfile

echo Correlation,ImageA,ImageB
test_one $ref $ref
$EXEPATH/test-dataset-fftw $ref $tmpfile

rm $tmpfile
