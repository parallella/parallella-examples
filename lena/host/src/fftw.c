#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <fftw3.h>

#define TIMERS (4)
#define N (128)   // Size of FFT
#define Q (1000)  // Times to compute - for averaging


int main(int argc, char *argv[])
{
	fftwf_complex *in, *out;
	fftwf_plan p;
	int i, j;
	float *fpi, *fpo;
	struct timespec timer[TIMERS];
	double time_d[TIMERS];

	fprintf(stderr, "Allocating...\n");
	in = (fftwf_complex *) fftwf_malloc(sizeof(fftwf_complex) * N * N);
	out = (fftwf_complex *) fftwf_malloc(sizeof(fftwf_complex) * N * N);

	fprintf(stderr, "Planning... ");
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &timer[0]);
//	p = fftwf_plan_dft_2d(N, N, in, out, FFTW_FORWARD, FFTW_MEASURE);
	p = fftwf_plan_dft_2d(N, N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &timer[1]);
	time_d[0] = (timer[1].tv_sec - timer[0].tv_sec) * 1000 + ((double) (timer[1].tv_nsec - timer[0].tv_nsec) / 1000000.0);
	fprintf(stderr, "%5.3f msec\n", time_d[0]);

	fprintf(stderr, "Initializing...\n");
	fpi = (float *) &in[0];
	fpo = (float *) &out[0];
	for (i=0; i<N*N*2; i++)
	{
		fpi++ = 0.0;
		fpo++ = 0.0;
	}

	fprintf(stderr, "Executing... ");
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &timer[2]);
	for (i=0; i<Q; i++)
		fftwf_execute(p);
	clock_gettime(CLOCK_THREAD_CPUTIME_ID, &timer[3]);

	time_d[1] = (timer[3].tv_sec - timer[2].tv_sec) * 1000 + ((double) (timer[3].tv_nsec - timer[2].tv_nsec) / 1000000.0);
	time_d[1] = time_d[1] / Q;
	fprintf(stderr, "%5.3f msec\n", time_d[1]);

	fprintf(stderr, "Cleaning...\n");
	fftwf_destroy_plan(p);
	fftwf_free(in);
	fftwf_free(out);

	return 0;
}
