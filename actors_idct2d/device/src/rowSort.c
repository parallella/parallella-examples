/*

	rowSort.c
	Süleyman Savas

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "e_lib.h"
#include "idct.h" 
#include "common_buffers.h"
#include "rowSort.h"
#include "actors.h"
#include "communication.h"

// Actor instantiation
rowSort_t rowSort;

// IO ports
outputPort_t Y;

core_t me;

unsigned int timerValue = 0;

void init();

void main()
{
  // Configure the timers
 e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX); 

 // Start the timer (countdown from 0xFFFFFFFF)
 e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);
	int x0, x1, x2, x3, x5;
	int i = 0;
#if 0
int j = 0;
#endif
	// Initialize data structures - mainly target pointers
	init();

	// Wait for the connect actors signal
	while(*Mailbox.pConnectActors == 0);
	connect_actors();

	// Reset the connect actors signal to inform the host that actors are connected
	*Mailbox.pConnectActors = 0;

	// Wait for the trigger from the host
	while(Mailbox.pGo[me.corenum] == 0);

timerValue = e_ctimer_get(E_CTIMER_0);
Mailbox.pTimer0[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_0);

e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX); 
e_ctimer_start(E_CTIMER_1, E_CTIMER_CLK);
	while(i < IN_BUFFER_SIZE)
	{

		// Read x0, x1, x2, x3
		x0 = Mailbox.pInBuffer[i]; i++;
		x1 = Mailbox.pInBuffer[i]; i++;
		x2 = Mailbox.pInBuffer[i]; i++;
		x3 = Mailbox.pInBuffer[i]; i++;

		// Write x0 and read an input and write it directly to the output

		port_write(&Y, x0);
		port_write(&Y, Mailbox.pInBuffer[i]); i++;

#if 0
Mailbox.pOutputBuffer[j] = x0; j++;
Mailbox.pOutputBuffer[j] = Mailbox.pInBuffer[i - 1]; j++;
#endif

		// Read x5
		x5 = Mailbox.pInBuffer[i]; i++;

		// Write x2 and read an input and write it directly to the output
		port_write(&Y, x2);
		port_write(&Y, Mailbox.pInBuffer[i]); i++;

#if 0
Mailbox.pOutputBuffer[j] = x2; j++;
Mailbox.pOutputBuffer[j] = Mailbox.pInBuffer[i - 1]; j++;
#endif
		// write x1 and read an input and write it directly to the output
		port_write(&Y, x1);
		port_write(&Y, Mailbox.pInBuffer[i]); i++;
#if 0
Mailbox.pOutputBuffer[j] = x1; j++;
Mailbox.pOutputBuffer[j] = Mailbox.pInBuffer[i - 1]; j++;
#endif

		// Write x5 and x3
		port_write(&Y, x5);
		port_write(&Y, x3);

#if 0
Mailbox.pOutputBuffer[j] = x5; j++;
Mailbox.pOutputBuffer[j] = x3; j++;
#endif
	}

// Get timer value, find the elapsed time and stop 
timerValue = e_ctimer_get(E_CTIMER_1);
Mailbox.pTimer1[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_1);

}
	
void init()
{
    unsigned next_row, next_col;
	// Init core enumerations
	me.coreID  = e_get_coreid();
	e_coords_from_coreid(me.coreID, &me.row, &me.col);
    me.corenum = me.row * e_group_config.group_cols + me.col;
	//e_neighbor_id(E_NEXT_CORE, E_GROUP_WRAP, &next_row, &next_col);
	//me.coreIDn = next_row * e_group_config.group_cols + next_col;
	////e_neighbor_id(E_NEXT_CORE, E_GROUP_WRAP, (e_coreid_t *) &me.coreIDn);

	// Initialize the mailbox shared buffer pointers
	Mailbox.pBase = (void *) MAILBOX_ADDRESS;//(void*) SHARED_DRAM;
	Mailbox.pGo = Mailbox.pBase + offsetof(mbox_t, go[0]);
	Mailbox.pReady = Mailbox.pBase + offsetof(mbox_t, ready[0]);
	Mailbox.pClocks = Mailbox.pBase + offsetof(mbox_t, clocks);
	Mailbox.pInBuffer = Mailbox.pBase + offsetof(mbox_t, in_buffer[0]);
	Mailbox.pInBufferSize = Mailbox.pBase + offsetof(mbox_t, in_buffer_size);
	Mailbox.pConnectActors = Mailbox.pBase + offsetof(mbox_t, connectActors);
#if 0
	// Debug 
Mailbox.pOutputReady = Mailbox.pBase + offsetof(mbox_t, output_ready);
Mailbox.pOutputBuffer = Mailbox.pBase + offsetof(mbox_t, output_buffer);
#endif

	Mailbox.pTimer0 = Mailbox.pBase + offsetof(mbox_t, timer0);
	Mailbox.pTimer1 = Mailbox.pBase + offsetof(mbox_t, timer1);

	// initialize the port
	init_output_port(&Y);

	// Set the port pointer
	rowSort.Y = (me.coreID << 20) | (int) &Y;

	rowSort.coreID = me.coreID;

	// Set the global actor pointer
	actors.rowSort = (me.coreID << 20) | (int) &rowSort;

        // Init the host-accelerator sync signals
        Mailbox.pReady[me.corenum] = &me.mystate;

	return;
}

