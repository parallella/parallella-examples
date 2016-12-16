/*

	communication.c
	2013-07-04
	Süleyman Savas

*/

#include <e_common.h>

#include "communication.h"
#include "actors.h"

volatile actors_t actors 	SECTION(".shared_dram");
//int *ptr = 0x8f0004b0;

float port_read(inputPort_t* port){

	float temp;
	// Wait until the flag is set
	// which means there is an input
	while(!port->localFlag);

	// If we are here, it means there is input
	temp = port->buffer[0];

	// Reset the flag (consume the input)
	port->localFlag = 0; //FALSE
	*port->remoteFlag = 0;

	return temp;
}

void port_consume(inputPort_t* port){

	// Reset both local and remote flags (which means the input is consumed)
	port->localFlag = 0;
	*port->remoteFlag = 0;	// This is an access to the remote core memory

}


void port_write(outputPort_t* port, int value){
	// Wait until the flag is reset
	// which means the data on the port is consumed
  while(port->localFlag);	
	
	// If we are here, it means the data is consumed
	port->buffer[0] = value;

	// Set the flag which means there is data on this port now
	port->localFlag = 1;
	*port->remoteFlag = 1;

}

int input_available(inputPort_t* port){

	// If there is any input on the port, return true
	if(port->localFlag)
		return 1;
	else
		return 0;


}

void init_input_port(inputPort_t* port){

	port->localFlag = 0;
	// No need to initializce the remote flag because it will be initialized by the owner core


	// In the future the buffer size can be set in here
}

void init_output_port(outputPort_t* port){

	port->localFlag = 0;
	// No need to initializce the remote flag because it will be initialized by the owner core

	// In the future the buffer size can be set in here
}


unsigned int connect_actors(){
	// we use the coreID-s to get the global addresses

        // Connect the ports
 
	actors.rowSort->Y->buffer = ((actors.scale->coreID << 20) | (int) actors.scale->X->buffer);
        actors.rowSort->Y->remoteFlag = ((actors.scale->coreID << 20) | (int) &actors.scale->X->localFlag);
	actors.scale->X->remoteFlag = ((actors.rowSort->coreID << 20) | (int) &actors.rowSort->Y->localFlag);
	
//	return actors.scale->X->remoteFlag;
//	return (unsigned int) &actors.rowSort->Y->localFlag;
#ifdef FULL
        //idct1d - ROW
        actors.scale->Y->buffer = ((actors.combineRow->coreID << 20) | (int) actors.combineRow->X->buffer);
	actors.scale->Y->remoteFlag = ((actors.combineRow->coreID << 20) | (int) &actors.combineRow->X->localFlag);
	actors.combineRow->X->remoteFlag = ((actors.scale->coreID << 20) | (int) &actors.scale->Y->localFlag);

        actors.combineRow->Y->buffer = ((actors.shuffleFlyRow->coreID << 20) |  (int) actors.shuffleFlyRow->X->buffer);
        actors.combineRow->Y->remoteFlag = ((actors.shuffleFlyRow->coreID << 20) | (int) &actors.shuffleFlyRow->X->localFlag);
	actors.shuffleFlyRow->X->remoteFlag = ((actors.combineRow->coreID << 20) | (int) &actors.combineRow->Y->localFlag);

        actors.shuffleFlyRow->Y->buffer = ((actors.shuffleRow->coreID << 20) | (int) actors.shuffleRow->X->buffer);
        actors.shuffleFlyRow->Y->remoteFlag = ((actors.shuffleRow->coreID << 20) | (int) &actors.shuffleRow->X->localFlag);
	actors.shuffleRow->X->remoteFlag = ((actors.shuffleFlyRow->coreID << 20) | (int) &actors.shuffleFlyRow->Y->localFlag);

        actors.shuffleRow->Y->buffer = ((actors.finalRow->coreID << 20) | (int) actors.finalRow->X->buffer);
        actors.shuffleRow->Y->remoteFlag = ((actors.finalRow->coreID << 20) | (int) &actors.finalRow->X->localFlag);
	actors.finalRow->X->remoteFlag = ((actors.shuffleRow->coreID << 20) | (int) &actors.shuffleRow->Y->localFlag);


        //idct1d - COL
        actors.scaleCol->Y->buffer = ((actors.combineCol->coreID << 20) | (int) actors.combineCol->X->buffer);
        actors.scaleCol->Y->remoteFlag = ((actors.combineCol->coreID << 20) | (int) &actors.combineCol->X->localFlag);
	actors.combineCol->X->remoteFlag = ((actors.scaleCol->coreID << 20) | (int) &actors.scaleCol->Y->localFlag);

        actors.combineCol->Y->buffer = ((actors.shuffleFlyCol->coreID << 20) | (int) actors.shuffleFlyCol->X->buffer);
        actors.combineCol->Y->remoteFlag = ((actors.shuffleFlyCol->coreID << 20) | (int) &actors.shuffleFlyCol->X->localFlag);
	actors.shuffleFlyCol->X->remoteFlag = ((actors.combineCol->coreID << 20) | (int) &actors.combineCol->Y->localFlag);

        actors.shuffleFlyCol->Y->buffer = ((actors.shuffleCol->coreID << 20) | (int) actors.shuffleCol->X->buffer);
        actors.shuffleFlyCol->Y->remoteFlag = ((actors.shuffleCol->coreID << 20) | (int) &actors.shuffleCol->X->localFlag);
	actors.shuffleCol->X->remoteFlag = ((actors.shuffleFlyCol->coreID << 20) | (int) &actors.shuffleFlyCol->Y->localFlag);

        actors.shuffleCol->Y->buffer = ((actors.finalCol->coreID << 20) | (int) actors.finalCol->X->buffer);
        actors.shuffleCol->Y->remoteFlag = ((actors.finalCol->coreID << 20) | (int) &actors.finalCol->X->localFlag);
	actors.finalCol->X->remoteFlag = ((actors.shuffleCol->coreID << 20) | (int) &actors.shuffleCol->Y->localFlag);

        ////////////
        actors.finalRow->Y->buffer = ((actors.transpose->coreID << 20) | (int) actors.transpose->X->buffer);
        actors.finalRow->Y->remoteFlag = ((actors.transpose->coreID << 20) | (int) &actors.transpose->X->localFlag);
	actors.transpose->X->remoteFlag = ((actors.finalRow->coreID << 20) | (int) &actors.finalRow->Y->localFlag);

	actors.transpose->Y->buffer = ((actors.scaleCol->coreID << 20) | (int) actors.scaleCol->X->buffer);
	actors.transpose->Y->remoteFlag = ((actors.scaleCol->coreID << 20) |(int) &actors.scaleCol->X->localFlag);
	actors.scaleCol->X->remoteFlag = ((actors.transpose->coreID << 20) | (int) &actors.transpose->Y->localFlag);

        actors.finalCol->Y->buffer = ((actors.shift->coreID << 20) | (int) actors.shift->X->buffer);
        actors.finalCol->Y->remoteFlag = ((actors.shift->coreID << 20) | (int) &actors.shift->X->localFlag);
	actors.shift->X->remoteFlag = ((actors.finalCol->coreID << 20) | (int) &actors.finalCol->Y->localFlag);

        actors.shift->Y->buffer = ((actors.reTrans->coreID << 20) | (int) actors.reTrans->X->buffer);
        actors.shift->Y->remoteFlag = ((actors.reTrans->coreID << 20) | (int) &actors.reTrans->X->localFlag);
	actors.reTrans->X->remoteFlag = ((actors.shift->coreID << 20) | (int) &actors.shift->Y->localFlag);

 //       actors.reTrans->Y->buffer = ((actors.clip->coreID << 20) | (int) actors.clip->I->buffer);

        actors.reTrans->Y->buffer = ( actors.clip->I->buffer);
        actors.reTrans->Y->remoteFlag = ((actors.clip->coreID << 20) | (int) &actors.clip->I->localFlag);
	actors.clip->I->remoteFlag = ((actors.reTrans->coreID << 20) | (int) &actors.reTrans->Y->localFlag);


#endif

	return 5;
}
