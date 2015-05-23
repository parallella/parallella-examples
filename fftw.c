#include <string.h>
#include <stdlib.h>
#include <complex.h> /* Use C99 complex type */
#include <fftw3.h>
#include <float.h>

#include "demo.h"

#define NSIZE 128

/* Global state */
struct {
	bool initialized;

	/* Buffers */
	fftwf_complex *A;
	fftwf_complex *B;
	fftwf_complex *C;
	fftwf_complex *A_fft;
	fftwf_complex *B_fft;
	fftwf_complex *C_fft;

	/* Plans */
	fftwf_plan A_fwd;
	fftwf_plan B_fwd;
	fftwf_plan C_inv;
} GLOB = {
	.initialized = false,

	/* Buffers */
	.A = NULL,
	.B = NULL,
	.C = NULL,
	.A_fft = NULL,
	.B_fft = NULL,
	.C_fft = NULL,

	/* Plans */
	.A_fwd = NULL,
	.B_fwd = NULL,
	.C_inv = NULL,
};

void cleanup()
{
	/* Free buffers */
	if (GLOB.A) {
		fftwf_free(GLOB.A);
		GLOB.A = NULL;
	}
	if (GLOB.B) {
		fftwf_free(GLOB.B);
		GLOB.B = NULL;
	}
	if (GLOB.C) {
		fftwf_free(GLOB.C);
		GLOB.C = NULL;
	}
	if (GLOB.A_fft) {
		fftwf_free(GLOB.A_fft);
		GLOB.A_fft = NULL;
	}
	if (GLOB.B_fft) {
		fftwf_free(GLOB.B_fft);
		GLOB.B_fft = NULL;
	}
	if (GLOB.C_fft) {
		fftwf_free(GLOB.C_fft);
		GLOB.C_fft = NULL;
	}

	/* Destroy plans */
	if (GLOB.A_fwd) {
		fftwf_free(GLOB.A_fwd);
		GLOB.A_fwd = NULL;
	}
	if (GLOB.B_fwd) {
		fftwf_free(GLOB.B_fwd);
		GLOB.B_fwd = NULL;
	}
	if (GLOB.C_inv) {
		fftwf_free(GLOB.C_inv);
		GLOB.C_inv = NULL;
	}

	fftwf_cleanup();
}

void fftimpl_fini()
{
	if (!GLOB.initialized)
		return;

	cleanup();

	GLOB.initialized = false;
}

bool fftimpl_init()
{
	const int fftw_flags = FFTW_MEASURE | FFTW_DESTROY_INPUT;
	const size_t fftw_bufsize = sizeof(fftw_complex) * NSIZE * NSIZE;

	/* Init bufs */
	GLOB.A = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.B = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.C = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.A_fft = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.B_fft = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.C_fft = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	if (!GLOB.A || !GLOB.B || !GLOB.C ||
	    !GLOB.A_fft || !GLOB.B_fft || !GLOB.C_fft)
		goto fail;

	/* Init plans */
	GLOB.A_fwd = fftwf_plan_dft_2d(NSIZE, NSIZE, GLOB.A, GLOB.A_fft, FFTW_FORWARD, fftw_flags);
	GLOB.B_fwd = fftwf_plan_dft_2d(NSIZE, NSIZE, GLOB.B, GLOB.B_fft, FFTW_FORWARD, fftw_flags);
	GLOB.C_inv = fftwf_plan_dft_2d(NSIZE, NSIZE, GLOB.C_fft, GLOB.C, FFTW_BACKWARD, fftw_flags);
	if (!GLOB.A_fwd || !GLOB.B_fwd || !GLOB.C_inv)
	       goto fail;

	atexit(fftimpl_fini);
	GLOB.initialized = true;
	return true;

fail:
	fprintf(stderr, "%s:%s(): ERROR: Failed allocating memory.\n",
		__FILE__, __func__);

	cleanup();
	return false;
}

bool fftimpl_xcorr(float *A, float *B, int width, int height, float *out_corr)
{
	int i, j;
	float A_mean, B_mean, correlation;

	/* Preallocated buffers can take up to 128x128 incl. zero padding */
	if (width > NSIZE / 2 || height > NSIZE / 2) {
		fprintf(stderr,
			"ERROR: Input image dimensions must not exceed %dx%d\n",
			NSIZE / 2, NSIZE / 2);
		return false;
	}

	/* Calculate means */
	for (i = 0; i < width * height; i++) {
		A_mean = (A_mean * (i + 0.0f) + A[i]) / (i + 1.0f);
		B_mean = (B_mean * (i + 0.0f) + B[i]) / (i + 1.0f);
	}

	/* Zero out A and B bufs */
	memset(GLOB.A, 0, sizeof(*GLOB.A) * NSIZE * NSIZE);
	memset(GLOB.B, 0, sizeof(*GLOB.B) * NSIZE * NSIZE);

	/* Initialize data w/ DC component removed */
	for (i = 0; i < width; i++) {
		for (j = 0; j < height; j++) {
			GLOB.A[i * NSIZE + j] = A[i * width + j] - A_mean;
			GLOB.B[i * NSIZE + j] = B[i * width + j] - B_mean;
		}
	}

	/* Calculate FFT for image A */
	fftwf_execute(GLOB.A_fwd);

	/* Calculate FFT for image B */
	fftwf_execute(GLOB.B_fwd);

	/* C_fft = Element wise A_fft x B_fft(conjugate) (on host(!)) */
	for (i = 0; i < NSIZE * NSIZE; i++)
		GLOB.C_fft[i] = GLOB.A_fft[i] * conjf(GLOB.B_fft[i]);

	/* C = ifft(C_fft) */
	fftwf_execute(GLOB.C_inv);

	/* TODO: Is the max always @0 ??? */
	for (i = 0, correlation = FLT_MIN; i < NSIZE * NSIZE; i++) {
		if (crealf(GLOB.C[i]) > correlation)
			correlation = crealf(GLOB.C[i]);
	}

	/* Normalize correlation */
	correlation /= ((float) NSIZE * NSIZE);

	*out_corr = correlation;

	return true;
}
