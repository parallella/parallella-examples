/*
   matmul_multi.c
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
    This is the device side code for multi core matmul. 
    It reads the operand matrices from the shared memory and calls 
    the assembly function matmul_assembly (located in matmul_assembly.S) to perform
    per-core matmul.
    This uses the modified ldf file matmul_internal_multi.ldf to allocate the
    matrices and other objects in memory.
    Further details of implementation can be found in: http://arxiv.org/abs/1410.8772
   This has been built open the example code provided by Adapteva
*/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "e_lib.h"
#include "defs_multi.h"

#define TIMED_SECTION2

void bigmatmul();
void init();
void data_copy(e_dma_desc_t *dma_desc, void *dst, void *src);

void my_barrier(volatile e_barrier_t bar_array[], e_barrier_t *tgt_bar_array[]);

void matclr(float *a, int size);


volatile float  CC   [_Score][_Score] SECTION("section_data_7000");  // local C submatrix
volatile float  AA[1][_Score][_Score] SECTION("section_data_4000");  // local A submatrix
volatile float  BB[1][_Score][_Score] SECTION("section_data_5800");  // local B submatrix

#ifdef ASM
void matmul_assembly(float *a, float *b, float *c,int n);
#else
void matmac(volatile float *a, volatile float *b, volatile float *c, int NN);
#endif

e_mutex_t    mutex; // group lock mutex
volatile e_barrier_t  barriers[_Ncores]; // barriers array
         e_barrier_t *tgt_bars[_Ncores];// barriers array
         e_dma_desc_t dma_desc[4]; // TCB structure for DMA

core_t me;

Mailbox_t *mailbox = (Mailbox_t*)0x8e000000;

int main(int argc, char *argv[])
{
	// Initialize data structures - mainly target pointers
	e_mutex_init(0, 0, &mutex, MUTEXATTR_NULL);
    e_mutex_lock(0, 0, &mutex);
	init();
    e_mutex_unlock(0, 0, &mutex);
    unsigned time_e,time_s; 

	// Initialize the barriers
	e_barrier_init(barriers, tgt_bars);
	
    if (me.corenum == 0)
    {
       while (mailbox->flag != 1) {};
    }

    mailbox->output.dummy1=0;
    mailbox->output.clocks=0;
    // Sync with all other cores
    my_barrier(barriers, tgt_bars);
    if (me.corenum == 0) {
        e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX);
        e_ctimer_start(E_CTIMER_1, E_CTIMER_CLK);
        time_e = e_ctimer_get(E_CTIMER_1);
        mailbox->flag = 2;
    }

    bigmatmul();

    if (me.corenum == 0) {
        mailbox->flag = 3;
        time_s = e_ctimer_get(E_CTIMER_1);
        e_ctimer_stop(E_CTIMER_1);
        mailbox->output.clocks = time_e - time_s;
    }

    // Sync with all other cores
    my_barrier(barriers, tgt_bars);

    if (me.corenum == 0)
    {
        // Signal End-Of-Calculation to the host.
        mailbox->flag = 4;
    }

	return 1;
}


void init()
{
	me.row     = e_group_config.core_row;
	me.col     = e_group_config.core_col;
	me.corenum = me.row * e_group_config.group_cols + me.col;

	// Initialize the mailbox shared buffer pointers
	me.pA    = (float *)((unsigned int)0x8e000000 + offsetof(Mailbox_t, A[0]));
	me.pB    = (float *)((unsigned int)0x8e000000 + offsetof(Mailbox_t, B[0]));
	me.pC    = (float *)((unsigned int)0x8e000000 + offsetof(Mailbox_t, C[0]));

	// Initialize per-core parameters - core data structure
	
	// Initialize pointers to the operand matrices ping-pong arrays
	me.bank_A[_PING] = (float *) &(AA[_PING][0][0]);//0x4000
	me.bank_A[_PONG] = (float *) 0x4800; 

	me.bank_B[_PING] = (float *) &(BB[_PING][0][0]);//0x5800
	me.bank_B[_PONG] = (float *) 0x6000; 

	me.bank_C        = (float *) &(CC       [0][0]);//0x7000

    me.trans_A[0]    = (float *) 0x4000;
    me.trans_A[1]    = (float *) 0x5000;

    me.trans_B[0]    = (float *) 0x5800;
    me.trans_B[1]    = (float *) 0x6800;

	// Initialize the pointer addresses of the arrays in the horizontal and vertical target
	// cores, where the submatrices data will be swapped, and the inter-core sync signals.
    unsigned row_neigh,col_neigh;
    //prev core in row
	e_neighbor_id(E_PREV_CORE, E_ROW_WRAP,   &row_neigh, &col_neigh);
	me.tgt_A[_PING] = e_get_global_address(row_neigh, col_neigh, (void *)0x5000);
	me.tgt_A[_PONG] = e_get_global_address(row_neigh, col_neigh, me.bank_A[_PING]); //0x4000
	
	me.recv_A[_PING] = e_get_global_address(row_neigh, col_neigh, me.bank_A[_PONG]); //0x4800
	me.recv_A[_PONG] = e_get_global_address(row_neigh, col_neigh, me.bank_A[_PONG]); //0x4800

    //upper core in column
	e_neighbor_id(E_PREV_CORE, E_COL_WRAP,   &row_neigh, &col_neigh);
	me.tgt_B[_PING] = e_get_global_address(row_neigh, col_neigh, (void *)0x6800);
	me.tgt_B[_PONG] = e_get_global_address(row_neigh, col_neigh, me.bank_B[_PING]); //0x5800

	me.recv_B[_PING] = e_get_global_address(row_neigh, col_neigh, me.bank_B[_PONG]); //0x6000
	me.recv_B[_PONG] = e_get_global_address(row_neigh, col_neigh, me.bank_B[_PONG]); //0x6000


	me.pingpong = _PING;

	e_dma_wait(E_DMA_0);
	dma_desc[0].config       = E_DMA_MSGMODE | E_DMA_DWORD | E_DMA_MASTER | E_DMA_ENABLE;
	dma_desc[0].inner_stride = (0x0008 << 16) | 0x0008;
	dma_desc[0].count        = (_Score << 16) | (_Score >> 1);
	dma_desc[0].outer_stride = (0x0008 << 16) | (((_Smtx - _Score) * sizeof(float)) + 0x0008);

	// Duplicate descriptor twice and make necessary corrections for outer strides
	dma_desc[1] = dma_desc[0];
	dma_desc[1].outer_stride = (0x0008 << 16) | 0x0008;
	dma_desc[2] = dma_desc[0];
	dma_desc[2].outer_stride = ((((_Smtx - _Score) * sizeof(float)) + 0x0008) << 16) | 0x0008;
    dma_desc[3] = dma_desc[1];
	dma_desc[3].count        = (_Score/2 << 16) | (_Score >> 1);


	if (me.corenum == 0)
	{
		mailbox->flag = 0;
	}
	
	return;
}


void bigmatmul()
{
    int  im, jm, km; // index of chip array (chip) (0..#arrays-in-matrix)
    int  ic, jc, kc; // index of core in a chip (0..Nside)
    void *src, *dst; // source and destination addresses for DMA transfers
    #if defined(TIMED_SECTION2) || defined(TIMED_SECTION3)
    unsigned time_e,time_s;
    #endif

    // Chip loop through operand matrix:
    // Smtx is the size of operand matrices (Smtx x Smtx)
    // Schip is size of a chip matrix (Schip x Schip)
    for (im=0; im<_Smtx; im+=_Schip)
    {
        for (jm=0; jm<_Smtx; jm+=_Schip)
        {
            // First clear the local result submatrix. The product result will be
            // integrated into this submatrix.
            matclr(me.bank_C, _Score);

            for (km=0; km<_Smtx; km+=_Schip)
            {
                // Core loop through chip:
                // for every chip (mesh) iteration on the operand matrix
                // calculate the matmul of the chip-sized submatrices
                // in granularity of cores


                // get A block from external DRAM
                ic = me.row * _Score;
                jc = ((me.col + me.row) % _Nside) * _Score;

                src = &(me.pA[(im+ic)*_Smtx + (km+jc)]);
                dst = me.bank_A[me.pingpong];
                
                #ifdef TIMED_SECTION3
                if (me.corenum == 0) {
                    e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX);
                    e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);
                    time_e = e_ctimer_get(E_CTIMER_0);
                    mailbox->flag = 2;
                }
                #endif

                // Wait for the DMA token
                e_mutex_lock(0, 0, &mutex);
                //
                // Read the data
                data_copy(&dma_desc[0], dst, src);

                // get B block from DRAM
                jc = me.col * _Score;
                ic = ((me.row + me.col) % _Nside) * _Score;

                src = &(me.pB[(km+ic)*_Smtx + (jm+jc)]);
                dst = me.bank_B[me.pingpong];

                // Read the data
                data_copy(&dma_desc[0], dst, src);

                // Pass the DMA token to next core
                e_mutex_unlock(0, 0, &mutex);

                //Modified
                my_barrier(barriers, tgt_bars);

                #ifdef TIMED_SECTION2
                if (me.corenum == 0) {
                    e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX);
                    e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);
                    time_e = e_ctimer_get(E_CTIMER_0);
                }
                #endif

                // Multiply submatrices (inner product of row x column)
                for (kc=0; kc<_Nside; kc++)
                {
                    // Core matmul:
                    // for every core calculate the matmul
                    // of its sample elements and accumulate with
                    // previous partial products
                    #ifdef ASM
                    matmul_assembly(me.bank_A[me.pingpong], me.bank_B[me.pingpong], me.bank_C, _Score);
                    #else
                    matmac(me.bank_A[me.pingpong], me.bank_B[me.pingpong], me.bank_C, _Score);
                    #endif

                    // After multiplying the submatrices in each core, rotate the rows of A and columns of B
                    // If this is the last iteration of the inner product, skip the matrix swap
                    #ifdef EXCLUDE_CORE_COMM 
                    if (me.corenum == 0) {
                        time_s = e_ctimer_get(E_CTIMER_0);
                        e_ctimer_stop(E_CTIMER_0);
                        mailbox->output.dummy1 += time_e - time_s;
                    }
                    #endif
                    if (kc <= (_Nside - 1)) { 
                        data_copy(&dma_desc[3], me.tgt_A[me.pingpong], me.bank_A[_PONG]);
                        data_copy(&dma_desc[3], me.tgt_B[me.pingpong], me.bank_B[_PONG]);
                        data_copy(&dma_desc[3], me.recv_A[me.pingpong], me.trans_A[me.pingpong]);
                        data_copy(&dma_desc[3], me.recv_B[me.pingpong], me.trans_B[me.pingpong]);
                    }
                    #ifdef EXCLUDE_CORE_COMM
                    if (me.corenum == 0) {
                        e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX);
                        e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);
                        time_e = e_ctimer_get(E_CTIMER_0);
                    }
                    #endif

                    me.pingpong = 1 - me.pingpong;

                }
                #ifdef TIMED_SECTION2
                if (me.corenum == 0) {
                    time_s = e_ctimer_get(E_CTIMER_0);
                    e_ctimer_stop(E_CTIMER_0);
                    mailbox->output.dummy1 += time_e - time_s;
                }
                #endif

            }

            // Write the core's result to DRAM
            ic = me.row * _Score;
            jc = me.col * _Score;

            src = me.bank_C;
            dst = &(me.pC[(im+ic)*_Smtx + (jm+jc)]);

            // Wait for the DMA token
            e_mutex_lock(0, 0, &mutex);

            // Write data
            data_copy(&dma_desc[2], dst, src);

            // Pass the DMA token to the next core
            e_mutex_unlock(0, 0, &mutex);
            
            #ifdef TIMED_SECTION3
            if (me.corenum == 0) {
                mailbox->flag = 3;
                time_s = e_ctimer_get(E_CTIMER_0);
                e_ctimer_stop(E_CTIMER_0);
                mailbox->output.clocks = time_e - time_s;
            }
            #endif
        }
    }

    return;
}


// Use DMA to copy data blocks from src to dst
void data_copy(e_dma_desc_t *dma_desc, void *dst, void *src)
{
	// Make sure DMA is inactive before modifying the descriptor
	e_dma_wait(E_DMA_0);
	dma_desc->src_addr = src;
	dma_desc->dst_addr = dst;

	e_dma_start(dma_desc, E_DMA_0);

	// All DMA transfers are blocking, so wait for process to finish
	e_dma_wait(E_DMA_0);

	return;
}


// Clear a sizexsize matrix
void matclr(float *c, int size)
{
    int i;

    for (i=0; i<size*size; i++)
        c[i] = 0;

    return;
}

void my_barrier(volatile e_barrier_t bar_array[], e_barrier_t *tgt_bar_array[])
{
    int corenum, numcores, i;

    numcores = e_group_config.group_rows * e_group_config.group_cols;
    corenum = e_group_config.core_row * e_group_config.group_cols + e_group_config.core_col;

    // Barrier as a Flip-Flop

    if (corenum == 0)
    {
        // Flip pass
        // set "my" slot
        bar_array[corenum] = 1;
        // poll on all slots
        for (i=1; i<numcores; i++)
            while (bar_array[i] == 0) {};

        // Flop pass
        // clear all local slots
        for (i=0; i<numcores; i++)
            bar_array[i] = 0;
        // set remote slots
        for (i=1; i<numcores; i++)
            *(tgt_bar_array[i]) = 1;
    } else {
        // Flip pass
        // set "my" remote slot
        *(tgt_bar_array[0]) = 1;

        // Flop pass
        // poll on "my" local slot
        while (bar_array[0] == 0) {};
        // clear "my" local slot
        bar_array[0] = 0;
    }

    return;
}
