/*
 * Copyright (c) 2015 Brown Deer Technology, LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * This software was developed by Brown Deer Technology, LLC.
 * For more information contact info@browndeertechnology.com
 */

/* DAR */

#include <complex.h>
#define cfloat float complex
#include <float.h>
#include <string.h>
#if 0
#include <stdint.h>
#else
/* Workaround: Including stdint result in clcc1 segfault, oh and typedefs
 * won't work either ... */
#define uint8_t		unsigned char
#define uint16_t	unsigned short
#define uint32_t	unsigned int
#define uint64_t	unsigned long long

#define int8_t		char
#define int16_t		short
#define int32_t		int
#define int64_t		long long

#define uintptr_t	unsigned int
#endif

#include <coprthr.h>

/* Use repo version. Doesn't matter for device code right now though */
#include "coprthr_mpi.h"

/* struct my_args */
#include "device.h"

void bitreverse_swap(uint16_t * const brp, void *p_data)
{
	uint16_t i, j;
	int k;

        cfloat *data = (cfloat *) p_data;

	for (k=0; brp[k]; ) {
		i = brp[k++];
		j = brp[k++];
		cfloat tmp = data[i];
		data[i] = data[j];
		data[j] = tmp;
	}
}

void fft_r2_dit(unsigned int n, unsigned int m, void* p_wn, void* p_data )
{
	cfloat* wn = (cfloat*)p_wn;
	cfloat* data = (cfloat*)p_data;

	int l,l1,l2,wstride = n;
	int i0,i1;
	l2 = 1;
	for(l=0; l<m; l++) {
		l1 = l2;
		l2 <<= 1;
		int i=0, j;
		wstride = wstride >> 1;
		for(j=0; j<l1; j++) {
			cfloat wni = wn[i];
			for(i0=j; i0<n; i0+=l2) {
				i1 = i0 + l1;
				cfloat tmp0 = data[i0];
				cfloat tmp = wni * data[i1];
				data[i1] = tmp0 - tmp;
				data[i0] = tmp0 + tmp;
			}
			i += wstride;
		}
	}
}


void corner_turn( 
	int nprocs, int rank, void* p_data, unsigned int n, unsigned int nlocal,
	void* p_comm 
) {
	cfloat* data = (cfloat*)p_data;
	MPI_Comm comm = (MPI_Comm)p_comm;

	MPI_Status status;

	void* memfree = coprthr_tls_sbrk(0);
	cfloat* buf2 = (cfloat*)coprthr_tls_sbrk(nlocal*nlocal*sizeof(cfloat));

	int i, j, k = rank, l;

	int ct = (nprocs - k) % nprocs;

	for(l=0;l<nprocs;l++) {

		cfloat* src = data + ct*nlocal;
		cfloat* dst = buf2;
		for(i=0;i<nlocal;i++) {
			uint64_t *psrc = (uint64_t *)src;
			uint64_t *pdst = (uint64_t *)dst;
			for(j=0; j<nlocal; j+=4) {
				*(pdst++) = *(psrc++);
				*(pdst++) = *(psrc++);
				*(pdst++) = *(psrc++);
				*(pdst++) = *(psrc++);
			}
			src += n;
			dst += nlocal;
		}

		MPI_Sendrecv_replace(buf2,2*nlocal*nlocal,MPI_FLOAT,
				     ct,11,ct,11,comm,&status);


		for(i=0;i<nlocal;i++) {
			cfloat* pdst = data+ct*nlocal+i;
			cfloat* psrc = buf2+i*nlocal;
			for(j=0; j<nlocal; j+=4) {
				*pdst = *psrc++;
				pdst += n;
				*pdst = *psrc++;
				pdst += n;
				*pdst = *psrc++;
				pdst += n;
				*pdst = *psrc++;
				pdst += n;
			}
		}

		ct = (ct+1) % nprocs;

	}

	coprthr_tls_brk(memfree);

}

void normalize2(void *p_comm, int nprocs, int rank,
		unsigned int nlocal, unsigned int n, void *p_signal)
{
	MPI_Comm comm = (MPI_Comm) p_comm;
	MPI_Status status;
	cfloat *signal = (cfloat *) p_signal;

	int i = 0, j = 0;
	float local_sum = 0, total_sum = 0, mean = 0;

	void* memfree = coprthr_tls_sbrk(0);
	float *buf = (float *) coprthr_tls_sbrk(8);

	/* First sum local portion of signal */

	/* Zero padded input signal */

	for (i = 0; i < nlocal; i++) {
		for (j = 0; j < n / 2; j++)
			local_sum += crealf(signal[i * n + j]);
	}

	int ct = (nprocs - rank) % nprocs;
	for (i = 0; i < nprocs; i++) {
		*buf = local_sum;

		MPI_Sendrecv_replace(buf, 2, MPI_FLOAT,
				     ct, 25 , ct, 25, comm, &status);

		/* Zero padded entire lower half is black */
		if (ct == rank)
			*buf = local_sum;

		if (ct < nprocs / 2)
			total_sum += *buf;

		ct = (ct + 1) % nprocs;
	}

	/* again it's zero padded */
	mean = total_sum / ((float) (n * n / 4));

	/* normalize local portion of signal */
	if (rank < nprocs / 2) {
		for (i = 0; i < nlocal; i++) {
			for (j = 0; j < n / 2; j++)
				signal[i * n + j] -= mean;
		}
	}

	coprthr_tls_brk(memfree);
}

float global_max(void *p_comm, int nprocs, int rank,
		 unsigned int nlocal, unsigned int n, void *p_signal)
{
	MPI_Comm comm = (MPI_Comm) p_comm;
	MPI_Status status;
	cfloat *signal = (cfloat *) p_signal;

	int i = 0, j = 0;
	float my_max = FLT_MIN, max = FLT_MIN;

	void* memfree = coprthr_tls_sbrk(0);
	float *buf = (float *) coprthr_tls_sbrk(8);

	/* First calculate local max of signal */
	for (i = 0, my_max = FLT_MIN; i < nlocal * n; i++) {
		if (crealf(signal[i]) > my_max)
			my_max = crealf(signal[i]);
	}

	int ct = (nprocs - rank) % nprocs;
	for (i = 0; i < nprocs; i++) {
		*buf = my_max;

		MPI_Sendrecv_replace(buf, 2, MPI_FLOAT,
				     ct, 25 , ct, 25, comm, &status);

		if (ct == rank)
			*buf = my_max;

		if (*buf > max)
			max = *buf;

		ct = (ct + 1) % nprocs;
	}

	coprthr_tls_brk(memfree);
	return max;
}



void fft2d(void *comm, int nprocs, int rank, unsigned int nlocal,
	   unsigned int n, unsigned int m, uint16_t *brp, void *p_wn,
	   void *p_signal)
{
	cfloat *s;
	unsigned int row;

	//// bit-reversal swap in-place
	for(s = (cfloat *) p_signal, row = 0; row < nlocal; row++, s += n) {
		bitreverse_swap(brp, s);
	}

	for(s = (cfloat *) p_signal, row=0; row < nlocal; row++, s += n) {
		fft_r2_dit(n, m, p_wn, s);
	}

	//// corner turn
	corner_turn(nprocs, rank, p_signal, n, nlocal, comm);

	//// bit-reversal swap in-place
	for(s = (cfloat *) p_signal, row=0; row < nlocal; row++, s += n) {
		bitreverse_swap(brp, s);
	}

	//// forward FFT
	for(s = (cfloat *) p_signal, row=0; row < nlocal; row++, s += n) {
		fft_r2_dit(n, m, p_wn, s);
	}

	//// corner turn
	corner_turn(nprocs, rank, p_signal, n, nlocal, comm);
}

float xcorr_one(void *p_comm, int nprocs, int myrank, void *pargs,
		unsigned int nlocal, uint8_t *bitmap, void *brp, void *p_l_tmp_fft)
{
	MPI_Comm comm = (MPI_Comm)p_comm;
	struct my_args *args = (struct my_args *) pargs;
	cfloat *g_wn_fwd = args->wn_fwd;
	cfloat *g_wn_bwd = args->wn_bwd;
	const float divider = 1.0f/255.0f;
	const int width = args->n / 2;
	const int height = args->n / 2;

	size_t wn_sz		= args->n * sizeof(cfloat);
	size_t brp_sz		= 2 * args->n * sizeof(uint16_t);
	size_t l_fft_sz		= nlocal * args->n * sizeof(cfloat);

	int i, j;

	// offset to bitmap (assume needs zero padding)

	void *memfree = coprthr_tls_sbrk(0);

	cfloat *l_tmp_fft = (cfloat *) p_l_tmp_fft;

	// FFT IMG B
	if (myrank < nprocs / 2)
		e_dma_copy(l_tmp_fft, bitmap, nlocal*width * sizeof(*bitmap));
		//e_dma_copy(l_tmp_fft, g_cmp_bmp + myrank * nlocal * width, nlocal*width * sizeof(*g_cmp_bmp));

	uint8_t *bptr = (uint8_t *) l_tmp_fft;
	cfloat *cptr = (cfloat *) l_tmp_fft;

	if (myrank < nprocs / 2) {
		// zeropad (lower part always zero)
		for (i = nlocal - 1; i > 0; i--) {
			for (j = width -1 ; j >= 0; j--)
				bptr[i * args->n + j] = bptr[i * width + j];
		}
		for (i = 0; i < nlocal; i++) {
			for (j = width; j < args->n; j++)
				bptr[i * args->n + j] = 0;
		}
		// Unpack image (uint8_t -> cfloat) backwards
		int last = nlocal * args->n - 1;
		for (i = last; i >= 0; i--)
			l_tmp_fft[i] = ((float) bptr[i]) * divider;
	} else {
		for (i = 0; i < nlocal * args->n; i++)
			cptr[i] = 0;
	}

	/* Normalize signal to zero out DC component */
	normalize2(comm, nprocs, myrank, nlocal, args->n, l_tmp_fft);

	/* Copy fwd wn coeffs to local mem */
	cfloat *wn = (cfloat *) coprthr_tls_sbrk(wn_sz);
	e_dma_copy(wn, g_wn_fwd, wn_sz);

	fft2d(comm, nprocs, myrank, nlocal, args->n, args->m, brp, wn,
	      l_tmp_fft);

	coprthr_tls_brk(wn);

	// tmp = A * conj(B)

	/* Not enough core SRAM to store two FFTs + code ...
	 * So we resort to copying in smaller chunks of ref FFT...
	 * It is possible to get the number of iterations down to 4 if you patch
	 * COPRTHR to use -Os instead of -O3 when compiling this code.
	 *
	 * TODO: Investigate if we can get rid of this (fit two FFTs in mem)
	 * or at least get the number of iterations down.
	 */


	size_t small_iters = 8;
	size_t n_small = args->n * nlocal / small_iters;
	size_t sz_small = n_small * sizeof(cfloat);
	cfloat *l_ref_fft = (cfloat *) coprthr_tls_sbrk(sz_small);

	for (i = 0; i < small_iters; i++) {
		e_dma_copy(l_ref_fft,
			   args->ref_fft + myrank * nlocal * args->n + i * n_small,
			   sz_small);

		for (j = 0; j < n_small; j++) {
			l_tmp_fft[i * n_small + j] =
				l_ref_fft[j] * conjf(l_tmp_fft[i * n_small + j]);
		}
	}
	/* Free ref fft */
	coprthr_tls_brk(l_ref_fft);

	/* Bring in wn_bwd coeffs */
	wn = (cfloat *) coprthr_tls_sbrk(wn_sz);
	e_dma_copy(wn, g_wn_bwd, wn_sz);
	/* IFFT() */
	fft2d(comm, nprocs, myrank, nlocal, args->n, args->m, brp, wn,
	      l_tmp_fft);

	/* Free wn */
	coprthr_tls_brk(wn);

	float max = global_max(comm, nprocs, myrank, nlocal, args->n, l_tmp_fft);

	coprthr_tls_brk(memfree);

	return max;
}

/* TODO: xcorr_batch */
__kernel void
my_thread (void *p) {
	struct my_args args;

        memcpy(&args, p, sizeof(args));

	cfloat *g_wn_fwd = args.wn_fwd;
	cfloat *g_wn_bwd = args.wn_bwd;

	int i,j,k,l;
	int row;

	const float divider = 1.0f/255.0f;

	int nprocs;
	int myrank;

	MPI_Init(0, MPI_BUF_SIZE);

	MPI_Comm comm = MPI_COMM_THREAD;

	MPI_Comm_size(comm, &nprocs);
	MPI_Comm_rank(comm, &myrank);

	size_t nlocal = args.n / nprocs;

	size_t wn_sz		= args.n * sizeof(cfloat);
	size_t brp_sz		= 2 * args.n * sizeof(uint16_t);
	size_t l_fft_sz		= nlocal * args.n * sizeof(cfloat);

	const int width = args.n / 2;
	const int height = args.n / 2;

	/* Probably unneccessary */
	uintptr_t align = ((uintptr_t) coprthr_tls_sbrk(0)) & 7;
	coprthr_tls_sbrk(align);

	void *memfree = coprthr_tls_sbrk(0);

	uint16_t *brp = (uint16_t *) coprthr_tls_sbrk((brp_sz+7) & ~7);
	for (i = 0; i < brp_sz / sizeof(*brp); i++)
		brp[i] = 0;

	for(i = 0, k = 0; i < args.n; i++) {
		int x = i;
		int y = 0;
		for(j=0; j < args.m; j++)
			y = (y << 1) | ((x >> j) & 1);
		if (x < y) {
			brp[k++] = x;
			brp[k++] = y;
		}
	}

	/* Copy IMG A (reference image) to local memory */
	cfloat* l_tmp_fft  = (cfloat *) coprthr_tls_sbrk(l_fft_sz);
	if (myrank < nprocs / 2) {
		e_dma_copy(l_tmp_fft, args.ref_bitmap + myrank * nlocal * width,
			   nlocal * args.n * sizeof(uint8_t));
	}

	uint8_t *bptr = (uint8_t *) l_tmp_fft;
	cfloat *cptr = (cfloat *) l_tmp_fft;

	if (myrank < nprocs / 2) {
		// zeropad (lower part always zero)
		for (i = nlocal - 1; i > 0; i--) {
			for (j = width -1 ; j >= 0; j--)
				bptr[i * args.n + j] = bptr[i * width + j];
		}
		for (i = 0; i < nlocal; i++) {
			for (j = width; j < args.n; j++)
				bptr[i * args.n + j] = 0;
		}
		// Unpack image (uint8_t -> cfloat) backwards
		int last = nlocal * args.n - 1;
		for (i = last; i >= 0; i--)
			l_tmp_fft[i] = ((float) bptr[i]) * divider;
	} else {
		for (i = 0; i < nlocal * args.n; i++)
			cptr[i] = 0;
	}

	/* Normalize signal to zero out DC component */
	normalize2(comm, nprocs, myrank, nlocal, args.n, l_tmp_fft);

	/* Copy fwd wn coeffs to local mem */
	cfloat *wn = (cfloat *) coprthr_tls_sbrk(wn_sz);
	e_dma_copy(wn, g_wn_fwd, wn_sz);


	// FFT IMG A
	fft2d(comm, nprocs, myrank, nlocal, args.n, args.m, brp, wn,
	      l_tmp_fft);

	/* Copy back to shared RAM */
	e_dma_copy(args.ref_fft + myrank * nlocal * args.n, l_tmp_fft,
		   l_fft_sz);

	// Free wn
	coprthr_tls_brk(wn);

	/* Compute autocorrelation */
	float autocorr = xcorr_one(comm, nprocs, myrank, &args, nlocal,
				   args.ref_bitmap + myrank * nlocal * width,
				   brp, l_tmp_fft);

	int nbitmap = 0;

	/* Iterate over all bitmaps in args.bitmaps */
	for (nbitmap = 0; nbitmap < args.nbitmaps; nbitmap++) {
		uint8_t *bitmap = args.bitmaps + nbitmap * width * height;
		uint8_t *myportion = bitmap + myrank * nlocal * width;

		float xcorr;
		xcorr = xcorr_one(comm, nprocs, myrank, &args, nlocal, myportion,
				  brp, l_tmp_fft);

		/* Root writes back result */
		if (myrank == 0) {
			float corr;

			/* Report results as factor of autocorrelation. */
			if (xcorr > autocorr)
				corr = autocorr / xcorr;
			else
				corr = xcorr / autocorr;

			args.results[nbitmap] = corr;
		}
	}

	coprthr_tls_brk(memfree);

	MPI_Finalize();
}
