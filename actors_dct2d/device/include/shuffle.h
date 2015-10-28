/*

	shuffle.h
	Süleyman Savas
	2013-07-08

*/

#ifndef __SHUFFLE_H__
#define __SHUFFLE_H__

#include "communication.h"

//int x4, x5, x6h, x7h, x6l, x7l;

typedef struct{

	inputPort_t* X;
	outputPort_t* Y;

       unsigned int coreID;

}shuffle_t;










#endif //__SHUFFLE_H__
