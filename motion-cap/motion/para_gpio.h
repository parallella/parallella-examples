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

  Parallella GPIO Class, member functions:
    Except for the constructors, all functions return 0 (success) or an
      error code.

    CParaGpio()  - Constructs an 'empty' GPIO object which may later be 
      assigned to a pin or group of pins.

    CParaGpio(int nStartID, int nNumIDs=1, bool bPorcOrder=false) - 
      Constructs a multi-pin GPIO object starting at pin nStartID and
      continuing for a total of nNumIDs pins.  If bPorcOrder is false,
      the pins are assigned in numerical order 0, 1, 2, 3...  If true,
      the pin assignments are made in the order of the Porcupine
      breakout board's single-ended assignments, i.e. 0 2 1 3 4 6 5 7,
      so they come out 'nicely' on the headers.  If using bPorcOrder,
      do NOT add the offset of 54 for the first external GPIO pin,
      instead use a startID based at 0.  The offset will be added
      automatically.

    CParaGpio(int *pIDArray, int nNumIDs, bool bPorcOrder=false) -
      Constructs a multi-pin GPIO object using the pin numbers defined
      in the array pIDArray.  The first ID in the array corresponds to
      the lowest bit in any read or write transaction.

    AddPin(int nID, bool bPorcOrder=false) - Adds a new pin to the object,
      for multi-pin objects this will become the new most-significant bit.
      Returns para_ok on success or else an integer error code.

    IsOK() - Checks that all pin assignments were successful, returns
      true if no errors have occurred during pin assignment, including
      if no pins have been asssigned, returns false otherwise.

    GetNPins() - Returns the number of pins assigned.

    SetDirection(para_gpiodir eDir) - Sets the direction for all pins of the object
      based on the enum eDir:
        para_dirin - input
	para_dirout - output
	para_dirwand - wired-and, a/k/a open-drain / open-collector
	  (will either float or pull to 0)
        para_dirwor - wired-or (will either pull to 1 or float)

    GetDirection(para_gpiodir *pDir) - Gets the current direction setting as above.

    SetValue(unsigned long long nValue) - Sets the values of all pins.
      The effect of this function depends on the current Direction setting.

    GetValue(unsigned long long *pValue) - OR
    GetValue(unsigned *pValue) - Gets the current levels of all
      pins.  This function always reads the pin levels, it doesn't just
      return the values most recently Set, regardless of direction.

    WaitLevel(int nPin, int nValue, int nTimeout) - Waits for the given
      value to be present on the input, meaning it will return immediately
      if the input is already at the requested value.  Times out after
      nTimeout seconds if request not satisfied.

    WaitEdge(int nPin, int nValue, int nTimeout) - Waits for a rising 
      (nValue = 1) or falling (nValue = 0) edge on the input.  Requires
      an edge, i.e. if the input is already at the requested level it
      must toggle before this function will return.  Times out after
      nTimeout seconds if no edge.

    Blink(unsigned long long nMask, int nMSOn, int nMSOff) -
      "Blinks" the gpio pin(s) defined in nMask by turning them on for
      nMSOn milliseconds then then off for nMSOff before returning.

    Close() - Releases all pins from the object.  This happens automatically
      when the object is destroyed.  New pins may be added with AddPin()
      after calling this functions.

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

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

  int         para_initgpio(para_gpio **ppGpio, int nID);
  int         para_initgpio_ex(para_gpio **ppGpio, int nID, bool bMayExist);
  void        para_closegpio(para_gpio *pGpio);
  void        para_closegpio_ex(para_gpio *pGpio, bool bForceUnexport);
  int         para_setgpio(para_gpio *pGpio, int nValue);
  int         para_dirgpio(para_gpio *pGpio, para_gpiodir eDir);
  int         para_getgpio(para_gpio *pGpio, int *pValue);
  int         para_blinkgpio(para_gpio *pGpio, int nMSOn, int nMSOff);
  
#ifdef __cplusplus
}  // extern "C"

class CParaGpio {
 protected:
  int  nPins;
  para_gpio *pGpio[MAXPINSPEROBJECT];
  bool bIsOK;

 public:
  CParaGpio();
  CParaGpio(int nStartID, int nNumIDs=1, bool bPorcOrder=false);
  CParaGpio(int *pIDArray, int nNumIDs, bool bPorcOrder=false);
  ~CParaGpio();
  int AddPin(int nID, bool bPorcOrder=false);
  bool IsOK() { return bIsOK; }
  int GetNPins() { return nPins; }
  int SetDirection(para_gpiodir eDir);
  int GetDirection(para_gpiodir *pDir);
  int SetValue(unsigned long long nValue);
  int GetValue(unsigned long long *pValue);
  int GetValue(unsigned *pValue);
  int WaitLevel(int nPin, int nValue, int nTimeout);
  int WaitEdge(int nPin, int nValue, int nTimeout);
  int Blink(unsigned long long nMask, int nMSOn, int nMSOff);
  void Close();
};

#endif  // __cplusplus


#endif  // PARA_GPIO_H
