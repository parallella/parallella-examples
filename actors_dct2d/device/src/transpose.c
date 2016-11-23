/*

	transpose.c
	Süleyman Savas
	2013-07-09

*/

#include <stdlib.h>
#include <stdio.h>

#include "transpose.h"
#include "e_lib.h"
#include "idct.h" 
#include "common_buffers.h"
#include "actors.h"

// Actor instantiation
transpose_t transpose;

// Port instantiation
inputPort_t X;
outputPort_t Y;

// Core struct instantiaton
core_t me;

unsigned int timerValue = 0;

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
		if(transpose.rcount < 64){

			int row = (transpose.rcount >> 3);
			int quad = (transpose.rcount >> 2) & 1;
			int i;
	
			if(quad == 0){

				for(i = 0; i < 4; i++){

					if(input_available(&X)){

						switch(consumed_elements){
						case 0:
							transpose.mem[transpose.select][row][0] = port_read(&X);
							break;
						case 1:
							transpose.mem[transpose.select][row][7] = port_read(&X);
							break;
						case 2:
							transpose.mem[transpose.select][row][3] = port_read(&X);
							break;
						case 3:
							transpose.mem[transpose.select][row][4] = port_read(&X);
							transpose.rcount = transpose.rcount + 4;
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
                                                        transpose.mem[transpose.select][row][1] = port_read(&X);
                                                        break;
                                                case 1:
                                                        transpose.mem[transpose.select][row][6] = port_read(&X);
                                                        break;
                                                case 2:
                                                        transpose.mem[transpose.select][row][2] = port_read(&X);
                                                        break;
                                                case 3:
                                                        transpose.mem[transpose.select][row][5] = port_read(&X);
                                                        transpose.rcount = transpose.rcount + 4;
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
		if(transpose.ccount > 0){


			int a, b;
			int col = (64 - transpose.ccount) >> 3;
			int pair = ((64 - transpose.ccount) >> 1) & 3;
			int k = transpose.select ^ 1;

			if(pair == 0){
				a = 0;
				b = 4;
			}
			else if(pair == 1){
				a = 2;
				b = 6;
			}
			else if(pair == 2){
				a = 1;
				b = 7;
			}
			else{
				a = 5;
				b = 3;
			}

#if 1
			port_write(&Y, transpose.mem[k][a][col]); j++;
			port_write(&Y, transpose.mem[k][b][col]); j++;
#endif



#if 0
			// DEBUG
			Mailbox.pOutputBuffer[j] = transpose.mem[k][a][col]; j++;
			Mailbox.pOutputBuffer[j] = transpose.mem[k][b][col]; j++;
#endif

			transpose.ccount = transpose.ccount - 2;


		}
		// end of action #2

		// action #3
		if(transpose.ccount == 0 && transpose.rcount == 64){
			transpose.select = transpose.select ^ 1;
			transpose.ccount = 64;
			transpose.rcount = 0;

		}
		// end of action #3

	}
#if 0		
*Mailbox.pOutputReady = 7;
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
	
	// Init the global variables
	transpose.rcount = 0;
	transpose.ccount = 0;
	transpose.select = 0;

	// Init the ports
	init_input_port(&X);
	init_output_port(&Y);

	// Set the port pointers of the actor struct
	transpose.X = (me.coreID << 20) | (int) &X;
	transpose.Y = (me.coreID << 20) | (int) &Y;

	transpose.coreID = me.coreID;

	// Set the global actor pointer
	actors.transpose = (me.coreID << 20) | (int) &transpose;

	// Init the host-accelerator sync signals
	// Let the host know that we are ready (for sync)	
	Mailbox.pReady[me.corenum] = 1;
}
