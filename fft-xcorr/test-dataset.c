#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <math.h>
#include <complex.h>
#include <stdbool.h>
#include <stdint.h>

#include "demo.h"

#define IMG_W 64
#define IMG_H 64


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
	uint8_t *A = NULL, *B = NULL;
	int width, height;
	FILE *fp;
	int i, j;
	bool eof = false;
	char fn_buf[MAX_BITMAPS][4096];

	uint8_t *img_buf =
		(uint8_t *) malloc(MAX_BITMAPS * IMG_W * IMG_H * sizeof(*img_buf));

	float *corr = calloc(MAX_BITMAPS, sizeof(*corr));

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

	A = jpeg_file_to_grayscale_int(refimg, &width, &height);
	if (!A) {
		ret = 1;
		goto out;
	}

	if (width != IMG_W || height != IMG_H) {
		fprintf(stderr,
			"ERROR: Wrong image dimension. Need %dx%d\n",
			IMG_W, IMG_H);
		ret = 1;
		goto free_A;
	}

	fp = fopen(filelist, "r");
	if (!fp) {
		fprintf(stderr, "ERROR: Could not open %s\n", filelist);
		ret = 2;
		goto free_A;
	}

	while (!eof) {
		for (i = 0; i < MAX_BITMAPS; i++) {
			if (fscanf(fp, "%s", fn_buf[i]) != 1) {
				eof = true;
				break;
			}
			if (fn_buf[i][0] == '\0') {
				eof = true;
				break;
			}
			B = jpeg_file_to_grayscale_int(fn_buf[i], &width, &height);
			if (!B) {
				eof = true;
				ret = 3;
				break;
			}
			if (width != IMG_W || height != IMG_H) {
				fprintf(stderr,
				"ERROR: Wrong image dimension. Need %dx%d\n",
				IMG_W, IMG_H);
				eof = true;
				ret = 3;
				break;
			}
			memcpy(&img_buf[IMG_W *IMG_H * i],
			       B, IMG_W *IMG_H * sizeof(*img_buf));
			free(B);
		}
		if (!i)
			break;
		if (!fftimpl_xcorr(A, img_buf, i, width, height, corr)) {
			fprintf(stderr, "ERROR: xcorr failed\n");
			break;
		}

		for (j = 0; j < i; j++)
			printf("%f,%s,%s\n", corr[j], refimg, fn_buf[j]);
	}

	fclose(fp);

free_A:
	free(A);
out:
	return ret;
}
