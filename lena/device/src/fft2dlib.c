/*
  fft2dlib.c

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


#include "fft2dlib.h"
#include "static_buffers.h"

// Generate Wn array
void generateWn(volatile cfloat * restrict Wn, int lgNN)
{
	int   Wc, NN;
	float C, S;

	NN = 1 << lgNN;

	C = Cw_lg[lgNN]; //  Cos(2*Pi/(2^lgNN))
	S = Sw_lg[lgNN]; // -Sin(2*Pi/(2^lgNN))

	Wn[0] = 1.0 + 0.0 * I;
	Wn[0 + (NN >> 1)] = conj(Wn[0]);
	for (Wc=1; Wc<(NN >> 1); Wc++) {
		Wn[Wc] = (C * crealf(Wn[Wc-1]) - S * cimagf(Wn[Wc-1])) +
		         (S * crealf(Wn[Wc-1]) + C * cimagf(Wn[Wc-1])) * I;
		Wn[Wc + (NN >> 1)] = conj(Wn[Wc]);
	}

	return;
}


// Reorder a vector according to bit-reversed index order
void bitrev(volatile cfloat * restrict a, int lgNN, int N)
{
	int i, j, k, n, NN;
	cfloat t;

	n  = 32 - lgNN;
	NN = 1 << lgNN;

	// Do the bit reversal
	for (i=0; i<NN-1; i++) {
		__asm__("bitr %[j], %[i]"     : [j] "=r" (j) : [i] "r"   (i));
#if   _lgSfft == 4
		__asm__("lsr  %[j], %[j], 28" : [j] "=r" (j) : [i] "[j]" (j)); // 28 = 32 - lg2(16)
#elif _lgSfft == 5
		__asm__("lsr  %[j], %[j], 27" : [j] "=r" (j) : [i] "[j]" (j)); // 27 = 32 - lg2(32)
#elif _lgSfft == 6
		__asm__("lsr  %[j], %[j], 26" : [j] "=r" (j) : [i] "[j]" (j)); // 26 = 32 - lg2(64)
#elif _lgSfft == 7
		__asm__("lsr  %[j], %[j], 25" : [j] "=r" (j) : [i] "[j]" (j)); // 25 = 32 - lg2(128)
#else
		__asm__("lsr  %[xj], %[xj], %[xn]" :
				[xj] "=r" (j) :
				[xi] "[xj]" (j) , [xn] "r" (n)); // n = 32 - lg2(NN), j = j >> n;
#endif
		if (i < j) {
			for (k=0; k<N; k++) {
				// sawp(X[i], X[j])
				t         = a[i+k*NN];
				a[i+k*NN] = a[j+k*NN];
				a[j+k*NN] = t;
			}
		}
	}

	return;
}


//#define __SLOW_FFT__
#ifndef __SLOW_FFT__
void fft_1d_r2_dit(int lgN, volatile cfloat * restrict _X, volatile cfloat * restrict _W, int wstride)
{
	int i0, i1, j, l, l1, l2, N, Wc;
	cfloat t;
	cfloat *X;
	cfloat *W;

	X = __builtin_assume_aligned((void *) _X, 8);
	W = __builtin_assume_aligned((void *) _W, 8);

	// Calculate the number of points
	N = 1 << lgN;

	// Compute the FFT - stage #1
	// W[Wc] of first stage is always 1+0i -> avoid multiply
	for (i0=0; i0<N; i0+=2)
	{
		i1 = i0 + 1;

		t = X[i1];
		X[i1] = X[i0] - t;
		X[i0] = X[i0] + t;
	}

	// Compute the FFT - stage #2 to #(lgN-1)
	// N = 32 -> lgN = 5 -> l = 1,2,3 -> l2@i0 = 4,8,16 -> l1@j =  2,4,8
	wstride = wstride >> 1;
	l2 = 2;
	for (l=1; l<(lgN-1); l++)
	{
		// per stage, do
		l1 = l2;
		l2 <<= 1;

		wstride = wstride >> 1;

		// First W[Wc] in a group is always 1+0i -> avoid multiply
		for (i0=0; i0<N; i0+=l2)
		{
			i1 = i0 + l1;

			t = X[i1];
			X[i1] = X[i0] - t;
			X[i0] = X[i0] + t;
		}

		Wc = wstride;

		for (j=1; j<l1; j++)
		{
			for (i0=j; i0<N; i0+=l2)
			{
				i1 = i0 + l1;

				t = W[Wc] * X[i1];
				X[i1] = X[i0] - t;
				X[i0] = X[i0] + t;
			}

			Wc += wstride;
		}
	}

	// last stage, #lgN
	// l = lgN-1 = 4 -> l2@i0 = 32 -> l1@j = 16
	l1 = l2;
	l2 <<= 1;

	wstride = wstride >> 1;

	i0 = 0;
	t = X[l1];
	X[l1] = X[i0] - t;
	X[i0] = X[i0] + t;

	Wc = wstride;

	for (j=1; j<l1; j++) // j = 1,2...14,15
	{
		i0 = j; // i0 = 1,2...14,15
		i1 = i0 + l1;

		t = W[Wc] * X[i1];
		X[i1] = X[i0] - t;
		X[i0] = X[i0] + t;

		Wc += wstride;
	}

	return;
}

#else // __SLOW_FFT__
void fft_1d_r2_dit(int m, volatile cfloat * restrict X, volatile cfloat * restrict W, int wstride)
{
	int i0, i1, j, l, l1, l2, nn, Wc;
	cfloat t;

	// Calculate the number of points
	nn = 1 << m;

	// Compute the FFT
	l2 = 1;
	for (l=0; l<m; l++)
	{
		// per stage, do
		l1 = l2;
		l2 <<= 1;
		Wc = 0;

		wstride = wstride / 2;

		for (j=0; j<l1; j++)
		{
			for (i0=j; i0<nn; i0+=l2)
			{
				i1 = i0 + l1;

				t = W[Wc] * X[i1];
				X[i1] = X[i0] - t;
				X[i0] = X[i0] + t;
			}

			Wc += wstride;
		}
	}

	return;
}
#endif // __SLOW_FFT__


#if !((defined _USE_DMA_I_) && (defined _USE_DMA_E_))
#	warning "Using rowcopy() instead of DMA"
// Copy a row of length NN
void rowcpy(volatile cfloat * restrict a, volatile cfloat * restrict b, int NN)
{
	int i;

	for (i=0; i<NN; i++)
		b[i] = a[i];

	return;
}
#endif


#ifdef __HOST__
// Subtract two NNxNN matrices c = a - b
void matsub(volatile float * restrict a, volatile float * restrict b, volatile float * restrict c, int NN)
{
	int i, j;

	for (i=0; i<NN; i++)
		for (j=0; j<NN; j++)
			c[i*NN+j] = a[i*NN+j] - b[i*NN+j];
	
	return;
}


// Check if a NNxNN matrix is zero
int iszero(volatile float * restrict a, int NN)
{
	int i, j, z;

	z = 0;
	for (i=0; i<NN; i++)
		for (j=0; j<NN; j++)
			if (fabs(a[i*NN+j]) > EPS)
				z = z | 1;

	return (!z);
}
#endif // __HOST__
