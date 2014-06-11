/*
  fft2dlib.h

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


#ifndef __FFT2DLIB_H__
#define __FFT2DLIB_H__
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <complex.h>

typedef complex float cfloat;

#define M_PI        3.14159265358979323846
#define M_TWOPI     6.28318530717958647692
#define M_PIOVERTWO 1.57079632679489661923

void rowcpy(volatile cfloat * restrict a, volatile cfloat * restrict b, int NN);
void generateWn(volatile cfloat * restrict Wn, int lgNN);
void bitrev(volatile cfloat * restrict a, int lgNN, int N);
void fft_1d_r2_dit(int lgN, volatile cfloat * restrict X, volatile cfloat * restrict W, int wstride);

#define STIMER(time_v)                       \
if (me.corenum == 0)                         \
{                                            \
	time32[0] = *(p_sys_timer + 1);          \
	time32[1] = *(p_sys_timer + 0);          \
	time32[2] = *(p_sys_timer + 1);          \
	time32[3] = *(p_sys_timer + 0);          \
	if (time32[0] == time32[2])              \
	{                                        \
		time_v = (uint64_t) time32[0];       \
		time_v = (time_v << 32) | time32[1]; \
	} else {                                 \
		time_v = (uint64_t) time32[2];       \
		time_v = (time_v << 32) | time32[3]; \
	}                                        \
}

#ifdef __HOST__
void matsub(volatile float * restrict a, volatile float * restrict b, volatile float * restrict c, int NN);
int  iszero(volatile float * restrict a, int NN);
#endif // __HOST__

#endif // __FFT2DLIB_H__
