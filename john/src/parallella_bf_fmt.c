/*
 * This file is part of John the Ripper password cracker,
 * Copyright (c) 2013 by Katja Malvoni <kmalvoni at gmail dot com>
 * It is hereby released to the general public under the following terms:
 * Redistribution and use in source and binary forms, 
 * with or without modification, are permitted.
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stddef.h>

#include "arch.h"
#include "misc.h"
#include "common.h"
#include "formats.h"

#include <e-hal.h>

#define interleave

#define FORMAT_LABEL			"bcrypt-parallella"
#define FORMAT_NAME			"OpenBSD Blowfish"

#define BF_ALGORITHM_NAME		"Parallella"

#define BENCHMARK_COMMENT		" (\"$2a$05\", 32 iterations)"
#define BENCHMARK_LENGTH		-1

#define PLAINTEXT_LENGTH		72
#define CIPHERTEXT_LENGTH		60

#define BINARY_SIZE			8
#define BINARY_ALIGN			4
#define SALT_SIZE			22+7
#define SALT_ALIGN			4

#define EPIPHANY_CORES			16
#ifdef interleave
#define MIN_KEYS_PER_CRYPT		(EPIPHANY_CORES*2)
#define MAX_KEYS_PER_CRYPT		(EPIPHANY_CORES*2)
#else
#define MIN_KEYS_PER_CRYPT		EPIPHANY_CORES
#define MAX_KEYS_PER_CRYPT		EPIPHANY_CORES
#endif

#define BF_ROUNDS			16

#define ERR(x,s) \
if((x) == E_ERR) {\
	fprintf(stderr, s); \
	exit(1);\
}

typedef ARCH_WORD_32 BF_word;

/*
 * Binary ciphertext type.
 */
typedef BF_word BF_binary[2];
typedef BF_word BF_key[BF_ROUNDS + 2];

typedef struct {
	BF_word salt[4];
	unsigned char rounds;
	char subtype;
} BF_salt;

typedef struct {
	BF_word salt[4];
	unsigned char rounds;
	unsigned char flags; /* bit 0 keys_changed, bit 1 salt_changed */
	int dummy_offset;
        int start1[EPIPHANY_CORES];
	BF_key init_key[MAX_KEYS_PER_CRYPT];
	BF_key exp_key[MAX_KEYS_PER_CRYPT];
	int start2[EPIPHANY_CORES];
}inputs;

typedef struct {
	BF_binary result[MAX_KEYS_PER_CRYPT];
	int core_done[EPIPHANY_CORES];
}outputs;

typedef struct {
	inputs in;
	volatile outputs out;
} shared_buffer;

static BF_binary parallella_BF_out[MAX_KEYS_PER_CRYPT];

#define _BufSize (sizeof(shared_buffer))
#define _BufOffset (0x01000000)

static struct fmt_tests tests[] = {
	{"$2a$05$CCCCCCCCCCCCCCCCCCCCC.E5YPO9kmyuRGyh0XouQYb4YMJKvyOeW",
		"U*U"},
	{"$2a$05$CCCCCCCCCCCCCCCCCCCCC.VGOzA784oUp/Z0DY336zx7pLYAy0lwK",
		"U*U*"},
	{"$2a$05$XXXXXXXXXXXXXXXXXXXXXOAcXxm9kjPGEMsLznoKqmqw7tc8WCx4a",
		"U*U*U"},
	{"$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy",
		""},
	{"$2a$05$abcdefghijklmnopqrstuu5s2v8.iXieOjg/.AySBTTZIIVFJeBui",
		"0123456789abcdefghijklmnopqrstuvwxyz"
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		"chars after 72 are ignored"},
	{"$2x$05$/OK.fbVrR/bpIqNJ5ianF.CE5elHaaO4EbggVDjb8P19RukzXSM3e",
		"\xa3"},
	{"$2y$05$/OK.fbVrR/bpIqNJ5ianF.Sa7shbm4.OzKpvFnX1pQLmQW96oUlCq",
		"\xa3"},
	{"$2x$05$6bNw2HLQYeqHYyBfLMsv/OiwqTymGIGzFsA4hOTWebfehXHNprcAS",
		"\xd1\x91"},
	{"$2x$05$6bNw2HLQYeqHYyBfLMsv/O9LIGgn8OMzuDoHfof8AQimSGfcSWxnS",
		"\xd0\xc1\xd2\xcf\xcc\xd8"},
	{"$2a$05$/OK.fbVrR/bpIqNJ5ianF.swQOIzjOiJ9GHEPuhEkvqrUyvWhEMx6",
		"\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa"
		"\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa"
		"\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa"
		"\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa"
		"\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa"
		"\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa"
		"chars after 72 are ignored as usual"},
	{"$2a$05$/OK.fbVrR/bpIqNJ5ianF.R9xrDjiycxMbQE2bp.vgqlYpW5wx2yy",
		"\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55"
		"\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55"
		"\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55"
		"\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55"
		"\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55"
		"\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55\xaa\x55"},
	{"$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy",
		""},
	{"$2a$05$/OK.fbVrR/bpIqNJ5ianF.9tQZzcJfm3uj2NvJ/n5xkhpqLrMpWCe",
		"\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff"
		"\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff"
		"\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff"
		"\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff"
		"\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff"
		"\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff\x55\xaa\xff"},
	{NULL}
};

static char saved_key[MAX_KEYS_PER_CRYPT][PLAINTEXT_LENGTH + 1];
static char keys_mode;
static unsigned char flags;
static int sign_extension_bug;
static BF_salt saved_salt;
static BF_key BF_exp_key[MAX_KEYS_PER_CRYPT];
static BF_key BF_init_key[MAX_KEYS_PER_CRYPT];

static e_platform_t platform;
static e_epiphany_t dev;
static e_mem_t emem;

static BF_key P_init = {
	0x243f6a88, 0x85a308d3, 0x13198a2e, 0x03707344,
	0xa4093822, 0x299f31d0, 0x082efa98, 0xec4e6c89,
	0x452821e6, 0x38d01377, 0xbe5466cf, 0x34e90c6c,
	0xc0ac29b7, 0xc97c50dd, 0x3f84d5b5, 0xb5470917,
	0x9216d5d9, 0x8979fb1b
};

unsigned char parallella_BF_atoi64[0x80] = {
	64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 0, 1,
	54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 64, 64, 64, 64, 64,
	64, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
	17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 64, 64, 64, 64, 64,
	64, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
	43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 64, 64, 64, 64, 64
};

static void init(struct fmt_main *self)
{
	keys_mode = 'y';
	sign_extension_bug = 0;
	
	ERR(e_init(NULL),"Init of Epiphany chip failed!\n");
	ERR(e_reset_system(), "Reset of Epiphany chip failed!\n");
	ERR(e_get_platform_info(&platform), "Get platform info failed!\n");
	ERR(e_alloc(&emem, _BufOffset, _BufSize), "Epiphany memory allocation failed!\n");
	ERR(e_open(&dev, 0, 0, platform.rows, platform.cols), "e_open() failed!\n");
	ERR(e_load_group("parallella_e_bcrypt.elf", &dev, 0, 0,
		platform.rows, platform.cols, E_TRUE), "Load failed!\n");
}

static void done(void)
{	
	ERR(e_close(&dev), "Closing Epiphany chip failed!\n");
	ERR(e_free(&emem), "Freeing memory failed!\n");
	ERR(e_finalize(), "e_finalize failed!\n");
}

static void BF_swap(BF_word *x, int count)
{
	BF_word tmp;

	do {
		tmp = *x;
		tmp = (tmp << 16) | (tmp >> 16);
		*x++ = ((tmp & 0x00FF00FF) << 8) | ((tmp >> 8) & 0x00FF00FF);
	} while (--count);
}

static void BF_decode(BF_word *dst, char *src, int size)
{
	unsigned char *dptr = (unsigned char *)dst;
	unsigned char *end = dptr + size;
	unsigned char *sptr = (unsigned char *)src;
	unsigned int c1, c2, c3, c4;

	do {
		c1 = parallella_BF_atoi64[ARCH_INDEX(*sptr++)];
		c2 = parallella_BF_atoi64[ARCH_INDEX(*sptr++)];
		*dptr++ = (c1 << 2) | ((c2 & 0x30) >> 4);
		if (dptr >= end) break;

		c3 = parallella_BF_atoi64[ARCH_INDEX(*sptr++)];
		*dptr++ = ((c2 & 0x0F) << 4) | ((c3 & 0x3C) >> 2);
		if (dptr >= end) break;

		c4 = parallella_BF_atoi64[ARCH_INDEX(*sptr++)];
		*dptr++ = ((c3 & 0x03) << 6) | c4;
	} while (dptr < end);
}

static int valid(char *ciphertext, struct fmt_main *self)
{
	int rounds;
	char *pos;

	if (strncmp(ciphertext, "$2a$", 4) &&
	    strncmp(ciphertext, "$2x$", 4) &&
	    strncmp(ciphertext, "$2y$", 4))
		return 0;

	if (ciphertext[4] < '0' || ciphertext[4] > '9') return 0;
	if (ciphertext[5] < '0' || ciphertext[5] > '9') return 0;
	if (ciphertext[6] != '$') return 0;
	rounds = atoi(ciphertext + 4);
	if (rounds < 4 || rounds > 31) return 0;

	for (pos = &ciphertext[7]; atoi64[ARCH_INDEX(*pos)] != 0x7F; pos++);
	if (*pos || pos - ciphertext != CIPHERTEXT_LENGTH) return 0;

	if (parallella_BF_atoi64[ARCH_INDEX(*(pos - 1))] & 3) return 0;
	if (parallella_BF_atoi64[ARCH_INDEX(ciphertext[28])] & 0xF) return 0;

	return 1;
}

static int binary_hash_0(void *binary)
{	
#ifdef _DEBUG
	puts("get_binary_hash_0"); 
	printf("%x\n", *(BF_word *)binary);
#endif
	return *(BF_word *)binary & 0xF;
}

static int binary_hash_1(void *binary)
{
	return *(BF_word *)binary & 0xFF;
}

static int binary_hash_2(void *binary)
{
	return *(BF_word *)binary & 0xFFF;
}

static int binary_hash_3(void *binary)
{
	return *(BF_word *)binary & 0xFFFF;
}

static int binary_hash_4(void *binary)
{
	return *(BF_word *)binary & 0xFFFFF;
}

static int binary_hash_5(void *binary)
{
	return *(BF_word *)binary & 0xFFFFFF;
}

static int binary_hash_6(void *binary)
{
	return *(BF_word *)binary & 0x7FFFFFF;
}

static int get_hash_0(int index)
{	
#ifdef _DEBUG
	puts("get_hash_0"); 
	int i = 0;
	for(i = 0; i < sizeof(BF_binary)/sizeof(BF_word); i++)
		printf("%x ", parallella_BF_out[index][i]);
	printf("\n");
#endif
	return parallella_BF_out[index][0] & 0xF;
}

static int get_hash_1(int index)
{
	return parallella_BF_out[index][0] & 0xFF;
}

static int get_hash_2(int index)
{
	return parallella_BF_out[index][0] & 0xFFF;
}

static int get_hash_3(int index)
{
	return parallella_BF_out[index][0] & 0xFFFF;
}

static int get_hash_4(int index)
{
	return parallella_BF_out[index][0] & 0xFFFFF;
}

static int get_hash_5(int index)
{
	return parallella_BF_out[index][0] & 0xFFFFFF;
}

static int get_hash_6(int index)
{
	return parallella_BF_out[index][0] & 0x7FFFFFF;
}

static void set_salt(void *salt)
{	
	memcpy(&saved_salt, salt, sizeof(saved_salt));
}

static void *get_salt(char *ciphertext)
{
	static BF_salt salt;

	BF_decode(salt.salt, &ciphertext[7], 16);
	BF_swap(salt.salt, 4);

	salt.rounds = atoi(&ciphertext[4]);
	if (ciphertext[2] == 'a')
		salt.subtype = 'y';
	else
		salt.subtype = ciphertext[2];

	return &salt;
}

static void set_key(char *key, int index)
{
	char *ptr = key;
	int i, j;
	BF_word tmp;
	
	if (keys_mode != saved_salt.subtype) {
		keys_mode = saved_salt.subtype;
		sign_extension_bug = (keys_mode == 'x');
	}
		
	for (i = 0; i < BF_ROUNDS + 2; i++) {
		tmp = 0;
		for (j = 0; j < 4; j++) {
			tmp <<= 8;
			if (sign_extension_bug)
				tmp |= (int)(signed char)*ptr;
			else
				tmp |= (unsigned char)*ptr;

			if (!*ptr) ptr = key; else ptr++;
		}

		BF_exp_key[index][i] = tmp;
		BF_init_key[index][i] = P_init[i] ^ tmp;
	}
	
	if(strncmp(key, saved_key[index], PLAINTEXT_LENGTH) != 0 || !key[0])
		flags = 0;
	
	strnzcpy(saved_key[index], key, PLAINTEXT_LENGTH + 1);
}

static char *get_key(int index)
{
	return saved_key[index];
}

static int crypt_all(int *pcount, struct db_salt *salt)
{
	int count = *pcount;
	int i = 0;
	int core_start = 0;
	int done[EPIPHANY_CORES] = {0};
	inputs input;
	outputs out;
	size_t transfer_size;
	
	memcpy(&input.flags, &flags, sizeof(flags));
	
	core_start = 16;
	for(i = 0; i < platform.rows*platform.cols; i++) {
		memcpy(&input.salt, &saved_salt.salt, sizeof(input.salt));
		memcpy(&input.rounds, &saved_salt.rounds, sizeof(input.rounds));
		if(flags == 0) {
			memcpy(&input.init_key[i], &BF_init_key[i], sizeof(BF_key));
			memcpy(&input.exp_key[i], &BF_exp_key[i], sizeof(BF_key));
#ifdef interleave
			memcpy(&input.init_key[i + EPIPHANY_CORES], 
				&BF_init_key[i + EPIPHANY_CORES], sizeof(BF_key));
			memcpy(&input.exp_key[i + EPIPHANY_CORES], 
				&BF_exp_key[i + EPIPHANY_CORES], sizeof(BF_key));
#endif
			memcpy(&input.start1[i], &core_start, sizeof(core_start));
			memcpy(&input.start2[i], &core_start, sizeof(core_start));
			transfer_size = sizeof(inputs);
		} else {
			memcpy(&input.start1[i], &core_start, sizeof(core_start));
			transfer_size = sizeof(inputs) - sizeof(input.start2) - 
					sizeof(input.init_key) - sizeof(input.exp_key);
		}
	}
	
	ERR(e_write(&emem, 0, 0, 0, &input, transfer_size), "Writing input data failed!\n");

	for(i = 0; i < platform.rows*platform.cols; i++)
		while(done[i] != i + 1)
			ERR(e_read(&emem, 0, 0, offsetof(shared_buffer, out.core_done[i]), 
				&done[i], sizeof(done[i])), "Reading done flag failed!\n");
	
	ERR(e_read(&emem, 0, 0, offsetof(shared_buffer, out.result), out.result, 
		sizeof(out.result)), "Reading results failed!\n");
	
	for(i = 0; i < platform.rows*platform.cols; i++) {
		memcpy(parallella_BF_out[i], out.result[i], sizeof(BF_binary));
#ifdef interleave		
		memcpy(parallella_BF_out[i + EPIPHANY_CORES], 
			out.result[i + EPIPHANY_CORES], sizeof(BF_binary));
#endif
	}
	
	flags = 1;
	
	return count;
}

static int cmp_all(void *binary, int count)
{
	int i;
	for (i = 0; i < count; i++)
		if (*(BF_word *)binary == parallella_BF_out[i][0])
			return 1;
	return 0;
}

static int cmp_one(void *binary, int index)
{
	return
	    ((BF_word *)binary)[0] == parallella_BF_out[index][0] &&
	    ((BF_word *)binary)[1] == parallella_BF_out[index][1];
}

static int cmp_exact(char *source, int index)
{
	return 1;
}

void *parallella_BF_std_get_binary(char *ciphertext)
{
	static BF_binary binary;

	BF_decode(binary, &ciphertext[29], 8);
	BF_swap(binary, 2);

	return &binary;
}

struct fmt_main parallella_fmt_BF = {
	{
		FORMAT_LABEL,
		FORMAT_NAME,
		BF_ALGORITHM_NAME,
		BENCHMARK_COMMENT,
		BENCHMARK_LENGTH,
		PLAINTEXT_LENGTH,
		BINARY_SIZE,
		BINARY_ALIGN,
		SALT_SIZE,
		SALT_ALIGN,
		MIN_KEYS_PER_CRYPT,
		MAX_KEYS_PER_CRYPT,
		FMT_CASE | FMT_8_BIT,
		tests
	}, {
		init,
		done,
		fmt_default_reset,
		fmt_default_prepare,
		valid,
		fmt_default_split,
		parallella_BF_std_get_binary,
		get_salt,
		fmt_default_source,
		{
			binary_hash_0,
			binary_hash_1,
			binary_hash_2,
			binary_hash_3,
			binary_hash_4,
			binary_hash_5,
			binary_hash_6
		},
		fmt_default_salt_hash,
		set_salt,
		set_key,
		get_key,
		fmt_default_clear_keys,
		crypt_all,
		{
			get_hash_0,
			get_hash_1,
			get_hash_2,
			get_hash_3,
			get_hash_4,
			get_hash_5,
			get_hash_6
		},
		cmp_all,
		cmp_one,
		cmp_exact
	}
};
