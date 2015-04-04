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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "e_lib.h"

volatile unsigned long long *count = (void *)0x7000;
volatile unsigned long long *num = (void *)0x7008;
volatile unsigned long long *primes = (void *)0x7010;
volatile unsigned long long *sq = (void *)0x7018;
volatile unsigned long long *max_tests = (void *)0x7020;

int isprime(unsigned long number);

int main(void)
{
	e_coreid_t id = e_get_coreid();
	unsigned row, col;
	
	unsigned long number;

	// Get the row, column coordinates of this core
	e_coords_from_coreid(id, &row, &col);

	// Assign the starting value for each core (3,5,7,..33)
	// Each core starts with a unique odd number (2 is the only even prime number)
	number = 2 + ((2*row*4) + (2*col+1));

	// Initialize this core iteration count for stats
	(*count) = 0;

	// Initialize the number of found primes counter
	(*primes) = 0;

	while(*count < *max_tests)
	{
		if(isprime(number))
			(*primes)++;

		// Skip to the next odd number for this core to test, assuming total of 16 cores
		// Core (0,0) started with 3 on the first iteration, and next test 35
		// Core (0,1) started with 5 on the first iteration, and next test 37
		// etc
		number += (2*16);

		*sq = sqrt(number);

		*num = number;

		(*count)++;
	}

	return EXIT_SUCCESS;
} 
