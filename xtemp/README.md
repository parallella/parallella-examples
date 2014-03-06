# XTemp

Reads the XADC on-chip temperature measurement for the Zynq chip, and
displays the results as a graph.

## Implementation

* Reads special file objects located in /sys/bus/iio/devices/iio:device0/ to
capture ADC measurements

* Other files in that location report static gain & offset values

* These numbers are combined to calculate the current core temperature

* Uses basic Xlib to create a graphical window with the temperature history

* Captures the 'q' key to quit, or just close the window.

## Building

System requirements:

* Parallella board Gen 1.1 or later
* Official Ubuntu and X environment

Download and unzip,

``% cd THE_PATH``

``% make``

## Usage

``% ./xtemp``

## License

BSD 3-clause License

## Author

[Fred Huettig](mailto:Fred@Adapteva.com)

