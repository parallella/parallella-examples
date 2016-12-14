Community created example Parallella projects.
===================================================

NAME                             | CONTENT                                          | Builds | Works |
---------------------------------|--------------------------------------------------|--------|-------|
[actors_dct2d](actors_dct2d)     | Actor based 2D DCT                               | YES | YES? |
[aobench](aobench)               | Ambient occlusion renderer                       | ?   | NO |
[blobluska](blobluska)           | Real-time ray tracing visual music generator     | ?   | ?  |
[dac-wavegen](dac-wavegen)       | Sine/sawtooth waveform generator using I2C DAC   | ?   | ?  |
[digital-pot](digital-pot)       | LED fader using 8-bit digital potentiometer      | ?   | ?  |
[ebsp-hello](ebsp-hello)         | "Hello world!" example using Epiphany BSP        | YES | YES |
[epython](epython)               | Write Python code to run on the Epiphany         | YES | YES |
[mpi-fft2d](mpi-fft2d)           | Threaded MPI to implement a 2D FFT for Epiphany  | ?   | ?  |
[eprime](eprime)                 | Testing for prime numbers using Epiphany         | YES | YES |
[fft-xcorr](fft-xcorr)           | 2D image correlator demo                         | ?   | ?  |
[game-of-life](game-of-life)     | Conway's game of life, each eCore is a cell      | YES | YES |
[heat_stencil](heat_stencil)     | 5-point star shaped heat equation stencil        | ?   | ?  |
[john](john)                     | JohnTheRipper password cracker for Parallella    | YES | YES |
[kinect_test](kinect_test)       | Kinect demo that uses Epiphany                   | ?   | ?  |
[lena](lena)                     | 2D FFT based filter running on Epiphany          | YES | YES |
[mandelbrot](mandelbrot)         | Real time Mandelbrot zoomer                      | YES | NO |
[assembly-opt](assembly-opt)     | Assembly optimized matrix multiplication         | YES | NO |
[mini-nbody](mini-nbody)         | Nbody simulation                                 | ?   | ?  |
[motion-cap](motion-cap)         | Motion capture camera project for Parallella     | ?   | ?  |
[nbody_mpi](nbody_mpi)           | Nbody example using the Epiphany MPI             | ?   | ?  |
[omp4-epiphany](omp4-epiphany)   | OpenMP4.x examples where Epiphany is a device    | YES | YES |
[para-para](para-para)           | "hello world" apps in OpenMP, MPI and OpenCL     | YES | YES |
[paralle2](paralle2)             | Pseudo Eternity II solver                        | YES | NO |
[pi-machin-like](pi-machin-like) | Approximation of π using machin-like formula     | YES | YES |
[riecoin](riecoin)               | Riecoin miner                                    | YES | NO? |
[r-opencl](r-opencl)             | R with OpenCL running on Parallella              | ?   | ?  |
[rpi-camera](rpi-camera)         | Raspberry pi camera module bounty project        | ?   | ?  |
[slides](slides)                 | Creating slide decks from Markdown               | N/A | N/A |
[sobel](sobel)                   | Sobel filter example                             | ?   | ?  |
[vfft](vfft)                     | Very fast FFT for the Epiphany core              | YES | YES |
[raymarch](raymarch)             | Raymarching OpenCL framework with examples       | YES | YES |

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
