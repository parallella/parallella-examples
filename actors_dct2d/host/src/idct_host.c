/*
	
	idct_host.c
	Süleyman Savas
	2013-06-12

*/


#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/time.h>
#include <math.h>
#include <string.h>
#include "e-hal.h"

#include "common_buffers.h"
#include "actors.h"

#define offset 0x01000000 + 0x00000100 //(the extra 0x100 is for the actors


FILE *fo;
FILE *f_in;
FILE *f_signed;
FILE *f_out;
FILE *f_timer;
FILE *f_timer_raw;

int main(int argc, char *argv[])
{
	char buffer[10];
	int i, sz, result;

	e_epiphany_t Epiphany, *pEpiphany;
	e_mem_t      DRAM,     *pDRAM;
	unsigned int msize;
	unsigned int addr;

	pEpiphany = &Epiphany;
	pDRAM     = &DRAM;
	msize     = 0x00400000;

	fo = stderr;
	f_in = fopen("./ioFiles/idct2d_in_4m.txt", "r");
	f_signed = fopen("./ioFiles/signed.txt", "r");
	f_out = fopen("./ioFiles/out.txt", "w");
	f_timer = fopen("./ioFiles/timerData.txt", "w");
	f_timer_raw = fopen("./ioFiles/timerDataRaw.txt", "a");

	// Connect to device for communicating with the Epiphany system
	// Prepare device
	e_set_host_verbosity(H_D0);
	fprintf(fo,"Host verbosity set\n");
	e_init(NULL);
	fprintf(fo,"Device initialized\n");
	e_reset_system();
	fprintf(fo,"System is reset\n");


	if (e_alloc(pDRAM, offset, msize))
	{
		fprintf(fo, "\nERROR: Can't allocate Epiphany DRAM!\n\n");
		exit(1);
	}

        fprintf(fo, "pDRAM: 0x%x \n", pDRAM);


#ifndef FULL
	if (e_open(pEpiphany, 0, 0, 1, 2))
#else
	if (e_open(pEpiphany, 0, 0, 4, 4))
#endif
	{
		fprintf(fo, "\nERROR: Can't establish connection to Epiphany device!\n\n");
		exit(1);
	}

	//Let's clean the memory for ready messages
	for(i = 0; i < NUMBER_OF_CORES; i++){
		Mailbox.ready[i] = 0;
		Mailbox.go[i] = 0;
		Mailbox.timer0[i] = 0;
		Mailbox.timer1[i] = 0;
	}
	sz = sizeof(Mailbox.ready);
	addr = offsetof(mbox_t, ready[0]);// + 4;
	e_write(pDRAM, 0, 0, addr, Mailbox.ready, sz);

	fprintf(fo, "Ready messages are reset. \n");

	sz = sizeof(Mailbox.go);
	addr = offsetof(mbox_t, go[0]);
	e_write(pDRAM, 0, 0, addr, Mailbox.go, sz);

	fprintf(fo, "Go messages are reset. \n");

	sz = sizeof(Mailbox.timer0);
	addr = offsetof(mbox_t, timer0);
	e_write(pDRAM, 0, 0, addr, Mailbox.timer0, sz);
	
	fprintf(fo, "Timer0 array is reset. \n");

	sz = sizeof(Mailbox.timer1);
	addr = offsetof(mbox_t, timer1);
	e_write(pDRAM, 0, 0, addr, Mailbox.timer1, sz);
	
	fprintf(fo, "Timer0 array is reset. \n");
       
	Mailbox.connectActors = 0;
	addr = offsetof(mbox_t, connectActors);// + 4;
	sz = sizeof(Mailbox.connectActors);
	e_write(pDRAM, 0, 0, addr, &Mailbox.connectActors, sz);

	fprintf(fo, "connectActors is reset \n");

	Mailbox.in_buffer_size = IN_BUFFER_SIZE;
        addr = offsetof(mbox_t, in_buffer_size);// + 4;
        sz = sizeof(Mailbox.in_buffer_size);
        e_write(pDRAM, 0, 0, addr, &Mailbox.in_buffer_size, sz);

	fprintf(fo, "in buffer size is set \n");

	for(i = 0; i<IN_BUFFER_SIZE; i++)
		Mailbox.in_buffer[i] = 0;
	
	sz = sizeof(Mailbox.in_buffer);
	addr = offsetof(mbox_t, in_buffer[0]);
	e_write(pDRAM, 0, 0, addr, Mailbox.in_buffer, sz);

	fprintf(fo, "in_buffer is reset \n");

	for(i = 0; i<OUT_BUFFER_SIZE; i++)
		Mailbox.output_buffer[i] = 0;

	sz = sizeof(Mailbox.output_buffer);
	addr = offsetof(mbox_t, output_buffer);
	e_write(pDRAM, 0, 0, addr, Mailbox.output_buffer, sz);

	fprintf(fo, "out buffer is reset \n");

	// Reset output_ready
	Mailbox.output_ready = 0;
	sz = sizeof(Mailbox.output_ready);
	addr = offsetof(mbox_t, output_ready);
	e_write(pDRAM, 0, 0, addr, &Mailbox.output_ready, sz);

	fprintf(fo, "output ready is reset \n");

        Mailbox.signed_buffer_size = SIGNED_BUFFER_SIZE;
        addr = offsetof(mbox_t, signed_buffer_size);
        sz = sizeof(Mailbox.signed_buffer_size);
        e_write(pDRAM, 0, 0, addr, &Mailbox.signed_buffer_size, sz);

	fprintf(fo, "signed buffer size is set \n");

        // Read the inputs from the file and write to the mailbox so the Rowsort can read it
        fprintf(fo, "Reading in.txt\n");
        for(i = 0; i < Mailbox.in_buffer_size; i++){
	  fscanf(f_in, "%d", &Mailbox.in_buffer[i]);   
        }

	sz = sizeof(Mailbox.in_buffer);
	addr = offsetof(mbox_t, in_buffer[0]);
	e_write(pDRAM, 0, 0, addr, Mailbox.in_buffer, sz);

	fprintf(fo, "in_buffer is filled with data \n");

        fclose(f_in);

        fprintf(fo, "Reading signed.txt\n");
        for(i = 0; i < SIGNED_BUFFER_SIZE; i++){
	  fscanf(f_signed, "%d", &Mailbox.signed_buffer[i]);
        }

        addr = offsetof(mbox_t, signed_buffer[0]);// + 4;
        sz = sizeof(Mailbox.signed_buffer);
        e_write(pDRAM, 0, 0, addr, Mailbox.signed_buffer, sz);

	fprintf(fo, "signed_buffer is filled with data \n");

        fclose(f_signed);


	// Starting to load the cores 
	
	fprintf(fo, "\nLoading the cores \n");
	fprintf(fo, "ephy base 0x%x, phy base: 0x%x\n", (unsigned int) pDRAM->ephy_base, (unsigned int)pDRAM->phy_base);

        fprintf(fo,"\nHere are the definitions:\nsuccessfull: %d\nfailed: %d\n\n", E_OK, E_ERR);

	result = e_load("rowSort.elf", pEpiphany, 0, 0, E_FALSE);
	fprintf(fo,"rowsort load result: %d\n", result);
	//e_start(pEpiphany, 0, 0);	

	result = e_load("scale.elf", pEpiphany, 0, 1, E_FALSE);
	fprintf(fo,"scaleRow load result: %d\n", result);

	/* 
	placement of the cores on the chip
	1- 2- 3- 4
	8- 7- 6- 5
	9-10-11-12
	  15-14-13
	*/

#ifdef FULL
        result = e_load("reTrans.elf", pEpiphany, 3, 2, E_FALSE);
        fprintf(fo,"reTrans load result: %d\n", result);

	result = e_load("shift.elf", pEpiphany, 3, 3, E_FALSE);
        fprintf(fo,"shift load result: %d\n", result);

        result = e_load("clip.elf", pEpiphany, 3, 1, E_FALSE);
        fprintf(fo,"clip load result: %d\n", result);
 
	result = e_load("finalCol.elf", pEpiphany, 2, 3, E_FALSE);
        fprintf(fo,"finalCol load result: %d\n", result);

	result = e_load("combineRow.elf", pEpiphany, 0, 2, E_FALSE);
	fprintf(fo,"combineRow load result: %d\n", result);

	result = e_load("shuffleFlyRow.elf", pEpiphany, 0, 3, E_FALSE);
	fprintf(fo,"shuffleFlyRow load result: %d\n", result);

	result = e_load("shuffleRow.elf", pEpiphany, 1, 3, E_FALSE);
	fprintf(fo,"shuffleRow load result: %d\n", result);

	result = e_load("finalRow.elf", pEpiphany, 1, 2, E_FALSE);
	fprintf(fo,"finalRow load result: %d\n", result);

	result = e_load("transpose.elf", pEpiphany, 1, 1, E_FALSE);
	fprintf(fo,"transpose load result: %d\n", result);

	result = e_load("scaleCol.elf", pEpiphany, 1, 0, E_FALSE);
	fprintf(fo,"scaleCol load result: %d\n", result);

	result = e_load("combineCol.elf", pEpiphany, 2, 0, E_FALSE);
	fprintf(fo,"combineCol load result: %d\n", result);

	result = e_load("shuffleFlyCol.elf", pEpiphany, 2, 1, E_FALSE);
	fprintf(fo,"shuffleFlyCol load result: %d\n", result);

        result = e_load("shuffleCol.elf", pEpiphany, 2, 2, E_FALSE);
        fprintf(fo,"shuffleCol load result: %d\n", result);

#endif

	e_start(pEpiphany, 0, 0);
	e_start(pEpiphany, 0, 1);
#ifdef FULL
	e_start(pEpiphany, 0, 2);
	e_start(pEpiphany, 0, 3);
	e_start(pEpiphany, 1, 3);
	e_start(pEpiphany, 1, 2);
	e_start(pEpiphany, 1, 1);
	e_start(pEpiphany, 1, 0);
	e_start(pEpiphany, 2, 0);
	e_start(pEpiphany, 2, 1);
	e_start(pEpiphany, 2, 2);
	e_start(pEpiphany, 2, 3);
	e_start(pEpiphany, 3, 3);
	e_start(pEpiphany, 3, 2);
	e_start(pEpiphany, 3, 1);
#endif

	fprintf(fo, "Loaded all cores\n");

	fprintf(fo, "Waiting for the ready message from all cores\n");
	int wait = 1;
	sz = sizeof(Mailbox.ready);
	fprintf(fo, "Mailbox, ready array has the size : %d\n", sz/sizeof(int));
	addr = offsetof(mbox_t,  ready[0]);// + 4;

	int tempFlag[NUMBER_OF_CORES];
	for(i = 0; i < NUMBER_OF_CORES; i++)
		tempFlag[i] = 0;

	//	fprintf(fo, "address of ready array: %x\n", addr);
	int j;	
	// here we need to create the actor-network
	// First wait for ready message from all cores
	while(wait == 1){
		e_read(pDRAM, 0, 0, addr, Mailbox.ready, sz);
		wait = 0;
		for(i=0; i<NUMBER_OF_CORES; i++)
		{
			if(Mailbox.ready[i] == 0)
				wait = 1;
			else if(tempFlag[i]  == 0){
				fprintf(fo, "Received ready msg from core %u, ready value: 0x%x\n", i, (unsigned int) Mailbox.ready[i]);
				tempFlag[i] = 1;
			}
		}		
	}

	// All cores are ready, let's connect them
	fprintf(fo, "Received ready signal from all cores, now we should connect them \n");

	// Trigger the first core to connect the actors
	Mailbox.connectActors = 1;
	addr = offsetof(mbox_t, connectActors);// + 4;
	sz = sizeof(Mailbox.connectActors);
	e_write(pDRAM, 0, 0, addr, &Mailbox.connectActors, sz);
	fprintf(fo, "\nTriggered the actor connection. \n");

	// Wait until the core resets the connect actors flag
	while(Mailbox.connectActors == 1){
		e_read(pDRAM, 0, 0, addr, &Mailbox.connectActors, sz);
	}

	//###############This part is for debugging###############
//Mailbox.connectActors = 1;
//addr = offsetof(mbox_t, connectActors);// + 4;
//sz = sizeof(Mailbox.connectActors);
//e_write(pDRAM, 0, 0, addr, &Mailbox.connectActors, sz);
	// ################## End of debug part ###############

	fprintf(fo, "Receieved actors connected signal :%d, sending the GO\n", Mailbox.connectActors);

	// Trigger the cores
	for(i=0; i<NUMBER_OF_CORES; i++)
		Mailbox.go[i] = 1;

	addr = offsetof(mbox_t, go);
	sz = sizeof(Mailbox.go);
	e_write(pDRAM, 0, 0, addr, Mailbox.go, sz);

	fprintf(fo, "GO signal is sent...to the address: %d \n\n", addr);

	fprintf(fo, "Waiting for the outputs\n");


	// ########## Debuggin Part ###################
/*
addr = offsetof(mbox_t, connectActors);
sz = sizeof(Mailbox.connectActors);
while(Mailbox.connectActors == 0){
e_read(pDRAM, 0, 0, addr, &Mailbox.connectActors, sz);
}
	fprintf(fo, "wrote to 0x%x \n", Mailbox.connectActors);
*/
	// ########### end of debug part #############



	// Wait for the last core to send the outputs
	//while(Mailbox.go[1] != 1);

/*
	addr = offsetof(mbox_t, in_buffer);// + 4;
	sz = sizeof(Mailbox.in_buffer);
	while(Mailbox.in_buffer[0] == 123){
		e_read(pDRAM, 0, 0, addr, Mailbox.in_buffer, sz);
	}
	fprintf(fo, "Writing the outputs to a file\n");
	// Outputs are served, lets write them to the file
	for(i=0; i<8; i++){
		fprintf(f_out, "%d\n", Mailbox.output_buffer[i]);
		fprintf(fo, "Input buffer[%d]: 0x%x\n",i, Mailbox.in_buffer[i]);
	}
*/


	// Wait for the outputs
	addr = offsetof(mbox_t, output_ready);
	sz = sizeof(Mailbox.output_ready);
	while(!Mailbox.output_ready){
		e_read(pDRAM, 0, 0, addr, &Mailbox.output_ready, sz);
		
	}

	/* DEBUG *//*
	int _temp = 0;
	while(1){
	  if(_temp != Mailbox.output_ready)
	    fprintf(fo, "output_ready : %d\n", Mailbox.output_ready);

	  e_read(pDRAM, 0, 0, addr, &Mailbox.output_ready, sz);
	  _temp = Mailbox.output_ready;
	}
		   *//*END OF DEBUG */

	fprintf(fo, "output_ready message is received. %d \n", Mailbox.output_ready);

	fprintf(fo, "waiting for the timer data \n");

	int wait_timer = 1;
	addr = offsetof(mbox_t, timer0);
	sz = sizeof(Mailbox.timer0);
	while(wait_timer){
	  e_read(pDRAM, 0, 0, addr, Mailbox.timer0, sz);
	  
	  wait_timer = 0;

	  for(i = 0; i < NUMBER_OF_CORES; i++)
	    if(Mailbox.timer0[i] == 0)
	      wait_timer = 1;

	  if(Mailbox.timer0[12] < 10000)
	    wait_timer = 1;
	}

	wait_timer = 1;
	addr = offsetof(mbox_t, timer1);
	sz = sizeof(Mailbox.timer1);
	while(wait_timer){
	  e_read(pDRAM, 0, 0, addr, Mailbox.timer1, sz);
	  
	  wait_timer = 0;

	  for(i = 0; i < NUMBER_OF_CORES; i++)
	    if(Mailbox.timer1[i] == 0)
	      wait_timer = 1;
	}


	fprintf(f_timer,"The structure is serpentine, array indices do not follow the actor order.\n\n");
	fprintf(f_timer,"Timer 0 - Setup time \n\n");
	for(i = 0; i < NUMBER_OF_CORES; i++){
	  fprintf(f_timer, "Timer0[%d] value = %u\n", i, Mailbox.timer0[i]);
	  fprintf(f_timer_raw, "%u\n", Mailbox.timer0[i]);
	}
	fprintf(f_timer,"\n\nTimer 1 - Computation + communication\n\n");
	for(i = 0; i < NUMBER_OF_CORES; i++){;
	  fprintf(f_timer, "Timer1[%d] value = %u\n", i, Mailbox.timer1[i]); 
	  fprintf(f_timer_raw, "%u\n", Mailbox.timer1[i]);
	}

	addr = offsetof(mbox_t, output_buffer);
	sz = sizeof(Mailbox.output_buffer);
	fprintf(fo, "Reading output \n");
	e_read(pDRAM, 0, 0, addr, Mailbox.output_buffer, sz);

	
	for(i=0; i<OUT_BUFFER_SIZE; i++){
	  fprintf(f_out, "%d\n", Mailbox.output_buffer[i]);
	  //fprintf(fo, "Output %d :  %d \n", i, Mailbox.output_buffer[i]);
	}
	fprintf(fo, "***End of run***\n");

	fclose(f_timer);
	fclose(f_timer_raw);
	fclose(f_out);
	fclose(fo);

	// Close connection to device
	if (e_close(pEpiphany))
	{
		fprintf(fo, "\nERROR: Can't close connection to Epiphany device!\n\n");
		exit(1);
	}
	if (e_free(pDRAM))
	{
		fprintf(fo, "\nERROR: Can't release Epiphany DRAM!\n\n");
		exit(1);
	}

	e_finalize();

	return 1;

}



