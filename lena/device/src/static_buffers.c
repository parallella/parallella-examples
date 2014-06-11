/*
  static_buffers.c

  Copyright (C) 2012 Adapteva, Inc.
  Contributed by Yainv Sapir <yaniv@adapteva.com>

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


#include "static_buffers.h"


// Here's an example of explicit placement of static objects in memory. The three matrices
// are placed in the respective SRAM banks. However, if necessary, the linker may relocate
// the objects wherever within the bank. The core structure "me" is specifically located
// at an explicit address - 0x7000. To do that, a custom linker file (LDF) was defined,
// based on a standard LDF, in which a special data section was added with the required
// address to assign to the "me" object.
volatile cfloat  AA[_Score][_Sfft] ALIGN(8) SECTION(".data_bank1");       // local operand array (ping)
volatile cfloat  BB[_Score][_Sfft] ALIGN(8) SECTION(".data_bank2");       // local operand array (pong)
volatile cfloat  Wn[_Sfft/2]       ALIGN(8) SECTION(".data_bank3");       // local Wn twiddles array
core_t           me                ALIGN(8) SECTION("core_data_section"); // core data structure
shared_buf_ptr_t Mailbox           ALIGN(8) SECTION("core_data_section"); // Mailbox pointers
volatile e_dma_desc_t tcb          ALIGN(8) SECTION("core_data_section"); // TCB structure for DMA
float recipro[16]                  ALIGN(8) SECTION("core_data_section"); // 1/n   LUT
float recipro_2_by[16]             ALIGN(8) SECTION("core_data_section"); // 1/2^n LUT
float Cw_lg[16]                    ALIGN(8) SECTION("core_data_section"); //  Cos(2 * Pi / 2^N)
float Sw_lg[16]                    ALIGN(8) SECTION("core_data_section"); // -Sin(2 * Pi / 2^N)


// Initialize reciprocals LUTs
float recipro[16] = {
		0.000000000000000, // 1/0
		1.000000000000000, // 1/1
		0.500000000000000, // 1/2
		0.333333333333333, // 1/3
		0.250000000000000, // 1/4
		0.200000000000000, // 1/5
		0.166666666666667, // 1/6
		0.142857142857143, // 1/7
		0.125000000000000, // 1/8
		0.111111111111111, // 1/9
		0.100000000000000, // 1/10
		0.090909090909091, // 1/11
		0.083333333333333, // 1/12
		0.076923076923077, // 1/13
		0.071428571428571, // 1/14
		0.066666666666667, // 1/15
};

float recipro_2_by[16] = {
		1.000000000000000, // 1/2^0
		0.500000000000000, // 1/2^1
		0.250000000000000, // 1/2^2
		0.125000000000000, // 1/2^3
		0.062500000000000, // 1/2^4
		0.031250000000000, // 1/2^5
		0.015625000000000, // 1/2^6
		0.007812500000000, // 1/2^7
		0.003906250000000, // 1/2^8
		0.001953125000000, // 1/2^9
		0.000976562500000, // 1/2^10
		0.000488281250000, // 1/2^11
		0.000244140625000, // 1/2^12
		0.000122070312500, // 1/2^13
		0.000061035156250, // 1/2^14
		0.000030517578125, // 1/2^15
};

// Initialize trigonometric LUTs
// Cos(2 * Pi / 2^N)
float Cw_lg[16] = {
		 1.0000000000000000, // Cos(2 * Pi / 2^0)
		-1.0000000000000000, // Cos(2 * Pi / 2^1)
		 0.0000000000000001, // Cos(2 * Pi / 2^2)
		 0.7071067811865480, // Cos(2 * Pi / 2^3)
		 0.9238795325112870, // Cos(2 * Pi / 2^4)
		 0.9807852804032300, // Cos(2 * Pi / 2^5)
		 0.9951847266721970, // Cos(2 * Pi / 2^6)
		 0.9987954562051720, // Cos(2 * Pi / 2^7)
		 0.9996988186962040, // Cos(2 * Pi / 2^8)
		 0.9999247018391450, // Cos(2 * Pi / 2^9)
		 0.9999811752826010, // Cos(2 * Pi / 2^10)
		 0.9999952938095760, // Cos(2 * Pi / 2^11)
		 0.9999988234517020, // Cos(2 * Pi / 2^12)
		 0.9999997058628820, // Cos(2 * Pi / 2^13)
		 0.9999999264657180, // Cos(2 * Pi / 2^14)
		 0.9999999816164290, // Cos(2 * Pi / 2^15)
};

// -Sin(2 * Pi / 2^N)
float Sw_lg[16] = {
		 0.0000000000000000, // -Sin(2 * Pi / 2^0)
		 0.0000000000000000, // -Sin(2 * Pi / 2^1)
		-1.0000000000000000, // -Sin(2 * Pi / 2^2)
		-0.7071067811865470, // -Sin(2 * Pi / 2^3)
		-0.3826834323650900, // -Sin(2 * Pi / 2^4)
		-0.1950903220161280, // -Sin(2 * Pi / 2^5)
		-0.0980171403295606, // -Sin(2 * Pi / 2^6)
		-0.0490676743274180, // -Sin(2 * Pi / 2^7)
		-0.0245412285229123, // -Sin(2 * Pi / 2^8)
		-0.0122715382857199, // -Sin(2 * Pi / 2^9)
		-0.0061358846491545, // -Sin(2 * Pi / 2^10)
		-0.0030679567629660, // -Sin(2 * Pi / 2^11)
		-0.0015339801862848, // -Sin(2 * Pi / 2^12)
		-0.0007669903187427, // -Sin(2 * Pi / 2^13)
		-0.0003834951875714, // -Sin(2 * Pi / 2^14)
		-0.0001917475973107, // -Sin(2 * Pi / 2^15)
};

