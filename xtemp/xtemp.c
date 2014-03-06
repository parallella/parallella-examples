/*
Copyright (c) 2014, Adapteva, Inc.
Contributed by Fred Huettig <Fred@Adapteva.com>
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

  xtemp.c

  Show a graph of the Zynq temperature over time.  Graph will go
  ORANGE if the temperature exceeds a preset warning limit and then
  RED above a higher limit.

*/

/*   To Build:
  > make
or
  > gcc -o xtemp xtemp.c -pthread -lX11 -Wall
*/

// TODO:
//
//  - Maybe some averaging?
//  - Add horizontal graticule lines?
//  - Rescale if high/low peaks drop off the array?
//  - Add lines or choice for voltages in addition to temperature
//

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <pthread.h>
#include <semaphore.h>
#include <signal.h>
#include <unistd.h>
#include <math.h>

#define kSTRMAX    256
#define kXADCPATH  "/sys/bus/iio/devices/iio:device0/"
#define kMAXSAMPLES 2048

Display  *dpy;
Window   win;
GC       gc;
unsigned long clrBlack, clrWhite, clrRed, clrBlue, clrOrange;
Atom      wmDeleteMessage;

int      nOffset = 0;
float    fScale = 0.0;

float    fTempWarn = 70., fTempLimit = 80.;
float    fTemps[kMAXSAMPLES], fMaxTemp=-999., fMinTemp=999.;
int      nLastSample=-1, nSamples=0;
int      nSleepSecs = 2;

void Usage() {

  printf("\nUsage: xtemp [-l maxtemp] [-w warntemp] [-r refresh]\n");
  printf("       xtemp -h\n\n");

  printf("Defaults:\n");
  printf("    -l 80    : Set Temperature Limit in deg. C (\"redline\")\n");
  printf("    -w 70    : Set Tempertature Warning in (\"orangeline\")\n");
  printf("    -r 2     : Set Refresh Period in seconds\n\n");

  printf("Press 'q' or click the 'X' to close the window\n\n");
}

int InitX() {
  XColor    xColor;
  Colormap  colormap;

  dpy = XOpenDisplay(NULL);
  if(dpy == NULL)
    return 1;

  clrBlack = BlackPixel(dpy, DefaultScreen(dpy));
  clrWhite = WhitePixel(dpy, DefaultScreen(dpy));

  colormap = DefaultColormap(dpy, DefaultScreen(dpy));
  XParseColor(dpy, colormap, "red", &xColor);
  XAllocColor(dpy, colormap, &xColor);
  clrRed = xColor.pixel;

  XParseColor(dpy, colormap, "blue", &xColor);
  XAllocColor(dpy, colormap, &xColor);
  clrBlue = xColor.pixel;

  XParseColor(dpy, colormap, "orange", &xColor);
  XAllocColor(dpy, colormap, &xColor);
  clrOrange = xColor.pixel;

  wmDeleteMessage = XInternAtom(dpy, "WM_DELETE_WINDOW", False);

  // Create the window
  win = XCreateSimpleWindow(dpy, DefaultRootWindow(dpy), 0, 0, 
			    400, 300, 8, clrBlack, clrWhite);

  XSetWMProtocols(dpy, win, &wmDeleteMessage, 1);
  XSelectInput(dpy, win, StructureNotifyMask | ExposureMask | KeyPressMask);

  XGCValues    values;
  XFontStruct *font;

  font = XLoadQueryFont(dpy, "fixed");
  if(!font) {
    fprintf(stderr, "No fixed font?\n");
    return 2;
  }
  
  values.line_width = 1;
  values.line_style = LineSolid;
  values.font = font->fid;
  gc = XCreateGC(dpy, win, GCLineWidth|GCLineStyle|GCFont,
		 &values);

  XStoreName(dpy, win, "xtemp");
  
  // Map the window (that is, make it appear on the screen)
  XMapWindow(dpy, win);

  // Tell the GC we draw using black on white
  XSetForeground(dpy, gc, clrBlack);
  XSetBackground(dpy, gc, clrWhite);

  // Wait for the MapNotify event
  for(;;) {
    XEvent e;
    XNextEvent(dpy, &e);
    if (e.type == MapNotify)
      break;
  }

  return 0;
}

int GetConstants() {
  char  strRead[kSTRMAX];
  FILE *sysfile;

  if((sysfile = fopen(kXADCPATH "in_temp0_offset", "ra")) == NULL) {
    fprintf(stderr, "ERROR: Can't open offset device file\n");
    return 1;
  }
  fgets(strRead, kSTRMAX-1, sysfile);
  fclose(sysfile);
  nOffset = atoi(strRead);

  if((sysfile = fopen(kXADCPATH "in_temp0_scale", "ra")) == NULL) {
    fprintf(stderr, "ERROR: Can't open scale device file\n");
    return 2;
  }
  fgets(strRead, kSTRMAX-1, sysfile);
  fclose(sysfile);
  fScale = atof(strRead);

  return 0;
}

int GetTemp(float *fTemp) {
  FILE *sysfile;
  char  strRead[kSTRMAX];
  int  nRaw;

  if(nOffset == 0 || fScale == 0.0)
    return 1;

  if((sysfile = fopen(kXADCPATH "in_temp0_raw", "ra")) == NULL) {
    return 2;
  }

  fgets(strRead, kSTRMAX-1, sysfile);
  fclose(sysfile);
  nRaw = atoi(strRead);

  *fTemp = (nRaw + nOffset) * fScale / 1000.;

  return 0;
}

void *UpdateThread(void *idThread) {
  int   nSample;
  XClientMessageEvent  evt;

  while(1) {

    nSample = (nLastSample + 1)  % kMAXSAMPLES;

    if(GetTemp(fTemps + nSample))
      continue;

    if(fTemps[nSample] < fMinTemp)
      fMinTemp = fTemps[nSample];

    if(fTemps[nSample] > fMaxTemp)
      fMaxTemp = fTemps[nSample];

    nLastSample = nSample;
    if(nSamples < kMAXSAMPLES)
      nSamples++;

    memset(&evt, 0, sizeof(XClientMessageEvent));
    evt.type = ClientMessage;
    evt.window = win;
    evt.format = 32;
    evt.data.l[0] = 42;
    XSendEvent(dpy, win, 0, 0, (XEvent*)&evt);
    XFlush(dpy);

    if(nSleepSecs < 1)
      nSleepSecs = 1;

    sleep(nSleepSecs);
  }

  pthread_exit(NULL);
}

#define AXISX  30
#define CHARY  16
#define yval(t)      ((int)(height * (fMax - (t)) / (fMax - fMin)))

int Redraw() {
  Window     root;
  int        xPos, yPos;
  unsigned   width, height, widBorder, depth, x, y, i, n;
  float      fMax, fMin;
  char       str[kSTRMAX];

  if(!XGetGeometry(dpy, win, &root, &xPos, &yPos, &width, &height,
		  &widBorder, &depth))
    return 1;

  XSetBackground(dpy, gc, clrWhite);
  XSetForeground(dpy, gc, clrBlack);

  if(nSamples < 1) {
    strcpy(str, "WAIT");
    XDrawImageString(dpy, win, gc, 3, CHARY, str, strlen(str));
    return 0;
  }

  fMax = ((int)((fMaxTemp + 10.0) / 10.0)) * 10.0;
  fMin = ((int)(fMinTemp / 10.0)) * 10.0;

  // Erase Y-axis area
  XClearArea(dpy, win, 0, 0, AXISX, height, 0);

  sprintf(str, "%.1f", fMax);
  XDrawImageString(dpy, win, gc, 3, CHARY, str, strlen(str));
  
  sprintf(str, "%.1f", fMin);
  XDrawImageString(dpy, win, gc, 3, height, str, strlen(str));

  XSetForeground(dpy, gc, clrBlue);
  y = yval(fMinTemp);
  sprintf(str, "%.1f", fMinTemp);
  XDrawImageString(dpy, win, gc, 3, y+CHARY/2, str, strlen(str));

  XSetForeground(dpy, gc, clrRed);
  y = yval(fMaxTemp);
  sprintf(str, "%.1f", fMaxTemp);
  XDrawImageString(dpy, win, gc, 3, y+CHARY/2, str, strlen(str));

  if(fTemps[nLastSample] >= fTempLimit)
    XSetForeground(dpy, gc, clrRed);
  else if(fTemps[nLastSample] >= fTempWarn)
    XSetForeground(dpy, gc, clrOrange);
  else
    XSetForeground(dpy, gc, clrBlack);
  
  y = yval(fTemps[nLastSample]);
  sprintf(str, "%.1f", fTemps[nLastSample]);
  XDrawImageString(dpy, win, gc, 3, y+CHARY/2, str, strlen(str));
  
  for(x=width-1, i=nLastSample, n=0; x > AXISX && n < nSamples; x--, n++) {

    y = yval(fTemps[i]);
    XDrawLine(dpy, win, gc, x, y, x, height);
    i = (i - 1) % kMAXSAMPLES;
  }
  
  // Now fill-in the upper "clear" section
  XSetForeground(dpy, gc, clrWhite);

  for(x=width-1, i=nLastSample, n=0; x > AXISX && n < nSamples; x--, n++) {

    y = yval(fTemps[i]);
    XDrawLine(dpy, win, gc, x, y, x, 0);
    i = (i - 1) % kMAXSAMPLES;
  }

  // Send all the requests to the server
  XFlush(dpy);

  return 0;
}

int main(int argc, char **argv) {
  pthread_t   tidUpdate;
  int         nFlag, nQuit=0, c;
  KeySym      key;
  char        str[kSTRMAX];

  opterr = 0;
     
  while ((c = getopt (argc, argv, "hl:w:r:")) != -1) {
    switch (c) {

    case 'h':
      Usage();
      return 0;

    case 'l':
      fTempLimit = atof(optarg);
      break;
	
    case 'w':
      fTempWarn = atof(optarg);
      break;

    case 'r':
      nSleepSecs = atoi(optarg);
      break;

    case '?':
      if (optopt == 'l' || optopt == 'w' || optopt == 'r')
	fprintf (stderr, "Option -%c requires an argument.\n", optopt);
      else if (isprint (optopt))
	fprintf (stderr, "Unknown option `-%c'.\n", optopt);
      else
	fprintf (stderr,
		 "Unknown option character `\\x%x'.\n",
		 optopt);
      return 1;

    default:
      abort ();
    }
  }
  
  XInitThreads();

  if(InitX())
    return 1;
  if(GetConstants())
    return 2;
  if(pthread_create(&tidUpdate, NULL, &UpdateThread, NULL))
    return 3;

  float fTemp;
  GetTemp(&fTemp);
  printf("Current Temp = %.1f\n", fTemp);

  while(1) {
    XEvent e;
    XNextEvent(dpy, &e);

    nFlag = 0;
    switch(e.type) {

    case Expose:
      nFlag = 1;
      break;

    case ClientMessage:
      
      if(e.xclient.data.l[0] == 42) {
	nFlag = 1;
      } else if(e.xclient.data.l[0] == wmDeleteMessage) {
	XDestroyWindow(dpy, e.xclient.window);
	nQuit = 1;
      }
      break;

    case KeyPress:
      if(XLookupString(&e.xkey, str, kSTRMAX-1, &key, 0)==1) {
	if(str[0] == 'q' || str[0] == 'Q') {
	  XDestroyWindow(dpy, win);
	  nQuit = 1;
	}
      }
      break;

    case ConfigureNotify:
      break;
    
    }

    if(nQuit)
      break;

    if(nFlag) {

      int rc = Redraw();
      if(rc) {
	fprintf(stderr, "Redraw() returned %d\n", rc);
	break;
      }
    }
  }

  XCloseDisplay(dpy);
  pthread_kill(tidUpdate, 1);
  pthread_exit(NULL);
}

