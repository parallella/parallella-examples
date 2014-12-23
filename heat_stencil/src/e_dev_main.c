/*
   e_dev_main.c

   Contributed by Anish Varghese <anish.varghese@anu.edu.au>, Bob Edwards <bob@cs.anu.edu.au>
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
   This is the device side code for the heat stencil. It receives the input grid
   from the host and performs a 5-point stencil operation (10 flops per grid point)
   with boundary grid points being transferred to neighbouring cores in each iteration.
   The program runs for a fixed number of iterations.
   Further details of implementation can be found in: http://arxiv.org/abs/1410.8772
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include "e_lib.h"
#include "defs.h"
#include "e_dma.h"

#define NEIGHBOURS 4

typedef enum
{
    LEFT,
    RIGHT,
    TOP, 
    BOTTOM,
} flag_sync;


Mailbox mailbox SECTION("shared_dram");

void stencil_20n (float *t_old, float *t_new, int num, float *scale);

int main(void) {

    e_coreid_t coreid;
    unsigned core_row,core_col;
    unsigned time_s, time_e, clock_s, clock_e;;
    int start_core;

    core_row=e_group_config.core_row;
    core_col=e_group_config.core_col;
    start_core=e_group_config.group_id;

    coreid = e_get_coreid();

    float coefs[5] = {0.25, 0.25, 0.0, 0.25, 0.25};

    int i;
    int debug = 0;

    static float temp_old[CORE_GRID_SIZE];// SECTION(".data_bank1");
    float *dptr = &temp_old[0];

    if (coreid == start_core) mailbox.output.t_old = dptr; 

    float save_vect[CORE_GRID_Y];
    float *t1;
    
    static int iter = 0;

    e_dma_desc_t dma_desc[4];

    unsigned int neighbour_row,neighbour_col;//store neighbour's position
    //volatile int iter_array[NEIGHBOURS], t_iter_array[NEIGHBOURS];                           
    int iter_array[NEIGHBOURS], t_iter_array[NEIGHBOURS];                           
    int* iter_neigh[NEIGHBOURS],*t_iter_neigh[NEIGHBOURS];                                   
    float *t_neighbour[NEIGHBOURS];                                                          
    iter_array[LEFT] = iter_array[RIGHT] = iter_array[TOP] = iter_array[BOTTOM] = 0;         
    t_iter_array[LEFT] = t_iter_array[RIGHT] = t_iter_array[TOP] = t_iter_array[BOTTOM] = 0; 
    
    volatile e_barrier_t bar_array[NUM_CORES]; 
    e_barrier_t *tgt_bar_array[NUM_CORES];     

  
    e_neighbor_id(E_NEXT_CORE,E_ROW_WRAP,&neighbour_row,&neighbour_col);
    iter_neigh[RIGHT] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&iter_array[LEFT]);
    t_iter_neigh[RIGHT] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&t_iter_array[LEFT]);
    t_neighbour[RIGHT] = (float *)e_get_global_address(neighbour_row,neighbour_col,dptr);

    e_neighbor_id(E_PREV_CORE,E_ROW_WRAP,&neighbour_row,&neighbour_col);
    iter_neigh[LEFT] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&iter_array[RIGHT]);
    t_iter_neigh[LEFT] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&t_iter_array[RIGHT]);
    t_neighbour[LEFT] = (float *)e_get_global_address(neighbour_row,neighbour_col,dptr);

    e_neighbor_id(E_PREV_CORE,E_COL_WRAP,&neighbour_row,&neighbour_col);
    iter_neigh[TOP] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&iter_array[BOTTOM]);
    t_iter_neigh[TOP] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&t_iter_array[BOTTOM]);
    t_neighbour[TOP] = (float *)e_get_global_address(neighbour_row,neighbour_col,dptr);

    e_neighbor_id(E_NEXT_CORE,E_COL_WRAP,&neighbour_row,&neighbour_col);
    iter_neigh[BOTTOM] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&iter_array[TOP]);
    t_iter_neigh[BOTTOM] = (int *)e_get_global_address(neighbour_row,neighbour_col,(void *)&t_iter_array[TOP]);
    t_neighbour[BOTTOM] = (float *)e_get_global_address(neighbour_row,neighbour_col,dptr);


        //Resetting neighbours for edge cores               
    if (core_row == 0) {                                
        iter_neigh[TOP] = &iter_array[TOP];             
        t_iter_neigh[TOP] = &t_iter_array[TOP];         
    }                                                   
    if (core_row == group_rows - 1) {                   
        iter_neigh[BOTTOM] = &iter_array[BOTTOM];       
        t_iter_neigh[BOTTOM] = &t_iter_array[BOTTOM];   
    }                                                   
    if (core_col == 0) {                                
        iter_neigh[LEFT] = &iter_array[LEFT];           
        t_iter_neigh[LEFT] = &t_iter_array[LEFT];       
    }                                                   
    if (core_col == group_cols - 1) {                   
        iter_neigh[RIGHT] = &iter_array[RIGHT];         
        t_iter_neigh[RIGHT] = &t_iter_array[RIGHT];     
    }                                                   

    e_barrier_init(bar_array,tgt_bar_array);

    if (coreid == start_core) {
        while (mailbox.start_flag == 0);
    }

    e_barrier(bar_array,tgt_bar_array);

#ifdef _righty
    t1 = &dptr[CORE_DATA_X + 1];    // right boundary
#else
    t1 = dptr;                      // left boundary
#endif
    // save the relevant boundary
    for (i = 0; i < CORE_GRID_X; i++) {
        save_vect[i] = *t1;
        t1 += CORE_GRID_X;
    }

    int src_offset, dst_offset;

    //Setting up dma descriptors
    e_dma_desc_t *start_descr0=0x0000,*start_descr1=0x0000;
    unsigned dma_config = E_DMA_ENABLE | E_DMA_MASTER;
    unsigned config = 0x0;
    
    e_dma_wait(E_DMA_0);
    e_dma_wait(E_DMA_1);

    //BOTTOM
    if (core_row != group_rows - 1) {
        dst_offset = 0;
        src_offset = (CORE_GRID_Y - 2) * CORE_GRID_X;
        config = dma_config | E_DMA_DWORD;
        e_dma_set_desc(E_DMA_0, config, start_descr0,
                0x0008, 0x0008,
                CORE_GRID_X>>1, 0x0001,
                0x0000 , 0x0000,
                (void *)(dptr+src_offset),(void *)(t_neighbour[BOTTOM]+dst_offset), &dma_desc[3]);
        start_descr0=&dma_desc[3];
    }
    //TOP
    if (core_row != 0) {
        dst_offset = (CORE_GRID_Y - 1) * CORE_GRID_X;
        src_offset = CORE_GRID_X;
        config = dma_config | E_DMA_DWORD;
        if (start_descr0 != 0x0000) config = config | E_DMA_CHAIN;
        e_dma_set_desc(E_DMA_0, config, start_descr0,
                0x0008, 0x0008,
                CORE_GRID_X>>1, 0x0001,
                0x0000 , 0x0000,
                (void *)(dptr+src_offset),(void *)(t_neighbour[TOP]+dst_offset), &dma_desc[2]);
        start_descr0=&dma_desc[2];
    }
    //RIGHT
    if (core_col != (group_cols - 1)) {
        dst_offset = 0;
        src_offset = CORE_GRID_X - 2;
        config = dma_config | E_DMA_WORD;
        e_dma_set_desc(E_DMA_1, config, start_descr1,
                0x0000, 0x0000,
                0x0001, CORE_GRID_X, 
                (CORE_GRID_X * sizeof(float)), (CORE_GRID_X * sizeof(float)) ,
                (void *)(dptr+src_offset),(void *)(t_neighbour[RIGHT]+dst_offset), &dma_desc[1]);
        start_descr1=&dma_desc[1];
    }
    //LEFT
    if (core_col != 0) {
        dst_offset = CORE_GRID_X - 1;
        src_offset = 1;
        config = dma_config | E_DMA_WORD;
        if (start_descr1 != 0x0000) config = config | E_DMA_CHAIN;
        e_dma_set_desc(E_DMA_1, config, start_descr1,
                0x0000, 0x0000,
                0x0001, CORE_GRID_X,
                (CORE_GRID_X * sizeof(float)), (CORE_GRID_X * sizeof(float)) ,
                (void *)(dptr+src_offset),(void *)(t_neighbour[LEFT]+dst_offset), &dma_desc[0]);
        start_descr1=&dma_desc[0];
    }

   
    if (coreid==start_core) {                      
        e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX);
        e_ctimer_start(E_CTIMER_1, E_CTIMER_FPU_INST);
        clock_e = e_ctimer_get(E_CTIMER_1);

        e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX);    
        e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);  
        time_e = e_ctimer_get(E_CTIMER_0);         
    }

    do {
        
#ifdef _righty
        t1 = &dptr[CORE_DATA_X + 1];    // right boundary
        stencil_20n (&dptr[2 * STRIPE_WIDTH], t1, CORE_DATA_Y / 2, coefs);

        stencil_20n (&dptr[1 * STRIPE_WIDTH], t1, CORE_DATA_Y / 2, coefs);

        stencil_20n (&dptr[0 * STRIPE_WIDTH], t1, CORE_DATA_Y / 2, coefs);
        
#else
        t1 = dptr;                      // left boundary
        stencil_20n (&dptr[0 * STRIPE_WIDTH], t1, CORE_DATA_Y / 2, coefs);

        stencil_20n (&dptr[1 * STRIPE_WIDTH], t1, CORE_DATA_Y / 2, coefs);

        stencil_20n (&dptr[2 * STRIPE_WIDTH], t1, CORE_DATA_Y / 2, coefs);

#endif
        // restore relevant boundary for next iteration
        for (i = 0; i < CORE_GRID_Y; i++) {
            *t1 = save_vect[i];
            t1 += CORE_GRID_X;
        }

        
        //Communicate the boundary to other cores - TOP,BOTTOM,LEFT,RIGHT

        iter++;                                                       
        *(iter_neigh[LEFT]) = iter;
        *(iter_neigh[RIGHT]) = iter;
        *(iter_neigh[TOP]) = iter;
        *(iter_neigh[BOTTOM]) = iter;            

        while ( iter_array[TOP] < iter || iter_array[BOTTOM] < iter   
             || iter_array[LEFT] < iter || iter_array[RIGHT] < iter);  

       
        e_dma_start(start_descr0,E_DMA_0);
        e_dma_start(start_descr1,E_DMA_1);
        e_dma_wait(E_DMA_0);
        e_dma_wait(E_DMA_1);


        *(t_iter_neigh[LEFT]) = iter;
        *(t_iter_neigh[RIGHT]) = iter;
        *(t_iter_neigh[TOP]) = iter;
        *(t_iter_neigh[BOTTOM]) = iter;             

        while ( t_iter_array[TOP] < iter || t_iter_array[BOTTOM] < iter    
             || t_iter_array[LEFT] < iter || t_iter_array[RIGHT] < iter);   

    } while (iter < MAX_ITER);


    if (coreid == start_core) {
        //debug = 2; - To print debug messages 
        time_s = e_ctimer_get(E_CTIMER_0);             
        e_ctimer_stop(E_CTIMER_0);                     

        clock_s = e_ctimer_get(E_CTIMER_1);
        e_ctimer_stop(E_CTIMER_1);

        mailbox.output.clocks = time_e - time_s; 
        mailbox.output.measure_clock_event = clock_e - clock_s;
        mailbox.output.from_core = coreid;
        mailbox.output.core_row = core_row;
        mailbox.output.core_col = core_col;
        mailbox.output.t_new = t_neighbour[RIGHT]; 

        mailbox.output.iters = iter; 
        mailbox.output.debug=debug; 
        
        mailbox.finish_flag = 1; 

    }
    return EXIT_SUCCESS;
}

