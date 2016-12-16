/*

	reTrans.c
	Süleyman Savas
	2013-07-09

*/

#include <stdlib.h>
#include <stdio.h>

#include "reTrans.h"
#include "e_lib.h"
#include "idct.h" 
#include "common_buffers.h"
#include "actors.h"

// Actor instantiation
reTrans_t reTrans;

// Port instantiation
inputPort_t X;
outputPort_t Y;

// Core struct instantiaton
core_t me;

unsigned timerValue = 0;

void init();

void main(){

// Configure the timers
 e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX); 

 // Start the timer (countdown from 0xFFFFFFFF)
 e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);

	init();
	int j = 0;
	int consumed_elements = 0;	
	
	// wait for the go (which means actors are connected)
	while(Mailbox.pGo[me.corenum] == 0);

timerValue = e_ctimer_get(E_CTIMER_0);
Mailbox.pTimer0[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_0);

e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX); 
e_ctimer_start(E_CTIMER_1, E_CTIMER_CLK);

        while(j < IN_BUFFER_SIZE)
        {
                // action #1
                if(reTrans.rcount < 64){

		        int row_ = (reTrans.rcount >> 3);
                        int quad = (reTrans.rcount >> 2) & 1;
			int i;

                        if(quad == 0){
			        for(i = 0; i < 4; i++){
					if(input_available(&X)){

						switch(consumed_elements){
						case 0:
						        reTrans.mem[reTrans.select][row_][0] = port_read(&X);
							break;
						case 1:
							reTrans.mem[reTrans.select][row_][7] = port_read(&X);
							break;
						case 2:
							reTrans.mem[reTrans.select][row_][3] = port_read(&X);
							break;
						case 3:
							reTrans.mem[reTrans.select][row_][4] = port_read(&X);
							reTrans.rcount = reTrans.rcount + 4;
							break;
						default:
							break;
						}
					
						// if we consumed 4 elements, get out of for loop
						if(consumed_elements == 3)
						     i = 4;

						consumed_elements = (consumed_elements + 1) % 4;
				      	}
				}
                        }
                        else{
                                 for(i = 0; i < 4; i++){
                                        if(input_available(&X)){
                                                switch(consumed_elements){
                                                case 0:
                                                        reTrans.mem[reTrans.select][row_][1] = port_read(&X);
                                                        break;
                                                case 1:
                                                        reTrans.mem[reTrans.select][row_][6] = port_read(&X);
                                                        break;
                                                case 2:
                                                        reTrans.mem[reTrans.select][row_][2] = port_read(&X);
                                                        break;
                                                case 3:
                                                        reTrans.mem[reTrans.select][row_][5] = port_read(&X);
                                                        reTrans.rcount = reTrans.rcount + 4;
                                                        break;
                                                default:
							break;
                                                }

						// if we consumed 4 elements, get out of for loop
						if(consumed_elements == 3)
						  i = 4;

                                                consumed_elements = (consumed_elements + 1) % 4;

                                        }
                                }
                        }
                }
                // end of action #1
		                               

		// action #2
		if(reTrans.ccount > 0){
			int col = (64 - reTrans.ccount) >> 3;
			int row = (64 - reTrans.ccount) & 7; 	
			int k = reTrans.select ^ 1;
		
			reTrans.ccount = reTrans.ccount - 1;
#if 1
			port_write(&Y, reTrans.mem[k][row][col]); j++;
#endif

#if 0
Mailbox.pOutputBuffer[j] = reTrans.mem[k][row][col]; j++;
#endif

		}
		// end of action #2

		// action #3
		if(reTrans.ccount == 0 && reTrans.rcount == 64){
			reTrans.select = reTrans.select ^ 1;
			reTrans.ccount = 64;
			reTrans.rcount = 0;

		}
		// end of action #3
	}

#if 0
*Mailbox.pOutputReady = 14;
#endif

// Get timer value, find the elapsed time and stop 
timerValue = e_ctimer_get(E_CTIMER_1);
Mailbox.pTimer1[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_1);

}

void init(){

	// Init core enumerations
	me.coreID  = e_get_coreid();
	e_coords_from_coreid(me.coreID, &me.row, &me.col);
	//me.row     = me.row - E_FIRST_CORE_ROW;
	//me.col     = me.col - E_FIRST_CORE_COL;
	//me.corenum = me.row * E_COLS_IN_CHIP + me.col;
    me.corenum = me.row * e_group_config.group_cols + me.col;
	// we need an adjustment fore corenum because of corenum 12 being unused
	me.corenum--; // OJ: ??? will be negative on core 0

	// Initialize the mailbox shared buffer pointers
	Mailbox.pBase = (void *)  MAILBOX_ADDRESS;
	Mailbox.pGo = Mailbox.pBase + offsetof(mbox_t, go[0]);
	Mailbox.pReady = Mailbox.pBase + offsetof(mbox_t, ready[0]);
	Mailbox.pClocks = Mailbox.pBase + offsetof(mbox_t, clocks);

#if 0
	// ## For debugging ##
Mailbox.pOutputBuffer = Mailbox.pBase + offsetof(mbox_t, output_buffer[0]);
Mailbox.pOutputReady = Mailbox.pBase + offsetof(mbox_t, output_ready);
#endif

	Mailbox.pTimer0 = Mailbox.pBase + offsetof(mbox_t, timer0);
	Mailbox.pTimer1 = Mailbox.pBase + offsetof(mbox_t, timer1);

	me.count = 0;

	int i, j, k;
	for(i = 0; i < 2; i++)
	  for(j = 0; j < 8; j++)
	    for(k = 0; k < 8; k++)
	      reTrans.mem[i][j][k] = -1;

	// Init the global variables
	reTrans.rcount = 0;
	reTrans.ccount = 0;
	reTrans.select = 0;
	
	// Init the ports
	init_input_port(&X);
	init_output_port(&Y);

	// Set the port pointers of the actor struct
	reTrans.X = (me.coreID << 20) | (int) &X;
	reTrans.Y = (me.coreID << 20) | (int) &Y;

	reTrans.coreID = me.coreID;

	// Set the global actor pointer
	actors.reTrans = (me.coreID << 20) | (int) &reTrans;

	// Init the host-accelerator sync signals
	// Let the host know that we are ready (for sync)	
	Mailbox.pReady[me.corenum] = me.corenum;
}
