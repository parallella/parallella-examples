/* 
	idct.h
	2013-07-04
	Süleyman Savas
*/

#ifndef __COMMUNICATION_H__
#define __COMMUNICATION_H__

typedef struct {
  volatile float buffer[1];
  //float buffer[1];
  volatile int localFlag;
  //int localFlag;
  volatile int *remoteFlag;
  //int *remoteFlag;
}inputPort_t;

//Output port keeps pointers to an input port
typedef struct {
	volatile float *buffer;
  //float *buffer;
  	volatile int *remoteFlag;
  //int *remoteFlag;
  	volatile int localFlag;
  //int localFlag;
}outputPort_t;

float port_read(inputPort_t*);

void port_consume(inputPort_t*);

void port_write(outputPort_t*, int);

int input_available(inputPort_t*);

void init_input_port(inputPort_t*);

void init_output_port(outputPort_t*);

unsigned int connect_actros();





#endif
