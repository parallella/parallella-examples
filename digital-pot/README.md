# Parallella SPI Bit Bang Library Examples

## Demo Video/Tutorial

[Watch on YouTube!](https://www.youtube.com/watch?v=4iSA1yNHykU)

## Implementation

* All examples are using the Porcupine breakout board to break out the GPIO  
and PMOD connector. The SPI devices used can be found here  
(http://www.maximintegrated.com/en/design/design-technology/fpga-design-resources/pmod-compatible-plug-in-peripheral-modules.html)

* Each Program is set to use pin 54 for SS, 55 for MOSI, 56 for MISO, and 57  
for CLK in software. This corresponds with the PMOD pins on the Porcupine  
breakout board, and correctly follows the PMOD SPI standard. To translate  
the pin numbers written on the porcupine breakout board into what they are  
called in software, simply add 54 (ex. pin 0 on the Porcupine board is pin 54  
in the GPIO/SPI library).
 

## Building

System requirements:

* [Parallella board Gen 1.1 or later](http://www.parallella.org/)
* Parallella Official Ubuntu
* [Parallella Porcupine Board](http://www.digikey.com/product-detail/en/ACC1600-01/1554-1003-ND/5048176) (or some way to break out IO pins)


Download required libraries:

* [The GPIO and SPI library](https://github.com/parallella/parallella-utils.)

NOTE: As of 11/26/14 the current Parallella master repository does not have  
the updated SPI library that patches the bug when communicating with SPI  
devices that read on the second clock edge.  Until these changes get  
incorporated into the master repo, these example programs will not work.  
Instead, please use my updated version, which can be found [here](https://github.com/wizard97/parallella-utils.)


Compiling Code (assuming ProgramName.cpp is in the same directory as the  
parallella-utils you downlaoded earlier)
```bash
$ ./build.sh
```

##Usage

* See comments at the beginning of each example for explanation on what  
each program does, what perepheral it is using, and how to connect it.

* Program must be run with root shell to access IO pins, run with:
```bash
$ sudo ./[ProgramName]
```

Feel free to email me with any questions

## License
BSD


## Author

(c) Aaron Wisner (aaronwisner@gmail.com)

December 1, 2014
