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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <math.h>
#include <complex.h>
#include <float.h>
#include <stdbool.h>

#include <coprthr.h>
#include <coprthr_cc.h>
#include <coprthr_thread.h>
#include <coprthr_sched.h>

/* Use repo header */
#include "coprthr_mpi.h"
/* ... and check that we have the right header */
#ifndef __coprthr_mpi_fft
#error Wrong MPI header got included
#endif

#include "demo.h"

/* struct my_args */
#include "device.h"

#define __free free
#define __free_event(ev) do { \
	__coprthr_free_event(ev); \
	free(ev); \
} while(0)


typedef float complex cfloat;

#define NPROCS 16
#define NSIZE 128
#define MSIZE 7


/* Global state */
struct {
	bool initialized;
	cfloat *wn_fwd;
	cfloat *wn_bwd;
	int coprthr_dd;			/* Device descriptor */
	coprthr_program_t coprthr_prg;	/* COPRTHR device program */
	coprthr_sym_t coprthr_fn;	/* Thread function symbol */
	coprthr_mem_t wn_fwd_mem;
	coprthr_mem_t wn_bwd_mem;
	coprthr_mem_t ref_bmp_mem;
	coprthr_mem_t bmps_mem;
	coprthr_mem_t ref_fft_mem;
	coprthr_mem_t results_mem;
} GLOB = {
	.initialized = false,
	.wn_fwd = NULL,
	.wn_bwd = NULL,
	.coprthr_dd = -1,
	.coprthr_prg = NULL,
	.coprthr_fn = NULL,
	.wn_fwd_mem = NULL,
	.wn_bwd_mem = NULL,
	.ref_bmp_mem = NULL,
	.bmps_mem = NULL,
	.ref_fft_mem = NULL,
	.results_mem = NULL,
};

static void generate_wn_(unsigned int n, unsigned int m, int sign, float* cc,
			 float* ss, cfloat* wn)
{
	int i;

	float c = cc[m];
	float s = sign * ss[m];

	int n2 = n >> 1;

	wn[0] = 1.0f + 0.0f * I;
	wn[0 + n2] = conj(wn[0]);

	for(i=1; i<n2; i++) {
		wn[i] = (c * crealf(wn[i-1]) - s * cimagf(wn[i-1])) +
			(s * crealf(wn[i-1]) + c * cimagf(wn[i-1])) * I;
		wn[i + n2] = conj(wn[i]);
	}
}

static void free_wn()
{
	if (GLOB.wn_fwd)
		free(GLOB.wn_fwd);
	if (GLOB.wn_bwd)
		free(GLOB.wn_bwd);

	GLOB.wn_fwd = GLOB.wn_bwd = NULL;
}

static bool generate_wn(unsigned int n, unsigned int m)
{
	int i;
	float *cc, *ss;

	if (GLOB.wn_fwd)
		return true;

	/* Allocate sin and cos tables on stack (they're small) */
	cc = (float *) alloca(16 * sizeof(float));
	ss = (float *) alloca(16 * sizeof(float));

	GLOB.wn_fwd = (cfloat *) malloc(n * sizeof(cfloat));
	GLOB.wn_bwd = (cfloat *) malloc(n * sizeof(cfloat));
	if (!GLOB.wn_fwd || !GLOB.wn_bwd) {
		free_wn();
		return false;
	}

	/* initialize cos/sin table */
	for(i = 0; i < 16; i++) {
		cc[i] = + (float) cos(2.0 * M_PI / pow(2.0, (double)i));
		ss[i] = - (float) sin(2.0 * M_PI / pow(2.0, (double)i));
	}

	/* Generate WN coeffs */
	generate_wn_( n, m, +1, cc, ss, GLOB.wn_fwd);
	generate_wn_( n, m, -1, cc, ss, GLOB.wn_bwd);

	return true;
}

void cleanup()
{
	if (GLOB.coprthr_dd > -1) {
		coprthr_dclose(GLOB.coprthr_dd);
		GLOB.coprthr_dd = -1;
	}

	/* Not pretty, from coprthr code, but at least we're only leaking
	 * ~3kb now (compared to 70kb) ... */
	if (GLOB.coprthr_prg) {
		free(GLOB.coprthr_prg->bin);
		free(GLOB.coprthr_prg);
		GLOB.coprthr_prg = NULL;
	}

	if (GLOB.coprthr_fn) {
		free(GLOB.coprthr_fn->arg_off);
		free(GLOB.coprthr_fn->arg_buf);
		free(GLOB.coprthr_fn);
		GLOB.coprthr_fn = NULL;
	}

	free_wn();

	/* TODO: Free GLOB.*mem buffers */
}

void fftimpl_fini()
{
	if (!GLOB.initialized)
		return;

	cleanup();

	GLOB.initialized = false;
}

/* TODO: Error check */
static bool allocate_bufs()
{
	size_t wn_sz = NSIZE * sizeof(cfloat);
	size_t bitmap_sz = NSIZE * NSIZE * sizeof(uint8_t);

	size_t bmp_sz = MAX_BITMAPS * (NSIZE / 2) * (NSIZE / 2) * sizeof(uint8_t);

	/* allocate memory on device */
	GLOB.wn_fwd_mem	= coprthr_dmalloc(GLOB.coprthr_dd, wn_sz, 0);
	GLOB.wn_bwd_mem	= coprthr_dmalloc(GLOB.coprthr_dd, wn_sz, 0);
	GLOB.ref_bmp_mem= coprthr_dmalloc(GLOB.coprthr_dd, bitmap_sz, 0);
	/* / 2 since we use float here, /4 == no transfer zero pad */
	GLOB.bmps_mem	= coprthr_dmalloc(GLOB.coprthr_dd, bmp_sz, 0);
	GLOB.ref_fft_mem= coprthr_dmalloc(GLOB.coprthr_dd, bitmap_sz, 0);
	/* TODO: nmbr of bitmaps in bmps_mem * sizeof(float) */
	GLOB.results_mem= coprthr_dmalloc(GLOB.coprthr_dd,
					  MAX_BITMAPS * sizeof(float), 0);

	return true;
}

bool fftimpl_init()
{
	if (GLOB.initialized)
		return true;

	/* Generate WN coeffs */
	if (!generate_wn(NSIZE, MSIZE)) {
		fprintf(stderr,
			"ERROR: Failed generating wn coeffs.\n");

		return false;
	}

	/* Open device for threads */
	GLOB.coprthr_dd = coprthr_dopen(COPRTHR_DEVICE_E32,COPRTHR_O_THREAD);
	if (GLOB.coprthr_dd < 0 ) {
		fprintf(stderr, "ERROR: Device open failed: %d\n",
			GLOB.coprthr_dd);

		return false;
	}

	/* Read device binary */
	GLOB.coprthr_prg = coprthr_cc_read_bin(DEVICE_BINARY, 0);
	if (!GLOB.coprthr_prg) {
		fprintf(stderr,
			"ERROR: Failed reading device binary %s. Check file permissions\n",
			DEVICE_BINARY);

		goto fail;
	}


	/* Get handle to thread function */
	GLOB.coprthr_fn = coprthr_getsym(GLOB.coprthr_prg, "my_thread");
	if (!GLOB.coprthr_fn) {
		fprintf(stderr,
			"ERROR: Could not find symbol in device binary.\n");

		goto fail;
	}

	/* TODO: Print error */
	if (!allocate_bufs())
		goto fail;

	atexit(fftimpl_fini);
	GLOB.initialized = true;
	return true;

fail:
	cleanup();

	return false;
}

bool fftimpl_xcorr(uint8_t *ref_bmp, uint8_t *bmps, int nbmps,
		   int width, int height, float *out_corr)
{
	/* COPRTHR event */
	coprthr_event_t ev;

	if (nbmps > MAX_BITMAPS) {
		fprintf(stderr,
			"ERROR: coprthr fftimpl_xcorr supports up to %d bitmaps in one go\n",
			MAX_BITMAPS);
		return false;
	}

	/* Current device algo can only support up to 128x128 including
	 * zero padding. */
	if (width != NSIZE / 2 || height != NSIZE / 2) {
		fprintf(stderr,
			"ERROR: Input image dimensions must be %dx%d\n",
			NSIZE / 2, NSIZE / 2);
		return false;
	}

	/* copy wn coeffs to device memory (shared mem) */
	ev = coprthr_dwrite(GLOB.coprthr_dd, GLOB.wn_fwd_mem, 0, GLOB.wn_fwd,
			    NSIZE * sizeof(cfloat), COPRTHR_E_WAIT);
	__free_event(ev);
	ev = coprthr_dwrite(GLOB.coprthr_dd, GLOB.wn_bwd_mem, 0, GLOB.wn_bwd,
			    NSIZE * sizeof(cfloat), COPRTHR_E_WAIT);
	__free_event(ev);


	/* Copy A (reference image) to device (shared mem) */
	ev = coprthr_dwrite(GLOB.coprthr_dd, GLOB.ref_bmp_mem, 0, ref_bmp,
			    width * height * sizeof(uint8_t), COPRTHR_E_WAIT);
	__free_event(ev);

	/* Copy bitmaps to compare to device (shared mem). */
	ev = coprthr_dwrite(GLOB.coprthr_dd, GLOB.bmps_mem, 0, bmps,
			    nbmps * width * height * sizeof(uint8_t), COPRTHR_E_WAIT);
	__free_event(ev);

	/* Calculate FFT for image A */
	struct my_args args_xcorr = {
		.n		= NSIZE,
		.m		= MSIZE,
		.wn_fwd		= (__e_ptr(cfloat)) coprthr_memptr(GLOB.wn_fwd_mem, 0),
		.wn_bwd		= (__e_ptr(cfloat)) coprthr_memptr(GLOB.wn_bwd_mem,0),
		.ref_bitmap	= (__e_ptr(uint8_t)) coprthr_memptr(GLOB.ref_bmp_mem, 0),
		.bitmaps	= (__e_ptr(uint8_t)) coprthr_memptr(GLOB.bmps_mem, 0),
		.nbitmaps	= nbmps,
		.ref_fft	= (__e_ptr(cfloat)) coprthr_memptr(GLOB.ref_fft_mem, 0),
		.results	= (__e_ptr(float)) coprthr_memptr(GLOB.results_mem, 0),
	};

	coprthr_mpiexec(GLOB.coprthr_dd, NPROCS, GLOB.coprthr_fn, &args_xcorr,
			sizeof(args_xcorr), 0);

	/* read back data from memory on device */
	ev = coprthr_dread(GLOB.coprthr_dd, GLOB.results_mem, 0, out_corr,
			   nbmps * sizeof(float), COPRTHR_E_WAIT);
	__free_event(ev);

	return true;
}

