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

/* gol_fast.c
 * ----------
 * This program is a fast implementation of Conway's Game of Life on the Epiphany,
 * using OpenMP4.x kernels.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <omp.h>

#define NSTEPS  1000  /* Number of time steps */
#define NCORES  16    /* Number of cores used (16 for Epiphany-16) */

#define ROWS    16    /* Number of rows */
#define COLS    90    /* Number of columns */

#define RPC     ((ROWS + NCORES-1) / NCORES) /* Rows per core */


/* Initialize cells randomly. */
void init_field(char field[ROWS][COLS])
{
	int i, j;
	float x;

	for (i = 0; i < ROWS; i++)
	{
		for (j = 0; j < COLS; j++)
		{
			x = rand() / ((float)RAND_MAX + 1);
			if (x < 0.5)
				field[i][j] = 0;
			else
				field[i][j] = 1;
		}
	}
}


int main(int argc, char *argv[])
{
	int i, j, w, z, y, isum, nthreads;
	char field[ROWS][COLS];

	if (RPC * (COLS + 2) > 4 * 184)
	{
		printf("Error. Field too large.\n");
		return 0;
	}

	init_field(field);

	/* Offload epiphany kernel. */
	#pragma omp target data map(field, nthreads)
	{
		#pragma omp target
		{
			char(*(ptrs_curr_field[NCORES]))[COLS + 2];

			omp_set_num_threads(NCORES);

			#pragma omp parallel shared(field, ptrs_curr_field)
			{
				int i, j, n, nsum;
				int my_id = omp_get_thread_num();

				char curr_field[RPC + 2][COLS + 2]; /* My part of the field. */
				char new_row[COLS + 2]; /* New cell values in each row are staged here. */
				char new_row_copy[COLS + 2]; /* Temporary copy of new_row[] */
				char(*prev_core)[COLS + 2]; /* Last row of previous core. */
				char(*next_core)[COLS + 2]; /* First row of next core. */

				#pragma omp master
				nthreads = omp_get_num_threads();

				/* Copy the rows of interest and zero out first/last row and first/last column. */
				for (i = 0; i < RPC; i++)
				{
					for (j = 0; j < COLS; j++)
						curr_field[i + 1][j + 1] = field[i + (my_id * RPC)][j];
					curr_field[i + 1][0] = curr_field[i + 1][COLS + 1] = 0;
				}

				/* Copy previous line (neighbour). */
				for (j = 0; j < COLS; j++)
					curr_field[0][j + 1] = (my_id) ? field[(my_id * RPC) - 1][j] : 0;

				/* Copy next line (neighbour). */
				for (j = 0; j < COLS; j++)
					curr_field[RPC + 1][j + 1] = (my_id != NCORES - 1) ?
					field[((my_id + 1) * RPC)][j] : 0;

				curr_field[0][0] = curr_field[0][COLS + 1] = 0;
				curr_field[RPC + 1][0] = curr_field[RPC + 1][COLS + 1] = 0;

				ptrs_curr_field[my_id] = (char(*)[(COLS + 2)]) ort_dev_gaddr(curr_field);

				#pragma omp barrier

				/* Initialize the pointers to my neighbours. */
				prev_core = ptrs_curr_field[(my_id + (NCORES - 1)) % NCORES];
				next_core = ptrs_curr_field[(my_id + 1) % NCORES];

				for (n = 0; n < NSTEPS; n++)
				{
					/* Compute new values for each row (and store in new_row[]). */
					for (i = 1; i <= RPC; i++)
					{
						for (j = 1; j <= COLS; j++)
						{
							nsum =    curr_field[i - 1][j - 1] + curr_field[i - 1][j] + curr_field[i - 1][j
							+ 1]
							+ curr_field[i][j - 1]                        + curr_field[i][j + 1]
							+ curr_field[i + 1][j - 1] + curr_field[i + 1][j] + curr_field[i + 1][j + 1];

							switch (nsum)
							{
								case 3:
									new_row[j] = 1;
									break;

								case 2:
									new_row[j] = curr_field[i][j];
									break;

								default:
									new_row[j] = 0;
							}
						}

						/* Apply new values to previous row. */
						if (i > 1)
							for (j = 1; j <= COLS; j++)
								curr_field[i - 1][j] = new_row_copy[j];

						/* Copy new row. */
						for (j = 1; j <= COLS; j++)
							new_row_copy[j] = new_row[j];
					}

					/* Apply new values to last row. */
					for (j = 1; j <= COLS; j++)
						curr_field[RPC][j] = new_row[j];

					#pragma omp barrier

					/* Write my last row to the first row of next core. */
					if (my_id != NCORES - 1)
						for (j = 1; j <= COLS; j++)
							next_core[0][j] = curr_field[RPC][j];

					/* Write my first row to the last row of previous core. */
					if (my_id != 0)
						for (j = 1; j <= COLS; j++)
							prev_core[RPC + 1][j] = curr_field[1][j];

					#pragma omp barrier

				}

				/* Copy back my part of the field. */
				for (i = 0; i < RPC; i++)
					for (j = 0; j < COLS; j++)
						field[(my_id * RPC) + i][j] = curr_field[i + 1][j + 1];

			}
		}
	}

	/*  Iterations are done; sum the number of live cells. */
	isum = 0;
	for (i = 0; i < ROWS; i++)
		for (j = 0; j < COLS; j++)
			isum = isum + field[i][j];

	printf("Game of Life using OpenMP4\n");
	printf("Field: %dx%d\n", ROWS, COLS);
	printf("Number of steps: %d\n", NSTEPS);
	printf("Number of live cells: %d\n", isum);
	printf("Number of threads used: %d threads\n", NCORES);

	return 0;
}

