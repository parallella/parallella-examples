# parallella-examples

Community created example Parallella projects.

## Contents

* aobench/ - A small ambient occlusion renderer for benchmarking real world floating-point performance
* blobubska/ - A real-time ray tracing visual music generator
* IO_pins/ - Example programs for using the Parallella's IO Pins, examples include GPIO writes/reads, Bit Banged SPI, and I2C
* john/ - John the Ripper password cracker with Parallella support
* kinect_test - Program for MS Kinect that uses Epiphany to colorize, scale and render
* lena/ - Image processing example that uses the DevIL library to filter noise
* mandelbrot/ - Calculating the mandelbrot set and rendering it to the frame buffer in real-time
* para-para/ -  Example that shows how to run a simple "hello world" app with OpenMP, MPI and OpenCL
* r-opencl/ - Vector addition from within the R programming language via OpenCL

### Moved

* xtemp/ - this is now in the [parallella-utils repository](https://github.com/parallella/parallella-utils).

## Contributing

Contributions to this repository are welcomed.

To submit a project for inclusion:

1. Fork this repository
2. Create a new sub-directory 
3. Add your project files and ensure the headers state GPL, BSD, MIT, or Apache license
4. Add a README.md file (see the .skeleton directory for a template)
5. Submit a pull request

### Note

* The project must build, run and serve as a useful example
* Basic documentation must be included, e.g. dependencies, building and use
* Only GPL (v2 or later), BSD, Apache, and MIT licensed code will be accepted
