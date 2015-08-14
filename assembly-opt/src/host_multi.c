/*
   host_multi.c
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
    This is the host side code for multi core matmul. This code initializes
   the operand matrices and writes them to shared memory and signals the
   device to start execution. Once computation is over, it reads the result
   from the shared memory and writes it to a file.
   This has been built open the example code provided by Adapteva
*/


#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <e-hal.h>
#include "defs_multi.h"

//#define _BufOffset (0x01000000)
#define _BufOffset (0x00000000)
#define _MAX_MEMBER_ 32

typedef struct timeval timeval_t;
timeval_t timer[4];              


float clock_to_time(int clocks);
void print_to_file(const char *filename,float *c);
void matrix_init(int seed);
Mailbox_t mailbox;

int main(int argc, char *argv[])
{
	unsigned row, col, coreid, i, j;
	e_platform_t platform;
	e_epiphany_t dev;
	e_mem_t emem;

    double tdiff;

    mailbox.flag = -1;
    matrix_init(0.0);
    //matrix_init(54.0);

	// initialize system, read platform params from
	// default HDF. Then, reset the platform and
	// get the actual system parameters.
	e_init(NULL);
	e_reset_system();
	e_get_platform_info(&platform);

	// Allocate a buffer in shared external memory
	// for message passing from eCore to host.
	e_alloc(&emem, _BufOffset, sizeof(Mailbox_t));

    row = 0;
    col = 0;
    coreid = (row + platform.row) * 64 + col + platform.col;
    fprintf(stderr,"\n\nMultiplying A[%d][%d] x B[%d][%d] = C[%d][%d]\n",_Smtx,_Smtx,_Smtx,_Smtx,_Smtx,_Smtx);
    fprintf(stderr, "\nGroup rows: %d Group_cols: %d. Starting row: %d col : %d\n",group_rows_num,group_cols_num,row,col);

    // Open the single-core workgroup and reset the core, in
    // case a previous process is running. Note that we used
    // core coordinates relative to the workgroup.
    e_open(&dev, row, col, group_rows_num, group_cols_num);
    for ( i=0 ; i < group_rows_num; i++ ) {     
        for ( j=0 ; j < group_cols_num ; j++ ) {
            e_reset_core(&dev, i, j);       
        }                                   
    }                                       


    // Load the device program onto the selected eCore
    // and launch after loading.

    int load_err=e_load_group("matmul_multi.srec", &dev, 0, 0, group_rows_num, group_cols_num, E_FALSE);
    char load_result[5];
    if (load_err == E_OK) strcpy(load_result,"E_OK");
    if (load_err == E_ERR) strcpy(load_result,"E_ERR");
    if (load_err == E_WARN) strcpy(load_result,"E_WARN");
    fprintf(stderr,"Load result: %s\n",load_result);

    //gettimeofday(&timer[0], NULL);
    e_start_group(&dev);

    unsigned int addr = offsetof(Mailbox_t, flag);                              
    while (mailbox.flag != 0) {
        e_read(&emem, 0, 0, addr, &mailbox.flag, sizeof(mailbox.flag));
    }

    //fprintf(stderr,"\nReceived Ready signal from Epiphany: %d\n",mailbox.flag);

//Initialize and write the matrix to shared memory
    addr = offsetof(Mailbox_t, A[0]);
    e_write(&emem, 0, 0, addr, (void *)mailbox.A, sizeof(mailbox.A));
    
    addr = offsetof(Mailbox_t, B[0]);
    e_write(&emem, 0, 0, addr, (void *)mailbox.B, sizeof(mailbox.B));

    addr = offsetof(Mailbox_t, C[0]);
    e_write(&emem, 0, 0, addr, (void *)mailbox.C, sizeof(mailbox.C));

    mailbox.flag = 1;
    addr = offsetof(Mailbox_t, flag);

    //fprintf(stderr,"\nSending Ready signal to Epiphany: %d\n",mailbox.flag);
    e_write(&emem, 0, 0, addr, &mailbox.flag, sizeof(mailbox.flag));

    while (mailbox.flag != 2)                                                
        e_read(&emem, 0, 0, addr, &mailbox.flag, sizeof(mailbox.flag));

    gettimeofday(&timer[0], NULL);

    while (mailbox.flag != 3)                                                
        e_read(&emem, 0, 0, addr, &mailbox.flag, sizeof(mailbox.flag));

    gettimeofday(&timer[1], NULL);


    //usleep(3000000);
    //e_read(&emem, 0, 0, addr, &mailbox.flag, sizeof(mailbox.flag));

    // Wait for core program execution to finish, then                               
    // read mailbox from shared buffer.                                              
    while (mailbox.flag != 4) {
        e_read(&emem, 0, 0, addr, &mailbox.flag, sizeof(mailbox.flag));
    }

    // Wait for core program execution to finish, then
    // read message from shared buffer.
    //usleep(100000);


    addr = offsetof(Mailbox_t, output);
    e_read(&emem, 0, 0, addr, &mailbox.output, sizeof(mailbox.output));
    addr = offsetof(Mailbox_t, C[0]);
    e_read(&emem, 0, 0, addr, (void *)mailbox.C, sizeof(mailbox.C));


    print_to_file("../output/optresult",(void *)mailbox.C);
    
    // Print the message and close the workgroup.
    e_close(&dev);

    tdiff = (timer[1].tv_sec - timer[0].tv_sec) * 1000 + ((double) (timer[1].tv_usec - timer[0].tv_usec) / 1000.0);


    //printf("Optimized MATMUL time: %d cycles\tTime: %9.9f msec\n", mailbox.output.clocks,clock_to_time(mailbox.output.clocks)); 

    //printf("Optimized MATMUL Exec time: %d cycles\tTime: %9.9f msec\n", mailbox.output.dummy1,clock_to_time(mailbox.output.dummy1)); 

    //printf("Optimized MATMUL Shared memory Comms time: %d cycles\tTime: %9.9f msec\n", (mailbox.output.clocks-mailbox.output.dummy1),clock_to_time(mailbox.output.clocks-mailbox.output.dummy1)); 
    //
    //printf("\nTime from host: %9.6f msec\n",tdiff);
    float gflops = ((2.0 * _Smtx * _Smtx * _Smtx)/(clock_to_time(mailbox.output.clocks)/1000))/1000/1000/1000;

    float gflops2 = ((2.0 * _Smtx * _Smtx * _Smtx)/(clock_to_time(mailbox.output.dummy1)/1000))/1000/1000/1000;

    printf("\nGFlops (On chip): %9.6f\tPerformance = %9.4f %% of peak\n",gflops2,gflops2/(1.2*group_rows_num*group_cols_num)*100);

    printf("\nGFlops (including off-chip transfers): %9.6f\tPerformance = %9.4f %% of peak\n",gflops,gflops/(1.2*group_rows_num*group_cols_num)*100);

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

void print_to_file(const char *filename,float *c) {
    int i,j;
    FILE *f = fopen(filename, "w");
    if (f == NULL)
    {
        fprintf(stderr,"Error opening file!\n");
        exit(1);
    }

    for (i = 0; i < _Smtx; i++) {
        for (j = 0; j < _Smtx; j++) {
            fprintf(f,"%3.2f  ",c[i * _Smtx + j]);
        }
        fprintf(f,"\n");
    }
    fprintf(stderr,"\nResult matrix written to %s\n",filename);
    fclose(f);
}

// Initialize operand matrices
void matrix_init(int seed)
{
    int i, j, p;

    p = 0;
    for (i=0; i<_Smtx; i++)
        for (j=0; j<_Smtx; j++)
            mailbox.A[p++] = (i + j + seed + 4) % _MAX_MEMBER_;
            //mailbox.A[p++] = (i + j + seed * (j - 1) + seed) % _MAX_MEMBER_;

    p = 0;
    for (i=0; i<_Smtx; i++)
        for (j=0; j<_Smtx; j++)
            //mailbox.B[p++] = ((i + j + seed * (i - j)  ) * 2 + seed) % _MAX_MEMBER_;
            mailbox.B[p++] = ((i + j) * 2 + seed - 5) % _MAX_MEMBER_;

    p = 0;
    for (i=0; i<_Smtx; i++)
        for (j=0; j<_Smtx; j++)
            mailbox.C[p++] = 0xdeadbeef;
            //mailbox.C[p++] = 0;

    return;
}
