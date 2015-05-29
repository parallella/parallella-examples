#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <sys/types.h>

/* Max bitmaps / iteration fftmpl_xcorr supports */
#define MAX_BITMAPS 1024

/* JPEG manipulation */
float *jpeg_file_to_grayscale(char *path, int *width, int *height);
uint8_t *jpeg_file_to_grayscale_int(char *path, int *width, int *height);
float *jpeg_to_grayscale(void *jpeg, size_t jpeg_size, int *width, int *height);
uint8_t *jpeg_to_grayscale_int(void *jpeg, size_t jpeg_size, int *width, int *height);
bool grayscale_to_jpeg_file(float *bitmap, int width, int height, char *path);
void *grayscale_to_jpeg(float *bitmap, int width, int height, unsigned long *jpeg_size);

/* FFT implementation hooks */
bool fftimpl_init();
/* No fftimpl_fini() Register atexit handler in fftimpl_init() */
bool fftimpl_xcorr(uint8_t *ref_bmp, uint8_t *bmps, int nbmps,
		   int width, int height, float *out_corr);

