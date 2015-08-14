/* mpi_fft2d_tfunc.c
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


#include <coprthr.h>
#include <coprthr_mpi.h>
#include <complex.h>
#define cfloat float complex

void bitreverse_swap( short* brp, void* p_data )
{
	cfloat* data = (cfloat*)p_data;

	int k=0;
	while( brp[k] ) {
		int i = brp[k++];
		int j = brp[k++];
		cfloat tmp = data[i];
		data[i] = data[j];
		data[j] = tmp;
	}
}

void fft_r2_dit( unsigned int n, unsigned int m, void* p_wn, void* p_data )
{
	cfloat* wn = (cfloat*)p_wn;
	cfloat* data = (cfloat*)p_data;

	int l,l1,l2,wstride = n;
	int i0,i1;
	l2 = 1;
	for(l=0; l<m; l++) {
		l1 = l2;
		l2 <<= 1;
		int i=0, j;
		wstride = wstride >> 1;
		for(j=0; j<l1; j++) {
			cfloat wni = wn[i];
			for(i0=j; i0<n; i0+=l2) {
				i1 = i0 + l1;
				cfloat tmp0 = data[i0];
				cfloat tmp = wni * data[i1];
				data[i1] = tmp0 - tmp;
				data[i0] = tmp0 + tmp;
			}
			i += wstride;
		}
	}
}


void corner_turn( 
	int nprocs, int rank, void* p_data, unsigned int n, unsigned int nlocal,
	void* p_comm 
) {
	cfloat* data = (cfloat*)p_data;
	MPI_Comm comm = (MPI_Comm)p_comm;

	MPI_Status status;

	void* memfree = coprthr_tls_sbrk(0);
	cfloat* buf2 = (cfloat*)coprthr_tls_sbrk(nlocal*nlocal*sizeof(cfloat));

	int i, j, k = rank, l;

	int ct = (nprocs - k) % nprocs;

	for(l=0;l<nprocs;l++) {

		cfloat* src = data + ct*nlocal;
		cfloat* dst = buf2;
		for(i=0;i<nlocal;i++) {
			long long* psrc = (long long*)src;
			long long* pdst = (long long*)dst;
			for(j=0; j<nlocal; j+=4) {
				*(pdst++) = *(psrc++);
				*(pdst++) = *(psrc++);
				*(pdst++) = *(psrc++);
				*(pdst++) = *(psrc++);
			}
			src += n;
			dst += nlocal;
		}

		MPI_Sendrecv_replace(buf2,2*nlocal*nlocal,MPI_FLOAT,
			ct,71,ct,72,comm,&status);

		for(i=0;i<nlocal;i++) {
			cfloat* pdst = data+ct*nlocal+i;
			cfloat* psrc = buf2+i*nlocal;
			for(j=0; j<nlocal; j+=4) {
				*pdst = *psrc++;
				pdst += n;
				*pdst = *psrc++;
				pdst += n;
				*pdst = *psrc++;
				pdst += n;
				*pdst = *psrc++;
				pdst += n;
			}
		}

		ct = (ct+1) % nprocs;

	}

	coprthr_tls_brk(memfree);

}



typedef struct { 
	unsigned int n;
	unsigned int m;
	int inverse;
	cfloat* wn; 
	cfloat* data2; 
} my_args_t;

__kernel void
my_thread( void* p) {

	my_args_t* pargs = (my_args_t*)p;

	unsigned int n = pargs->n;
	unsigned int m = pargs->m;
	int inverse = pargs->inverse;
	cfloat* g_wn = pargs->wn;
	cfloat* g_data2 = pargs->data2;

	int i,j,k,l;
	int row;

	int mask = (1 << m) - 1;

	int nprocs;
	int myrank;

	MPI_Init(0,MPI_BUF_SIZE);

	MPI_Comm comm = MPI_COMM_THREAD;

	MPI_Comm_size(comm, &nprocs);
	MPI_Comm_rank(comm, &myrank);

	size_t nlocal = n/nprocs;

	void* memfree = coprthr_tls_sbrk(0);

	short* brp = (short*)coprthr_tls_sbrk(n*2*sizeof(short));
	for(i=0;i<n*2;i++) brp[i] = 0;
	k=0;
	for(i=0; i<n; i++) {
		int x = i;
		int y = 0;
		for(j=0; j<m; j++)
			y = (y << 1) | ((x >> j) & 1);
		if (x < y) {
			brp[k++] = x;
			brp[k++] = y;
		}
	}

	cfloat* wn = (cfloat*)coprthr_tls_sbrk(n*sizeof(cfloat));
	cfloat* data2 = (cfloat*)coprthr_tls_sbrk(nlocal*n*sizeof(cfloat));

	e_dma_copy(wn,g_wn,n*sizeof(cfloat));
	e_dma_copy(data2,g_data2+myrank*nlocal*n,nlocal*n*sizeof(cfloat));

	//////////////////////////////

	//// bit-reversal swap in-place
	cfloat* data = data2;
	data = data2;
	for(row=0; row<nlocal; row++, data+=n) {
		bitreverse_swap(brp,data);
	}


	//// forward FFT
	data = data2;
	for(row=0; row<nlocal; row++, data+=n) {
		fft_r2_dit( n, m, wn, data );
	}

	//// corner turn
	corner_turn( nprocs, myrank, data2, n, nlocal, comm);


	//// bit-reversal swap in-place
	data = data2;
	for(row=0; row<nlocal; row++, data+=n) {
		bitreverse_swap(brp,data);
	}

	//// forward FFT
	data = data2;
	for(row=0; row<nlocal; row++, data+=n) {
		fft_r2_dit(n, m, wn,data);
	}

	//// corner turn
	corner_turn( nprocs, myrank, data2, n, nlocal, comm);


	/// rescale if inverse
	float inv_n2 = 1.0f / ((float)n*n);

	if (inverse) {
		cfloat* pdata = data2;
		for(i=0; i<nlocal*n; i+=4) {
			*(pdata++) *= inv_n2;
			*(pdata++) *= inv_n2;
			*(pdata++) *= inv_n2;
			*(pdata++) *= inv_n2;
		}
	}

	//////////////////////////////

	e_dma_copy(g_data2+myrank*nlocal*n,data2,nlocal*n*sizeof(cfloat));

	coprthr_tls_brk(memfree);

	MPI_Finalize();

}

