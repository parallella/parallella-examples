/*
 * e_fft.c
 *
 * Main code running on the epiphany for the fft test/demo software
 *
 * Copyright (C) 2015 - Sylvain Munaut <tnt@246tNt.com>
 * Copyright (C) 2012 - Adapteva, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 */

#include <complex.h>
#include <stdint.h>
#include <string.h>

#include <e-lib.h>


/* ------------------------------------------------------------------------ */
/* C FFT code                                                               */
/* ------------------------------------------------------------------------ */
/* This is taken from the lena example as reference */

typedef complex float cfloat;

/* Reorder a vector according to bit-reversed index order */
void bitrev(volatile cfloat * restrict a, int lgN)
{
	int i, j, n, N;
	cfloat t;

	n = 32 - lgN;
	N = 1 << lgN;

	// Do the bit reversal
	for (i=0; i<N-1; i++) {
		__asm__("bitr %[j], %[i]"     : [j] "=r" (j) : [i] "r"   (i));
		__asm__("lsr  %[xj], %[xj], %[xn]" :
				[xj] "=r" (j) :
				[xi] "[xj]" (j) , [xn] "r" (n)); // n = 32 - lg2(N), j = j >> n;

		if (i < j) {
			t    = a[i];
			a[i] = a[j];
			a[j] = t;
		}
	}

	return;
}

/* FFT: 1D - Radix 2 - DIT */
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


/* ------------------------------------------------------------------------ */
/* Main                                                                     */
/* ------------------------------------------------------------------------ */

/* Data buffer (defined externally) */
extern float complex twiddle[];
extern float complex data0[];
extern float complex data1[];

/* Optimized assembly fft routines */
extern int fft_1d_r2_dit_asm(float complex *buf, float complex *twiddle, const int logN);

/* Command mailbox */
static volatile uint32_t *cmd = (void*)0x2000;


/* Optimized memcpy */
    /* Only supports double word aligned pointer and len must be a multiple
     * of 32 bytes ! */
static void
memcpy_aligned(void *dst, void *src, int len)
{
	__asm__ __volatile__ (
		"lsr %[len], %[len], #5		\n"
		"movts lc, %[len]		\n"
		"mov %[len], %%low(1f)		\n"
		"movt %[len], %%high(1f)	\n"
		"movts ls, %[len]		\n"
		"mov %[len], %%low(2f - 4)	\n"
		"movt %[len], %%high(2f - 4)	\n"
		"movts le, %[len]		\n"
		".balignw 8,0x01a2		\n"
		"1:				\n"
		"ldrd r56, [%[src]], #1		\n"
		"ldrd r58, [%[src]], #1		\n"
		"ldrd r60, [%[src]], #1		\n"
		"ldrd r62, [%[src]], #1		\n"
		"strd r56, [%[dst]], #1		\n"
		"strd r58, [%[dst]], #1		\n"
		"strd r60, [%[dst]], #1		\n"
		"strd r62, [%[dst]], #1		\n"
		"2:				\n"

		: [dst] "+r" (dst), [src] "+r" (src), [len] "+r" (len)
		:
		: "r56", "r57", "r58", "r59",
		  "r60", "r61", "r62", "r63",
		  "lc", "ls", "le", "memory"
	);
}

/* Main */
int main(int argc, char *argv[])
{
	int iter, logN, buf_len, type;
	uint32_t time_s, time_e;

	while (1)
	{
		/* Wait for command signal */
		while (cmd[0] == 0);

		/* Parse command */
		type    = (cmd[0] >> 31);
		logN    = (cmd[0] >> 24) & 0x7f;
		iter    = (cmd[0]      ) & 0xffffff;
		buf_len = 8 << logN;

		/* Copy input data */
		memcpy_aligned(data1, data0, buf_len);

		/* Run loop in-place for benchmarking */
		if (type)
		{
			while (iter--)
				fft_1d_r2_dit_asm(data1, twiddle, logN);
		}
		else
		{
			while (iter--)
				fft_1d_r2_dit(logN, data1, twiddle, 1 << logN);
		}

		/* Do 1 run with fresh data for correctness test and
		 * counter data gathering */
		memcpy_aligned(data1, data0, buf_len);

		e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX);
		e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);

		if (type) {
			time_s = e_ctimer_get(E_CTIMER_0);
			fft_1d_r2_dit_asm(data1, twiddle, logN);
			time_e = e_ctimer_get(E_CTIMER_0);
			bitrev(data1, logN);
		} else {
			bitrev(data1, logN);
			time_s = e_ctimer_get(E_CTIMER_0);
			fft_1d_r2_dit(logN, data1, twiddle, 1 << logN);
			time_e = e_ctimer_get(E_CTIMER_0);
		}

		cmd[1] = time_s - time_e;

		/* Signal completion */
		cmd[0] = 0;
	}
}
