/*
Copyright (c) 2014, Adapteva, Inc.
Contributed by Aaron Wisner (aaronwisner@gmail.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

  Neither the name of the copyright holders nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*

  dac-wavegen.c

  This is a I2C DAC signal generator example using the Parallella's built in hardware I2C support through the Linux I2C driver. It can generate either a sawtooth waveform or sine wave. 
  User can select how many steps for each wave, which will increase the precision (at the expense of frequency). Using the least amount of steps, waveforms max out around 600Hz. 
  The Porcupine breakout board breaks out the Parallella's SDA and SCL I2C lines. A 12 bit MAXIM Integrated PMOD 8 channel digital DAC is used in this example (http://datasheets.maximintegrated.com/en/ds/MAX5825PMB1.pdf).
  Note, this is an 8 channel DAC, but only channel 0 is used. Connected according to the following pinout:

ADC Connections:
  VDD: 5V pin on Porcupine board (Note: I2C logic on Parallella is at 5V).
  SCL: Parallella's I2C SCL
  SDA: Parallella's I2C SDA
  GND: Parallella's Ground
  REF: Tied to your analog reference, in this example it's tied to VDD (5V)
  DAC0: Signal Output (To Oscilloscope or load)

  
  Build:
    gcc -std=c99 dac-wavegen.c -o dac-wavegen -lm

  Running:
  sudo ./dac-wavegen

  Notes:


*/

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <math.h> 


#define PI (3.14159265)

int main() {
    int file;           //file descripter
    char filename[40];          //holds filename for I2C
    int addr = 0B00010000;          // The I2C address of the DAC (0x10), note the address is zero padded to account for (read and write bit)


//Open the I2C Bus at the proper address

    sprintf(filename,"/dev/i2c-0");         //for the Parallella, I2C is located at "/dev/i2c-0"
    if ((file = open(filename,O_RDWR)) < 0) {
        printf("Failed to open the bus.\n");
        exit(1);
    }

    if (ioctl(file,I2C_SLAVE,addr) < 0) {
        printf("Failed to acquire bus access and/or talk to slave.\n");
        exit(1);
   }


int Q_Steps, P_Steps, end;
int * SinArray;         //pointer to dynamically allocated array that will hold all sine values to reduce the number of repetative sine function calls
char input[25];
char choice; //a=sin wave   b=sawtooth
char buf[10] = {0};


 buf[0] = 0B10110000;  //Command Byte to write to channel 0



//Let the user select which waveform they want

printf("Choose Waveform:\na). Sine\nb). Sawtooth\n\nWaveform: ");
if( fgets (input, 25, stdin)==NULL )
    {
        printf("Error reading input\n");
        return -1;
    }
sscanf(input, "%c", &choice);


//let user select how many steps (adjusts output frequency)
printf("\nEnter steps per quarter period (must be greater than zero): ");
if( fgets (input, 25, stdin)==NULL )
    {
        printf("Error reading input\n");
        return -1;
    }
sscanf(input, "%u", &Q_Steps);
if (Q_Steps < 1) 
{
    printf("Invalid Input\n");
    return -1;  
}


P_Steps = 4*Q_Steps; //4 times as many steps in period than in quarter period




//Save the proper sine waveform values into dynamically array acording to user's earlier choice into 

switch(choice)
{
    case 'a':

SinArray = (int*)malloc((P_Steps-1)*sizeof(int)); //allocate the proper size array to hold all sin values

for (int i=0; i < P_Steps; i++)
{
SinArray[i] = 2047*sin(((2*PI)/P_Steps)*i) +2048; //sine dilation and translation to transform sine wave to match our DAC's range
}



//Start infinite while loop writing values to DAC from the array

 printf("\nStarting...\nExit Program with Ctrl + C\n");
while(1)
{
    for (int i=0; i< P_Steps; i++)
    {
        buf[1] = SinArray[i] >> 4;
        buf[2] = SinArray[i] << 4;
    if (write(file,buf,3) != 3) 
    {
        /* ERROR HANDLING: i2c transaction failed */
        printf("Failed to write to the i2c bus.\n");
    }

    }
} 

free(SinArray); //not really necessary, but free our array of sin values



// if we are making sawtooth wave

case 'b':

 printf("Starting...\nExit Program with Ctrl + C\n");
while(1)
{

    // increment
    for (int i=0; i< 4096; i+=(4095/(2*Q_Steps)))
    {
        buf[1] = i >> 4;
        buf[2] = i << 4;
    if (write(file,buf,3) != 3) printf("Failed to write to the i2c bus.\n");
    end = i; //save ending value
    }
    
    //decrement
    for (int i=end; i>=0; i-=(4095/(2*Q_Steps)))
    {
        buf[1] = i >> 4;
        buf[2] = i << 4;
    if (write(file,buf,3) != 3) printf("Failed to write to the i2c bus.\n");  
    } 
}

//if unknown input

default:
        printf("Error reading input\n");
        return -1;
}


return 0;
}

