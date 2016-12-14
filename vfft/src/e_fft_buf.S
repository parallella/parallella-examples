/*
 * e_fft_buf.S
 *
 * Static symbol definitions for the test software
 *
 * Copyright (C) 2015 - Sylvain Munaut <tnt@246tNt.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 */

/* ANSI concatenation macros.  */
#define CONCAT1(a, b) CONCAT2(a, b)
#define CONCAT2(a, b) a ## b
/* Use the right prefix for global labels.  */
#define SYM(x) CONCAT1 (__USER_LABEL_PREFIX__, x)


/* Define the static arrays */

	/* Shared API struct: lower half of bank 1 */
	.global SYM(api)
	.equ SYM(api), 0x2000

	/* Twiddle factors: upper half of bank 1 */
	.global SYM(twiddle)
	.equ SYM(twiddle), 0x3000

	/* Data0 buffer: all of bank 2 */
	.global SYM(data0)
	.equ SYM(data0), 0x4000

	/* Data1 buffer: all of bank 3 */
	.global SYM(data1)
	.equ SYM(data1), 0x6000
