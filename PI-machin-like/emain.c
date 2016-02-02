/*
 * Author: Noémien Kocher
 * Date: january 2016
 * Licence: MIT
 * Purpose:
 *   This code is run by each eCore, it computes part of the sum.
 */

#include <math.h>

#include <e-lib.h> // Epiphany cores library

volatile unsigned x             SECTION(".text_bank2");     // 0x4000
volatile float    result        SECTION(".text_bank2") = 0; // 0x4004
volatile unsigned state         SECTION(".text_bank2") = 1; // 0x4008
volatile unsigned sub_iteration SECTION(".text_bank2");     // 0x400c

int main(void) {

  while(1) {
    state = 0;
    while(state != 1);

    result = 0;
    unsigned a = x * sub_iteration;
    unsigned b = a + sub_iteration;
    for(; a < b; ++a) {
      result += pow(-1,a) / (2*a + 1);
    }
  }
}
