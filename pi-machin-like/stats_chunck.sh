#!/bin/bash

# take as param the chunk number
if [ $# -lt 2 ]
  then
    echo "Usage ./stats_chunck.sh <start chunk> <end chunk>"
    exit 0
fi

A=$1
B=$2
OUT="stats_chunck_$A-$B.csv"

for((i=A;i<=B;i++))
do

  # Col
  for ((j=0;j<=i-1;j++));
  do
    i2=$(($i*$i*$i))
    j2=$(($j*$j*$j))
    echo "($i2,$j2)"
    ./main.elf $i2 $j2 >> $OUT
  done
  echo "" >> $OUT

  # Row
  for ((j=0;j<=i;j++));
  do
    i2=$(($i*$i*$i))
    j2=$(($j*$j*$j))
    echo "($j2,$i2)"
    ./main.elf $j2 $i2 >> $OUT
  done
  echo "" >> $OUT


done

C=$1
C2=$(($C-1)) # Prevents calculating the corner a second time
