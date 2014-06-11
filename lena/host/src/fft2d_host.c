/*
  fft2d_host.ldf

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


// This program is the host part of the fft2d() example project.
//
// This program runs on the linux host and invokes the Epiphany fft2d()
// implementation. It communicates with the system via the eHost library.
// After establishing a connection using the e-server, input image is
// read and parsed using the DevIL library API. A reference
// calculation is done on the host and is compared to the Epiphany
// result. A succes/error message is printed on the terminal according
// to the result of the comparison.
//
// May-2012, YS.

// **********************************
// To install DevIL on Linux, type:
//
// sudo apt-get install libdevil-dev
// sudo apt-get install libdevil1c2
// **********************************

#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <sys/time.h>

#include <IL/il.h>
#define ILU_ENABLED
#define ILUT_ENABLED
/* We would need ILU just because of iluErrorString() function... */
/* So make it possible for both with and without ILU!  */
#ifdef ILU_ENABLED
#include <IL/ilu.h>
#define PRINT_ERROR_MACRO printf("IL Error: %s\n", iluErrorString(Error))
#else /* not ILU_ENABLED */
#define PRINT_ERROR_MACRO printf("IL Error: 0x%X\n", (unsigned int) Error)
#endif /* not ILU_ENABLED */
#ifdef ILUT_ENABLED
#include <IL/ilut.h>
#endif

typedef unsigned int e_coreid_t;
#include <e-hal.h>
#include "fft2dlib.h"
#include "fft2d.h"
#include "dram_buffers.h"

#define FALSE 0
#define TRUE  1

typedef struct {
	int  run_target;
	e_loader_diag_t verbose;
	char srecFile[4096];
	char ifname[255];
	char ofname[255];
} args_t;

args_t ar = {TRUE, L_D0, ""};
void get_args(int argc, char *argv[]);


#define eMHz 600e6
#define RdBlkSz 1024

int  main(int argc, char *argv[]);
void matrix_init(int seed);
int  fft2d_go(e_mem_t *pDRAM);
void init_coreID(e_epiphany_t *pEpiphany, unsigned int *coreID, int rows, int cols, unsigned int base_core);

cfloat Bref[_Smtx];
cfloat Bdiff[_Smtx];

unsigned int DRAM_BASE  = 0x8f000000;
unsigned int BankA_addr = 0x2000;
unsigned int coreID[_Ncores];

typedef struct timeval timeval_t;
e_platform_t platform;

int main(int argc, char *argv[])
{
	e_epiphany_t Epiphany, *pEpiphany;
	e_mem_t      DRAM,     *pDRAM;
	unsigned int msize;
	int          row, col, cnum;



	ILuint  ImgId;
//	ILenum  Error;
	ILubyte *imdata;
	ILuint  imsize, imBpp;



	unsigned int addr;
	size_t sz;
	timeval_t timer[4];
	uint32_t time_p[TIMERS];
	uint32_t time_d[TIMERS];
	FILE *fo;
//	FILE *fi;
	int  result;
	

	pEpiphany = &Epiphany;
	pDRAM     = &DRAM;
	msize     = 0x00400000;

	get_args(argc, argv);



//	fi = fopen(ifname, "rb");
//	fo = stdout;
	fo = fopen("matprt.m", "w");
	if ((fo == NULL)) // || (fi == NULL))
	{
		fprintf(stderr, "Could not open Octave file \"%s\" ...exiting.\n", "matprt.m");
		exit(4);
	}
//	fo = stderr;


	// Connect to device for communicating with the Epiphany system
	// Prepare device
	e_set_loader_verbosity(ar.verbose);
	e_init(NULL);
	e_reset_system();
	e_get_platform_info(&platform);
	if (e_open(pEpiphany, 0, 0, platform.rows, platform.cols))
	{
		fprintf(fo, "\nERROR: Can't establish connection to Epiphany device!\n\n");
		exit(1);
	}
	if (e_alloc(pDRAM, 0x00000000, msize))
	{
		fprintf(fo, "\nERROR: Can't allocate Epiphany DRAM!\n\n");
		exit(1);
	}

	// Initialize Epiphany "Ready" state
	addr = offsetof(shared_buf_t, core.ready);
	Mailbox.core.ready = 0;
	e_write(pDRAM, 0, 0, addr, (void *) &(Mailbox.core.ready), sizeof(Mailbox.core.ready));

	printf("Loading program on Epiphany chip...\n");
	strcpy(ar.srecFile, "../../device/Release/e_fft2d.srec");
	result = e_load_group(ar.srecFile, pEpiphany, 0, 0, platform.rows, platform.cols, (e_bool_t) (ar.run_target));
	if (result == E_ERR) {
		printf("Error loading Epiphany program.\n");
		exit(1);
	}


	// Check if the DevIL shared lib's version matches the executable's version.
	if (ilGetInteger(IL_VERSION_NUM) < IL_VERSION)
	{
		fprintf(stderr, "DevIL version is different ...exiting!\n");
		exit(2);
	}

	// Initialize DevIL.
	ilInit();
#ifdef ILU_ENABLED
	iluInit();
#endif



	// create the coreID list
	init_coreID(pEpiphany, coreID, _Nside, _Nside, 0x808);


	// Generate the main image name to use, bind it and load the image file.
	ilGenImages(1, &ImgId);
	ilBindImage(ImgId);
	printf("\n");
	printf("Loading original image from file \"%s\".\n\n", ar.ifname);
	if (!ilLoadImage(ar.ifname))
	{
		fprintf(stderr, "Could not open input image file \"%s\" ...exiting.\n", ar.ifname);
		exit(3);
	}


	// Display the image's dimensions to the end user.
	printf("Width: %d  Height: %d  Depth: %d  Bpp: %d\n\n",
	       ilGetInteger(IL_IMAGE_WIDTH),
	       ilGetInteger(IL_IMAGE_HEIGHT),
	       ilGetInteger(IL_IMAGE_DEPTH),
	       ilGetInteger(IL_IMAGE_BITS_PER_PIXEL));

	imdata = ilGetData();
	imsize = ilGetInteger(IL_IMAGE_WIDTH) * ilGetInteger(IL_IMAGE_HEIGHT);
	imBpp  = ilGetInteger(IL_IMAGE_BYTES_PER_PIXEL);

	if (imsize != (_Sfft * _Sfft))
	{
		printf("Image file size is different from %dx%d ...exiting.\n", _Sfft, _Sfft);
		exit(5);
	}


	// Extract image data into the A matrix.
	for (unsigned int i=0; i<imsize; i++)
	{
		Mailbox.A[i] = (float) imdata[i*imBpp] + 0.0 * I;
	}

	fprintf(fo, "\n");


	// Generate operand matrices based on a provided seed
	matrix_init(0);

#ifdef _USE_DRAM_
	// Copy operand matrices to Epiphany system
	addr = DRAM_BASE + offsetof(shared_buf_t, A[0]);
	sz = sizeof(Mailbox.A);
	 printf(       "Writing A[%ldB] to address %08x...\n", sz, addr);
	fprintf(fo, "%% Writing A[%ldB] to address %08x...\n", sz, addr);
	e_write(addr, (void *) Mailbox.A, sz);

	addr = DRAM_BASE + offsetof(shared_buf_t, B[0]);
	sz = sizeof(Mailbox.B);
	 printf(       "Writing B[%ldB] to address %08x...\n", sz, addr);
	fprintf(fo, "%% Writing B[%ldB] to address %08x...\n", sz, addr);
	e_write(addr, (void *) Mailbox.B, sz);
#else
	// Copy operand matrices to Epiphany cores' memory
	 printf(       "Writing image to Epiphany\n");
	fprintf(fo, "%% Writing image to Epiphany\n");

	sz = sizeof(Mailbox.A) / _Ncores;
	for (row=0; row<(int) platform.rows; row++)
		for (col=0; col<(int) platform.cols; col++)
		{
			addr = BankA_addr;
			printf(".");
			fflush(stdout);
			cnum = e_get_num_from_coords(pEpiphany, row, col);
//			 printf(       "Writing A[%uB] to address %08x...\n", sz, addr);
			fprintf(fo, "%% Writing A[%uB] to address %08x...\n", sz, (coreID[cnum] << 20) | addr); fflush(fo);
			e_write(pEpiphany, row, col, addr, (void *) &Mailbox.A[cnum * _Score * _Sfft], sz);
		}
	printf("\n");
#endif



	// Call the Epiphany fft2d() function
	 printf(       "GO!\n");
	fprintf(fo, "%% GO!\n");
	fflush(stdout);
	fflush(fo);
	gettimeofday(&timer[0], NULL);
	fft2d_go(pDRAM);
	gettimeofday(&timer[1], NULL);
	 printf(       "Done!\n\n");
	fprintf(fo, "%% Done!\n\n");
	fflush(stdout);
	fflush(fo);

	// Read time counters
//	 printf(       "Reading time count...\n");
	fprintf(fo, "%% Reading time count...\n");
	addr = 0x7128+0x4*2 + offsetof(core_t, time_p[0]);
	sz = TIMERS * sizeof(uint32_t);
	e_read(pEpiphany, 0, 0, addr, (void *) (&time_p[0]), sz);

//	for (int i=0; i<TIMERS; i++)
//		printf("time_p[%d] = %u\n", i, time_p[i]);

	time_d[2] = time_p[7] - time_p[2]; // FFT setup
	time_d[3] = time_p[2] - time_p[3]; // bitrev (x8)
	time_d[4] = time_p[3] - time_p[4]; // FFT-1D (x8)
	time_d[5] = time_p[4] - time_p[5]; // corner-turn
	time_d[6] = time_p[7] - time_p[8]; // FFT-2D
	time_d[7] = time_p[6] - time_p[7]; // LPF
	time_d[9] = time_p[0] - time_p[9]; // Total cycles

	 printf(       "Finished calculation in %u cycles (%5.3f msec @ %3.0f MHz)\n\n", time_d[9], (time_d[9] * 1000.0 / eMHz), (eMHz / 1e6));
	fprintf(fo, "%% Finished calculation in %u cycles (%5.3f msec @ %3.0f MHz)\n\n", time_d[9], (time_d[9] * 1000.0 / eMHz), (eMHz / 1e6));

	 printf(       "FFT2D         - %7u cycles (%5.3f msec)\n", time_d[6], (time_d[6] * 1000.0 / eMHz));
	 printf(       "  FFT Setup   - %7u cycles (%5.3f msec)\n", time_d[2], (time_d[2] * 1000.0 / eMHz));
	 printf(       "  BITREV      - %7u cycles (%5.3f msec)\n", time_d[3], (time_d[3] * 1000.0 / eMHz));
	 printf(       "  FFT1D       - %7u cycles (%5.3f msec x2)\n", time_d[4], (time_d[4] * 1000.0 / eMHz));
	 printf(       "  Corner Turn - %7u cycles (%5.3f msec)\n", time_d[5], (time_d[5] * 1000.0 / eMHz));
	 printf(       "LPF           - %7u cycles (%5.3f msec)\n", time_d[7], (time_d[7] * 1000.0 / eMHz));
	 printf(       "\n");

	 printf(       "Reading processed image back to host\n");
	fprintf(fo, "%% Reading processed image back to host\n");



	// Read result matrix
#ifdef _USE_DRAM_
	addr = DRAM_BASE + offsetof(shared_buf_t, B[0]);
	sz = sizeof(Mailbox.B);
	 printf(       "Reading B[%ldB] from address %08x...\n", sz, addr);
	fprintf(fo, "%% Reading B[%ldB] from address %08x...\n", sz, addr);
	blknum = sz / RdBlkSz;
	remndr = sz % RdBlkSz;
	for (i=0; i<blknum; i++)
	{
		printf(".");
		fflush(stdout);
		e_read(addr+i*RdBlkSz, (void *) ((long unsigned)(Mailbox.B)+i*RdBlkSz), RdBlkSz);
	}
	printf(".");
	fflush(stdout);
	e_read(addr+i*RdBlkSz, (void *) ((long unsigned)(Mailbox.B)+i*RdBlkSz), remndr);
#else
	// Read result matrix from Epiphany cores' memory
	sz = sizeof(Mailbox.A) / _Ncores;
	for (row=0; row<(int) platform.rows; row++)
		for (col=0; col<(int) platform.cols; col++)
		{
			addr = BankA_addr;
			printf(".");
			fflush(stdout);
			cnum = e_get_num_from_coords(pEpiphany, row, col);
//			printf(        "Reading A[%uB] from address %08x...\n", sz, addr);
			fprintf(fo, "%% Reading A[%uB] from address %08x...\n", sz, (coreID[cnum] << 20) | addr); fflush(fo);
			e_read(pEpiphany, row, col, addr, (void *) &Mailbox.B[cnum * _Score * _Sfft], sz);
		}
#endif
	printf("\n");



	// Convert processed image matrix B into the image file date.
	for (unsigned int i=0; i<imsize; i++)
	{
		for (unsigned int j=0; j<imBpp; j++)
			imdata[i*imBpp+j] = cabs(Mailbox.B[i]);
	}

	// Save processed image to the output file.
	ilEnable(IL_FILE_OVERWRITE);
	printf("\nSaving processed image to file \"%s\".\n\n", ar.ofname);
	if (!ilSaveImage(ar.ofname))
	{
		fprintf(stderr, "Could not open output image file \"%s\" ...exiting.\n", ar.ofname);
		exit(7);
	}

	// We're done with the image, so let's delete it.
	ilDeleteImages(1, &ImgId);

	// Simple Error detection loop that displays the Error to the user in a human-readable form.
//	while ((Error = ilGetError()))
//		PRINT_ERROR_MACRO;

	// Close connection to device
	if (e_close(pEpiphany))
	{
		fprintf(fo, "\nERROR: Can't close connection to Epiphany device!\n\n");
		exit(1);
	}
	if (e_free(pDRAM))
	{
		fprintf(fo, "\nERROR: Can't release Epiphany DRAM!\n\n");
		exit(1);
	}

	fflush(fo);
	fclose(fo);

	//Returnin success if test runs expected number of clock cycles
	//Need to add comparison with golden reference image!
	if(time_d[9]>50000){
	  return EXIT_SUCCESS;
	}
	else{
	  return EXIT_FAILURE;
	}
}
	
// Call (invoke) the fft2d() function
int fft2d_go(e_mem_t *pDRAM)
{
	unsigned int addr;
	size_t sz;

	// Wait until Epiphany is ready
	addr = offsetof(shared_buf_t, core.ready);
	Mailbox.core.ready = 0;
	while (Mailbox.core.ready == 0)
		e_read(pDRAM, 0, 0, addr, (void *) &(Mailbox.core.ready), sizeof(Mailbox.core.ready));


	// Wait until cores finished previous calculation
	addr = offsetof(shared_buf_t, core.go);
	sz = sizeof(int64_t);
	Mailbox.core.go = 1;
	while (Mailbox.core.go != 0)
		e_read(pDRAM, 0, 0, addr, (void *) (&Mailbox.core.go), sz);

	
	// Signal cores to start crunching
	Mailbox.core.go = 1;
	addr = offsetof(shared_buf_t, core.go);
	sz = sizeof(int64_t);
	e_write(pDRAM, 0, 0, addr, (void *) (&Mailbox.core.go), sz);


	// Wait until cores finished calculation
	addr = offsetof(shared_buf_t, core.go);
	sz = sizeof(int64_t);
	Mailbox.core.go = 1;
	while (Mailbox.core.go != 0)
		e_read(pDRAM, 0, 0, addr, (void *) (&Mailbox.core.go), sz);

	return 0;
}


// Initialize result matrices
void matrix_init(int seed)
{
	int i, j, p;

	p = 0;
	for (i=0; i<_Sfft; i++)
		for (j=0; j<_Sfft; j++)
			Mailbox.B[p++] = 0x8dead;

	return;
}


// Generate Epiphany Core ID's
void init_coreID(e_epiphany_t *pEpiphany, unsigned int *coreID, int rows, int cols, unsigned int base_core)
{
	unsigned int cnum;
	unsigned int row, col;
	unsigned int base_row, base_col;

	base_row = base_core >> 6;
	base_col = base_core & 0x3f;

	cnum = 0;
	for (row=base_row; row<base_row+rows; row++)
		for (col=base_col; col<base_col+cols; col++)
		{
			cnum = e_get_num_from_coords(pEpiphany, row, col);
			coreID[cnum] = (row << 6) | (col << 0);
		}

		return;
}


// Print a usage message
void usage(int n)
{
	printf("Usage: fft2d_host.elf [-no-run] [-verboseN] [-h] <image-file>\n");
	printf("   -verbose0, -verbose1, -verbose2, -verbose3: available levels of diagnostics\n");
	printf("\n");
	printf("   The program will open the image file ""image-file"", apply a low-pass\n");
	printf("   filter and save the filtered image to ""lpf.image-file""\n\n");
	exit(n);
}


// Process command line args
void get_args(int argc, char *argv[])
{
	int n;
	char buf[255];
	char *dotp;

	for (n=1; n<argc; n++)
	{
		if (!strcmp(argv[n], "-no-run"))
			ar.run_target = FALSE;

		if (!strcmp(argv[n], "-verbose0"))
			ar.verbose = L_D0;

		if (!strcmp(argv[n], "-verbose1"))
			ar.verbose = L_D1;

		if (!strcmp(argv[n], "-verbose2"))
			ar.verbose = L_D2;

		if (!strcmp(argv[n], "-verbose3"))
			ar.verbose = L_D3;

		if (!strcmp(argv[n], "-h"))
			usage(0);

		strcpy(ar.ifname, argv[n]);
	}


	// Process input arguments
	if (!strcmp(ar.ifname, ""))
	{
		usage(1);
	} else {
		strcpy(ar.ofname, ar.ifname);
		dotp = strrchr(ar.ofname, '.');
		if (dotp != NULL)
		{
			strcpy(buf, dotp);
			strcpy(dotp, ".lpf");
			strcat(ar.ofname, buf);
		} else {
			strcat(ar.ofname, ".lpf");
		}
	}


	return;
}
