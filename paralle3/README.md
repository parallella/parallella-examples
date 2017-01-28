# A 10x10 Eternity II solver

## Build and Run

#data BEFORE ; will create bin/bench.bin - a bunch of benchs

 ./build_data.sh
 ./run_data.sh

 ./build.sh
 ./run.sh value

 Wanting an assembly output ? Use ./buildasm.sh
 Cross compiling for an x86_64 platform ? You can use ./x86*.sh  
 
## Benchmarks

All programs are full C, sometimes with some assembly.
Mn/s/W = Million nodes per second per Watt


GPU OpenCL                      : not even a tenth of a modest x86 core with a Radeon 5770 graphics card. The numerous branches are a dead end, not to talk about the watts.
Parallella, one ARM A9 core     :    6 Mn/s ;   3.0 W ;  2    Mn/s/W
My high-end computer, one core  :  166 Mn/s ;  72.0 W ;  2.3  Mn/s/W ; x86_64, Fedora Core 23, i7 5820k
Raspberry Pi 3                  :                        8-10 Mn/s/W iirc ; A53, 4-core, 1.2 GHz
My high-end computer, 12 threads: 1470 Mn/s ; 140.0 W ; 10.0  Mn/s/W
Odroid XU4                      :  245 Mn/s ;  15.7 W ; 15.6 Mn/s/W ; 8-core ; deeply optimized, not much margin
Parallella 16-core Epiphany     :  103 Mn/s ;   5.0 W ; 20.6 Mn/s/W ; remove the Ethernet cable to earn 0.6 W due to ssh with the headless Parabuntu distro


So...
To my knowledge, Parallella is today the most energy-efficient platform for this highly recursive task...
although it does *not* use any float !

Eagerly waiting the 1024-core Epiphany V...

## Author

DonQuichotteComputers at gmail dot com
2017

## License

BSD-3 clause.

