/*

	scale.c
	Süleyman Savas

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "e_lib.h"
#include "idct.h" 
#include "common_buffers.h"
#include "scale.h"
#include "actors.h"


// Actor
scale_t scale;

// IO ports
inputPort_t X;
#ifdef FULL
outputPort_t Y;
#endif

core_t me;

unsigned int timerValue = 0;

void init();

int W0[4];
int W1[4];
int ww0;
int ww1;
int index0;

void main()
{
  // Configure the timers
 e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX); 

 // Start the timer (countdown from 0xFFFFFFFF)
 e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);

	init();
	int i = 0;
	int a, b;
	int w0, w1;

	// Wait until we get the go message from the host
	while(Mailbox.pGo[me.corenum] == 0); 

timerValue = e_ctimer_get(E_CTIMER_0);
Mailbox.pTimer0[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_0);

e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX); 
e_ctimer_start(E_CTIMER_1, E_CTIMER_CLK);
	// Run continuously
	while(i < (IN_BUFFER_SIZE * 2))//temporary value 128
	{
	  w0 = ww0;
	  w1 = ww1;
		index0 = (index0 + 1) & 3;

		ww0 = W0[index0];
		ww1 = W1[index0];

		a = port_read(&X);
		b = port_read(&X);

// For full version we need to change the following line to #ifdef FULL
#if 1
		port_write(&Y, a * w0); i++;
		port_write(&Y, a * w1); i++;
		port_write(&Y, b * w0); i++;
		port_write(&Y, b * w1); i++;
#endif

#if 0
		// Send the outputs to the host
		Mailbox.pOutputBuffer[i] = a * w0; i++;
		Mailbox.pOutputBuffer[i] = a * w1; i++;
		Mailbox.pOutputBuffer[i] = b * w0; i++;
		Mailbox.pOutputBuffer[i] = b * w1; i++;
#endif
	}
	
// Get timer value, find the elapsed time and stop 
timerValue = e_ctimer_get(E_CTIMER_1);
Mailbox.pTimer1[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_1);
}

void init()
{
	// Init core enumerations
	me.coreID  = e_get_coreid();
	e_coords_from_coreid(me.coreID, &me.row, &me.col);
	//me.row     = me.row - E_FIRST_CORE_ROW;
	//me.col     = me.col - E_FIRST_CORE_COL;
    me.corenum = me.row * e_group_config.group_cols + me.col;
	//me.corenum = me.row * E_COLS_IN_CHIP + me.col;
	//me.coreIDn = me.coreID;
	//e_neighbor_id((e_coreid_t *) &me.coreIDn, E_NEXT_CORE, E_CHIP_WRAP);

	// Initialize the mailbox shared buffer pointers
	Mailbox.pBase = (void *)  MAILBOX_ADDRESS;
	Mailbox.pGo = Mailbox.pBase + offsetof(mbox_t, go[0]);
	Mailbox.pReady = Mailbox.pBase + offsetof(mbox_t, ready[0]);
	Mailbox.pClocks = Mailbox.pBase + offsetof(mbox_t, clocks);

#if 0
	Mailbox.pOutputBuffer = Mailbox.pBase + offsetof(mbox_t, output_buffer[0]);
	Mailbox.pOutputReady = Mailbox.pBase + offsetof(mbox_t, output_ready);
#endif

	Mailbox.pTimer0 = Mailbox.pBase + offsetof(mbox_t, timer0);
	Mailbox.pTimer1 = Mailbox.pBase + offsetof(mbox_t, timer1);

	// Init the ports
	init_input_port(&X);

	// Set the port pointer, the address must be global
	scale.X = (me.coreID << 20) | (int) &X;

#ifdef FULL
	init_output_port(&Y);
	scale.Y = (me.coreID << 20) | (int) &Y;
#endif

	scale.coreID = me.coreID;

	// Set the global actor pointer(don't forget to use global address)
	actors.scale = (me.coreID << 20) | (int) &scale;
	

	me.count = 0;

	// Coefficients
	W0[0] = 2048;	W0[1] = 2676;	W0[2] = 2841;	W0[3] = 1609;
	
	W1[0] = 2048;	W1[1] = 1108;	W1[2] = 565;	W1[3] = 2408;

	ww0 = W0[0];
	ww1 = 2048;

	index0 = 0;

	// Init the host-accelerator sync signals
	Mailbox.pReady[me.corenum] = &me.mystate;
	
	return;
}
