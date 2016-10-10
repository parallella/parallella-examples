/*
  Copyright since 2016 the OMPi Team
  Dept. of Computer Science & Engineering, University of Ioannina

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/* pi.c
 * ----
 * Simple pi calculation executed either on the Zynq or the Epiphany.
 */

#include <stdio.h>
#include <omp.h>

#define N 2000000      /* Intervals */


/* Naive pi calculation based on the trapezoid rule.
 */
void calc_pi(int nthr)
{
	double W = 4.0 / N, W2 = W * W / 16.0, pi = 0.0;

	/* Executed @ host (zynq, aka device 0) */
	#pragma omp parallel num_threads(nthr) reduction(+:pi)
	{
		int i = omp_get_thread_num();

		/* Offloaded @ default device (normally epiphany).
		 * Note that pi is implicitly mapped as tofrom.
		 */
		#pragma omp target map(to:i,W,W2,nthr)
		{
			for (; i < N; i += nthr)
				pi += W / (1.0 + (0.5 + i) * (0.5 + i) * W2);

		}
	}
	printf("pi = %.10lf", pi);
}


/* Calculate pi with 1, 2, 4, 8, 16 threads/kernels.
 */
int main()
{
	int    nthr, max_kernels;
	double t1, t2;

	if (omp_get_default_device() == 0)
	{
		printf("Calculating pi on the Zynq, using 1 and 2 kernels..\n");
		max_kernels = 2;
	}
	else
	{
		printf("Calculating pi on the Epiphany, using 1, 2, 4, 8, and 16 kernels..\n");
		max_kernels = 16;
	}

	for (nthr = 1; nthr <= max_kernels; nthr <<= 1)
	{
		t1 = omp_get_wtime();
		calc_pi(nthr);
		t2 = omp_get_wtime();

		printf("\t[%2d kernels => %2.5lf sec]\n", nthr, t2 - t1);
	}
	return 0;
}

