# Parallella Motion Triggered Image Capture Program

## Demo Video

Work in Progress.

## Implementation

* This is a project that uses the Parallella to alert you when it detects motion. 

* Using the IO pins, the Parallella waits until a motion sensor triggers. It then will take a picture using a USB webcam, sound an alarm, send you an email of the picture, and finally upload the image to a nice looking image gallery it is hosting on an Apache webserver. You can access this image gallery anywhere in the world with a simple browser to view and/or download the captured images.


**This project basically consists of two parts:**

* The motion.cpp program which is responsible for polling the motion sensor, capturing and saving the image, sounding the alarm, and sending the email. I wrote the code using OpenCV, a SMTP email class that supports SSL, and the Parallella's GPIO library. This part of the program is written in C++;

* The html folder (whose contents should be in the root directory of your Apache webserver). The motion.cpp program will save images it captures into the /captures folder, and then when a request comes to view the webpage, the index.php program will render the image gallerly webpage (including the images). I did not create the entire image gallery, I just added the functionality using PHP by modifying a free HTML template (see sources). This part contains CSS, Java Script, HTML, and PHP. 



**Required/Suggested Materials:**

* [A Parallella](http://www.parallella.org/)
* [Parallella Porcupine Board](http://www.digikey.com/product-detail/en/ACC1600-01/1554-1003-ND/5048176) (or some way to break out IO pins)
* Female header jumpers for GPIO on the Parallella
* A motion sensor (the cheap kind off eBay that write a pin high when it detects motion)
* Some sort of alarm. Ex: LED, Piezo buzzer, Buzzer, Doorbell. 
* If alarm is not at 2.5V (10 mA max) or 5V (0.5A max), a power supply for the alarm as well.
* If using an alarm other than the LED, a logic level mosfet or small signal transistor (depending on current requirements of alarm)
* A flyback diode if alarm is electro mechanical
* a Linux compatible webcam
* A USB OTG adapter
* Some resistors



**Hardware Connections:**

* GPIO 0: Output to alarm/transistor for alarm 
* GPIO 1: Input from motion sensor. Make sure input is at a max of 2.5V, make a voltage divider if neccisary. Since motion sensor outputs 3.3V, a 1K and 3.3K resitor as a divider should suffice.
* GND: Connected to motion sensor GND, and alarm GND
* 50: This pin is on connector J2 on the porcupine breakout board, it should be 5V. Connect this to VCC on your motion sensor.
* USB: Plug in OTG cable and connect webcam. Make sure camera is detected by seeing if /dev/video0 exists.


## Building

**System requirements:**
* [Parallella board Gen 1.1 or later](http://www.parallella.org/)
* Parallella Official Ubuntu


**We have a ton of dependencies:**
* [OpenCV](https://github.com/Itseez/opencv)
* [OpenSSL](https://github.com/openssl/openssl)
* [LAMP Server](https://help.ubuntu.com/community/ApacheMySQLPHP)
* [C++ SMTP Client with SSL](http://www.codeproject.com/Articles/98355/SMTP-Client-with-SSL-TLS)
* [Parallella GPIO Library](https://github.com/parallella/parallella-utils)

**Note:**
* Fortunately for you, I already included a modified version of the SMTP client (CSmtp.cpp) and its dependencies (base64.cpp and md5.cpp). I also included the Parallella GPIO Library (para_gpio.c).
* Unfortunately for you, your going to have to build OpenCV which is by far the worst. This takes several hours to build.




### Building OpenCV:

**First we need all of its dependencies:**
```bash
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install build-essential cmake pkg-config
$ sudo apt-get install libtiff4-dev libjpeg-dev libjasper-dev libpng12-dev
$ sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
```

We probably don't need all this, but better to be safe than sorry:
```bash
$ sudo apt-get -qq install build-essential checkinstall cmake pkg-config yasm libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev python-dev python-numpy libtbb-dev libqt4-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils
```

Now lets download the source code and build. Warning: this will take forever (3+ hours to build):
```bash
$ cd ~/Desktop
$ git clone https://github.com/Itseez/opencv.git
$ cd opencv/
$ mkdir build && cd build
$ cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_CUDA=OFF -D WITH_CUFFT=OFF -D WITH_CUBLAS=OFF -D WITH_NVCUVID=OFF -D WITH_OPENCL=OFF -D WITH_OPENCLAMDFFT=OFF -D WITH_OPENCLAMDBLAS=OFF -D ENABLE_NEON=on ..
$ make
$ sudo make install
$ sudo ldconfig
```

### Installing OpenSSL:

Now onto OpenSSL, which we need for sending emails:
```bash
$ sudo apt-get install libssl-dev openssl
```

### Setting up LAMP:


Finally, set up our LAMP server with:
```bash
$ sudo apt-get install lamp-server^
```

When prompted, make a password for your MySQL account (we won't be using it anyways).



Now we can finally download my program and compile it. Let's just clone the [parallella-examples repo](https://github.com/parallella/parallella-examples). Even though we will only be using the motion-cap folder, there are many other cool projects in there you should check out.
```bash
$ cd ~/Desktop
$ git clone https://github.com/parallella/parallella-examples.git
```

The program will look to save the images in a folder called "captures/" on your Desktop, and a folder in "/var/www/html/captures". The latter already exists in my repo, but we must make the former for your Desktop.
```bash
$ mkdir captures
```

We need to move all the needed files into our Apache webserver, and remove the default file.
```bash
$ sudo rm /var/www/html/index.html
$ cd parallella-examples/motion-cap
$ sudo cp -r html/. /var/www/html/
```
Check to make sure your webserver works, by going to any browser in your LAN, and typing in the Parallella's IP Address. Ex: http://192.168.1.19. If it worked you should see a webpage with a bunch of Parallella logos.


**We can finally compile my program:**
```bash
$ cd ~/Desktop/parallella-examples/motion-cap/motion/
$ g++ -o motion motion.cpp para_gpio.c CSmtp.cpp md5.cpp base64.cpp `pkg-config --static --cflags --libs opencv` -lssl -lcrypto
```

You will see a few warning messages (not from my code, from the SMTP client code), but it should compile fine. 



##Usage

You should have an executable in ~/Desktop/parallella-examples/motion-cap/motion/ called "motion".


**If you done want to send an email, run the program like this:**
```bash
$ sudo ./motion
```


**To send the picture to an email also, run the program like this:**
```bash
$ sudo ./motion <SSL SMTP Server Address> <Port for SSL> <Username> <Pass> <Sender Address> <Recipient Address>
```


For example, I created a gmail acount for my Parallella to use. It will send emails to my email (aaronwisner@gmail.com)
```bash
$ sudo ./motion smtp.gmail.com 465 linaroparallella parallellapass linaroparallella@gmail.com aaronwisner@gmail.com
```


**Important Note:**
* With gmail, it will not work unless you tell gmail to allow less secure Apps to connect.
* You can configure that [here](https://www.google.com/settings/security/lesssecureapps).


**How it should work:**
* When the motion sensor detects motion and writes pin 1 (our input) High, the program should say "Motion Detected!"
* After a second or so it should say "Image # Captured!"
* The image will be saved in ~/Desktop/captures and /var/www/html/captures with the name "capture_(number)"
* Now depending on your internet, a second or so later it should finish sending the email, and say "Email Sent!"
* Now it will write the alarm pin (Pin 0) High for 3 seconds.
* It will repeat this proceadure every time it detects motion



**Looking at the pictures:**
* Any pictures captured should also be in the specefied recepients email inbox. 
* You can also view and download the images from the gallary the Parallella is now hosting on its Apache webserver we set up
* To do this, go into any browser on your LAN and type in your Parallella's IP address. You should see all the recent images on a nice pretty webpage format



**Pro Tip (if you wan't to use this for real security purposes):**
* As of right now our Parallella's webserver only accesable when your connected in the same LAN
* You can view this webpage (your Parallella's hosting) anywhere in the world, relativley easily
* You will need to port forward port 80 to you Parallella on your router (if you ISP blocks port 80, use another port like 8080). Google how to portforward for your router model.
* If your ISP doesn't give you a static IP, you will probably need to setup a DDNS. There are many free options (google it)
* Now, you should be able to acces your Parallella webserver anywhere in the world. Just go into any web browser outside your LAN and type in your network's WAN IP address, or if using a DDNS type in the name you chose.
* You should see that same image gallerly hosted by your Parallella.



I hope you enjoyed this!

Feel free to email me with any questions

Aaron Wisner

## License
BSD


## Author

(c) Aaron Wisner (aaronwisner@gmail.com)

December 6, 2014
