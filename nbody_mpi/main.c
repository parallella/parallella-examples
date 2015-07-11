/* main.c
 *
 * Copyright (c) 2015, James A. Ross
 * All rights reserved.
 * Modified to add graphical display by Rob Foster
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 * may be used to endorse or promote products derived from this software without
 * specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* JAR */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
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
#include "nbody.h"

#define FLOPS_PER_INTERACTION 20
#define __gflops(time,steps,nparticle) \
	(((float)steps * (float)nparticle*(float)nparticle * FLOPS_PER_INTERACTION) / time / 1e9)
#define PRINTP(P,I) printf(#P"[%d] = {%f, %f, %f}\n", I, P[I].x, P[I].y, P[I].z);
#define ERROR(...) do{fprintf(stderr,__VA_ARGS__); exit(-1);}while(0)
#define _BufSize   (128)
#define _BufOffset (0x01000000)
#define _SeqLen    (20)
#define PAGE_OFFSET 0x2000
#define PAGE_SIZE 0x2000
#define FB "/dev/fb0"

static int fb;
static struct fb_fix_screeninfo fix;
static struct fb_var_screeninfo var;

void draw_stars(Particle *bufOutput, int nBodies, unsigned int *fp, int stride, int color);

void init_particles(Particle* particles, ParticleV* state, int n)
{
	int i;
	float a1,a2,a3,a4,a5,a6,a7,a8;
	float cmr[3];
	float cmrdot[3];
	float alphas = 2.0f;
	float body1 = 5.0f;
	float bodyn = 1.0f;
	float twopi = 6.283185307f;
	float alpha1 = alphas - 1.0f;
	float fm1 = 1.0f/powf(body1,alpha1);
	float fmn = (fm1 - 1.0f/powf(bodyn,alpha1))/((float)n - 1.0f);
	float zmass = 0.0f;
	float coef = 1.0f/alpha1;
	float u, v, theta, phi, radius;


	srand(time(NULL));
	for (i=0; i<n; i++) {
		float fmi = fm1 - (float)(i-1)*fmn;
		particles[i].mass = 1.0f/powf(fmi,coef);
		zmass += particles[i].mass;
	}

	float zmbar1 = zmass/(float)n;
	//for (i=0; i<n; i++) particles[i].mass /= zmbar1;
	zmass = (float)n;

	cmr[0] = cmr[1] = cmr[2] = 0.0f;
	cmrdot[0] = cmrdot[1] = cmrdot[2] = 0.0f;

	float ri;
	for (i=0; i<n; i++) {
		do {
			a1 = rand()/(float)RAND_MAX;
			ri = 1.0f/sqrtf((powf(a1,(-0.6666667f))-1.0f));
		} while (ri>10.0f);

		a2 = rand()/(float)RAND_MAX;
		a3 = rand()/(float)RAND_MAX;
		/* particles[i].z = (1.0f - 2.0f*a2)*ri;
		   particles[i].x = sqrtf(ri*ri - particles[i].z*particles[i].z)*cos(twopi*a3);
		   particles[i].y = sqrtf(ri*ri - particles[i].z*particles[i].z)*sin(twopi*a3);*/
		u = (float) rand() / (float) RAND_MAX;
		v = (float) rand() / (float) RAND_MAX;
		//radius = (float) (rand() % 250) + 100;
		radius = (float) var.xres_virtual / 4.0;
		theta = 2.0f * 3.14159f * u;
		phi = acos(2 * v - 1);
		particles[i].x = (float) var.xres_virtual / 2.0 + (radius * sin(phi) * cos(theta));
		particles[i].y = (float) var.yres_virtual / 2.0 + (radius * sin(phi) * sin(theta));
		particles[i].z = (float) var.yres_virtual / 2.0 + (radius * cos(phi));
		do {
			a4 = rand()/(float)RAND_MAX;
			a5 = rand()/(float)RAND_MAX;
			a6 = a4*a4*powf((1.0f-a4*a4),3.5f);
		} while (0.1f*a5>a6);

		a8 = a4*sqrtf(2.0f)/powf((1.0f + ri*ri),0.25f);
		a6 = rand()/(float)RAND_MAX;
		a7 = rand()/(float)RAND_MAX;

		/*state[i].vz = (1.0f - 2.0f*a6)*a8;
		  state[i].vx = sqrtf(a8*a8 - state[i].vz*state[i].vz)*cos(twopi*a7);
		  state[i].vy = sqrtf(a8*a8 - state[i].vz*state[i].vz)*sin(twopi*a7);*/
		state[i].vz = 0.0;
		state[i].vx = 0.0;
		state[i].vy = 0.0;

		cmr[0] += particles[i].mass * particles[i].x;
		cmr[1] += particles[i].mass * particles[i].y;
		cmr[2] += particles[i].mass * particles[i].z;
		cmrdot[0] += particles[i].mass * particles[i].x;
		cmrdot[1] += particles[i].mass * particles[i].y;
		cmrdot[2] += particles[i].mass * particles[i].z;
	}

	a1 = 1.5f*twopi/16.0f;
	a2 = sqrtf(zmass/a1);
	for (i=0; i<n; i++) {
		/*particles[i].x -= cmr[0]/zmass;
		  particles[i].y -= cmr[1]/zmass;
		  particles[i].z -= cmr[2]/zmass;
		  state[i].vx -= cmrdot[0]/zmass;
		  state[i].vy -= cmrdot[1]/zmass;
		  state[i].vz -= cmrdot[2]/zmass;*/
		/*particles[i].x *= a1;
		  particles[i].y *= a1;
		  particles[i].z *= a1;
		  particles[i].x += 512;
		  particles[i].y += 384;
		  particles[i].z += 384;
		  state[i].vx *= a2;
		  state[i].vy *= a2;
		  state[i].vz *= a2;*/
		state[i].ax = 0.0f;
		state[i].ay = 0.0f;
		state[i].az = 0.0f;
	}
}

void update_particles_epiphany(Particle* particles, ParticleV* state, int n, int s, float dt, float es, int iter, int cores)
{
	int N = n*s;

	// open device for threads
	int dd = coprthr_dopen(COPRTHR_DEVICE_E32,COPRTHR_O_THREAD);
	printf("dd=%d\n",dd);
	if (dd<0) ERROR("device open failed\n");

	coprthr_program_t prg;
	if (s==1) prg = coprthr_cc_read_bin("./mpi_tfunc.cbin.3.e32", 0);
	else prg = coprthr_cc_read_bin("./mpi_tfunc2.cbin.3.e32", 0); // special off-chip thread function
	coprthr_sym_t thr = coprthr_getsym(prg,"nbody_thread");
	printf("prg=%p thr=%p\n",prg,thr);

	// write data to shared DRAM
	coprthr_mem_t p_mem = coprthr_dmalloc(dd,N*sizeof(Particle), 0);
	coprthr_dwrite(dd,p_mem,0,particles,N*sizeof(Particle),COPRTHR_E_WAIT);

	coprthr_mem_t pn_mem;
	pn_mem = coprthr_dmalloc(dd,N*sizeof(Particle), 0); // special off-chip memory

	coprthr_mem_t v_mem = coprthr_dmalloc(dd,N*sizeof(ParticleV), 0);
	coprthr_dwrite(dd,v_mem,0,state,N*sizeof(ParticleV),COPRTHR_E_WAIT);


	my_args_t args;
	args.n = n;
	args.s = s;
	args.cnt = iter;
	args.dt = dt;
	args.es = es;
	args.p = coprthr_memptr(p_mem,0);
	args.pn = coprthr_memptr(pn_mem,0);
	args.v = coprthr_memptr(v_mem,0);
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


	int flag = 0;
	coprthr_mem_t p_mem_switch;
	system("clear");
	coprthr_mpiexec(dd, cores, thr, &args, sizeof(args),0);


	// read back data from memory on device
	p_mem_switch = (s>1 && (iter+2)%2) ? pn_mem : p_mem;
	flag++;
	coprthr_dread(dd,p_mem_switch,0,particles,N*sizeof(Particle),COPRTHR_E_WAIT);

	coprthr_dclose(dd);
}

void update_particles_cpu(Particle* particles, ParticleV* state, int n, int s, float dt, float es, int iter)
{
	int i;
	int N = n*s;
	Particle* p1 = (Particle*)malloc(N*sizeof(Particle));
	while (iter--) {
		for (i=0; i<N; i++) p1[i] = particles[i];
		ComputeAccel(particles, p1, state, N, es);
		ComputeNewPos(particles, state, N, dt);
	}
}

int validate_particles(Particle* p0, Particle* p1, int n, float* max_diff)
{
	int errors = 0;
	int i;
	float tol = 0.00001;
	*max_diff = 0.0f;
	for (i=0; i<n; i++) {
		float dx = fabs(p0[i].x - p1[i].x);
		float dy = fabs(p0[i].y - p1[i].y);
		float dz = fabs(p0[i].z - p1[i].z);
		float diff = (dx > dy) ? dx : dy;
		diff = (diff > dz) ? diff : dz;
		if(diff > tol) errors++;
		*max_diff = (*max_diff > diff) ? *max_diff : diff;
	}
	return errors;
}

int main(int argc, char** argv)
{
	int i,j,k;
	struct timeval t0,t1;
	double time,gflops;
	int validate = 0;
	int repeat = 0;

	int n = NPARTICLE;
	int cnt = STEPS;
	int s = SIZE;
	int d = ECORE;
	int res;
	float dt = 0.10;
	float es = 0.01;
	unsigned int *fp;

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


	res = ioctl(fb, FBIOGET_VSCREENINFO, &var);
	if (res != 0) {
		perror("getscreeninfo failed");
		close(fb);
		return 1;
	}

	//printf("size %dx%d @ %d bits per pixel\n", var.xres_virtual, var.yres_virtual, var.bits_per_pixel);

	i = 1;
	while (i < argc) {
		if (!strcmp(argv[i],"-n")) n = atoi(argv[++i]);
		else if (!strcmp(argv[i],"-i")) cnt = atoi(argv[++i]);
		else if (!strcmp(argv[i],"-s")) s = atoi(argv[++i]);
		else if (!strcmp(argv[i],"-d")) d = atoi(argv[++i]);
		else if (!strcmp(argv[i],"-t")) dt = atof(argv[++i]);
		else if (!strcmp(argv[i],"-r")) repeat = 1;
		else if (!strcmp(argv[i],"--validate")) validate = 1;
		else if (!strcmp(argv[i],"--help") || !strcmp(argv[i],"-h")) goto help;
		else {
			fprintf(stderr,"unrecognized option: %s\n",argv[i]);
help:
			ERROR("use -n [number of particles] -s [off-chip scale factor] -i [iteration step count] -d [number of Epiphany cores/threads] --validate\n");
		}
		++i;
	}

	int N = n*s;
	//printf("Using -n=%d, -i=%d -s=%d, dt=%f, es=%f\n", n, cnt, s, dt, es);

	// allocate memory on device and write a value
	Particle* p = (Particle*)malloc(N*sizeof(Particle));
	ParticleV* v = (ParticleV*)malloc(N*sizeof(ParticleV));

	// keep initial conditions around for CPU validation
	Particle* p_validate;
	ParticleV* v_validate;
	system("setterm -cursor off");
	system("setterm -blank 0");
	while(1){
		system("clear");
		init_particles(p, v, N);
		if (validate) {
			p_validate = (Particle*)malloc(N*sizeof(Particle));
			v_validate = (ParticleV*)malloc(N*sizeof(ParticleV));
			memcpy(p_validate,p,N*sizeof(Particle));
			memcpy(v_validate,v,N*sizeof(ParticleV));
		}

		//PRINTP(p,0);
		gettimeofday(&t0,0);
		update_particles_epiphany(p, v, n, s, dt, es, cnt, d);
		gettimeofday(&t1,0);
		//PRINTP(p,0);
		if(repeat == 0)
			break;

		time = t1.tv_sec - t0.tv_sec + 1e-6*(t1.tv_usec - t0.tv_usec);
		gflops = __gflops(time, cnt, N);
		printf("Epiphany Performance : %f GFLOPS (includes overhead)\n",gflops);
		printf("Execution time...... : %f seconds\n",time);
		sleep(4);
	}

	if (validate) {
		printf("Validating on CPU host....\n");
		gettimeofday(&t0,0);
		update_particles_cpu(p_validate, v_validate, n, s, dt, es, cnt);
		gettimeofday(&t1,0);

		PRINTP(p_validate,0);

		float max_diff = 0.0f;
		int errors = validate_particles(p, p_validate, N, &max_diff);

		time = t1.tv_sec - t0.tv_sec + 1e-6*(t1.tv_usec - t0.tv_usec);
		gflops = __gflops(time, cnt, n*s);
		printf("ARM CPU Performance : %f GFLOPS\n",gflops);
		printf("Execution time..... : %f seconds\n",time);
		printf("Errors............. : %d\n", errors);
		printf("Max position delta. : %f\n", max_diff);
	}

}
