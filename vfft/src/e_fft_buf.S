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

/* Define the static arrays */

	/* Shared API struct: lower half of bank 1 */
	.global _api
	.equ _api, 0x2000

	/* Twiddle factors: upper half of bank 1 */
	.global _twiddle
	.equ _twiddle, 0x3000

	/* Data0 buffer: all of bank 2 */
	.global _data0
	.equ _data0, 0x4000

	/* Data1 buffer: all of bank 3 */
	.global _data1
	.equ _data1, 0x6000
