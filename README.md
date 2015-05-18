#Parallella FFT cross-correlation demo

##TODO

* Do calculations on device.
* Use FFT to calculate correlation.
* Don't reinitialize COPRTHR on every call to xcorr().


##Generate data set
Labeled Faces in the Wild

```
which mogrify || sudo apt-get install -qq imagemagick imagemagick-common
wget http://vis-www.cs.umass.edu/lfw/lfw.tgz
tar xfz lfw.tgz
cd lfw
find . -type f -exec mogrify -gravity southwest -background black \
	-extent 256x256 -resize 128x128 -colorspace Gray '{}' ';'
```

##Build program and library

```
make
```
