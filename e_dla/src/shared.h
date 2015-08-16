/*
   shared.c

   Contributed by Rob Foster 

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

#define ALIGN8 8

typedef struct __attribute__((aligned(ALIGN8)))
{
  uint32_t smem_start;
  uint32_t smem_len;
  uint32_t line_length;
  uint32_t xres;
  uint32_t yres;
  uint32_t xres_virtual;
  uint32_t yres_virtual;
  uint32_t xoffset;
  uint32_t yoffset;
  uint32_t bits_per_pixel;
  uint32_t emptyPixVal;
} fbinfo_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
	int n;
	int offset;
	char color;
	fbinfo_t fbinfo;
} my_args_t;

unsigned int g_seed;

inline void fast_srand(int seed)
{
	g_seed = seed;
}

int fastrand()
{
	g_seed = (214013 * g_seed + 2531011);
	return (g_seed  >> 16) & 0x7fff;
}
