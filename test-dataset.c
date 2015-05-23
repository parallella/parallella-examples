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

void usage(char *argv0)
{
	fprintf(stderr, "Usage: %s REFIMG LISTFILE\n", argv0);
	exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
	int ret = 0;
	char *refimg, *filelist;
	float *A = NULL, *B = NULL;
	int width, height;
	float corr = 0;
	FILE *fp;
	char buf[256];

	if (!initialized) {
		if (!fftimpl_init()) {
			fprintf(stderr,
				"ERROR: failed to initialize fft library\n");
			exit(1);
		}
		initialized = true;
	}

	if (argc < 3)
		usage(argv[0]);

	refimg = argv[1];
	filelist = argv[2];

	A = jpeg_file_to_grayscale(refimg, &width, &height);
	if (!A) {
		ret = 1;
		goto out;
	}

	fp = fopen(filelist, "r");
	if (!fp) {
		fprintf(stderr, "ERROR: Could not open %s\n", filelist);
		ret = 2;
		goto free_A;
	}

	while (fscanf(fp, "%s", buf) == 1) {
		B = jpeg_file_to_grayscale(buf, &width, &height);
		if (!B) {
			ret = 3;
			break;
		}

		if (!fftimpl_xcorr(A, B, width, height, &corr)) {
			fprintf(stderr, "ERROR: xcorr failed\n");
			break;
		}
		free(B);
		printf("%f,%s,%s\n", corr, refimg, buf);
	}

	fclose(fp);

free_A:
	free(A);
out:
	return ret;
}
