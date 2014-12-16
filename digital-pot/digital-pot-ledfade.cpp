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

  DigitalPotLEDFade.cpp

  Simple example of the Parallella bit-bang'in SPI library by using it to fade an LED. Uses Porcupine breakout board to break out gpio and PMOD connector. An 8 bit digital POT is connected through PMOD connector (SPI), see IC data sheet (http://datasheets.maximintegrated.com/en/ds/MAX5487-MAX5489.pdf).
  5V is put across channel A pot, and an LED is connected from the wiper to Gnd. No series resistor is necessary to protect the LED, since the wiper has 200 ohms of resistance. Each loop is calculated to take about 5 seconds to fade the LED high then low.

  Build:
  gcc -o digital-pot-ledfade digital-pot-ledfade.cpp para_spi.cpp para_gpio.cpp para_gpio.c -lstdc++ -Wall

  Running:
  sudo ./DigitalPotLEDFade

  Notes:

Requires the para_spi class, which also requires the para_gpio library. Both can be found in parallella-utils Github here: https://github.com/parallella/parallella-utils. 

IMPORTANT: AS OF 11/26/14 THE CURRENT PARALLELLA MASTER REPOSITORY DOES NOT HAVE THE UPDATED SPI LIBRARY THAT PATCHES THE BUG WHEN COMMUNICATING WITH SPI DEVICES THAT READ ON THE SECOND CLOCK EDGE. 
UNTIL THESE CHANGES GET INCORPORATED INTO THE MASTER REPO, THIS PROGRAM WILL NOT WORK. INSTEAD, PLEASE USE MY UPDATED VERSION, WHICH CAN BE FOUND HERE: https://github.com/wizard97/parallella-utils.

*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include "para_spi.h"




int main() {
  int res;
  unsigned rval=0;


  CParaSpi spi; //create SPI object

  printf("Digital Pot SPI Example\n");
  printf("Initializing object...\n");

  spi.SetMode(1, 1, 0); //(nCPOL, nCPHA, nEPOL) Set the proper SPI mode for the digital pot

  //nCPOL = Idle Clock Polarity (1 or 0)      nCPHA = Clock Phase (0=first edge  1=second edge)      nEPOL= Slave Enable Polarity (1 or 0)

  res = spi.AssignPins(57, 55, 56, 54); //(nCLK, nMOSI, nMISO, nSS) Assign proper pins for PMOD SPI layout
  
  if(res) {
    fprintf(stderr, "spi.AssignPins returned %d", res); //make sure pins were assigned
    exit(1);
  }

  if(!spi.IsOK()) {
    fprintf(stderr, "SPI Object creation failed, exiting\n");
    exit(1);
  }

  printf("Success\n");
  printf("Program will write to channel A of digital pot from 0-255, then decrement from 255-0.\n");
  printf("Starting Infinite While Loop.\n");



while(1)
{
  for (int i=0; i<256;i++) //Increment the pot through all 8 bits of its resolution 0-256
  {
  	      res = spi.Xfer(16, i+0x100, &rval);
      if(res) return res;
      usleep(10000); //sleep the thread for 10ms between each write
  }

  for (int i=255; i>=0;i--) //Decrement the pot through all 8 bits of its resolution 0-256
  {
  	      res = spi.Xfer(16, i+0x100, &rval);
      if(res) return res;
      usleep(10000); //sleep the thread for 10ms between each write
  }
}


  printf("Closing\n");
  spi.Close();

  return 0;
}

