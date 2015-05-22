#Parallella FFT cross-correlation demo

##TODO

* Do calculations on device.
* Use FFT to calculate correlation.
* Don't reinitialize COPRTHR on every call to xcorr().
* ??? jpeg: Remove hack that scales images down to < 64x64 (?)
* FFTW implementation


##Generate data set
Labeled Faces in the Wild

```
which mogrify || sudo apt-get install -qq imagemagick imagemagick-common
wget http://vis-www.cs.umass.edu/lfw/lfw.tgz
tar xfz lfw.tgz
cd lfw
find . -type f -exec mogrify -gravity southwest -background black \
	-extent 256x256 -resize 64x64 -colorspace Gray '{}' ';'
```

##Dependencies

###libjpeg

###COPRTHR
Use this repo (parallellocalypse branch):  
https://github.com/olajep/coprthr

```
./configure --enable-epiphany
make
sudo make install
```

This will install COPRTHR to `/usr/local/browndeer`

###COPRTHR-MPI
Binary here:  
http://www.browndeertechnology.com/code/bdt-libcoprthr_mpi-preview.tgz  

Blog post:  
https://www.parallella.org/2015/04/09/threaded-mpi-for-the-epiphany-architecture

##Build program and library

```
make IMPL=coprthr
```
or (TODO)  
```
make IMPL=fftw
```

This will generate a test program `test-IMPL` and a shared library
`libfft-demo-IMPL.so`. If you want to build for both targets, run once for
each implementation.

The library exports this xcorr function:
```c
bool calculateXCorr(uint8_t *jpeg1, size_t jpeg1_size,
		    uint8_t *jpeg2, size_t jpeg2_size,
		    float *corr)
```
