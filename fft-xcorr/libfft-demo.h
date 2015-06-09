#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

/* FFT demo API header */

struct jpeg_image {
    uint8_t *data;
    size_t size;
};

bool calculateXCorr2(struct jpeg_image *ref_image, struct jpeg_image *compare,
		     int ncompare, float *corr);
