/*
 * fft.c
 *
 * Main code running on the host for the fft test/demo software
 *
 * Copyright (C) 2015 - Sylvain Munaut <tnt@246tNt.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 */

#include <complex.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>

#include <fftw3.h>

#include <e-hal.h>


/* ------------------------------------------------------------------------ */
/* Timing code                                                              */
/* ------------------------------------------------------------------------ */

static struct timeval g_tv;

void
tic(void)
{
	gettimeofday(&g_tv, NULL);
}

void
tac(const char *s, int logN, int iter)
{
	struct timeval tv;
	uint32_t d;
	float flops;

	tv = g_tv;
	gettimeofday(&g_tv, NULL);

	d  = (g_tv.tv_sec - tv.tv_sec) * 1000000;
	d += (g_tv.tv_usec - tv.tv_usec);

	flops = (float)(iter * ((5 * logN) << logN)) / (1e-6f * (float)d);

	fprintf(stderr, "%s: %f Mflops\n", s, flops / 1e6f);
}


/* ------------------------------------------------------------------------ */
/* FFTW                                                                     */
/* ------------------------------------------------------------------------ */

struct fftw_state {
	fftwf_complex *in, *out;
	fftwf_plan p;
};

static void
fftw_init(struct fftw_state *state, const int logN)
{
	const int N = 1 << logN;
	int i;

	state->in  = (fftwf_complex*) fftwf_malloc(sizeof(fftwf_complex) * N);
	state->out = (fftwf_complex*) fftwf_malloc(sizeof(fftwf_complex) * N);

	state->p = fftwf_plan_dft_1d(N, state->in, state->out, FFTW_FORWARD, FFTW_MEASURE);

	srandom(0);
	for (i=0; i<N; i++)
		state->in[i] = (float)(random() & 0xfff) / 256.0f;
}

static void
fftw_fini(struct fftw_state *state)
{
	fftwf_destroy_plan(state->p);
	fftwf_free(state->out);
	fftwf_free(state->in);
}

static void
fftw_run(struct fftw_state *state, int iter)
{
	int i;

	for (i=0; i<iter; i++)
		fftwf_execute(state->p);
}

static complex float *
fftw_get_result(struct fftw_state *state)
{
	return state->out;
}


/* ------------------------------------------------------------------------ */
/* Epiphany                                                                 */
/* ------------------------------------------------------------------------ */

/* Math helpers */

#define M_PIf 3.141592653589793f

static float complex
twiddle(int k, int N)
{
	return cexpf((- 2.0f * M_PIf * k * I) / (float)N);
}


/* Main code */

#define CMD		0x2000
#define TWIDDLE		0x3000
#define DATA_IN		0x4000
#define DATA_OUT	0x6000

struct epiphany_state {
	int logN;
	int N;
	e_platform_t platform;
	e_epiphany_t dev;
	complex float *data;
	complex float *twiddle;
};

static void
epiphany_init(struct epiphany_state *state, const int logN)
{
	int i, cmd;

	/* Save params */
	state->logN = logN;
	state->N = 1 << logN;

	/* Alloc array */
	state->data    = malloc(sizeof(complex float) * state->N);
	state->twiddle = malloc(sizeof(complex float) * state->N / 2);

	/* Open the device */
	e_init(NULL);
	e_reset_system();
	e_get_platform_info(&state->platform);

	e_open(&state->dev, 0, 0, 1, 1);

	/* Init mailbox */
	cmd = 0;
	e_write(&state->dev, 0, 0, CMD, &cmd, sizeof(uint32_t));

	/* Load software */
	e_load_group("bin/e_fft.elf", &state->dev, 0, 0, 1, 1, E_TRUE);

	/* Load the input data and twiddle factors */
	srandom(0);
	for (i=0; i<state->N; i++)
		state->data[i] = (float)(random() & 0xfff) / 256.0f;

	for (i=0; i<state->N/2; i++)
		state->twiddle[i] = twiddle(i, state->N);

	e_write(&state->dev, 0, 0, DATA_IN, state->data,    sizeof(float complex) * state->N);
	e_write(&state->dev, 0, 0, TWIDDLE, state->twiddle, sizeof(float complex) * state->N / 2);
}

static void
epiphany_fini(struct epiphany_state *state)
{
	e_close(&state->dev);
	e_finalize();

	free(state->twiddle);
	free(state->data);
}

static int
epiphany_run(struct epiphany_state *state, int iter, int mode)
{
	e_epiphany_t *dev = &state->dev;
	uint32_t cmd;

	/* Go ! */
	cmd = (mode << 31) | (state->logN << 24) | iter;
	e_write(dev, 0, 0, CMD, &cmd, sizeof(uint32_t));

	/* Poll for end */
	while (cmd) {
		e_read(dev, 0, 0, CMD, &cmd, sizeof(uint32_t));
		usleep(1000);
	}

	e_read(dev, 0, 0, CMD + 4, &cmd, sizeof(uint32_t));
	printf("(%d cycles)\n", cmd);
	return cmd;
}

static complex float *
epiphany_get_result(struct epiphany_state *state)
{
	e_read(&state->dev, 0, 0, DATA_OUT, state->data, sizeof(float complex) * state->N);
	return state->data;
}


/* ------------------------------------------------------------------------ */
/* Main                                                                     */
/* ------------------------------------------------------------------------ */

static void
compare(complex float *a, complex float *b, int logN)
{
	int i;

	/* Scan all values */
	for (i=0; i<(1<<logN); i++)
	{
		if (cabsf(a[i] - b[i]) / cabsf(a[i]) > 2e-5)
			printf("%4d | %10f %10f | %10f %10f | %f\n", i,
				crealf(a[i]), cimagf(a[i]),
				crealf(b[i]), cimagf(b[i]),
				cabsf(a[i] - b[i])
			);
	}
}

int main(int argc, char *argv[])
{
	const int logN = 10;
	const int ITER = 10000;
	struct fftw_state fftw;
	struct epiphany_state epi;

	// FFTW
	fftw_init(&fftw, logN);

	tic();
	fftw_run(&fftw, ITER);
	tac("fftw         ", logN, ITER);

	// Epiphany
	epiphany_init(&epi, logN);

		// C variant
	tic();
	epiphany_run(&epi, ITER, 0);
	tac("epiphany C   ", logN, ITER);

	compare(
		fftw_get_result(&fftw),
		epiphany_get_result(&epi),
		logN
	);

		// Assembly variant
	tic();
	epiphany_run(&epi, ITER, 1);
	tac("epiphany ASM ", logN, ITER);

	compare(
		fftw_get_result(&fftw),
		epiphany_get_result(&epi),
		logN
	);

	epiphany_fini(&epi);

	fftw_fini(&fftw);

	return 0;
}
