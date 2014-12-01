# Parallella SPI Bit Bang Library examples

## Demo Video

Work in Progress

## Implementation

* All examples are using the Porcupine breakout board to break out the GPIO and PMOD connector. The SPI devices used can be found here (http://www.maximintegrated.com/en/design/design-technology/fpga-design-resources/pmod-compatible-plug-in-peripheral-modules.html)

* Each Program is set to use pin 54 for SS, 55 for MOSI, 56 for MISO, and 57 for CLK in software. This corresponds with the PMOD pins on the Porcupine breakout board, and correctly follows the PMOD SPI standard. To translate the pin numbers written on the porcupine breakout board into what they are called in software, simply add 54 (ex. pin 0 on the Porcupine board is pin 54 in the GPIO/SPI library).
 

## Building

System requirements:

* [Parallella board Gen 1.1 or later](http://www.parallella.org/)
* Parallella Official Ubuntu
* Parallella Porcupine Board (or some way to break out IO pins)


Download required libraries:

    The GPIO and SPI library can be found here: https://github.com/parallella/parallella-utils.

NOTE: AS OF 11/26/14 THE CURRENT PARALLELLA MASTER REPOSITORY DOES NOT HAVE THE UPDATED SPI LIBRARY THAT PATCHES THE BUG WHEN COMMUNICATING WITH SPI DEVICES THAT READ ON THE SECOND CLOCK EDGE. 
UNTIL THESE CHANGES GET INCORPORATED INTO THE MASTER REPO, THESE EXAMPLE PROGRAMS WILL NOT WORK. INSTEAD, PLEASE USE MY UPDATED VERSION, WHICH CAN BE FOUND HERE: https://github.com/wizard97/parallella-utils.

Compiling Code (assuming ProgramName.cpp is in the same directory as the parallella-utils you downlaoded earlier)
	$ gcc -o [OutputName] [ProgramName].cpp para_spi.cpp para_gpio.cpp para_gpio.c -lstdc++ -Wall


##Usage

* See comments at the beginning of each example for explanation on what each program does, what perepheral it is using, and how to connect it.

* Program must be run with root shell to access IO pins, run with:
	$ sudo ./[ProgramName]


Feel free to email me with any questions

## License
BSD


## Author

(c) Aaron Wisner (aaronwisner@gmail.com)

December 1, 2014
