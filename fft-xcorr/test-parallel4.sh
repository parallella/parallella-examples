#!/bin/bash
trap 'j=$(jobs -p); [ "x$j" = "x" ] || kill $j >/dev/null 2>&1' EXIT

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


tmpdir=$(mktemp -d)

find $dir -type f -iname "*.jpg" | sort > $tmpdir/all
split -n l/4 --numeric-suffixes=1 --suffix-length=1 $tmpdir/all $tmpdir/set

echo Starting. No output until program finishes. Stay tuned... >/dev/stderr

$EXEPATH/test-dataset-fftw $ref $tmpdir/set1 > $tmpdir/out1.txt &
$EXEPATH/test-dataset-fftw $ref $tmpdir/set2 > $tmpdir/out2.txt &
$EXEPATH/test-dataset-fftw $ref $tmpdir/set3 > $tmpdir/out3.txt &
$EXEPATH/test-dataset-fftw $ref $tmpdir/set4 > $tmpdir/out4.txt

wait

echo Correlation,ImageA,ImageB
test_one $ref $ref
cat $tmpdir/out1.txt $tmpdir/out2.txt $tmpdir/out3.txt $tmpdir/out4.txt

rm -rf $tmpdir
