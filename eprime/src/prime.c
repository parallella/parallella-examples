/*
  Copyright (C) 2014 Adapteva, Inc.
  Contributed by Matt Thompson <mthompson@hexwave.com>

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

// Default maximum number of primality tests to run per core
// This is used if a limit it not provided as a runtime argument in argv[1]
#define DEFAULT_MAX_TESTS 1000000

int main(int argc, char *argv[])
{
	unsigned row, col, coreid, i, j;
	e_platform_t platform;
	e_epiphany_t dev;

	uint64_t max_tests = DEFAULT_MAX_TESTS;

	if(argc > 1)
	{
		max_tests = strtoull(argv[1], NULL, 10);
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
	e_load_group("e_prime.elf", &dev, 0, 0, platform.rows, platform.cols, E_FALSE);

	// Set the maximum per core test value on each core at address 0x7020
	for(row=0;row<platform.rows;row++)
	{
		for(col=0;col<platform.cols;col++)
		{
			e_write(&dev, row, col, 0x7020, &max_tests, sizeof(uint64_t));
		}
	}

	// Start all of the cores
	e_start_group(&dev);

	uint64_t sum = 0;
	uint64_t total_primes = 0;
	uint64_t last = 0;

	while(1)
	{
		sum = 0;
		total_primes = 0;
		usleep(100000);

		// Read the stats values from each core
		for(row=0;row<platform.rows;row++)
		{
			for(col=0;col<platform.cols;col++)
			{
				uint64_t count;
				uint64_t current;
				uint64_t sq;
				uint64_t primes;
		
				// Get the number of primality tests performed by this core
				if(e_read(&dev, row, col, 0x7000, &count, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				// Get the number being tested by the core
				if(e_read(&dev, row, col, 0x7008, &current, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				// Get the calculated sqrt for the current number from the core (race here as the number may have changed since the last e_read()
				if(e_read(&dev, row, col, 0x7018, &sq, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				// Get the number of primes found by this core
				if(e_read(&dev, row, col, 0x7010, &primes, sizeof(uint64_t)) != sizeof(uint64_t))
					fprintf(stderr, "Failed to read\n");

				fprintf(stderr, "Core (%02d,%02d) Tests: %" PRIu64 " Primes: %" PRIu64 " Current: %" PRIu64 " SQ: %" PRIu64 "\n", row, col, count, primes, current, sq);
				sum += count;
				total_primes += primes;
			}
		}

		// Print aggregate core stats
		printf("Total tests: %" PRIu64 " Found primes: %" PRIu64 "\n", sum, total_primes);
		printf("Iterations/sec: %lf\n", (double)(sum - last) / 0.1);
		last = sum;
	}

	e_finalize();

	return 0;
}

