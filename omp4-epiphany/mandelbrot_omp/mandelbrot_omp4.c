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

/* mandelbrot_ompi4.c
 * ------------------
 * Modified version of the Mandelbrot program found in the parallella-examples
 * repository, using OpenMP kernels.
 */

/* Copyright and license statement located in the original Mandelbrot program:
 *
 *    Copyright (c) 2013-2014, Shodruky Rhyammer
 *    All rights reserved.
 *
 *    Redistribution and use in source and binary forms, with or without modification,
 *    are permitted provided that the following conditions are met:
 *
 *    Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright notice, this
 *    list of conditions and the following disclaimer in the documentation and/or
 *    other materials provided with the distribution.
 *
 *    Neither the name of the copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 *    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 *    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <time.h>
#include <stdint.h>
#include <omp.h>
#include <assert.h>

#define __signed__
#include <linux/fb.h>

// SCALE: 1, 2, or 4
#define SCALE 1

#define FBDEV "/dev/fb0"
#define FRAMES 409

#define PAGE_SIZE 0x2000
#define CX -0.6510976f
#define CY 0.4920654f
#define MAXI 64
#define BPP 4


int main(int argc, char *argv[])
{
	struct timespec time;
	double time0, time1;
	char *fbp;

	char *smem_start;
	unsigned int smem_len;
	unsigned int line_length;
	unsigned int xres_virtual;
	unsigned int yres_virtual;

	printf("Calculations can be performed either on Zynq or Epiphany.\n");
	printf("Zynq is quite slower (be patient).\n");
	printf("Choose which device to use (0=Zynq, 1=Epiphany): ");
	omp_set_default_device(getchar() != '0');

	int fb = open(FBDEV, O_RDWR);
	if (fb > 0)
	{
		struct fb_fix_screeninfo fbfsi;
		struct fb_var_screeninfo fbvsi;
		if (ioctl(fb, FBIOGET_FSCREENINFO, &fbfsi) == 0)
		{
			smem_start = (char *)fbfsi.smem_start;
			smem_len = fbfsi.smem_len;
			line_length = fbfsi.line_length;
		}
		else
			printf("Error in FBIOGET_FSCREENINFO\n");

		if (ioctl(fb, FBIOGET_VSCREENINFO, &fbvsi) == 0)
		{
			xres_virtual = fbvsi.xres_virtual;
			yres_virtual = fbvsi.yres_virtual;
		}
		else
			printf("Error in FBIOGET_VSCREENINFO\n");

		if (omp_get_default_device() == 0) /* HOST */
		{
			fbp = (char *)mmap(0, fbfsi.smem_len, PROT_READ | PROT_WRITE, MAP_SHARED, fb,
			                   0);
			if (fbp == (char *) - 1)
			{
				fprintf(stderr, "Error: failed to map framebuffer device to memory.\n");
				exit(4);
			}
			smem_start = fbp;
		}

		close(fb);
	}
	else
	{
		printf("Error opening frame buffer\n");
		exit(EXIT_FAILURE);
	}

	printf("\n\nCalculating Mandelbrot set for image %d x %d...\n", xres_virtual,
	       yres_virtual);
	printf("...on %s.\n", omp_get_default_device() == 0 ? "Zynq" : "Epiphany");

	clock_gettime(CLOCK_REALTIME, &time);
	time0 = time.tv_sec + time.tv_nsec * 1.0e-9;

	#pragma omp target data
	{
		#pragma omp target map(to:xres_virtual, yres_virtual, smem_start, line_length)
		{
			#pragma omp parallel shared(xres_virtual, yres_virtual, smem_start, line_length)
			{
				unsigned int core, cores;
				core = omp_get_thread_num();
				cores = omp_get_num_threads();

				typedef struct
				{
					float x;
					float y;
				} center_t;

				center_t center[] = {
					{ -1.7919611f, 0.0f},
					{ -1.2963551f, 0.4418516f},
					{ -0.4003391f, 0.6823806f},
					{ 0.2802601f, -0.0081061f},
					{ -0.4910717f, -0.6303451f},
					{ -0.8011453f, 0.18482280f},
				};
				unsigned int frame = 1;
				unsigned int xres = xres_virtual / SCALE;
				xres = (xres > 1920) ? 1920 : xres;

				unsigned int yres = yres_virtual / SCALE;
				float resx = 2.0f / (float)xres;
				float resy = 2.0f / (float)yres;
				float aspect = resy / resx;

				float zoom = 5.0f;
				float zf = 0.97f;
				unsigned int point = 0;
				unsigned int points = (sizeof(center) / sizeof(center_t)) - 1;

				/* Draw frame */
				while (1)
				{
					unsigned int x, y, sc;
					float z0x = resx * zoom * aspect;
					float z0y = resy * zoom;
					float zx = center[point].x - zoom * aspect;
					float zy = center[point].y - zoom;
					char *dst, *pixel;
					for (y = 0; y < yres; y += cores)
					{
						dst = (char *)(smem_start + ((y + core) * SCALE) * line_length);
						for (x = 0; x < xres; x++)
						{
							float x0 = (float)x * z0x + zx;
							float y0 = (float)(y + core) * z0y + zy;
							float q = x0 - 0.25f;
							float q0 = q * q + y0 * y0;
							float q1 = q0 * (q0 + (x0 - 0.25f));
							float q2 = 0.25f * y0 * y0;
							unsigned int i = (q1 < q2) ? MAXI : 0;
							float a = 0.0f;
							float b = 0.0f;

							while ((a * a + b * b < 4.0f) && (i < MAXI))
							{
								float a1 = a * a - b * b + x0;
								b = 2.0f * a * b + y0;
								a = a1;
								i++;
							}

							unsigned int color = (i >= MAXI) ? 0.0f : i * i * i * i;

							for (sc = 0; sc < SCALE; sc++)
							{
								pixel = dst + sc * line_length + x * SCALE * BPP;
								*((unsigned int *)(pixel)) = color;
#if SCALE > 1
								((unsigned int *)(pixel))[1] = color;
#endif
#if SCALE > 3
								((unsigned int *)(pixel))[2] = color;
								((unsigned int *)(pixel))[3] = color;
#endif
							}
						}
					}
					zoom *= zf;
					zf = (zoom < 0.0001f) ? 1.111111f : zf;
					if (zoom > 4.0f)
					{
						zf = 0.9f;
						point++;
						if (point > points)
							point = 0;
					}

					/* Check to exit or not... */
					frame++;
					if (frame > FRAMES)
						break;

					#pragma omp barrier
				}
			}
		}
	}

	clock_gettime(CLOCK_REALTIME, &time);
	time1 = time.tv_sec + time.tv_nsec * 1.0e-9;
	printf("frames: %d\n", FRAMES);
	printf("time: %f sec\n", time1 - time0);

	return 0;
}
