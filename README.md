Community created example Parallella projects.
===================================================

NAME                             | CONTENT                                          | Verified |
---------------------------------|--------------------------------------------------|:--------:|
[actors_idct2d](actors_idct2d)   | Actor based 2D inverse DCT                       | YES      |
[aobench](aobench)               | Ambient occlusion renderer                       | YES      |
[blobluska](blobluska)           | Real-time ray tracing visual music generator     | [1]      |
[dac-wavegen](dac-wavegen)       | Sine/sawtooth waveform generator using I2C DAC   | [2]      |
[digital-pot](digital-pot)       | LED fader using 8-bit digital potentiometer      | [2]      |
[ebsp-hello](ebsp-hello)         | "Hello world!" example using Epiphany BSP        | YES      |
[epython](epython)               | Write Python code to run on the Epiphany         | YES      |
[mpi-fft2d](mpi-fft2d)           | Threaded MPI to implement a 2D FFT for Epiphany  | [3]      |
[eprime](eprime)                 | Testing for prime numbers using Epiphany         | YES      |
[eprime2](eprime2)               | Testing for prime numbers using Epiphany         | YES      |
[fft-xcorr](fft-xcorr)           | 2D image correlator demo                         | [3]      |
[game-of-life](game-of-life)     | Conway's game of life, each eCore is a cell      | YES      |
[gdb-tutorial](gdb-tutorial)     | Epiphany multicore GDB debugging tutorial        | YES      |
[heat_stencil](heat_stencil)     | 5-point star shaped heat equation stencil        | YES      |
[john](john)                     | JohnTheRipper password cracker for Parallella    | YES      |
[kinect_test](kinect_test)       | Kinect demo that uses Epiphany                   |          |
[lena](lena)                     | 2D FFT based filter running on Epiphany          | YES      |
[mandelbrot](mandelbrot)         | Real time Mandelbrot zoomer                      |          |
[assembly-opt](assembly-opt)     | Assembly optimized matrix multiplication         | [4]      |
[mini-nbody](mini-nbody)         | Nbody simulation                                 | [3]      |
[motion-cap](motion-cap)         | Motion capture camera project for Parallella     | [1]      |
[nbody_mpi](nbody_mpi)           | Nbody example using the Epiphany MPI             | [3]      |
[omp4-epiphany](omp4-epiphany)   | OpenMP4.x examples where Epiphany is a device    | YES,[5]  |
[para-para](para-para)           | "hello world" apps in OpenMP, MPI and OpenCL     | YES,     |
[paralle2](paralle2)             | Pseudo Eternity II solver                        | YES      |
[pi-machin-like](pi-machin-like) | Approximation of π using machin-like formula     | YES      |
[riecoin](riecoin)               | Riecoin miner                                    |          |
[r-opencl](r-opencl)             | R with OpenCL running on Parallella              |          |
[rpi-camera](rpi-camera)         | Raspberry pi camera module bounty project        |          |
[simulator-tutorial](simulator-tutorial) | Epiphany multicore simulator tutorial    | YES      |
[slides](slides)                 | Creating slide decks from Markdown               | YES      |
[vfft](vfft)                     | Very fast FFT for the Epiphany core              | YES      |
[raymarch](raymarch)             | Raymarching OpenCL framework with examples       | YES      |

Footnotes:  
1: Need OH RX elink MMU remapping (or intermediate host buffer as workaround)  
2: Requires special hardware  
3: Requires COPRTHR MPI library compatible with ESDK 2016.3+  
4: Requires Epiphany-IV  
5: Except mandelbrot_omp, which requires 1  

## Contributing

Contributions to this repository are welcomed.

To submit a project for inclusion:

1. Fork this repository to your personal github account using the 'fork' button above
2. Clone your 'parallella-examples' fork to a local computer using 'git clone'
2. Create a new sub-directory at the root of the repo
3. Add your project files with the appropriate license clearly stated
4. Add a README.md file (see the .skeleton directory for a template)
5. Use git add-->git commit-->git push to add changes to your fork of 'parallella-examples'
6. Submit a pull request by clicking the 'pull request' button on YOUR github 'parallella-examples' repo.


### Note

* The project must build, run and serve as a useful example
* Basic documentation must be included, e.g. dependencies, building and use
* Only GPL (v2 or later), BSD, Apache, and MIT licensed code will be accepted
