#!/bin/bash

#######################################################
#WARNING: HACK!
#Execute "su -" to get around the permissions problem
#######################################################

pin=$1
value=$2
base=906
offset=54
let syspin=$pin+$base+$offset
chip=gpiochip906
echo $syspin >  /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$syspin/direction
echo $value  | sudo tee /sys/class/gpio/gpio$syspin/value


