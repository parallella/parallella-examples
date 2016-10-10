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

/* omp4_demo1.c
 * ------------
 * Simple demonstration of the Zynq and Epiphany as OpenMP4.0 devices.
 */

#include <omp.h>
#include <stdio.h>


void demo_devices()
{
	int i, isinitial;

	/* Diagnostics */
	printf("Available devices:    %d\n", omp_get_num_devices());
	printf("Default device:       %d\n", omp_get_default_device());
	for (i = 0; i < omp_get_num_devices(); i++)
	{
		printf("Kernel check @ device %d ", i);
		#pragma omp target device(i) map(from:isinitial)
		{
			isinitial = omp_is_initial_device();
		}
		printf(isinitial ? "(zynq)\n" : "(epiphany)\n");
	}
}


int main()
{
	demo_devices();
	return 0;
}

