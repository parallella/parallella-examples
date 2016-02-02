#!/bin/bash

# take as param the number of iterations
if [ $# -eq 0 ]
  then
    echo "Usage ./stats_chunck.sh <iteration number>"
    exit 0
fi

IT=$1

for ((i=0;i<=$IT;i++));
do
  for ((j=0;j<=$IT;j++));
  do
    echo "($(($i*$i*$i)),$(($j*$j*$j)))"
    ./main.elf $(($i*$i*$i)) $(($j*$j*$j)) >> stats.csv
  done
  echo "" >> stats.csv
done
