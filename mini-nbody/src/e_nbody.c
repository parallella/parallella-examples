
/*
   e_nbody.c

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

// This is the DEVICE side of the Hello World example.
// The host may load this program to any eCore. When
// launched, the program queries the CoreID and prints
// a message identifying itself to the shared external
// memory buffer.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "e_lib.h"
#include "shared.h"


float Q_rsqrt(float number);

void sync_isr(int);


int main(void) {
	e_coreid_t coreid;
	unsigned row, col, *done;
	int core;
	int *n = (int *) 0x1000; //numBodies
	int *o = (int *) 0x1004; //Done
	const float dt = 0.75f; // time step

	e_irq_attach(E_SYNC, sync_isr);
	e_irq_mask(E_SYNC, E_FALSE);
	e_irq_global_mask(E_FALSE);
	while(1){

		// Who am I? Query the CoreID from hardware.
		coreid = e_get_coreid();
		e_coords_from_coreid(coreid, &row, &col);
		Body *q = (Body *) 0x5000;
		Body *r = (Body *) 0x1008;
		Body *p;

		core = (4 * row) + (col + 1);
		int i, j, x, y;
		float dx;
		float dy;
		float dz;
		float distSqr;
		float invDist;
		float invDist3;

		// only work on this core's slice of the data array
		for (i = 0; i < *n; i++) {
			float Fx = 0.0f; float Fy = 0.0f; float Fz = 0.0f;
			for(x = 0; x < 4; x++){
				for(y = 0; y < 4; y++){
					p = (Body *) e_get_global_address(x, y, q);

					for (j = 0; j < *n; j++) {
						dx = p[j].x - r[i].x;
						dy = p[j].y - r[i].y;
						dz = p[j].z - r[i].z;
						distSqr = dx*dx + dy*dy + dz*dz + SOFTENING;
						// Bad performance 
						//invDist = 1.0f / sqrtf(distSqr);
						invDist = Q_rsqrt(distSqr);
						invDist3 = invDist * invDist * invDist;
						float s = p[j].m * invDist3;	


						/* Fx += dx * invDist3; 
						   Fy += dy * invDist3;
						   Fz += dz * invDist3;*/
						Fx += dx * s; 
						Fy += dy * s;
						Fz += dz * s;

					}
				}
			}

			r[i].vx += dt*Fx * r[i].im;
			r[i].vy += dt*Fy * r[i].im;
			r[i].vz += dt*Fz * r[i].im;

		}
		/*if(core == 1){
		  int *z[NUM_CORES];
		  int num = 0;
		  int all_done;
		  for(i = 0; i < 4; i++){
		  for(j = 0; j < 4; j++){
		  z[num++] = e_get_global_address(i, j, o);
		  }
		  }
		  while(1){
		  all_done = 0;
		  for (i = 1; i < NUM_CORES; i++){
		  all_done += *z[i];
		  }
		  if(all_done == 0){
		  break;
		  }
		  }*/
		// all cores done processing this iterationns, calculate new x, y, z corrdinates for next iteration
		for (i = 0; i < *n; i++) { 
			r[i].x += r[i].vx * dt;
			r[i].y += r[i].vy * dt;
			r[i].z += r[i].vz * dt;
		}
		//}
		(*(o)) = 0x00000000;

		while(((*(o)) == 0x00000000))
			__asm__ __volatile__ ("idle");
	}
}

void __attribute__((interrupt)) sync_isr(int x)
{
	return;
}

float Q_rsqrt(float number)
{
	long i;
	float x2, y;
	const float threehalfs = 1.5F;

	x2 = number * 0.5F;
	y = number;
	i = * ( long * ) &y;
	i = 0x5f3759df - ( i >> 1 );
	y = * (float *) &i;

	// 3 Iterations give good result, even # iterations don't work properly
	y = y * ( threehalfs - ( x2 * y * y ));
	y = y * ( threehalfs - ( x2 * y * y ));
	y = y * ( threehalfs - ( x2 * y * y ));
	y = y * ( threehalfs - ( x2 * y * y ));
	y = y * ( threehalfs - ( x2 * y * y ));

	return y;
}
