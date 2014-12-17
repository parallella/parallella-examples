# Parallella I2C DAC Signal Generator

## Demo Video

[Finally finished Youtube tutorial!](http://youtu.be/146GBR_I6ko)

## Implementation


* This is a I2C DAC signal generator example using the Parallella's built in  
hardware I2C support through the Linux I2C driver. It can generate either  
a sawtooth waveform or sine wave. 

* User can select how many steps for each wave, which will increase the   
precision (at the expense of frequency). Using the least amount of steps (1  
step per quarter period), waveforms max out around 600Hz. 

* The Porcupine breakout board breaks out the Parallella's SDA and SCL I2C   
lines. A 12 bit MAXIM Integrated PMOD 8 channel digital DAC is used in this   
example (http://datasheets.maximintegrated.com/en/ds/MAX5825PMB1.pdf).  
Note, this is an 8 channel DAC, but only channel 0 is used.

ADC Connections:

* VDD: 5V output pin on Porcupine board (Note: I2C logic on Parallella is at 5V).
* SCL: Parallella's I2C SCL
* SDA: Parallella's I2C SDA
* GND: Parallella's Ground
* REF: Tied to your analog reference, in this example it's tied to VDD (5V)
* DAC0: Signal Output (To Oscilloscope or load)

* Note: To learn more about using I2C with Linux or learn about more advanced  
features, look [here](http://elinux.org/Interfacing_with_I2C_Devices).

## Building

System requirements:

* [Parallella board Gen 1.1 or later](http://www.parallella.org/)
* Parallella Official Ubuntu


Required/Suggested Materials:

* [Parallella Porcupine Board](http://www.digikey.com/product-detail/en/ACC1600-01/1554-1003-ND/5048176) (or some way to break out IO pins)
* 12 bit DAC (http://datasheets.maximintegrated.com/en/ds/MAX5825PMB1.pdf)
* Female header jumpers to connect DAC to Parallella
* Something to look at waveform: Oscilloscope, Computer Soundcard, Small  
Speaker, LED, etc... 

Important note:
Do not directly connect the DAC output to a speaker/pair of headphones. Due  
to the nature of DAC's the signal has a 2.5V DC offset, that could easily  
damage your speakers/headphones. If you wish to safely connect the output to  
such devices, a coupling capacitor in series with the output must be used to  
block any DC voltage (this will shift the center of the waveform back to 0V).  
Due to the low frequency of the output, a larger electrolytic capacitor should  
be used, so it doesn't act too much like a high pass filter and attenuate the  
signal. Hook the positive lead of the capacitor to the DAC output and the GND  
lead to the input of your speakers/headphones. To pick a proper size capacitor,  
the reactance introduced by the coupling capacitor can be calculated with  
X = 1/(2*pi*f*C), where x is  (ohms), f is signal frequency (Hz), and C is  
capacitance (Farads). The lower the input impedance of your load is, the larger  
the coupling capacitor must be.


Compile with:

```bash
$ gcc -std=c99 dac-wavegen.c -o dac-wavegen -lm
```

##Usage

* Program must be run with root shell to access IO pins, run with:
```bash
$ sudo ./dac-wavegen
```
* Adjust frequency by changing steps per quarter period.
* For those of you who play an instrument, just by coincidence, selecting a  
sine wave with 1 step per quarter period will produce a crude sine wave at ~587Hz  
(an almost perfect D Natural)


* See the pics folder for oscilloscope pictures!

Feel free to email me with any questions

## License
BSD


## Author

(c) Aaron Wisner (aaronwisner@gmail.com)

December 6, 2014
