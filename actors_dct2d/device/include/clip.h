/*

	clip.h
	Süleyman Savas
	2013-07-09

*/

#ifndef __CLIP_H__
#define __CLIP_H__

#include "communication.h"

typedef struct{
	inputPort_t* SIGNED;
	inputPort_t* I;
	//outputPort_t* O;

	unsigned int coreID;
	int count;
	int sflag;
}clip_t;






#endif // __CLIP_H__
