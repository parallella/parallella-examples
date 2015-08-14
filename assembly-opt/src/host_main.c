/*
   host_main.c
   Copyright (C) 2012 Adapteva, Inc.
   Contributed by Yaniv Sapir <yaniv@adapteva.com>, Aug 2013
   Modified by: Anish Varghese <anish.varghese@anu.edu.au>, May 2014

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

Description:
    This is the host side code for single core matmul.
    The parameters such as matrix sizes M,N,K are configured in defs.h 
 */

#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include "defs.h"

#include <e-hal.h>

#define _BufOffset (0x01000000)

float clock_to_time(int clocks);
void print_to_file(const char *filename,float c[][N]);

int main(int argc, char *argv[])
{
	unsigned row, col, coreid, i;
	e_platform_t platform;
	e_epiphany_t dev;
	e_mem_t emem;

    Mailbox mailbox;
    mailbox.flag = 0;
	// initialize system, read platform params from
	// default HDF. Then, reset the platform and
	// get the actual system parameters.
	e_init(NULL);
	e_reset_system();
	e_get_platform_info(&platform);

	// Allocate a buffer in shared external memory
	// for message passing from eCore to host.
	e_alloc(&emem, _BufOffset, 1024);

    row = 0;
    col = 0;
    coreid = (row + platform.row) * 64 + col + platform.col;
    fprintf(stderr,"\n\nMultiplying A[%d][%d] x B[%d][%d] = C[%d][%d]\n",N,ROWS,N,ROWS,N,ROWS);

    // Open the single-core workgroup and reset the core, in
    // case a previous process is running. Note that we used
    // core coordinates relative to the workgroup.
    e_open(&dev, row, col, 1, 1);
    e_reset_core(&dev, 0, 0);

    // Load the device program onto the selected eCore
    // and launch after loading.

    e_load("e_dev_main.srec", &dev, 0, 0, E_FALSE);
    e_start_group(&dev);


    // Wait for core program execution to finish, then                               
    // read mailbox from shared buffer.                                              
    unsigned int addr = offsetof(Mailbox, flag);                              
    while (mailbox.flag != 1) {                                               
        e_read(&emem, 0, 0, addr, &mailbox.flag, sizeof(mailbox.flag));
    }                                                                                

    // Wait for core program execution to finish, then
    // read message from shared buffer.
    //usleep(100000);


    e_read(&emem, 0, 0, 0x0, &mailbox, sizeof(mailbox));


    float c_o[N][N];
    addr = (unsigned int)mailbox.c_o;
    e_read(&dev, 0, 0, addr, &c_o[0][0], N * N * sizeof(float));
    print_to_file("../output/optresult",c_o);
    
    // Print the message and close the workgroup.
    e_close(&dev);



    printf("\nOptimized MATMUL time = %d cycles\tTime: %9.3f msec\n", mailbox.clocks1,clock_to_time(mailbox.clocks1)); 
    float gflops = ((2 * N * ROWS * N)/(clock_to_time(mailbox.clocks1)/1000))/1000/1000/1000;
    printf("\nGFlops: %9.6f\tPerformance = %9.4f %% of peak\n",gflops,gflops/1.2*100);
    fprintf(stderr,"\n");
	// Release the allocated buffer and finalize the
	// e-platform connection.
	e_free(&emem);
	e_finalize();


	return 0;
}

float clock_to_time(int clocks) {
    float  time = clocks*(1/(CLOCK*1000000.0))*1000.0;
    return time;
}

void print_to_file(const char *filename,float c[][N]) {
    int i,j;
    FILE *f = fopen(filename, "w");
    if (f == NULL)
    {
        fprintf(stderr,"Error opening file!\n");
        exit(1);
    }

    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            fprintf(f,"%3.2f  ",c[i][j]);
        }
        fprintf(f,"\n");
    }
    fprintf(stderr,"\nMatrix written to %s\n",filename);
    fclose(f);
}
