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

#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <opencv2/opencv.hpp>
#include <vector>
#include <string.h>
#include <sstream>
#include "CSmtp.h"
#include "para_gpio.h"

#define OUT_PIN 54
#define IN_PIN 55
#define SAVE_DESTINATION "/home/linaro/Desktop/captures/"
#define WEBSAVE_DESTINATION "/var/www/html/captures/"

using namespace cv;
using namespace std;

int capture_img(int pictureNum);
int email(int picNum, char server[], int port, char username[], char pass[], char sender[], char recipient[]);

int main(int argc, char *argv[]) {

if (argc != 7 && argc != 1)
{

printf("Usage:\n\n");
printf("With Email: sudo ./motion <SSL SMTP Server Address> <Port> <Username> <Pass> <Sender Address> <Recipient Address>\n");
printf("Ex: sudo ./motion smtp.gmail.com 465 linaroparallella parallellapass linaroparallella@gmail.com aaronwisner@gmail.com\n\n");

printf("Without Email: sudo ./motion\n\n");
return 0;
}


int pinVal;
int picNum = 0;
bool event_trigger=false;

struct timespec currentT, endT;

//used to time our alarm_pin
clock_gettime(CLOCK_MONOTONIC, &endT);
clock_gettime(CLOCK_MONOTONIC, &currentT);
  //create a pointer to gpio struct
  para_gpio *pin_out, *pin_in;
  
  //initialize gpio pins
  para_initgpio(&pin_out, OUT_PIN);
  para_initgpio(&pin_in, IN_PIN);
  
  //make sure everything opened successfully
    if (pin_out == NULL || pin_in == NULL) 
  {
  printf("Error opening pins, perhaps run as root?\n");
  return (1);
  }
  
  //set pin 54 to out, pin 55 to input
  para_dirgpio(pin_out, para_dirout);
  para_dirgpio(pin_in, para_dirin);
  
  //make sure pin 54 is Low
 para_setgpio(pin_out, false);


printf("Waiting for motion...\n\n");
  //wait for event
  while(1)
  {
  
  //read input
  if(para_getgpio(pin_in, &pinVal))
  {
  printf("Error reading input pin\n");
  return (1);
  }
  
  //check if input pin is high
  if(pinVal==1)
  {
 event_trigger=true;
printf("Motion Detected!\n");
  //call trigger event, and make sure it completes successfully
  if(capture_img(picNum) != 0)
  {
	printf("Error capturing and/or saving image!\n");
	return(1);
	}
	else printf("Image %d Captured!\n", picNum);

	if (argc == 7)
	{
  if(email(picNum, argv[1], atoi(argv[2]), argv[3], argv[4], argv[5], argv[6]) != 0)
  {
  printf("Error sending email!\n\n");
  return(1);
  }
  else printf("Email Sent!\n\n");
}

//if not sending emails
else 
  {
    printf("\n");
    //cant have it take to many pictures at once
    usleep(500000);
    }
picNum++;

  //set off alarm
  para_setgpio(pin_out, true);

  //get current time
  clock_gettime(CLOCK_MONOTONIC, &endT);

  //stop alarm 3 seconds from now
  endT.tv_sec+=3;

  }
  
  //if alarm is on, check time
if(event_trigger)
{
clock_gettime(CLOCK_MONOTONIC, &currentT);

if(currentT.tv_sec >= endT.tv_sec && currentT.tv_nsec >= endT.tv_nsec)
{
para_setgpio(pin_out, false);
  event_trigger= false;
}

}


  }
  
  
  //close the gpio pins 
   para_closegpio(pin_out);
   para_closegpio(pin_in);
   }
   


//our function for capturing and saving the image
   
   int capture_img(int pictureNum)
   {
//crazy c++ complicated syntax to append a string
    ostringstream save, websave;

    save << SAVE_DESTINATION << "capture_" << pictureNum << ".jpg";

    websave << WEBSAVE_DESTINATION << "capture_" << pictureNum << ".jpg";

string save_name = save.str();
string websave_name = websave.str();
   
   // open the default camera
     VideoCapture cap(0);
	  
	  // check if we succeeded
    if(!cap.isOpened())  
{       
printf("Unable to open camera\n");
 return -1;
}

//create new Mat object
        Mat frame;
		
// get a new frame from camera
        cap.read(frame); 

        if(frame.empty()){
                cout << "Failed to capture an image\n" << endl;
                return -1;
        }
  
                
if(!imwrite(save_name , frame) || !imwrite(websave_name , frame) )
{
printf("Error saving image\n");
printf("Does \"%s\" and \"%s\" both exist? If not make them!\n", SAVE_DESTINATION, WEBSAVE_DESTINATION);
return (-1);
}

    cap.release();	
   
   return (0);
 }


int email(int picNum, char server[], int port, char username[], char pass[], char sender[], char recipient[])
{
   ostringstream ostr;

    ostr << SAVE_DESTINATION << "capture_" << picNum << ".jpg";

string save_name = ostr.str();

 bool bError = false;

    try
    {
        CSmtp mail;

        mail.SetSMTPServer(server, port);
        mail.SetSecurityType(USE_SSL);
        
    mail.SetLogin(username);
    mail.SetPassword(pass);
      mail.SetSenderName("Parallella Motion");
      mail.SetSenderMail(sender);
      mail.SetReplyTo(sender);
      mail.SetSubject("Motion Detected!");
      mail.AddRecipient(recipient);
      mail.SetXPriority(XPRIORITY_NORMAL);
      mail.SetXMailer("Parallella Mailer");
      mail.AddMsgLine("Hello,");
    mail.AddMsgLine("");
    mail.AddMsgLine("Motion was just detected by yours truly.");
    mail.AddMsgLine("");
    mail.AddMsgLine("But don't worry, I took a picture of the trespasser and attached it.");
    mail.AddMsgLine("");
    mail.AddMsgLine("Regards,");
    mail.AddMsgLine("Your Parallella :)");
        mail.AddMsgLine("");

        mail.AddAttachment(save_name.c_str());
    
        mail.Send();
    }
    catch(ECSmtp e)
    {
        std::cout << "Error: " << e.GetErrorText().c_str() << ".\n";
        bError = true;
    }

    if(!bError)
    {
        std::cout << "Mail was send successfully.\n";
        return 0;
    }
    else
        return 1;
}


   