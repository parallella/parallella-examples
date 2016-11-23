/*

	combine.c
	Süleyman Savas
	2013-07-08

*/

#include <stdlib.h>
#include <stdio.h>

#include "combine.h"
#include "e_lib.h"
#include "idct.h" 
#include "common_buffers.h"
#include "actors.h"

// Actor instantiation
combine_t combine;

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

	int i = 0;

	// wait for the go (which means actors are connected)
	while(Mailbox.pGo[me.corenum] == 0);

timerValue = e_ctimer_get(E_CTIMER_0);
Mailbox.pTimer0[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_0);

e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX); 
e_ctimer_start(E_CTIMER_1, E_CTIMER_CLK);

	while(i < IN_BUFFER_SIZE)   //temporary value 64
	{
		int o, y0, y1, a, b, c, d, y0out, y1out;

		bool s = (count == 0);

		if(combine.row){
			if(s)
				o = 128;
			else
				o = 0;	
		}
		else{
			if(s)
				o = 65536;
			else
				o = 4;	
		}

	
		a = port_read(&X);
		b = port_read(&X);
		c = port_read(&X);
		d = port_read(&X);

		y0 = a + d + o;
		y1 = b - c + o;

		if(combine.row){
			y0out = y0;
			y1out = y1;
		}
		else
		{
			y0out = (y0 >> 3);
			y1out = (y1 >> 3);
		}
#if 1
		port_write(&Y, y0out); i++;
		port_write(&Y, y1out); i++;
#endif

#if 0
// ## Debug ##
Mailbox.pOutputBuffer[i] = y0out; i++;
Mailbox.pOutputBuffer[i] = y1out; i++;
// ## End of Debug ##
#endif
		count = (count + 1) & 3;
	}

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


	// Init ports
	init_input_port(&X);
	init_output_port(&Y);

	// Set the port pointers of the actor struct
	combine.X = (me.coreID << 20) | (int) &X;
	combine.Y = (me.coreID << 20) | (int) &Y;

	// This combine actor works on rows
	combine.row = 1;

	combine.coreID = me.coreID;

	// Set the global actor pointer
	actors.combineRow = (me.coreID << 20) | (int) &combine;


	count = 0;

	// Init the host-accelerator sync signals
	// Let the host know that we are ready (for sync)
	Mailbox.pGo[me.corenum] = 0;	
	Mailbox.pReady[me.corenum] = Mailbox.pReady;//me.corenum;

}
