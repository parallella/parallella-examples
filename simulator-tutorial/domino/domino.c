/*
  domino.c

  Copyright (C) 2015 Adapteva, Inc.
  Contributed by Ola Jeppsson <ola@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program, see the file COPYING.  If not, see
  <http://www.gnu.org/licenses/>.
*/

// This is the HOST side of the domino example

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#include <e-hal.h>
#include <e-loader.h>

#define BUF_OFFSET 0
#define BUF_SIZE (1024*1024)

static uint32_t
group_rank (uint32_t row, uint32_t col)
{
	e_platform_t platform;
	e_get_platform_info(&platform);
	return row * platform.cols + col;
}

inline static uint32_t
group_last_row ()
{
	e_platform_t platform;
	e_get_platform_info(&platform);

	uint32_t rows = platform.rows;
	return rows ? rows - 1 : 0;
}

inline static uint32_t
group_last_col ()
{
	e_platform_t platform;
	e_get_platform_info(&platform);

	uint32_t cols = platform.cols;
	return cols ? cols - 1 : 0;
}

static void print_path (uint16_t *path, uint16_t row, uint16_t col)
{
	signed north, east, south, west;
	uint16_t next, prev;

	north = row == 0                   ? -2 : path[group_rank (row-1, col  )];
	west  = col == 0                   ? -2 : path[group_rank (row  , col-1)];
	south = row == group_last_row () ? -2 : path[group_rank (row+1, col  )];
	east  = col == group_last_col () ? -2 : path[group_rank (row  , col+1)];

	next = path[group_rank(row, col)] + 1;
	prev = path[group_rank(row, col)] - 1;

	if (!prev)
		fputs ("○", stdout);
	else if (north == next)
		if (south == prev) fputs ("|", stdout); else fputs ("▲", stdout);
	else if (south == next)
		if (north == prev) fputs ("|", stdout); else fputs ("▼", stdout);
	else if (west == next)
		if (east == prev)  fputs ("—", stdout); else fputs ("◀", stdout);
	else if (east == next)
		if (west == prev)  fputs ("—", stdout); else fputs ("▶", stdout);
	else
		fputs ("⚫", stdout);
}
//
//void
//print_n_messages ()
//{
//	uint16_t *msgbox = (uint16_t *) MSG_BOX;
//
//	printf ("Got %d messages\n", msgbox[0]);
//}
//
void print_route (e_platform_t *pf, uint16_t *msgbox)
{
	unsigned i,j;
	uint32_t rank1; /* rank + 1 */
	uint16_t path[pf->rows * pf->cols];

	path[0] = 0;

	printf ("Got %d messages\n", msgbox[0]);
	printf ("Message path:\n");
	for (i=0; i < msgbox[0]; i++) {
		rank1 = msgbox[i+1];
		if (rank1)
			path[rank1 - 1] = i+1;
	}
	for (i=0; i < pf->rows; i++) {
		for (j=0; j < pf->cols; j++) {
			if (path[group_rank (i, j)])
				print_path (path, i, j);
			else
				fputs ("⨯", stdout);
		}

		fputs ("\n", stdout);
	}
}

int main(int argc, char *argv[])
{
	e_platform_t platform;
	e_epiphany_t dev;
	e_mem_t emem;
	uint16_t done;
	uint16_t *msgbox;

	srand(1);

	e_set_loader_verbosity(H_D0);
	e_set_host_verbosity(H_D0);

	// initialize system, read platform params from
	// default HDF. Then, reset the platform and
	// get the actual system parameters.
	e_init(NULL);
	e_reset_system();
	e_get_platform_info(&platform);

	e_open(&dev, 0, 0, platform.rows, platform.cols);
	e_alloc(&emem, BUF_OFFSET, BUF_SIZE);

	done = 0;
	e_write(&emem, 0, 0, 0, &done, sizeof(done));
	e_load_group("e-domino.elf", &dev, 0, 0, platform.rows, platform.cols, E_TRUE);

	while (!done)
		e_read(&emem, 0, 0, 0, &done, sizeof(done));

	msgbox = alloca(sizeof(msgbox[0]) * (platform.rows * platform.cols + 1));

	e_read(&emem, 0, 0, sizeof(done), msgbox, sizeof(msgbox[0]) * (platform.rows * platform.cols + 1));

	print_route (&platform, msgbox);

	usleep(1000000);

	e_free(&emem);
	e_finalize();

	return 0;
}
