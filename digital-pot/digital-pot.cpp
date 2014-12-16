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

  DigitalPot.cpp

  Example of the Parallella bit-bang'in SPI library by using it to write to a digital pot. Uses Porcupine breakout board to break out gpio and PMOD connector. An 8 bit digital POT is connected through PMOD connector (SPI), see IC data sheet (http://datasheets.maximintegrated.com/en/ds/MAX5487-MAX5489.pdf).
  Program lets user select value to write to pot (0-255), then select which of the two pots to write to (a or b). Finally, he or she is prompted to choose whether to save the value in the pots EEPROM (so it will remember it after the next power cycle). 
  For a more simple example of using the digital pot, see DigitalPotLEDFade.cpp

  Running:
  sudo ./DigitaPot


  Build:
  gcc -o digital-pot digital-pot.cpp para_spi.cpp para_gpio.cpp para_gpio.c -lstdc++ -Wall

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


int get_input(bool* potA, bool* writeNV, int* val); //function for getting users input


int main() {
  int res, Wval;
  bool NVWrite, WPotA;
  unsigned rval=0;


  CParaSpi spi; //create SPI object

  printf("Digital Pot SPI Example\n");
  printf("Initializing object...\n");

  spi.SetMode(1, 1, 0); //(nCPOL, nCPHA, nEPOL) Set the proper SPI mode for the digital pot

  res = spi.AssignPins(57, 55, 56, 54); //(nCLK, nMOSI, nMISO, nSS)
  //nCPOL = Idle Clock Polarity (1 or 0)      nCPHA = Clock Phase (0=first edge  1=second edge)      nEPOL= Slave Enable Polarity (1 or 0)
  
  if(res) {
    fprintf(stderr, "spi.AssignPins returned %d", res);
    exit(1);
  }

  if(!spi.IsOK()) {
    fprintf(stderr, "SPI Object creation failed, exiting\n");
    exit(1);
  }

  printf("Success\n");

while(1)
{
res = get_input(&WPotA, &NVWrite, &Wval);
if(res) break;

if (WPotA)
{
Wval = Wval + 0x100; //add the write hex value if writing to pot A
}
else Wval = Wval + 0x200 ; //add the write hex value if writing to pot B

if (NVWrite) Wval = Wval + 0x1000; //if writing to EEPROM, add correct hex value to the two byte message


      res = spi.Xfer(16, (unsigned int)Wval, &rval); //transfer the message (16 bits/2 bytes)
      if(res) {
	fprintf(stderr, "Xfer() returned %d, exiting\n", res); //print what was sent
return res;
      }

      printf("Sent 0x%08X, Rcvd 0x%08X\n\n", Wval, rval); //print what was recieved back
  
}
  // done:
  printf("Closing\n"); 
  spi.Close(); //close the connection

  return 0;
}


int get_input(bool* potA, bool* writeNV, int* val) //returns 0 if succesful
{
	char * result;
	char stringInput[100]; //input buffer
	char input;
	int write_val;
	  printf("Enter 'q' to quit.\n\n");

while ((input!='a' && input!='b' && input !='A' && input!='B') || result==NULL)
{
	  printf("Which Pot to write (a/b)? ");
	  result = fgets(stringInput, 100, stdin);
	  if (result!=NULL)
	  {
	  sscanf(stringInput, "%c", &input);

if (input== 'q' || input== 'Q') return 1;

else if(input=='a' || input == 'A') *potA=true;
else if(input=='b' || input == 'B') *potA=false;
else printf("I don't understand, try again.\n");
}
else printf("I don't understand, try again.\n");
}


printf("Would you like to write to the Pot's EEPROM (y/n)? ");
if (fgets(stringInput, 100, stdin)!=NULL)
{
sscanf(stringInput, "%c", &input);
if (input =='y' || input =='Y') *writeNV = true;
else if (input =='n' || input =='N') *writeNV = false;
else 
	{
		*writeNV=false;
		printf("I don't understand, defaulting to no.\n");
	}
}
else 
	{
		*writeNV=false;
		printf("I don't understand, defaulting to no.\n");
	}


do
{
    printf("Enter Pot Value 0-255> ");
    result = fgets(stringInput, 100, stdin);
    if (result!=NULL) 
{
    	sscanf(stringInput, "%d", &write_val);
    	if (write_val>255 || write_val <0) printf("I don't understand, try again.\n");
    }
    else printf("I don't understand, try again.\n");
} while ((write_val>255 || write_val <0) || result==NULL);
*val = write_val;

return 0;
}
