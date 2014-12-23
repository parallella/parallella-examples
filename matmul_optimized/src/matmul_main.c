/*
   matmul_main.c
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
    This is the device side code for single core matmul. 
    It generates the operand matrices and calls the assembly function
    matmul_assembly (located in matmul_assembly.S) to perform
    matmul. 
    This uses the modified ldf file matmul_internal.ldf to allocate the 
    matrices in memory.
    This has been built upon the example code provided by Adapteva
 */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "e_lib.h"
#include "defs.h"

//#define NAIVE_MULT
//#define FLOP_COUNT

float a[N][N]   ALIGN(8) SECTION(".section_core_db1");
float b[N][N]   ALIGN(8) SECTION(".data_bank2");
float c_o[N][N] ALIGN(8) SECTION(".data_bank3");
#ifdef NAIVE_MULT
float c_n[N][N] ALIGN(8) SECTION(".data_bank3");
#endif 

#ifdef ASM
void matmul_assembly(float *a, float *b, float *c,int n);
#else
unsigned matmul(float * restrict aa, float * restrict bb, float * restrict cc);
#endif


int matmul_main (Mailbox* mailbox)
{
    int  i;
    mailbox->c_o = (float *)c_o;
    mailbox->a = (float *)a;
    mailbox->b = (float *)b;
#ifdef NAIVE_MULT
    mailbox->c_n = (float *)c_n;
#endif

    for (i = 0; i < N; i++)
    {
        int  j;
        for (j = 0; j < N; j++)
        {
            a[i][j] = (float) (i+1) * (float) (j+2);
            b[i][j] = (float) (i+2) * (float) (j+1);
            c_o[i][j] = 0.0;
            #ifdef NAIVE_MULT
            c_n[i][j] = 0.0;
            #endif
        }
    }

    unsigned time_s, time_e;

#ifdef FLOP_COUNT
    unsigned clock_s, clock_e; 
    e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX);
    e_ctimer_start(E_CTIMER_1, E_CTIMER_FPU_INST);
    clock_e = e_ctimer_get(E_CTIMER_1);
#endif

    e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX);  
    e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);
    time_s = e_ctimer_get(E_CTIMER_0);       
    

#ifdef ASM
    matmul_assembly((float *) a, (float *) b, (float *) c_o, ROWS);
#else
    matmul((float *) a, (float *) b, (float *) c_o);
#endif

    time_e = e_ctimer_get(E_CTIMER_0); 
    e_ctimer_stop(E_CTIMER_0);         
    mailbox->clocks1 = time_s - time_e;            

#ifdef FLOP_COUNT
    clock_s = e_ctimer_get(E_CTIMER_1);
    e_ctimer_stop(E_CTIMER_1);
    mailbox->flops1 = clock_e - clock_s;
#endif

#ifdef NAIVE_MULT
    return 3;
#else
    return 2;
#endif
}
