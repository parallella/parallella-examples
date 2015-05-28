#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <math.h>
#include <complex.h>
#include <stdbool.h>
#include <stdint.h>

#include "demo.h"

bool initialized = false;

/* Returns true on success */
__attribute__ ((visibility ("default")))
bool calculateXCorr(uint8_t *jpeg1, size_t jpeg1_size,
		    uint8_t *jpeg2, size_t jpeg2_size,
		    float *corr)
{
	bool ret = true;
	float *A, *B;
	int width, height;

	if (!initialized) {
		if (!fftimpl_init()) {
			fprintf(stderr,
				"ERROR: failed to initialize fft library\n");
			return false;
		}
		initialized = true;
	}

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

	if (!fftimpl_xcorr(A, B, 1, width, height, corr)) {
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

	if (!initialized) {
		if (!fftimpl_init()) {
			fprintf(stderr,
				"ERROR: failed to initialize fft library\n");
			exit(1);
		}
		initialized = true;
	}

	if (argc > 1)
		file1 = argv[1];

	if (argc > 2)
		file2 = argv[2];

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

	if (!fftimpl_xcorr(A, B, 1, width, height, &corr)) {
		fprintf(stderr, "ERROR: xcorr failed\n");
		ret = 3;
	}

	printf("%f,%s,%s\n", corr, file1, file2);

	free(B);
free_A:
	free(A);
out:
	return ret;
}
