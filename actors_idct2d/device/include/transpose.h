/*

	transpose.h
	Süleyman Savas
	2013-07-09

*/

#ifndef __TRANSPOSE_H__
#define __TRANSPOSE_H__

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
}transpose_t;










#endif //__TRANSPOSE_H__
