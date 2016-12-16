/*

	reTrans.h
	Süleyman Savas
	2013-07-09

*/

#ifndef __RETRANS_H__
#define __RETRANS_H__

#include "communication.h"

typedef struct{
	inputPort_t* X;
	outputPort_t* Y;

	int rcount;
	int ccount;
	int select;

       unsigned int coreID;

	//int mem[2][8][8] SECTION(".data_bank2");
	int mem[2][8][8];
}reTrans_t;




#endif // __RETRANS_H__
