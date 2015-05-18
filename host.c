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
#include <stdbool.h>
typedef float complex cfloat;

#include "coprthr.h"
#include "coprthr_cc.h"
#include "coprthr_thread.h"
#include "coprthr_mpi.h"

#define NPROCS 16
#define NSIZE 128
#define MSIZE 7

#define frand() ((float)rand()/(float)RAND_MAX)

float *jpeg_file_to_grayscale(char *path, int *width, int *height);
float *jpeg_to_grayscale(void *jpeg, size_t jpeg_size, int *width, int *height);
bool grayscale_to_jpeg_file(float *bitmap, int width, int height, char *path);

static cfloat *wn_fwd = NULL;
static cfloat *wn_inv = NULL;

static void generate_wn_( 
	unsigned int n, unsigned int m, int sign, 
	float* cc, float* ss, cfloat* wn 
) {
   int i;

   float c = cc[m];
   float s = sign * ss[m];

   int n2 = n >> 1;

   wn[0] = 1.0f + 0.0f * I;
   wn[0 + n2] = conj(wn[0]);

   for(i=1; i<n2; i++) {
      wn[i] = (c * crealf(wn[i-1]) - s * cimagf(wn[i-1]))
         + (s * crealf(wn[i-1]) + c * cimagf(wn[i-1])) * I;
      wn[i + n2] = conj(wn[i]);
   }
}

static void free_wn()
{
	free(wn_fwd);
	free(wn_inv);

	wn_fwd = wn_inv = NULL;
}

static void generate_wn(unsigned int n, unsigned int m)
{
	int i;
	float *cc, *ss;

	if (wn_fwd)
		return;

	/* Allocate sin and cos tables on stack (they're small) */
	cc = (float *) alloca(16 * sizeof(float));
	ss = (float *) alloca(16 * sizeof(float));

	wn_fwd = (cfloat *) malloc(n * sizeof(cfloat));
	wn_inv = (cfloat *) malloc(n * sizeof(cfloat));

	/* Free wn coeffs on exit */
	atexit(free_wn);

	/* initialize cos/sin table */
	for(i = 0; i < 16; i++) {
		cc[i] = (float)cos( 2.0 * M_PI / pow(2.0,(double)i) );
		ss[i] = - (float)sin( 2.0 * M_PI / pow(2.0,(double)i) );
		printf("%2.16f %2.16f\n",cc[i],ss[i]);
	}

	/* Generate WN coeffs */
	generate_wn_( n, m, +1, cc, ss, wn_fwd);
	generate_wn_( n, m, -1, cc, ss, wn_inv);
}

struct my_args {
	unsigned int n;
	unsigned int m;
	int inverse;
	cfloat* wn;
	cfloat* data2;
};

bool xcorr(float *A, float *B, int width, int height, float *retval)
{
	int i, j, k;
	struct timeval t0, t1, t2, t3;

	unsigned int n = NSIZE;
	unsigned int m = MSIZE;

	float A_mean = 0, B_mean = 0;	/* Means */

	int dd;				/* Device descriptor */
	coprthr_program_t prg;		/* COPRTHR device program */
	coprthr_sym_t thr;		/* Thread function symbol */

	if (width != NSIZE || height != NSIZE) {
		fprintf(stderr, "ERROR: Width and height must be %d\n", MSIZE);
		return false;
	}


	/* open device for threads */
	dd = coprthr_dopen(COPRTHR_DEVICE_E32,COPRTHR_O_THREAD);
	if (dd < 0 ) {
		fprintf(stderr, "Device open failed: %d\n", dd);
		return false;
	}

	/* compile thread function */
	prg = coprthr_cc_read_bin(DEVICE_BINARY, 0);
	if (!prg) {
		fprintf(stderr,
			"Error reading target binary %s. Check file permissions\n",
			DEVICE_BINARY);
		/* Clean up ? */
		return false;
	}

	thr = coprthr_getsym(prg,"my_thread");
	if (!thr) {
		fprintf(stderr,
			"ERROR: Could not find symbol in device binary.\n");
		/* Cleanup? */
		return false;
	}

	/* allocate memory on host */
	cfloat* A_cbitmap = (cfloat*)malloc(n*n*sizeof(cfloat));
	cfloat* A_fft = (cfloat*)malloc(n*n*sizeof(cfloat));
	cfloat* B_fft = (cfloat*)malloc(n*n*sizeof(cfloat));
	cfloat* C_fft = (cfloat*)malloc(n*n*sizeof(cfloat));
	cfloat* C = (cfloat*)malloc(n*n*sizeof(cfloat));
	cfloat* B_cbitmap = (cfloat*)malloc(n*n*sizeof(cfloat));

	/* Generate WN coeffs */
	generate_wn(n, m);

	/* Calculate means */
	for (i = 0; i < n * n; i++) {
		A_mean = (A_mean * (i + 0.0f) + A[i]) / (i + 1.0f);
		B_mean = (B_mean * (i + 0.0f) + B[i]) / (i + 1.0f);
	}

#if 1
	/* Should we do this ??? */

	/* Normalize (yes this is naive) */
	for(i = 0; i < n * n; i++) {
		A[i] -= A_mean;
		B[i] -= B_mean;
	}
#endif

	/* initialize data */
	for (i = 0; i < n * n; i++) {
		A_cbitmap[i] = A[i];
		B_cbitmap[i] = B[i];
	}

	/* allocate memory on device */
	coprthr_mem_t wn_mem = coprthr_dmalloc(dd,n*sizeof(cfloat),0);
	coprthr_mem_t A_mem = coprthr_dmalloc(dd,n*n*sizeof(cfloat),0);
	coprthr_mem_t B_mem = coprthr_dmalloc(dd,n*n*sizeof(cfloat),0);
	coprthr_mem_t C_mem = coprthr_dmalloc(dd,n*n*sizeof(cfloat),0);

	/* copy memory to device */
	coprthr_dwrite(dd,wn_mem,0,wn_fwd,n*sizeof(cfloat),COPRTHR_E_WAIT);
	coprthr_dwrite(dd,A_mem,0, A_cbitmap,n*n*sizeof(cfloat),COPRTHR_E_WAIT);

	/* Calculate FFT for image A */
	struct my_args args_a_fft = {
		.n = n, .m = m,
		.inverse = 0,
		.wn = coprthr_memptr(wn_mem,0),
		.data2 = coprthr_memptr(A_mem,0)
	};

	gettimeofday(&t0,0);
	coprthr_mpiexec(dd, NPROCS, thr, &args_a_fft, sizeof(args_a_fft), 0);
	gettimeofday(&t1,0);

	/* read back data from memory on device */
	coprthr_dread(dd, A_mem,0, A_fft,n*n*sizeof(cfloat), COPRTHR_E_WAIT);

	coprthr_dwrite(dd,wn_mem,0,wn_fwd,n*sizeof(cfloat),COPRTHR_E_WAIT);
	coprthr_dwrite(dd, B_mem,0, B_cbitmap,n*n*sizeof(cfloat),COPRTHR_E_WAIT);

	/* Calculate FFT for bitmap B */
	struct my_args args_b_fft = {
		.n = n, .m = m,
		.inverse = 0,
		.wn = coprthr_memptr(wn_mem,0),
		.data2 = coprthr_memptr(B_mem,0)
	};

	gettimeofday(&t2,0);
	coprthr_mpiexec(dd, NPROCS, thr, &args_b_fft, sizeof(args_b_fft), 0);
	gettimeofday(&t3,0);

	coprthr_dread(dd,B_mem,0,B_fft,n*n*sizeof(cfloat),
		COPRTHR_E_WAIT);

	/* Calculate conjugate for B (on host(!)) */
	for (i = 0; i < n * n; i++) {
		B_fft[i] = conjf(B_fft[i]);
	}

	/* C_fft = Element wise A_fft x B_fft(conjugate) (on host(!)) */
	for (i = 0; i < n * n; i++)
		C_fft[i] = A_fft[i] * B_fft[i];

	/* C = ifft(C_fft) */
	coprthr_dwrite(dd,wn_mem,0,wn_inv,n*sizeof(cfloat),COPRTHR_E_WAIT);
	coprthr_dwrite(dd, C_mem,0, C_fft,n*n*sizeof(cfloat),COPRTHR_E_WAIT);

	/* Calculate inv FFT for bitmap C */
	struct my_args args_c_inv = {
		.n = n, .m = m,
		.inverse = 1,
		.wn = coprthr_memptr(wn_mem,0),
		.data2 = coprthr_memptr(C_mem,0)
	};

	coprthr_mpiexec(dd, NPROCS, thr, &args_c_inv, sizeof(args_c_inv), 0);

	coprthr_dread(dd,C_mem,0,C,n*n*sizeof(cfloat), COPRTHR_E_WAIT);

	double time_fwd = t1.tv_sec-t0.tv_sec + 1e-6*(t1.tv_usec - t0.tv_usec);
	double time_inv = t3.tv_sec-t2.tv_sec + 1e-6*(t3.tv_usec - t2.tv_usec);
	printf("mpiexec time: forward %f sec inverse %f sec\n", time_fwd,time_inv);

	/* Save output */

	/* Save A FFT bitmap */
	for(i=0; i<n*n; i++) {
		A[i] = cabsf(A_fft[i]);
	}
	if (!grayscale_to_jpeg_file(A, width, height, "A.fft.jpg")) {
		free(A);
		exit(2);
	}

	/* Save B FFT bitmap */
	for(i=0; i<n*n; i++) {
		B[i] = cabsf(B_fft[i]);
	}
	if (!grayscale_to_jpeg_file(B, width, height, "B.fft.jpg")) {
		free(A);
		exit(2);
	}

	float C_sum = 0, C_mean = 0, A_diff = 0, B_diff = 0;
	for (i = 0; i < n*n; i++) {
#if 0
		C_sum += cabsf(C[i]);
		C_mean = (C_mean * (i + 0.0f) + cabsf(C[i])) / (i + 1.0f);

#else
		C_sum += (A[i] - A_mean) * (B[i] - B_mean);
#endif
		A_diff += powf(A[i] - A_mean, 2.0f);
		B_diff += powf(B[i] - B_mean, 2.0f);
	}

	printf("A_mean = %f\n", A_mean);
	printf("C_sum = %f\n", C_sum);
	printf("C_mean = %f\n", C_mean);
	float factor = sqrt(A_diff*B_diff);
	printf("factor = %f\n", factor);
	printf("correlation = %f\n", C_sum / factor);

	/* clean up */
	coprthr_dclose(dd);

	/* Not pretty, from coprthr code, but at least we're only leaking
	 * ~3kb now (compared to 70kb) ... */
	free(prg->bin);
	free(prg);
	free(thr->arg_off);
	free(thr->arg_buf);
	free(thr);

	free(A_cbitmap);
	free(A_fft);
	free(B_fft);
	free(C_fft);
	free(C);
	free(B_cbitmap);

	*retval = C_sum / factor;

	return true;
}

/* Returns true on success */
__attribute__ ((visibility ("default")))
bool calculateXCorr(uint8_t *jpeg1, size_t jpeg1_size,
		    uint8_t *jpeg2, size_t jpeg2_size,
		    float *corr)
{
	bool ret = true;
	float *A, *B;
	int width, height;

	A = jpeg_to_grayscale(jpeg1, jpeg1_size, &width, &height);
	if (!A) {
		ret = false;
		goto out;
	}

	B = jpeg_to_grayscale(jpeg2, jpeg2_size, &width, &height);
	if (!B) {
		ret = false;
		goto free_A;
	}

	if (!xcorr(A, B, width, height, corr)) {
		fprintf(stderr, "ERROR: xcorr failed\n");
		ret = false;
	}

	free(B);
free_A:
	free(A);
out:
	return ret;
}

int main(int argc, char *argv[])
{
	int ret = 0;
	char *file1 = "A.jpg";
	char *file2 = "B.jpg";
	float *A = NULL, *B = NULL;
	int width, height;
	float corr = 0;

	if (argc > 1)
		file1 = argv[1];

	if (argc > 2)
		file1 = argv[2];

	A = jpeg_file_to_grayscale(file1, &width, &height);
	if (!A) {
		ret = 1;
		goto out;
	}

	B = jpeg_file_to_grayscale(file2, &width, &height);
	if (!B) {
		ret = 2;
		goto free_A;
	}

	if (!xcorr(A, B, width, height, &corr)) {
		fprintf(stderr, "ERROR: xcorr failed\n");
		ret = 3;
	}

	printf("correlation: %f\n", corr);

	if (!xcorr(A, B, width, height, &corr)) {
		fprintf(stderr, "ERROR: xcorr failed\n");
		ret = 3;
	}

	printf("correlation: %f\n", corr);


free_B:
	free(B);
free_A:
	free(A);
out:
	return ret;
}
