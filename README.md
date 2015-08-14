# parallella-examples

Community created example Parallella projects.

## Contents
NAME                         | CONTENT  
---------------------------- |-------------------------------
[aobench](aobench)           | An ambient occlusion renderer  
[blobuska](blobuska)         | A real-time ray tracing visual music generator  
[dac-wavegen](dac-wavegen)   | A sine and sawtooth waveform generator using an I2C DAC  
[digital-pot](digital-pot)   | Fading an LED using an 8-bit digital potentiometer  
[mpi-fft2d](mpi-fft2d)       | Threaded MPI to implement a 2D FFT for Epiphany  
[eprime](eprime)             | Testing for prime numbers using Epiphany  
[fft-xcorr](fft-xcorr)       | A 2D image correlator demo using fast convolution (FFT)  
[heat_stencil](heat_stencil) | 5-point star shaped stencil for solving heat equation  
[john](john)                 | John the Ripper password cracker with Parallella support    
[kinect_test](kinect_test)   | Kinect demo that uses Epiphany to colorize/scale image  
[lena](lena)                 | 2D FFT based filter running on Epiphany  
[mandelbrot](mandelbrot)     | A real time Mandelbrot zoomer  
[assembly-opt](assembly-opt) | Assembly optimized parallel matrix multiplication  
[mini-nbody](mini-nbody)     | Nbody simulation  
[motion-cap](motion-cap)     | Turning the Parallella into a motion capture camera   
[nbody_mpi](nbody_mpi)       | Nbody example using the Epiphany MPI  
[para-para](para-para)       | "hello world" apps in OpenMP, MPI and OpenCL  
[riecoin](riecoin)           | A riecoin miner  
[r-opencl](r-opencl)         | An example showing R with OpenCL running on Parallella  
[rpi-camera](rpi-camera)     | Drivers and implementation of raspberry pi camera module    
[slides](slides)             | Example showing how to crate presentation from Markdown   
[sobel](sobel)               | A sobel filter demo application using the PAL sobel function  
[vfft](vfft)                 | A very fast FFT for the Epiphany core  

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
