/*
   nbody.c

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

// This is the HOST side of the Hello World example.
// The program initializes the Epiphany system,
// randomly draws an eCore and then loads and launches
// the device program on that eCore. It then reads the
// shared external memory buffer for the core's output
// message.

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
#include <math.h>
#include <termios.h>
#include "coprthr.h"
#include "coprthr_cc.h"
#include "coprthr_thread.h"
#include "coprthr_mpi.h"

#include <e-hal.h>
#include "shared.h"

#define _BufSize   (128)
#define _BufOffset (0x01000000)
#define _SeqLen    (20)
#define PAGE_OFFSET 0x2000
#define PAGE_SIZE 0x2000
#define FB "/dev/fb0"
#define ERROR(...) do{fprintf(stderr,__VA_ARGS__); exit(-1);}while(0)

static int fb;
static struct fb_fix_screeninfo fix;
static struct fb_var_screeninfo var;

void draw_stars(Body *bufOutput, int nBodies, unsigned int *fp, int stride, int color);

static inline void nano_wait(uint32_t sec, uint32_t nsec)
{
	struct timespec ts;
	ts.tv_sec = sec;
	ts.tv_nsec = nsec;
	nanosleep(&ts, NULL);
}

int initBodies(Body *data, char *initFile){
	FILE *ifp = fopen(initFile, "r");
	char cbuf[256];
	char *token;
	int n = 0;

	while(fgets(cbuf, 255, ifp) != NULL){
		token = strtok(cbuf, " ");
		data[n].m = atof(token);	
		data[n].im = 1.0f / data[n].m;
		token = strtok(NULL, " ");
		data[n].x = 512.0 + (75.0 * atof(token));
		token = strtok(NULL, " ");
		data[n].y = 384.0 + (75.0 * atof(token));
		token = strtok(NULL, " ");
		data[n].z = 192.0 + (75.0 * atof(token));
		token = strtok(NULL, " ");
		data[n].vx = atof(token);
		token = strtok(NULL, " ");
		data[n].vy = atof(token);
		token = strtok(NULL, " ");
		data[n++].vz = atof(token);
	}
	fclose(ifp);

	return n;
}

void randomizeSphereBodies(Body *data, int n) {
	int i;
	float u, v, theta, phi, radius;
	
	for(i = 0; i < n; i++){
		u = (float) rand() / (float) RAND_MAX;
		v = (float) rand() / (float) RAND_MAX;
		//radius =((float) (rand() % 500) - 250.0);
		//radius = 350.0;
		radius = (float) var.xres_virtual / 4;
		theta = 2.0f * 3.14159f * u;
		phi = acos(2 * v - 1);
		//data[i].x = 512.0 + (radius * sin(phi) * cos(theta));
		data[i].x = (float) var.xres_virtual / 2.0 + (radius * sin(phi) * cos(theta));
		data[i].y = (float) var.yres_virtual / 2.0 + (radius * sin(phi) * sin(theta));
		data[i].z = (float) var.yres_virtual / 2.0 + (radius * cos(phi));
//fprintf(stderr, "u = %f, v = %f, x = %f, y = %f, z = %f\n", u, v, data[i].x, data[i].y, data[i].z);
		data[i].vx = 0.0f;
		data[i].vy = 0.0f;
		data[i].vz = 0.0f;
		data[i].m = (rand() % 5) + 1;
		//data[i].m = 50;
		data[i].im = 1.0 / data[i].m;
	}
}

void randomizeBodies(Body *data, int n) {
	int i;
	float a1, a2, a3, ri;
	float twopi = 6.283185307f;
	// Hard code first 2 stars as 'mega-stars'
	/*data[0].x = 384.0;
	  data[0].y = 384.0;
	  data[0].z = 384.0;
	  data[0].vx = 0.0;
	  data[0].vy = 0.0;
	  data[0].vz = 0.0;
	  data[0].m = 900000000.0;
	  data[0].im = 1.0 / data[0].m;
	  data[1].x = 640.0;
	  data[1].y = 384.0;
	  data[1].z = 384.0;
	  data[1].vx = 0.0;
	  data[1].vy = 0.0;
	  data[1].vz = 0.0;
	  data[1].m = 9000000.0;
	  data[1].im = 1.0 / data[1].m;
	  data[0].x = 512.0;
	  data[0].y = 384.0;
	  data[0].z = 256.0;
	  data[0].vx = 0.0;
	  data[0].vy = 0.0;
	  data[0].vz = 0.0;
	//data[0].m = rand() % 500;
	data[0].m = 50;
	data[0].im = 1.0 / data[0].m;*/
	for (i = 0; i < n; i++) {
		/*  if(i == 1){
		    data[i].x = 303.575623;
		    data[i].y = 599.325623;
		    data[i].z = 183.000000;
		    data[i].vx = 2.000000;
		    data[i].vy = -9.000000;
		    data[i].vz = 18.000000;
		    data[i].m = 100.000000;
		    data[i].im = 1.0 / data[i].m;
		    }
		    else if(i == 2){
		    data[i].x = 148.797012;
		    data[i].y = 151.768005;
		    data[i].z = 293.000000;
		    data[i].vx = 11.000000;
		    data[i].vy = -20.000000;
		    data[i].vz = -2.000000;
		    data[i].m = 100.000000;
		    data[i].im = 1.0 / data[i].m;
		    }
		    else{*/
		//data[i].x = 1024.0f * (rand() / (float)RAND_MAX) - 1.0f;
		data[i].x = 512.0 - ((float) (rand() % 769) - 384.0);
		//data[i].y = 768.0f * (rand() / (float)RAND_MAX) - 1.0f;
		data[i].y = 384.0 - ((float) (rand() % 769) - 384.0);
		//data[i].z = rand() % 768;
		data[i].z = 384.0 - ((float) (rand() % 769) - 384.0);
		//data[i].vx = (rand() % 11) - 5.0f;
		/*do{
		  a1 = rand() % 100;
		  ri = 1.0f / sqrtf((pow(a1, (-0.6666667f)) - 1.0f));
		  } while(ri > 5000.0f);
		  a2 = rand() / (float) RAND_MAX;
		  a3 = rand() / (float) RAND_MAX;
		  data[i].z = (1.0f - 2.0f * a2) * ri;
		  data[i].x = 100.0f + sqrtf(ri * ri - data[i].z * data[i].z) * cos(twopi * a3);
		  data[i].y = 100.0f + sqrtf(ri * ri - data[i].z * data[i].z) * sin(twopi * a3);*/
		data[i].vx = 0.0;
		data[i].vy = 0.0f;
		data[i].vz = 0.0f;
		data[i].m = (rand() % 6) + 1;
		//data[i].m = 50;
		data[i].im = 1.0 / data[i].m;
		//}
	}
}

int main(int argc, char *argv[])
{
	unsigned row, col, core;
	e_platform_t platform;
	e_epiphany_t dev;
	int all_done, core_done;
	int i, x, y;
	int res;
	int keyVal;
	int numPerCore;
	int dd;
	unsigned int *fp;
	//FILE *ofp;

	int nBodies = 30000;
	const int startFlag = 0x00000001;
	int iters = 5000;  // simulation iterations
	const float dt = 0.05f; // time step
	if (argc > 1) nBodies = atoi(argv[1]);

	Body *buf = (Body *) malloc(sizeof(Body) * nBodies);
	Body *bufOutput = (Body *) malloc(sizeof(Body) * nBodies);
	Body *bufOutput1 = (Body *) malloc(sizeof(Body) * nBodies);
	Body *bufOutput2 = (Body *) malloc(sizeof(Body) * nBodies);
	Body *bufOutput3 = (Body *) malloc(sizeof(Body) * nBodies);
	Body *bufOutput4 = (Body *) malloc(sizeof(Body) * nBodies);
	Body *bufOutput5 = (Body *) malloc(sizeof(Body) * nBodies);
	//ofp = fopen("/tmp/stars.rot", "w");

	fb = open(FB, O_RDWR);
	if (fb == -1) {
		perror("Unable to open fb " FB);
		return 1;
	}

	//dd = coprthr_dopen(COPRTHR_DEVICE_E32,COPRTHR_O_THREAD);
	//if (dd<0) ERROR("device open failed\n");

	//coprthr_program_t prg;
	//prg = coprthr_cc_read_bin("./e_nbody.srec", 0);
	//coprthr_sym_t thr = coprthr_getsym(prg,"nbody_thread");
	//printf("prg=%p thr=%p\n",prg,thr);

	// write data to shared DRAM
	//coprthr_mem_t p_mem = coprthr_dmalloc(dd,nBodies*sizeof(Body), 0);
	//coprthr_dwrite(dd,p_mem,0,buf,nBodies*sizeof(Body),COPRTHR_E_WAIT);

	// rest here
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

	//printf("size %dx%d @ %d bits per pixel\n", var.xres_virtual, var.yres_virtual, var.bits_per_pixel);

	fp = mmap(NULL, fix.smem_len, O_RDWR, MAP_SHARED, fb, 0);
	if (fp == (void *)-1) {
		perror("mmap failed");
		close(fb);
		return 1;
	}

	//printf("virtual @ %p\n", fp);

	int stride = var.xres_virtual;

	system("clear");
	while(1){
		srand(time(NULL));

		if(argc > 2){
			nBodies = initBodies(buf, argv[2]);
		}
		else{
			randomizeSphereBodies(buf, nBodies); // Init pos / vel data
		}

		e_init(NULL);
		e_reset_system();
		e_get_platform_info(&platform);
		e_open(&dev, 0, 0, 4, 4);
		e_reset_group(&dev);
		e_load_group("e_nbody.srec", &dev, 0, 0, 4, 4, E_FALSE);
		numPerCore = nBodies / NUM_CORES;
		for (row = 0; row < platform.rows; row++){
			for (col = 0; col < platform.cols; col++){
				e_write(&dev, row, col, 0x1000, &numPerCore, sizeof(int));
				core = (4 * row) + col;
				e_write(&dev, row, col, 0x1008, (Body *) &buf[core * numPerCore], (sizeof(Body) * numPerCore)); 
				e_write(&dev, row, col, 0x5000, (Body *) &buf[core * numPerCore], (sizeof(Body) * numPerCore)); 
			}
		}
		//e_write(&dev, 0, 0, 0x1008, (Body *) buf, sizeof(Body) * nBodies);
		x = 0;
		//	for(x = 0; x < iters; x++){
		while(1){
			//fprintf(stderr, "Iter %d\n", x);
			for (row = 0; row < platform.rows; row++){
				for (col = 0; col < platform.cols; col++){
					//e_write(&dev, row, col, 0x00000008, &startFlag, sizeof(int));
					e_write(&dev, row, col, 0x1004, &startFlag, sizeof(int));
				}
			}
			e_start_group(&dev);
			//Check if all cores are done
			while(1){
				all_done = 0;
				for (row = 0; row < platform.rows; row++){
					for (col = 0; col < platform.cols; col++){
						//e_read(&dev, row, col, 0x00000008, &core_done, sizeof(int));
						e_read(&dev, row, col, 0x1004, &core_done, sizeof(int));
						all_done += core_done;
					}
				}
				if(all_done == 0){
					break;
				}
			}
			for (row = 0; row < platform.rows; row++){
				for (col = 0; col < platform.cols; col++){
					core = (4 * row) + col;
					e_read(&dev, row, col, 0x1008, (Body *) &bufOutput[core * numPerCore], (sizeof(Body) * numPerCore)); 
				}
			}
			//e_read(&dev, 0, 0, 0x1008, (Body *) bufOutput, sizeof(Body) * nBodies);
			if(x == 0){
				memcpy(bufOutput1, bufOutput, sizeof(Body) * nBodies);
			}
			else if(x == 1){
				memcpy(bufOutput2, bufOutput1, sizeof(Body) * nBodies);
				memcpy(bufOutput1, bufOutput, sizeof(Body) * nBodies);
			}
			else if(x == 2){
				memcpy(bufOutput3, bufOutput2, sizeof(Body) * nBodies);
				memcpy(bufOutput2, bufOutput1, sizeof(Body) * nBodies);
				memcpy(bufOutput1, bufOutput, sizeof(Body) * nBodies);
			}
			else if(x == 3){
				memcpy(bufOutput4, bufOutput3, sizeof(Body) * nBodies);
				memcpy(bufOutput3, bufOutput2, sizeof(Body) * nBodies);
				memcpy(bufOutput2, bufOutput1, sizeof(Body) * nBodies);
				memcpy(bufOutput1, bufOutput, sizeof(Body) * nBodies);
			}
			else if(x >= 4){
				draw_stars(bufOutput5, nBodies, fp, stride, 0x00000000);
				memcpy(bufOutput5, bufOutput4, sizeof(Body) * nBodies);
				memcpy(bufOutput4, bufOutput3, sizeof(Body) * nBodies);
				memcpy(bufOutput3, bufOutput2, sizeof(Body) * nBodies);
				memcpy(bufOutput2, bufOutput1, sizeof(Body) * nBodies);
				memcpy(bufOutput1, bufOutput, sizeof(Body) * nBodies);
			}
			x++;
			draw_stars(bufOutput, nBodies, fp, stride, 0x00ffffff);
			/*(keyVal = kbhit();
			if(keyVal){
				for(i = 0; i < nBodies; i++){
					if(keyVal == 1)
						bufOutput[i].x -= 100;
					else if(keyVal == 2)
						bufOutput[i].x += 100;
					else if(keyVal == 3)
						bufOutput[i].y -= 100;
					else if(keyVal == 4)
						bufOutput[i].y += 100;
				}
			}*/
			memcpy(buf, bufOutput, sizeof(Body) * nBodies);
			for (row = 0; row < platform.rows; row++){
				for (col = 0; col < platform.cols; col++){
					core = (4 * row) + col;
					e_write(&dev, row, col, 0x5000, (Body *) &buf[core * numPerCore], (sizeof(Body) * numPerCore)); 
				}
			}
			if(x == 1200){
				//for(i = 0; i < nBodies; i++)
				//	fprintf(ofp, "%f %f %f %d\n", bufOutput[i].x, bufOutput[i].y, bufOutput[i].z, bufOutput[i].m <= 2 ? -3 : bufOutput[i].m <=4 ? -7 : -1);
				//fclose(ofp);
				draw_stars(bufOutput5, nBodies, fp, stride, 0x00000000);
				draw_stars(bufOutput4, nBodies, fp, stride, 0x00000000);
				draw_stars(bufOutput3, nBodies, fp, stride, 0x00000000);
				draw_stars(bufOutput2, nBodies, fp, stride, 0x00000000);
				draw_stars(bufOutput1, nBodies, fp, stride, 0x00000000);
				x = 0;
				break;
			}
		}
		e_close(&dev);

		// Release the allocated buffer and finalize the
		// e-platform connection.
		e_finalize();
	}

	return 0;
	}

	void draw_stars(Body *bufOutput, int nBodies, unsigned int *fp, int stride, int color)
	{
		int y, s_x, s_y, s_z, s_m;
		for (y = 0; y < nBodies; y++){
			s_x = (int) bufOutput[y].x;
			s_y = (int) bufOutput[y].y;
			s_z = (int) bufOutput[y].z;
			s_m = (int) bufOutput[y].m;
			if(s_x >= 0 && s_x < var.xres_virtual && s_y >= 0 && s_y < var.yres_virtual){
				/*	if(y < 1){
					fp[s_x + s_y * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_x > 0)
					fp[(s_x - 1) + s_y * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_x < 1022)
					fp[(s_x + 1) + s_y * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_x > 1)
					fp[(s_x - 2) + s_y * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_x < 1021)
					fp[(s_x + 2) + s_y * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_y > 0)
					fp[s_x + (s_y - 1) * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_y < 766)
					fp[s_x + (s_y + 1) * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_y > 1)
					fp[s_x + (s_y - 2) * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					if(s_y < 765)
					fp[s_x + (s_y + 2) * stride] = (color == 0x00000000 ? color : 0x00ff0000);
					}
					else*/
				if(color == 0x00000000){
					fp[s_x + s_y * stride] = color;
				}
				else{
					/*if(bufOutput[y].vz < -50.0){
					  fp[s_x + s_y * stride] = 0x00ff0000;
					  }
					  else if(bufOutput[y].vz > 50.0){
					  fp[s_x + s_y * stride] = 0x000000ff;
					  }
					  else if(bufOutput[y].vz >= -50.0 && bufOutput[y].vz < 0.0){
					  fp[s_x + s_y * stride] = 0x00ffb6c1;
					  }
					  else if(bufOutput[y].vz > 0.0 && bufOutput[y].vz <= 50.0){
					  fp[s_x + s_y * stride] = 0x0087cefa;
					  }
					  else{
					  fp[s_x + s_y * stride] = 0x00ffffff;
					  }*/
					if(s_m <= 2)	
						fp[s_x + s_y * stride] = 0x000000ff;
					else if (s_m <= 4)
						fp[s_x + s_y * stride] = 0x00ffffff;
					else if (s_m <= 6)
						fp[s_x + s_y * stride] = 0x00ff0000;
				}
			}
		}
	}

int kbhit(void)
{
	struct termios oldt, newt;
	char ch = ' ';
	int oldf;

	tcgetattr(STDIN_FILENO, &oldt);
	newt = oldt;
	newt.c_lflag &= ~(ICANON | ECHO);
	tcsetattr(STDIN_FILENO, TCSANOW, &newt);
	oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
	fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

	ch = getchar();
	
	tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
	fcntl(STDIN_FILENO, F_SETFL, oldf);

	if(ch == 'h'){
		ungetc(ch, stdin);
		ch = getchar();
		return 1;
	}
	else if(ch == 'l'){
		ungetc(ch, stdin);
		ch = getchar();
		return 2;
	}
	else if(ch == 'j'){
		ungetc(ch, stdin);
		ch = getchar();
		return 3;
	}
	else if(ch == 'k'){
		ungetc(ch, stdin);
		ch = getchar();
		return 4;
	}

	return 0;
}
