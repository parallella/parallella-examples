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

/* omp4_demo2.c
 * ------------
 * Another demonstration of OpenMP4.0 constructs on the Zynq and the Epiphany.
 */

#include <omp.h>
#include <stdio.h>


void demo_devices()
{
	int arg = 0;

	/* Diagnostics */
	printf("Available devices:  %d\n", omp_get_num_devices());
	printf("Default device:     %d\n", omp_get_default_device());

	/* arg is mapped to the device with initial value 0 */
	#pragma omp target data map(to:arg)
	{
		int on_eCore, i;

		for (i = 0; i < 20; i++)
		{
			/* Kernels 0 & 10 will execute on the host */
			#pragma omp target map(from:on_eCore) if(i%10 != 0)
			{
				/* omp_is_initial_device returns TRUE only on Zynq */
				on_eCore = !omp_is_initial_device();
				arg++;
			}

			/* Get value from the device */
			#pragma omp target update from(arg)

			printf("Kernel %2d executed on %8s --- value of arg=%d\n", i,
			       on_eCore ? "Epiphany" : "Zynq", arg);

			/* When the 10th kernel was executed on the host */
			if (!on_eCore && i > 0)
			{
				/* Set arg to 100 and push to the device */
				printf("     --> Changing arg value to 100\n");
				arg = 100;
				#pragma omp target update to(arg)
			}
		}

	}
}


int main()
{
	demo_devices();
	return 0;
}

