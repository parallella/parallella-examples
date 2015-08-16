/*
   e_dla.c

   Contributed by Rob Foster 

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program, see the file COPYING.  If not, see
   <http://www.gnu.org/licenses/>.
 */

// This is the Epiphany side of the e_dla example.

#include <sys/types.h>
#include <unistd.h>
#include "coprthr_mpi.h"

#include "shared.h"

#define BPP 4



	__kernel void
dla_thread( void* p )
{
	my_args_t* pargs = (my_args_t*)p;
	int baseColor;
	int i, n, ix, iy, ixnew, iynew;
	int found;
	int R = 10;
	int R2 = 5;
	int seq;
	int row1[3], row2[3], row3[3];
	int rank;
	int x_half = pargs->fbinfo.xres_virtual / 2;
	int y_half = pargs->fbinfo.yres_virtual / 2;
	float angle, mySin, myCos, inv_rand_max = 1.0f / (float) 32767;


	MPI_Status status;
	MPI_Init(0,MPI_BUF_SIZE);
	MPI_Comm comm = MPI_COMM_THREAD;
	MPI_Comm_rank(comm, &rank);

	baseColor = 0x00ffffff;

	void* memfree = coprthr_tls_sbrk(0);
	fast_srand(getpid());
	seq = 1;
	if(rank == 0){
		e_dma_copy((char *) pargs->fbinfo.smem_start + (y_half * pargs->fbinfo.line_length) + ((x_half + pargs->offset) * BPP), (char *) &baseColor, 1 * BPP);
	}
	for(n = 0; n < pargs->n; n++){
		angle = ((2.0f * ((float) fastrand()) * inv_rand_max) - 1.0f) * 3.14159265f;
		if(angle < 0.0f){
			mySin = 1.275323954f * angle + 0.405284735f * angle * angle;
			if(mySin < 0)
				mySin = 0.225f * (mySin * -mySin - mySin) + mySin;
			else
				mySin = 0.225f * (mySin * mySin - mySin) + mySin;
		}
		else{
			mySin = 1.275323954f * angle - 0.405284735f * angle * angle;
			if(mySin < 0)
				mySin = 0.225f * (mySin * -mySin - mySin) + mySin;
			else
				mySin = 0.225f * (mySin * mySin - mySin) + mySin;
		}
		angle += 1.57079632f;
		if(angle > 3.14159265f)
			angle -= 6.28318531f;
		if(angle < 0.0f){
			myCos = 1.275323954f * angle + 0.405284735f * angle * angle;
			if(myCos < 0)
				myCos = 0.225f * (myCos * -myCos - myCos) + myCos;
			else
				myCos = 0.225f * (myCos * myCos - myCos) + myCos;
		}
		else{
			myCos = 1.275323954f * angle - 0.405284735f * angle * angle;
			if(myCos < 0)
				myCos = 0.225f * (myCos * -myCos - myCos) + myCos;
			else
				myCos = 0.225f * (myCos * myCos - myCos) + myCos;
		}
		ix = ((x_half + pargs->offset) + ((R2 - 2) * myCos));
		iy = (y_half + ((R2 - 2) * mySin));

		while(1){
			ixnew = ix + (fastrand() % 3) - 1;
			if(ixnew > (x_half + pargs->offset) - R2 && ixnew < (x_half + pargs->offset) + R2){
				ix = ixnew;
			}
			else{
				continue;
			}
			iynew = iy + (fastrand() % 3) - 1;
			if(iynew > y_half - R2 && iynew < y_half + R2){
				iy = iynew;
			}
			else{
				continue;
			}
			found = 0;
			e_dma_copy(row1, (char *) pargs->fbinfo.smem_start + ((iy - 1) * pargs->fbinfo.line_length) + ((ix - 1) * BPP), 3 * BPP);
			e_dma_copy(row2, (char *) pargs->fbinfo.smem_start + ((iy) * pargs->fbinfo.line_length) + ((ix - 1) * BPP), 3 * BPP);
			e_dma_copy(row3, (char *) pargs->fbinfo.smem_start + ((iy + 1) * pargs->fbinfo.line_length) + ((ix - 1) * BPP), 3 * BPP);
			if(row1[0] != pargs->fbinfo.emptyPixVal || row2[0] != pargs->fbinfo.emptyPixVal || row3[0] != pargs->fbinfo.emptyPixVal){
				found = 1;
				break;
			}
			if(row1[1] != pargs->fbinfo.emptyPixVal || row2[1] != pargs->fbinfo.emptyPixVal || row3[1] != pargs->fbinfo.emptyPixVal){
				found = 1;
				break;
			}
			if(row1[2] != pargs->fbinfo.emptyPixVal || row2[2] != pargs->fbinfo.emptyPixVal || row3[2] != pargs->fbinfo.emptyPixVal){
				found = 1;
				break;
			}
		}
		e_dma_copy((char *) pargs->fbinfo.smem_start + (iy * pargs->fbinfo.line_length) + (ix * BPP), (char *) &baseColor, 1 * BPP);

		if((ix - 3 <= ((x_half + pargs->offset) - R2) || (ix + 3 >= (x_half + pargs->offset) + R2) || (iy - 3 <= y_half - R2) || (iy + 3 >= y_half + R2))){
			R += 4;
			R2 += 2;
			if(seq == 1){
				baseColor -= (pargs->color == 'R' ? 0x00020000 : 0x00030000);
			}
			else if(seq == 2){
				baseColor -= (pargs->color == 'B' ? 0x00000002 : 0x00000003);
			}
			else{
				baseColor -= (pargs->color == 'G' ? 0x00000200 : 0x00000300);
			}
			seq++;
			if(seq > 3)
				seq = 1;
		}
	}

	coprthr_tls_brk(memfree);

	MPI_Finalize();
	return 0;
}
