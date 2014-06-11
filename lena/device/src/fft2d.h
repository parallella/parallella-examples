/*
  fft2d.h

  Copyright (C) 2012 Adapteva, Inc.
  Contributed by Yainv Sapir <yaniv@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program, see the file COPYING.  If not, see
  <http://www.gnu.org/licenses/>.
*/


#ifndef __FFT2D_H__
#define __FFT2D_H__

#include <stdint.h>
#include "fft2dlib.h"
#ifndef __HOST__
#include <e_coreid.h>
#endif // __HOST__

#define _Nchips 1                  // # of chips in operand matrix side
#define _Nside  4                  // # of cores in chip side
#define _Ncores (_Nside * _Nside)  // Num of cores = 16
#ifndef _lgSfft
#define _lgSfft 7                  // Log2 of size of 1D-FFT
#endif
#define _Sfft   (1<<_lgSfft)       // Size of 1D-FFT
#define _Score  (_Sfft / _Ncores)  // Num of 1D vectors per-core
#define _Schip  (_Score * _Ncores) // Num of 1D vectors per-chip
#define _Smtx   (_Schip * _Sfft)   // Num of elements in 2D array

#define _Nbanks 2                  // Num of SRAM banks on core

#define _BankA  0
#define _BankW  1
#define _BankB  2
#define _BankP  3
#define _PING   0
#define _PONG   1


#ifdef __Debug__
#define dstate(x) { me.mystate = (x); }
#else
#define dstate(x)
#endif

#define TIMERS 10

#if 0
#if _lgSfft == 5
#	warning "LgFFt = 5"
#elif _lgSfft == 6
#	warning "LgFFt = 6"
#elif _lgSfft == 7
#	warning "LgFFt = 7"
#endif
#endif

#ifdef __Debug__
typedef struct  /*__attribute__((packed))*/ {
#else
typedef struct {
#endif
	int        corenum;
	int        row;
	int        col;

	int        mystate;

	int volatile     go_sync;           // The "go" signal from prev core
	int volatile     sync[_Ncores];     // Sync with peer cores
	int volatile    *tgt_go_sync;       // ptr to go_sync of next core
	int volatile    *tgt_sync[_Ncores]; // ptr to sync of target neighbor

	cfloat volatile *bank[_Nbanks][2];            // Ping Pong Bank local space pointer
	cfloat volatile *tgt_bk[_Ncores][_Nbanks][2]; // Target Bank for matrix rotate in global space

	uint32_t time_p[TIMERS]; // Timers
} core_t;


typedef struct {
	volatile int64_t  go;     // Call for FFT2D function
	volatile int      ready;  // Core is ready after reset
} mbox_t;


typedef struct {
	volatile cfloat A[_Smtx]; // Global A matrix
	volatile cfloat B[_Smtx]; // Global B matrix
	volatile mbox_t core;
} shared_buf_t;


typedef struct {
	void            *pBase; // ptr to base of shared buffers
	volatile cfloat *pA;    // ptr to global A matrix
	volatile cfloat *pB;    // ptr to global B matrix
	mbox_t          *pCore; // ptr to cores mailbox
} shared_buf_ptr_t;


typedef enum {
	e_fft_fwd = 0,
	e_fft_bwd = 1,
} fft_dir_t;

#endif // __FFT2D_H__
