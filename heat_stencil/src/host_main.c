/*
   host_main.c
   Contributed by: Anish Varghese <anish.varghese@anu.edu.au>, Bob Edwards <bob@cs.anu.edu.au>
                   Oct 2013 

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
    This is the host side code for the heat stencil. It initializes the input grid
    and transfers the grid to the device for computation. When the device completes
    computation, the host reads the output grid and writes it to an output file.

    The parameters such as grid size, number of cores, number of iterations,
    boundary temperature are configured in defs.h
 */
 

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/time.h>
#include <e-hal.h>
#include "defs.h"

#define _BufOffset (0x01000000)

float clock_to_time(int clocks); 

int main(int argc, char *argv[])
{
    unsigned row, col, core_start;
    e_platform_t platform;
    e_epiphany_t dev;
    e_mem_t emem,emem_grid;

    static float temp_grid_core[CORE_GRID_SIZE];


    Mailbox mailbox; 
    mailbox.finish_flag = 0;
    mailbox.start_flag = 0;
    mailbox.output.t_old = 0x0;

    int i,j;

    // initialize system
    e_init(NULL);
    e_reset_system();
    e_get_platform_info(&platform);

    // Allocate a buffer in shared external memory
    // for mailbox passing from eCore to host.
    e_alloc(&emem, _BufOffset, 1024);
    e_alloc(&emem_grid,_BufOffset + 1024, CHIP_GRID_SIZE * sizeof(float));

    float *temp_grid_chip = (float*)(unsigned int)(emem_grid.base);
    float *t1 = temp_grid_chip;

    unsigned int addr;

    //Initializing the arrays                           
    for (i = 0; i < CHIP_GRID_Y; i++) {
        for (j = 0; j < CHIP_GRID_X; j++) {
            //temp_grid_chip[i * CHIP_GRID_X + j] = 0.0;
            *t1++ = 0.0;
        }
    }

    // fix boundary values
    t1 = temp_grid_chip;
    for (i = 0; i < CHIP_GRID_X; i++) *t1++ = T_EDGE;
    t1 = &temp_grid_chip[(CHIP_GRID_Y - 1) * CHIP_GRID_X];
    for (i = 0; i < CHIP_GRID_X; i++) *t1++ = T_EDGE;
    t1 = temp_grid_chip;
    for (j = 0; j < CHIP_GRID_Y; j++, t1+=CHIP_GRID_X) *t1 = T_EDGE;
    t1 = &temp_grid_chip[(CHIP_GRID_X - 1)]; 
    for (j = 0; j < CHIP_GRID_Y; j++, t1+=CHIP_GRID_X) *t1 = T_EDGE;

    core_start = (start_row + platform.row) * 64 + start_col + platform.col;

    e_open(&dev, start_row, start_col, group_rows, group_cols);

    fprintf(stderr,"\nRows: %d Columns: %d\n",group_rows,group_cols);
    fprintf(stderr,"\nOverall Grid size: %d X %d\n\n",CHIP_GRID_X, CHIP_GRID_Y);
    
    // Load the device program onto the selected eCore group
    // and launch after loading.
    e_load_group("e_dev_main.elf", &dev, 0, 0, group_rows, group_cols, E_FALSE);

    e_write(&emem, 0, 0, (off_t) (0x0000), (void *) &mailbox, sizeof(Mailbox)); 
    
    e_start_group(&dev);

    // Wait for cores to allocate the grid  
    // read the address from shared buffer. 
    addr = offsetof(Mailbox, output.t_old);
    while (mailbox.output.t_old == 0x0) {                                                       
        e_read(&emem, 0, 0, addr, &mailbox.output.t_old, sizeof(mailbox.output.t_old));        
    }

    
    int gridi,gridj;
    for (row = 0; row < group_rows; row++) {
        for (col = 0; col < group_cols ; col++) {
            //Transfer it to correct position of temp_grid_chip

            for (i = 0, gridi = row * CORE_DATA_Y; i < CORE_GRID_Y; i++, gridi++) {
                for (j = 0, gridj = col * CORE_DATA_X; j < CORE_GRID_X; j++,gridj++) {
                    //Copy
                    temp_grid_core[i * CORE_GRID_X + j] = temp_grid_chip[gridi * CHIP_GRID_X + gridj];
                }
            }
            e_write(&dev, row, col, (off_t) mailbox.output.t_old, &temp_grid_core, CORE_GRID_SIZE * sizeof(float));
        }
    }


    //Signal the core to start the program
    mailbox.start_flag = 1;
    addr = offsetof(Mailbox, start_flag);
    e_write(&emem, 0, 0, addr, (void *)&mailbox.start_flag, sizeof(mailbox.start_flag)); 


    // Wait for core program execution to finish, then                                       
    // read mailbox from shared buffer.                                                      
    addr = offsetof(Mailbox, finish_flag);
    while (mailbox.finish_flag == 0) {                                                       
        e_read(&emem, 0, 0, addr, &mailbox.finish_flag, sizeof(mailbox.finish_flag));        
    }                                                                                        


    //Only for debugging purposes
    //usleep(1000000);  
    //Read Final mailbox from shared dram	
    e_read(&emem, 0, 0, 0x0, &mailbox, sizeof(Mailbox)); 


    fprintf(stderr, "Num of iterations: %d\nT_edge: %4.2f\n", mailbox.output.iters, T_EDGE);

    addr = (unsigned int)mailbox.output.t_old;

    for (row = 0; row < group_rows; row++) {
        for (col = 0; col < group_cols ; col++) {
            e_read(&dev, row, col, addr, &temp_grid_core, CORE_GRID_SIZE * sizeof(float));
            //Transfer it to correct position of temp_grid_chip

            for (i = 1, gridi = row * CORE_DATA_Y + 1; i <= CORE_DATA_Y; i++, gridi++) {
                for (j = 1, gridj = col * CORE_DATA_X + 1; j <= CORE_DATA_X; j++,gridj++) {
                    //Copy
                    temp_grid_chip[gridi * CHIP_GRID_X + gridj] = temp_grid_core[i * CORE_GRID_X + j];
                }
            }
        }
    }

    e_close(&dev);

    double epiphany_time=clock_to_time(mailbox.output.clocks);
    fprintf(stderr, "Epiphany time: %9.3f msec\n",epiphany_time);

    double gflops=((CORE_DATA_X*CORE_DATA_Y*NUM_CORES*10*MAX_ITER)/(1000*1000))/epiphany_time;
    fprintf(stderr, "Floating point performance: %4.2f GFLOPS (%3.2f %% of peak)\n",gflops,gflops/(1.2*group_rows*group_cols)*100);


#ifdef PRINT
    const char *filename = "../output/e_output";

    FILE *f = fopen(filename, "w");
    if (f == NULL)
    {
        fprintf(stderr,"Error opening file!\n");
        exit(1);
    }
   
   
    fprintf(stderr,"\nFinal grid written to %s\n\n",filename);
    for (i = 0; i < CHIP_GRID_Y; i++) {
        for (j = 0; j < CHIP_GRID_X; j++) {
            fprintf(f,"%3.2f  ",temp_grid_chip[i * CHIP_GRID_X + j]);
        }
        fprintf(f,"\n");
    }

    fclose(f);
#endif

    e_free(&emem);
    e_free(&emem_grid);
    e_finalize();



    return 0;
}

float clock_to_time(int clocks) {                                
        float  time = clocks*(1/(CLOCK*1000000.0))*1000.0;
            return time;                                                 
}                                                                

