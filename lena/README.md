# Image processing example that filters noise

This program demonstrates the use of the Epiphany on the Parallella computer for image processing. The package includes a noise-imposed image, "lenna.jpg". By default, the program loads this image, and filters the high-frequency noise, generating a clean file "lenna.lpf.jpg". For reference, the resulting image is "lenna.lpf.ref.jpg".

## Implementation

The program uses the DevIL library for reading and writing the image file from/to the storage. After reading the file, the pixel data is extracted and loaded to the Epiphany, where the filter program is running.

## Building and usage

To install DevIL on Linux, type:

```bash
$ sudo apt-get install libdevil-dev
$ sudo apt-get install libdevil1c2
```

Timing measurements of the various parts are displayed after the calculation concludes.

For performance reference, an implementation of 2D-FFT transform of the same size is provided. The reference utilizes the FFTW library, which is considered a best-in-class library for DFT calculations. We used an ARM port for the FFTW. This version can be found here:

http://www.vesperix.com/arm/fftw-arm/source/index.html

For reference on the FFTW library, read:

http://www.fftw.org

```bash
$ sudo apt-get install fftw3 fftw3-dev
```

## License

GPL v3

## Author

Contributed by Yaniv Sapir.
Copyright 2012, 2014 Adapteva, Inc.
