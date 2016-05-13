// raymarch.c -- STDCL framework for OpenCL programs.
// Copyright (C) 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.
//
//   This software is released under the GPLv3.
//   See LICENSE for more info.

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SDL/SDL.h>
#include <stdcl.h>

#define XRES 800
#define YRES 480
#define BPP 32

int do_events(void)
{
	int temp;
	SDL_Event event;

	temp = 0;

	if (SDL_PollEvent(&event) >= 0)
		switch (event.type) {
		case SDL_QUIT:
			temp = 1;
			break;
		case SDL_KEYDOWN:
			if ((event.key.keysym.sym == SDLK_ESCAPE) || (event.key.keysym.sym == SDLK_SPACE))
				temp = 1;
			break;
		}
	return temp;
}

void show_info(void)
{
	printf("RayMarch, a WIP raymarching example framework using COPRTHR and OpenCL.\n");
	printf("(C) Copyright 2016, Jan Vermeulen <janverm@gmail.com>, all rights reserved.\n");
	printf("Released under GPLv3, see file LICENSE for details.\n");
}

void show_usage(void)
{
	printf("\nUsage: ./raymarch [options]\n");
	printf("\t-c\t\tUse CPUs (COPRTHR) as OpenCL target.\n");
	printf("\t-a\t\tUse accellerator (Epiphany) as OpenCL target.\n");
	printf("\t-g\t\tUse GPU as OpenCL target.\n");
	printf("\t-nthreads X\tUse X number of threads/compute units.\n");
}

int main(int argc, char* argv[])
{
	int i,forkdur,syncdur,waitdur,flipdur,dur,prevdur;
	int nthreads = 2;
	SDL_Surface *screen;
	uint32_t devnum = 0;

	/* default CPU */
	CLCONTEXT* cp = stdcpu;

	show_info();
	i=1;
	while(i<argc) {
		if     (!strcmp(argv[i], "-c")) cp = stdcpu;
		else if(!strcmp(argv[i], "-g")) cp = stdgpu;
		else if(!strcmp(argv[i], "-a")) cp = stdacc;
		else if(!strcmp(argv[i], "-nthreads")) nthreads = atoi(argv[++i]);
		else {
			printf("Error. Unrecognized option: %s\n",
				argv[i]);
			show_usage();
			exit(1);
		}
		i++;
	}
	printf("Using %s with %d threads.\n", 
		(cp == stdcpu) ? "CPU" : (cp == stdacc) ? "Accellerator" : "GPU",
		nthreads);

	/* find & load opencl kernel code */
	cl_kernel krn = clsym(cp, 0, "raymarch_kern", 0);

	/* allocate OpenCL device-sharable memory */
	cl_uint  *frame = (cl_uint *)clmalloc(cp, XRES * YRES * sizeof(cl_uint), 0);

	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
		printf("Unable to init SDL Video library: %s\n", SDL_GetError());
		clfree(frame);
		exit(1);
	}

	screen = SDL_SetVideoMode(XRES, YRES, BPP, SDL_SWSURFACE);

	if (screen == NULL) {
		printf("Unable to set %dx%d video: %s\n", XRES, YRES, SDL_GetError());
		clfree(frame);
		exit(1);
	}
	if (screen->format->BytesPerPixel != 4) {
		printf("Screen is not 32bpp, but %dbpp. Aborting.\n",
			screen->format->BitsPerPixel);
		clfree(frame);
		exit(1);
	}
	printf("\n");
	cl_float time = 0.1f;
	cl_uint xres = XRES;
	cl_uint yres = YRES;
	cl_uint pitch = screen->pitch;
	/* define the computational domain and workgroup size */
	clndrange_t ndr = clndrange_init1d(0, yres, nthreads);
	while (1) {
		prevdur = SDL_GetTicks();
		time = (float)prevdur / 1000.0f;

		/* non-blocking fork of the OpenCL kernel to execute on the CPU/PPU/GPU */
		clforka(cp, devnum, krn, &ndr, CL_EVENT_NOWAIT, time, pitch, xres, yres, frame);
	
		dur = SDL_GetTicks();
		forkdur = dur - prevdur;
		prevdur = dur;
		
		/* non-blocking copy back to host */
		clmsync(cp, devnum, frame, CL_MEM_HOST | CL_EVENT_NOWAIT);
		dur = SDL_GetTicks();
		syncdur = dur - prevdur;
		prevdur = dur;
	
		/* force execution of operations in command queue (non-blocking call) */
//		clflush(cp, devnum, 0);

		/* block on completion of operations in command queue */
		clwait(cp, devnum, CL_ALL_EVENT);
		dur = SDL_GetTicks();
		waitdur = dur - prevdur;
		prevdur = dur;
	
		/* copy sync'ed frame memory to SDL_Surface */		
		memcpy(screen->pixels, frame, YRES * XRES * sizeof(cl_uint));
		SDL_Flip(screen);
		dur = SDL_GetTicks();
		flipdur = dur - prevdur;
		fprintf(stderr, "stats: fork: %dms, sync: %dms, wait: %dms, memcpy: %dms, time: %.2fs             \r",
				forkdur,syncdur,waitdur,flipdur,time);
	
		/* force the printing */
		fflush(stderr);	
		if (do_events())
			break;
	}
	clfree(frame);
	SDL_FreeSurface(screen);
	SDL_Quit();
	return 0;
}

