/* mpi_fft2d_host.c
 *
 * Copyright (c) 2015 Brown Deer Technology, LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * This software was developed by Brown Deer Technology, LLC.
 * For more information contact info@browndeertechnology.com
 */

/* DAR */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <math.h>
#include <complex.h>
typedef float complex cfloat;

#include "coprthr.h"
#include "coprthr_cc.h"
#include "coprthr_thread.h"
#include "coprthr_mpi.h"

#define NPROCS 16
#define NSIZE 128
#define MSIZE 7

#define frand() ((float)rand()/(float)RAND_MAX)

void generate_wn( 
	unsigned int n, unsigned int m, int sign, 
	float* cc, float* ss, cfloat* wn 
) {
   int i;

   float c = cc[m];
   float s = sign * ss[m];

   int n2 = n >> 1;

   wn[0] = 1.0f + 0.0f * I;
   wn[0 + n2] = conj(wn[0]);

   for(i=1; i<n2; i++) {
      wn[i] = (c * crealf(wn[i-1]) - s * cimagf(wn[i-1]))
         + (s * crealf(wn[i-1]) + c * cimagf(wn[i-1])) * I;
      wn[i + n2] = conj(wn[i]);
   }
}

struct my_args {
	unsigned int n;
	unsigned int m;
	int inverse;
	cfloat* wn;
	cfloat* data2;
};

int main()
{
	int i,j,k;
	struct timeval t0,t1,t2,t3;

	unsigned int n = NSIZE;
	unsigned int m = MSIZE;

	/* open device for threads */
	int dd = coprthr_dopen(COPRTHR_DEVICE_E32,COPRTHR_O_THREAD);
	printf("dd=%d\n",dd); fflush(stdout);
	if (dd<0) {
		printf("device open failed\n");
		exit(-1);
	}

	/* compile thread function */
	char* log = 0;
	coprthr_program_t prg 
		= coprthr_cc_read_bin("./mpi_fft2d_tfunc.cbin.3.e32",0);
	coprthr_sym_t thr = coprthr_getsym(prg,"my_thread");
	printf("%p %p\n",prg,thr);

	/* allocate memory on host */
	float* cc = (float*)malloc(16*sizeof(float));
	float* ss = (float*)malloc(16*sizeof(float));
	cfloat* wn_fwd = (cfloat*)malloc(n*sizeof(cfloat));
	cfloat* wn_inv = (cfloat*)malloc(n*sizeof(cfloat));
	cfloat* data1 = (cfloat*)malloc(n*n*sizeof(cfloat));
	cfloat* data2 = (cfloat*)malloc(n*n*sizeof(cfloat));
	cfloat* data3 = (cfloat*)malloc(n*n*sizeof(cfloat));

	/* initialize cos/sin table */
	for(i=0;i<16;i++) {
		cc[i] = (float)cos( 2.0 * M_PI / pow(2.0,(double)i) );
		ss[i] = - (float)sin( 2.0 * M_PI / pow(2.0,(double)i) );
		printf("%2.16f %2.16f\n",cc[i],ss[i]);
	}

	/* initialize wn coefficients */
	generate_wn( n, m, +1, cc, ss, wn_fwd);
	generate_wn( n, m, -1, cc, ss, wn_inv);

	/* initialize data */
	for(i=0; i<n*n; i++) {
		float tmpr = frand();
		float tmpi = frand();
		data1[i] = tmpr + tmpi * I;
		data2[i] = 0.0f;
		data3[i] = 0.0f;
	}


	/* allocate memory on device */
	coprthr_mem_t wn_mem = coprthr_dmalloc(dd,n*sizeof(cfloat),0);
	coprthr_mem_t data2_mem = coprthr_dmalloc(dd,n*n*sizeof(cfloat),0);

	/* copy memory to device */
	coprthr_dwrite(dd,wn_mem,0,wn_fwd,n*sizeof(cfloat),COPRTHR_E_WAIT);
	coprthr_dwrite(dd,data2_mem,0,data1,n*n*sizeof(cfloat),COPRTHR_E_WAIT);

	/* execute parallel calculation */
	struct my_args args_fwd = {
		.n = n, .m = m,
		.inverse = 0,
		.wn = coprthr_memptr(wn_mem,0),
		.data2 = coprthr_memptr(data2_mem,0)
	};

	gettimeofday(&t0,0);
	coprthr_mpiexec( dd, NPROCS, thr, &args_fwd, sizeof(struct my_args),0 );
	gettimeofday(&t1,0);

	/* read back data from memory on device */
	coprthr_dread(dd,data2_mem,0,data2,n*n*sizeof(cfloat),
		COPRTHR_E_WAIT);

	coprthr_dwrite(dd,wn_mem,0,wn_inv,n*sizeof(cfloat),COPRTHR_E_WAIT);
	coprthr_dwrite(dd,data2_mem,0,data2,n*n*sizeof(cfloat),COPRTHR_E_WAIT);

	/* execute parallel calculation */
	struct my_args args_inv = {
		.n = n, .m = m,
		.inverse = 1,
		.wn = coprthr_memptr(wn_mem,0),
		.data2 = coprthr_memptr(data2_mem,0)
	};

	gettimeofday(&t2,0);
	coprthr_mpiexec( dd, NPROCS, thr, &args_inv, sizeof(struct my_args),0 );
	gettimeofday(&t3,0);

	coprthr_dread(dd,data2_mem,0,data3,n*n*sizeof(cfloat),
		COPRTHR_E_WAIT);


	for(i=0; i<n*n; i++) {
		printf("%d:\t(%f %f)\t(%f %f)\t(%f %f)\n",i,
			crealf(data1[i]),cimagf(data1[i]),
			crealf(data2[i]),cimagf(data2[i]),
			crealf(data3[i]),cimagf(data3[i]) );
	}


	double time_fwd = t1.tv_sec-t0.tv_sec + 1e-6*(t1.tv_usec - t0.tv_usec);
	double time_inv = t3.tv_sec-t2.tv_sec + 1e-6*(t3.tv_usec - t2.tv_usec);
	printf("mpiexec time: forward %f sec inverse %f sec\n", time_fwd,time_inv);

	/* clean up */
	coprthr_dclose(dd);
}
