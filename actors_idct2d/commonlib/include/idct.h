/* 
	idct.h
	2013-06-10
	Süleyman Savas
*/

#ifndef __IDCT_H__
#define __IDCT_H__

#ifdef FULL
#define NUMBER_OF_CORES 15
#else
#define NUMBER_OF_CORES 2
#endif

#define IN_BUFFER_SIZE	64
#define SIGNED_BUFFER_SIZE 10
#define OUT_BUFFER_SIZE IN_BUFFER_SIZE

#define  PACKED __attribute__((packed))
typedef struct {
	int    coreID;
	int    corenum;
	unsigned int    row;
	unsigned int    col;
	int    coreIDn;

	int    mystate;

	int    count;
} core_t;

typedef struct {
	int	go[NUMBER_OF_CORES]; // 
	int	in_buffer[IN_BUFFER_SIZE];  // The size is temporary
	int signed_buffer[SIGNED_BUFFER_SIZE];
	int	output_buffer[OUT_BUFFER_SIZE];
	int ready[NUMBER_OF_CORES];      // Core is ready after init
	int clocks;      // Cycle count
	int	in_buffer_size;
	int signed_buffer_size;	
	int	connectActors;
    int	output_ready;

  unsigned int timer0[NUMBER_OF_CORES];
  unsigned int timer1[NUMBER_OF_CORES];
  
} PACKED mbox_t;


typedef struct {
	void*	pBase;
	int*	pGo;
	int*	pInBuffer;
	int*	pSignedBuffer;
	int*	pOutputBuffer;
	int*	pReady;
	int*	pClocks;
	int*	pInBufferSize;
	int*	pSignedBufferSize;
	int*	pConnectActors;
	int*	pOutputReady;

  unsigned int* pTimer0;
  unsigned int* pTimer1;
} mbox_ptr_t;


#endif //__IDCT_H__
