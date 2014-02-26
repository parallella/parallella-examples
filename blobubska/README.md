# BLOBUBSKA

A Realtime Raytracing Visual Music Generator

[Demo Video](http://youtu.be/RHTZ3CLOlqw)

## Implementation

Host side:

* Controlling and synchronizing 16x eCores to parallelize the raytracing.
* Detecting the physical address of the frame buffer and telling it to the eCores.
* Generating random music

Device(Epiphany) side:

* The eCore N (1-16) calculates the row ((Y / 16) + N) and buffers it to the eCore local memory.
* DMAing the calculated data from the local memory to the frame buffer row by row.
* After rendering a frame, halting until interrupted by the host.

## Building

System requirements:

* [Parallella board Gen 1.1 or later](http://www.parallella.org/)
* Parallella Official Ubuntu
* Epiphany SDK 5 or later

Install dependent packages:

``sudo apt-get install libfluidsynth-dev fluidsynth fluid-soundfont-gm alsa-base alsa-utils libasound2-plugins``

Switch to TTY by pressing Ctrl + Alt + F2, then login. (Return to X Window: Ctrl + Alt + F7)

``cd blobubska/src``

``make``

## Usage

``./run.sh``

Quit: Escape Key

Mode switching (Generator Mode <-> Play Mode): Enter Key

(Play Mode)

Note:
Q W E ... I O P
A S D ... J K L

Scale change: 1 - 8

Instrument Change: Z X C ... B N M

All note off: Space Key

## License

BSD 3-Clause license

## Author

[Shodruky Rhyammer](https://github.com/shodruky-rhyammer)
