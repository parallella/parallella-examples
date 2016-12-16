/*

	shift.h
	Süleyman Savas
	2013-07-09

*/

#ifndef __SHIFT_H__
#define __SHIFT_H__

#include "communication.h"

typedef struct{
	inputPort_t* X;
	outputPort_t* Y;

       unsigned int coreID;

}shift_t;






#endif // __SHIFT_H__
