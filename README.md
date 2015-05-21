#Parallella FFT cross-correlation demo

##TODO

* Do calculations on device.
* Use FFT to calculate correlation.
* Don't reinitialize COPRTHR on every call to xcorr().
* ??? jpeg: Remove hack that scales images down to < 64x64 (?)


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
Use this repo (epiphany-stable-1.6 branch):  
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
make
```
