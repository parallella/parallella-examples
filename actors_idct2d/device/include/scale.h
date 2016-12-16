/*

	scale.h
	Süleyman Savas
	2013-07-05

*/ 

#ifndef __SCALE_H__ 
#define __SCALE_H__

#include "communication.h"

typedef struct{

	inputPort_t* X;	//input

#ifdef FULL
	outputPort_t* Y;
#endif

       unsigned int coreID;

}scale_t;













#endif //__SCALE_H__
