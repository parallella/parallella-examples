/*

	shuffleCol.c
	Süleyman Savas
	2013-07-09

*/

#include <stdlib.h>
#include <stdio.h>

#include "shuffle.h"
#include "e_lib.h"
#include "idct.h" 
#include "common_buffers.h"
#include "actors.h"

// Actor instantiation
shuffle_t shuffle;

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

	while(i < IN_BUFFER_SIZE)
	{
		int a, b, c, d, x, x2, x3, x4, x5, x6h, x6l, x7h, x7l;
		// action a0
		a = port_read(&X);
		b = port_read(&X);
		c = port_read(&X);
		d = port_read(&X);

		x4 = c;
		x5 = d;

#if 1
		port_write(&Y, a); i++;
		port_write(&Y, b); i++;
		// end of action a0
#endif 

#if 0
		Mailbox.pOutputBuffer[i] = a; i++;
		Mailbox.pOutputBuffer[i] = b; i++;
#endif

		// action a1
		x2 = port_read(&X);
		a = port_read(&X);
		x3 = port_read(&X);
		b = port_read(&X);
	
		int ah = a >> 8;
		int bh = b >> 8;
		int al = a & 255;
		int bl = b & 255;

		x6h = 181 * (ah + bh);
		x7h = 181 * (ah - bh);
		x6l = 181 * (al + bl) + 128;
		x7l = 181 * (al - bl) + 128;

#if 1
		port_write(&Y, x2); i++;	
		port_write(&Y, x3); i++;
		// end of action a1

		// action a2
		port_write(&Y, x4); i++;
		port_write(&Y, x5); i++;
		port_write(&Y, x6h + (x6l >> 8)); i++;
		port_write(&Y, x7h + (x7l >> 8)); i++;
		// end of action a2
#endif 

#if 0
		Mailbox.pOutputBuffer[i] = x2; i++;
		Mailbox.pOutputBuffer[i] = x3; i++;

		Mailbox.pOutputBuffer[i] = x4; i++;	
		Mailbox.pOutputBuffer[i] = x5; i++;	
		Mailbox.pOutputBuffer[i] = x6h + (x6l >> 8); i++;		
		Mailbox.pOutputBuffer[i] = x7h + (x7l >> 8); i++;
#endif


	}

#if 0
*Mailbox.pOutputReady = 11;
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
	
	// Init the ports
	init_input_port(&X);
	init_output_port(&Y);

	// Set the port pointers of the actor struct
	shuffle.X = (me.coreID << 20) | (int) &X;
	shuffle.Y = (me.coreID << 20) | (int) &Y;

	shuffle.coreID = me.coreID;

	// Set the global actor pointer
	actors.shuffleCol = (me.coreID << 20) | (int) &shuffle;

	// Init the host-accelerator sync signals
	// Let the host know that we are ready (for sync)	
	Mailbox.pReady[me.corenum] = 1;


}

