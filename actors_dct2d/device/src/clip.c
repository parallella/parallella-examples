/*

	clip.c
	Süleyman Savas
	2013-07-09
	
	Limit pixel value to either [0,255] or [-255,255]
*/

#include <stdlib.h>
#include <stdio.h>

#include "e_ctimers.h"
#include "clip.h"
#include "e_lib.h"
#include "idct.h" 
#include "common_buffers.h"
#include "actors.h"

// Actor instantiation
clip_t clip;

// Port instantiation
//inputPort_t SIGNED;
inputPort_t I;
//outputPort_t O;

// Core struct instantiaton
core_t me;

unsigned int timerValue = 0;

void init();

void main(){

 e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX); 
 e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);

	init();

	// wait for the go (which means actors are connected)
	while(Mailbox.pGo[me.corenum] == 0);


timerValue = e_ctimer_get(E_CTIMER_0);
Mailbox.pTimer0[me.corenum] = E_CTIMER_MAX - timerValue;
e_ctimer_stop(E_CTIMER_0);

  // Timer functions 1
  e_ctimer_set(E_CTIMER_1, E_CTIMER_MAX);
  e_ctimer_start(E_CTIMER_1, E_CTIMER_CLK);

	int j = 0;	
	int signed_counter = 0;

	// Run until there is no input left
	while(j < IN_BUFFER_SIZE)
	{
		//action read_signed
		if(clip.count < 0){

			//clip.sflag = port_read(&SIGNED);
			clip.sflag = Mailbox.pSignedBuffer[signed_counter++];
			clip.count = 63;
		} // end of action read_signed
		else { // action limit


			int i = port_read(&I);	


			if(i > 255){
#if 0
			  port_write(&O, 255); j++;
#endif

#if 1
Mailbox.pOutputBuffer[j] = 255; j++;
#endif
// j++;
			}
			else if(clip.sflag == 0 && i < 0){
#if 0
			  port_write(&O, 0); j++;
#endif

#if 1
Mailbox.pOutputBuffer[j] = 0; j++;
#endif
//j++;
			}
			else if(i < -255){
#if 0
			  port_write(&O, -255); j++;
#endif

#if 1
Mailbox.pOutputBuffer[j] = -255; j++;
#endif
//j++;
			}
			else{
#if 0
			  port_write(&O, i); j++;
#endif

#if 1
Mailbox.pOutputBuffer[j] = i; j++;
#endif
//j++;
			}

			clip.count = clip.count - 1;	
		}
		
	}

	timerValue = e_ctimer_get(E_CTIMER_1);
	Mailbox.pTimer1[me.corenum] = E_CTIMER_MAX - timerValue;
#if 1
	*Mailbox.pOutputReady = 1;
#endif
	
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
	// corenum 12 is empty because of our structure
// hence this core gets num 13 but it should be 12
	me.corenum--; // OJ ??? will be negative on core 0

	// Initialize the mailbox shared buffer pointers
	Mailbox.pBase = (void *) MAILBOX_ADDRESS;
	Mailbox.pGo = Mailbox.pBase + offsetof(mbox_t, go[0]);
	Mailbox.pReady = Mailbox.pBase + offsetof(mbox_t, ready[0]);
	Mailbox.pClocks = Mailbox.pBase + offsetof(mbox_t, clocks);

	Mailbox.pSignedBuffer = Mailbox.pBase + offsetof(mbox_t, signed_buffer[0]);
	Mailbox.pSignedBufferSize = Mailbox.pBase + offsetof(mbox_t, signed_buffer_size);


	Mailbox.pOutputReady = Mailbox.pBase + offsetof(mbox_t, output_ready);	
	Mailbox.pOutputBuffer = Mailbox.pBase + offsetof(mbox_t, output_buffer[0]);

	Mailbox.pTimer0 = Mailbox.pBase + offsetof(mbox_t, timer0);
	Mailbox.pTimer1 = Mailbox.pBase + offsetof(mbox_t, timer1);

	me.count = 0;

	// Init the global variables
	clip.count = -1;
	clip.coreID = me.coreID;

	// Init the ports
	//init_input_port(&SIGNED);
	init_input_port(&I);
	//init_output_port(&O);

	// Set the port pointers of the actor struct
	//clip.SIGNED = &SIGNED;
	clip.I = (me.coreID << 20) | (int) &I;
	//clip.O = &O;

	// Set the global actor pointer
	actors.clip = (me.coreID << 20) | (int) &clip;

	// Init the host-accelerator sync signals
	// Let the host know that we are ready (for sync)	
	Mailbox.pReady[me.corenum] = 3;

}
