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
	fftwf_complex *ref;
	fftwf_complex *B;
	fftwf_complex *C;
	fftwf_complex *ref_fft;
	fftwf_complex *B_fft;
	fftwf_complex *C_fft;

	/* Plans */
	fftwf_plan ref_fwd;
	fftwf_plan B_fwd;
	fftwf_plan C_inv;
} GLOB = {
	.initialized = false,

	/* Buffers */
	.ref = NULL,
	.B = NULL,
	.C = NULL,
	.ref_fft = NULL,
	.B_fft = NULL,
	.C_fft = NULL,

	/* Plans */
	.ref_fwd = NULL,
	.B_fwd = NULL,
	.C_inv = NULL,
};

void cleanup()
{
	/* Free buffers */
	if (GLOB.ref) {
		fftwf_free(GLOB.ref);
		GLOB.ref = NULL;
	}
	if (GLOB.B) {
		fftwf_free(GLOB.B);
		GLOB.B = NULL;
	}
	if (GLOB.C) {
		fftwf_free(GLOB.C);
		GLOB.C = NULL;
	}
	if (GLOB.ref_fft) {
		fftwf_free(GLOB.ref_fft);
		GLOB.ref_fft = NULL;
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
	if (GLOB.ref_fwd) {
		fftwf_free(GLOB.ref_fwd);
		GLOB.ref_fwd = NULL;
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
	GLOB.ref = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.B = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.C = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.ref_fft = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.B_fft = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	GLOB.C_fft = (fftwf_complex *) fftwf_malloc(fftw_bufsize);
	if (!GLOB.ref || !GLOB.B || !GLOB.C ||
	    !GLOB.ref_fft || !GLOB.B_fft || !GLOB.C_fft)
		goto fail;

	/* Init plans */
	GLOB.ref_fwd = fftwf_plan_dft_2d(NSIZE, NSIZE, GLOB.ref, GLOB.ref_fft, FFTW_FORWARD, fftw_flags);
	GLOB.B_fwd = fftwf_plan_dft_2d(NSIZE, NSIZE, GLOB.B, GLOB.B_fft, FFTW_FORWARD, fftw_flags);
	GLOB.C_inv = fftwf_plan_dft_2d(NSIZE, NSIZE, GLOB.C_fft, GLOB.C, FFTW_BACKWARD, fftw_flags);
	if (!GLOB.ref_fwd || !GLOB.B_fwd || !GLOB.C_inv)
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

bool fftimpl_xcorr_one(uint8_t *B, int width, int height, float *out_corr)
{
	int i, j;
	float B_mean, B_sum, correlation;

	/* Preallocated buffers can take up to 128x128 incl. zero padding */
	if (width > NSIZE / 2 || height > NSIZE / 2) {
		fprintf(stderr,
			"ERROR: Input image dimensions must not exceed %dx%d\n",
			NSIZE / 2, NSIZE / 2);
		return false;
	}

	/* Convert to float */
	for (i = 0; i < width; i++) {
		for (j = 0; j < height; j++) {
			GLOB.B[i * NSIZE + j] =
				((float) B[i * width + j] / 255.0f);
		}
	}

	/* Calculate means */
	for (B_sum = 0, i = 0; i < width; i++) {
		for (j = 0; j < height; j++) {
			B_sum += GLOB.B[i * NSIZE + j];
		}
	}
	B_mean = B_sum / ((float) width * height);

	/* Remove  DC component */
	for (i = 0; i < width; i++) {
		for (j = 0; j < height; j++)
			GLOB.B[i * NSIZE + j] -= B_mean;
	}

	/* Calculate FFT for image B */
	fftwf_execute(GLOB.B_fwd);

	/* C_fft = Element wise ref_fft x B_fft(conjugate) (on host(!)) */
	for (i = 0; i < NSIZE * NSIZE; i++)
		GLOB.C_fft[i] = GLOB.ref_fft[i] * conjf(GLOB.B_fft[i]);

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

bool fftimpl_xcorr(uint8_t *ref_bmp, uint8_t *bmps, int nbmps,
		   int width, int height, float *out_corr)
{
	int i, j, n;
	float ref_mean, ref_sum;
	float autocorr, tmp;

	/* Preallocated buffers can take up to 128x128 incl. zero padding */
	if (width > NSIZE / 2 || height > NSIZE / 2) {
		fprintf(stderr,
			"ERROR: Input image dimensions must not exceed %dx%d\n",
			NSIZE / 2, NSIZE / 2);
		return false;
	}

	/* Convert to float */
	for (i = 0; i < width; i++) {
		for (j = 0; j < height; j++) {
			GLOB.ref[i * NSIZE + j] =
				((float) ref_bmp[i * width + j] / 255.0f);
		}
	}

	/* Calculate means */
	for (ref_sum = 0, i = 0; i < width; i++) {
		for (j = 0; j < height; j++) {
			ref_sum += GLOB.ref[i * NSIZE + j];
		}
	}
	ref_mean = ref_sum / ((float) width * height);


	/* Remove  DC component */
	for (i = 0; i < width; i++) {
		for (j = 0; j < height; j++)
			GLOB.ref[i * NSIZE + j] -= ref_mean;
	}

	/* Calculate FFT for image A */
	fftwf_execute(GLOB.ref_fwd);

	/* Calculate autocorrelation */
	if (!fftimpl_xcorr_one(ref_bmp, width, height, &autocorr)) {
			fprintf(stderr,
				"ERROR: fftimpl_xcorr_one_failed w ref img\n");
			return false;
	}

	for (n = 0; n < nbmps; n++, out_corr++) {
		if (!fftimpl_xcorr_one(&bmps[n * width * height],
				       width, height, &tmp)) {
			fprintf(stderr,
				"ERROR: fftimpl_xcorr_one_failed at bitmap %d\n",
				n);
			return false;
		}
		if (tmp > autocorr)
			*out_corr = autocorr / tmp;
		else
			*out_corr = tmp / autocorr;
	}

	return true;
}
