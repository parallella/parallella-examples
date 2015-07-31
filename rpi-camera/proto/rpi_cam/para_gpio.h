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

  para_gpio.h

  Header file for the para_gpio library, enabling use of GPIO pins
  of the Parallella in user applications.  This file defines both
  basic C functions and, if used in a C++ project, a gpio class.

  Available GPIO pins:

    On the Parallella, the first user-accessible pin is GPIO7.  Access
    to the LED requires an FSBL (flash image) created after 5/14/14,
    which includes all 7010-based boards but not the kickstarter boards.
    The easy way to tell if the LED is supported is to check if CR10
    lights up when the board boots.  If not, the flash can be updated
    through the UART but this may not be something everyone will be
    comfortable doing.

    Besides the FPGA-LED, the GPIO pins on the Parallella Expansion 
    Connector (PEC) are accessible in the following ranges depending
    on the FPGA and IO standard.  This assumes the 'standard' FPGA
    configuration, different configurations may have different ranges
    of pins available.

      FPGA   IOSTANDARD   RANGE
      7020   Single-ended 54-101
      7020   Differential 54-77
      7010   Single-ended 54-77
      7010   Differential 54-65

  Basic C functions:
    Unless otherwise stated, all functions return a result code, 0 always
      indicates success.  The codes are enumerated as e_para_gpiores.

    para_initgpio(para_gpio **ppGpio, int nID) - 
      initializes a single GPIO pin, returning either a pointer to a new
      gpio structure on success or NULL on failure.  The caller must 
      record this pointer for use with all other gpio functions.

    para_initgpio_ex(para_gpio **ppGpio, int nID, bool bMayExist) - 
      Same as para_initgpio but allow specifying whether the sysfs
      entries for gpio nID may already exist or not.  If the
      bMayExist argument is false and the pin has already been
      exported to the file system, the init call will fail.

    para_closegpio(para_gpio *pGpio) - Closes and de-allocates the GPIO,
      including deleting the para_gpio object.  The caller must not
      use the para_gpio pointer again after calling this function.

    para_closegpio_ex(para_gpio *pGpio, bool bForceUnexport) -
      Same as para_closegpio but allow forcibly un-exporting the
      pin even if we did not export it in the first place.

    para_setgpio(para_gpio *pGpio, int nValue) - Sets the pin level to
      nValue, looking only at the lsb.  Returns 0 on success or else
      an error code.

    para_dirgpio(para_gpio *pGpio, para_gpiodir eDir) - Sets the pin
      direction based on the enum eDir:
        para_dirin - input
        para_dirout - output
        para_dirwand - wired-and, a/k/a open-drain / open-collector
          (will either float or pull to 0)
        para_dirwor - wired-or (will either pull to 1 or float)

    para_getgpio(para_gpio *pGpio, int *pValue) - Gets the current
      pin level.  Returns 0 on success or else an error code.

    para_blinkgpio(para_gpio *pGpio, int nMSOn, nMSOff) - "Blinks"
      the gpio pin, turning it on for nMSOn milliseconds and then
      off for nMSOff before returning.

  Caveats:

    There has been no attempt to make this thread-safe or to deal intelligently 
      with two or more objects that refer to the same pins.  

    No support yet for edge detection.  Next "to-do."

    Before things like the direction or value are set, they may be anything.  No
      defaults are imposed when the gpio pins are opened.

*/

#ifndef PARA_GPIO_H
#define PARA_GPIO_H

#include <stdbool.h>

// Available directions
typedef enum e_para_gpiodir {
  para_dirunk,  // Unknown
  para_dirin,
  para_dirout,
  para_dirwand,
  para_dirwor
} para_gpiodir;

// GPIO structure for the C functions
typedef struct st_para_gpio {
  int nID;
  int fdVal;
  int fdDir;
  bool bIsNew;
  para_gpiodir eDir;
} para_gpio;

// Function return values
enum e_para_gpiores {
  para_ok = 0,
  para_outofrange = 1,
  para_outofmemory = 2,
  para_alreadyopen = 3,
  para_noaccess = 4,
  para_fileerr = 5,
  para_notopen = 6,
  para_nodir = 7,
  para_badgpio = 8,
  para_badreturn = 9,
  para_badarg = 10,
  para_timeout = 11,
};

#define MAXPINSPEROBJECT  64
#define EXTGPIOSTART      54
#define EXTGPIONUM        64
#define LASTGPIOID        (EXTGPIOSTART + EXTGPIONUM - 1)

int  para_initgpio(para_gpio **ppGpio, int nID);
int  para_initgpio_ex(para_gpio **ppGpio, int nID, bool bMayExist);
void para_closegpio(para_gpio *pGpio);
void para_closegpio_ex(para_gpio *pGpio, bool bForceUnexport);
int  para_setgpio(para_gpio *pGpio, int nValue);
int  para_dirgpio(para_gpio *pGpio, para_gpiodir eDir);
int  para_getgpio(para_gpio *pGpio, int *pValue);
int  para_blinkgpio(para_gpio *pGpio, int nMSOn, int nMSOff);

#endif  // PARA_GPIO_H
