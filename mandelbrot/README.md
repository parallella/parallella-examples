# Mandelbrot

Calculating the mandelbrot set and rendering it to the frame buffer in realtime

## Implementation

Host side:

* Controlling and synchronizing 16x eCores to parallelize the calculation.
* Detecting the physical address of the frame buffer and telling it to the eCores.

Device(Epiphany) side:

* The eCore N (1-16) calculates the row ((Y / 16) + N) and buffers it to the eCore local memory.
* DMAing the calculated data from the local memory to the frame buffer row by row.
* After rendering a frame, halting until interrupted by the host.

## Building

System requirements:

* Parallella board Gen 1.1 or later
* Official Ubuntu and X environment
* Epiphany SDK 5 or later

Download and unzip,

Switch to TTY by pressing Ctrl + Alt + F2, then login. (Return to X Window: Ctrl + Alt + F7)

``% cd THE_PATH``

``% make``

## Usage

``% ./run.sh``

## License

BSD 3-clause License

## Author

[Shodruky Rhyammer](https://github.com/shodruky-rhyammer)
