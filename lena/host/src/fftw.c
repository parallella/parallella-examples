#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <fftw3.h>

typedef struct timeval timeval_t;

#define TIMERS (4)
#define N (128)   // Size of FFT
#define Q (1000)  // Times to compute - for averaging


int main(int argc, char *argv[])
{
	fftwf_complex *in, *out;
	fftwf_plan p;
	int i, j;
	float *fpi, *fpo;
	timeval_t timer[TIMERS];
	double time_d[TIMERS];

	fprintf(stderr, "Allocating...\n");
	in = (fftwf_complex *) fftwf_malloc(sizeof(fftwf_complex) * N * N);
	out = (fftwf_complex *) fftwf_malloc(sizeof(fftwf_complex) * N * N);

	fprintf(stderr, "Planning... ");
	gettimeofday(&timer[0], NULL);
//	p = fftwf_plan_dft_2d(N, N, in, out, FFTW_FORWARD, FFTW_MEASURE);
	p = fftwf_plan_dft_2d(N, N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
	gettimeofday(&timer[1], NULL);
	time_d[0] = (timer[1].tv_sec - timer[0].tv_sec) * 1000 + ((double) (timer[1].tv_usec - timer[0].tv_usec) / 1000.0);
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
	gettimeofday(&timer[2], NULL);
	for (i=0; i<Q; i++)
		fftwf_execute(p);
	gettimeofday(&timer[3], NULL);

	time_d[1] = (timer[3].tv_sec - timer[2].tv_sec) * 1000 + ((double) (timer[3].tv_usec - timer[2].tv_usec) / 1000.0);
	time_d[1] = time_d[1] / Q;
	fprintf(stderr, "%5.3f msec\n", time_d[1]);

	fprintf(stderr, "Cleaning...\n");
	fftwf_destroy_plan(p);
	fftwf_free(in);
	fftwf_free(out);

	return 0;
}
