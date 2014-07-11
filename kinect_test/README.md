# Kinect Test

Kinect depth sensor test program

## Demo Video

[Demo Video](http://youtu.be/cVTc5PzMpPg)

## Implementation

Host side:

* Controlling and synchronizing an eCore
* Managing frame-buffer, libfreenect
* Transfer depth data to emem

Device(Epiphany) side:

* Get the depth data from emem
* Colorize, scale, render the depth data
* After rendering a frame, halting until interrupted by the host.

## Building

System requirements:

* [Parallella board Gen 1.1 or later](http://www.parallella.org/)
* Parallella Official Ubuntu
* Epiphany SDK 5 or later
* Kinect sensor (XBOX360 version)
* [libfreenect](http://openkinect.org/wiki/Main_Page)

Install dependent packages:

    sudo apt-get update

    sudo apt-get install git-core cmake freeglut3-dev pkg-config build-essential libxmu-dev libxi-dev libusb-1.0-0-dev nano

Install libfreenect

    git clone git://github.com/OpenKinect/libfreenect.git

    cd libfreenect

    mkdir build

    cd build

    cmake -L ..

    ########
    # For some newer Kinect models, audio must be enabled for tilt and LED control:
    # cmake -L .. -DBUILD_AUDIO=ON
    ########

    make

    sudo make install

    sudo ldconfig /usr/local/lib

    sudo nano /etc/udev/rules.d/51-kinect.rules

Copy, Paste and Save

    # ATTR{product}=="Xbox NUI Motor"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02b0", MODE="0666"
    # ATTR{product}=="Xbox NUI Audio"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ad", MODE="0666"
    # ATTR{product}=="Xbox NUI Camera"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ae", MODE="0666"
    # ATTR{product}=="Xbox NUI Motor"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02c2", MODE="0666"
    # ATTR{product}=="Xbox NUI Motor"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02be", MODE="0666"
    # ATTR{product}=="Xbox NUI Motor"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02bf", MODE="0666"

    sync

    sudo reboot

Switch to TTY by pressing Ctrl + Alt + F2, then login. (Return to X Window: Ctrl + Alt + F7)

    cd kinect_test

    make

    ./run.sh

It may fail first time, try again.

Quit: Ctrl + C

## License

BSD 3-Clause license

## Bookmarks

[Parallella](http://www.parallella.org/)

## Special Thanks

Thank you very much for your interest and advices.

Adapteva / 

## Author

(c) Shodruky Rhyammer

since July 11, 2014
