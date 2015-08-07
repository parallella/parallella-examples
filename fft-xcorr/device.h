#pragma once

#ifdef __epiphany__
# if 0
#include <stdint.h>
# else
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
# endif
#else
# include <stdint.h>
#endif

#include <complex.h>
#define _X_cfloat float complex

/* Assuming 32-bit arch */
#ifdef __epiphany__
#define __e_ptr(T) T *
#else
#define __e_ptr(T) uint32_t
#endif
struct my_args {
	uint32_t n;
	uint32_t m;

	__e_ptr(_X_cfloat) wn_fwd;
	__e_ptr(_X_cfloat) wn_bwd;

	__e_ptr(uint8_t) ref_bitmap;
	__e_ptr(uint8_t) bitmaps;
	uint32_t nbitmaps;

        /* Buffers */
	__e_ptr(_X_cfloat) ref_fft;

	/* Where we should store the results */
	__e_ptr(float) results;

	uint32_t _pad;
} __attribute__((packed));

#undef _X_cfloat
