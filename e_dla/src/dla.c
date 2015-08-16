/*
   dla.c

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

// This is the HOST side of the e_dla example.

#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <stdlib.h>
#include <math.h>
#include <termios.h>
#include "coprthr.h"
#include "coprthr_cc.h"
#include "coprthr_thread.h"
#include "coprthr_mpi.h"

#include "shared.h"

#define FB "/dev/fb0"
#define ERROR(...) do{fprintf(stderr,__VA_ARGS__); exit(-1);}while(0)

#define N 2000

static int fb;
static struct fb_fix_screeninfo fix;
static struct fb_var_screeninfo var;

int main(int argc, char *argv[])
{
	unsigned row, col, core;
	int all_done, core_done;
	int i, x, y;
	int res;
	int keyVal;
	int numPerCore;
	int j, n, ix, iy, ixnew, iynew;
	int found;
	int R = 100;
	int counter = 0;
	int numprocs, rank;
	int seq = 1;
	int process;
	int offset;
	double theta, d;
	int *fp;
	int dd, nCores;
	char color;
	coprthr_program_t prg;
	float angle;
	
	process = atoi(argv[1]);

	fb = open(FB, O_RDWR);
	if (fb == -1) {
		perror("Unable to open fb " FB);
		return 1;
	}

	res = ioctl(fb, FBIOGET_FSCREENINFO, &fix);
	if (res != 0) {
		perror("getscreeninfo failed");
		close(fb);
		return 1;
	}

	//printf("framebuffer size %d @ %08x\n", fix.smem_len, fix.smem_start);

	res = ioctl(fb, FBIOGET_VSCREENINFO, &var);
	if (res != 0) {
		perror("getscreeninfo failed");
		close(fb);
		return 1;
	}
	offset = 0;
	if(process == 1){
		offset = -1 * (var.xres_virtual / 4);
	}
	else if(process == 2){
		offset = var.xres_virtual / 4;
	}
	nCores = atoi(argv[2]);
	color = *argv[3];
	numPerCore = atoi(argv[4]);
	if(numPerCore == 0){
		numPerCore = N;
	}

	//printf("size %dx%d @ %d bits per pixel\n", var.xres_virtual, var.yres_virtual, var.bits_per_pixel);

	fp = mmap(NULL, fix.smem_len, O_RDWR, MAP_SHARED, fb, 0);
	if (fp == (void *) -1) {
		perror("mmap failed");
		close(fb);
		return 1;
	}

	//printf("virtual @ %p\n", fp);

	int stride = var.xres_virtual;

	dd = coprthr_dopen(COPRTHR_DEVICE_E32,COPRTHR_O_THREAD);
	if (dd<0) ERROR("device open failed\n");

	prg = coprthr_cc_read_bin("./e_dla.cbin.3.e32", 0);
	coprthr_sym_t thr = coprthr_getsym(prg,"dla_thread");

	my_args_t args;

	args.n = numPerCore;
	args.offset = offset;
	args.color = color;
	args.fbinfo.smem_start = fix.smem_start;
	args.fbinfo.smem_len = fix.smem_len;
	args.fbinfo.line_length = fix.line_length;
	args.fbinfo.xres = var.xres;
	args.fbinfo.yres = var.yres;
	args.fbinfo.xres_virtual = var.xres_virtual;
	args.fbinfo.yres_virtual = var.yres_virtual;
	args.fbinfo.xoffset = var.xoffset;
	args.fbinfo.yoffset = var.yoffset;
	args.fbinfo.bits_per_pixel = var.bits_per_pixel;
	args.fbinfo.emptyPixVal = fp[0];

	coprthr_mem_t p_mem_switch;
	system("clear");
	coprthr_mpiexec(dd, nCores, thr, &args, sizeof(args),0);

	coprthr_dclose(dd);

	//MPI_Finalize();
	return 0;
}
