/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Matt Thompson <mthompson@hexwave.com>
  Modified by Ted Swoyer <tswoyer@gmail.com>

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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>

#include <e-hal.h>

// Default x, where program will find the number of primes less than or equal to x
// This value is used if one is not provided as a runtime argument in argv[1]
#define DEFAULT_X 1000000

int main(int argc, char *argv[])
{
	unsigned row, col, coreid, i, j;
	e_platform_t platform;
	e_epiphany_t dev;

	uint64_t x_value = DEFAULT_X;

	if(argc > 1)
	{
		x_value = strtoull(argv[1], NULL, 10);
	}

	// Initialize the Epiphany HAL and connect to the chip
	e_init(NULL);

	// Reset the system
	e_reset_system();

	// Get the platform information
	e_get_platform_info(&platform);

	// Create a workgroup using all of the cores	
	e_open(&dev, 0, 0, platform.rows, platform.cols);
	e_reset_group(&dev);

	// Load the device code into each core of the chip, and don't start it yet
	e_load_group("bin/e_prime.srec", &dev, 0, 0, platform.rows, platform.cols, E_FALSE);

	// Set the maximum per core test value on each core at address 0x7020
	for(row=0;row<platform.rows;row++)
	{
		for(col=0;col<platform.cols;col++)
		{
			e_write(&dev, row, col, 0x7020, &x_value, sizeof(uint64_t));
		}
	}

	// Start all of the cores
	e_start_group(&dev);

	uint64_t sum = 0;
	uint64_t total_primes = 0;
	uint64_t last = 0;
	double iPs = 0.0;

	uint64_t count;
	uint64_t current;
	uint64_t primes;

	while(1)
	{
		usleep(100000);
		int done = 0;

		// wait for the cores to complete their work
		for(row=0;row<platform.rows;row++)
		{
			for(col=0;col<platform.cols;col++)
			{
		
				// Get the number being tested by the core
				if(e_read(&dev, row, col, 0x7008, &current, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				if ( current >= x_value)
					done++;
			}
		}

		if ( done >= 16 )
			break;
	}

	// print out the results for each core
	for(row=0;row<platform.rows;row++)
	{
		for(col=0;col<platform.cols;col++)
		{
				// Get the number of primality tests performed by this core
				if(e_read(&dev, row, col, 0x7000, &count, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				// Get the number the core ended on
				if(e_read(&dev, row, col, 0x7008, &current, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				// Get the number of primes found by this core
				if(e_read(&dev, row, col, 0x7010, &primes, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				// print the core values
				// fprintf(stderr, "Core (%02d,%02d) Tests: %" PRIu64 " Primes: %" PRIu64 " Current: %" PRIu64 "\n", row, col, count, primes, current);
				fprintf(stderr, "Core (%02d,%02d) Tests: %" PRIu64 " Primes: %" PRIu64 "\n", row, col, count, primes);

				// calculate the aggregates
				sum += count;
				total_primes += primes;
		}
	}

	// Print final results
	printf("\nTotal tests: %" PRIu64 " Found primes: %" PRIu64 "\n", sum, total_primes + 1);

	e_finalize();

	return 0;
}
