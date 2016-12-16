/*

	combine.h
	Süleyman Savas
	2013-07-08

*/

#ifndef __COMBINE_H__
#define __COMBINE_H__

#include "communication.h"

int count;

typedef struct{

	inputPort_t* X;
	outputPort_t* Y;
	unsigned int coreID;

	int row;
}combine_t;










#endif //__COMBINE_H__

