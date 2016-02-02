#!/bin/bash

# take as param the chunk number
if [ $# -lt 2 ]
  then
    echo "Usage ./speedup.sh <iterations number> <k>"
    exit 0
fi

M=$1
OUT="stats_speedup_$k_$M.csv"
k=$2

echo -e "Main it\tSub it\tNb Cores"
for ((i=1;i<=16;i++));
do
  N=$(( $k * $i ))
  n=$(( $M / $N ))
  echo -e "$N\t$n\t$i"
  (echo -e "$i," $(./main.elf $N $n $i)) >> $OUT
done
