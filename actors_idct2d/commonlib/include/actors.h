/* 

	actors.h
	Süleyman Savas
	2013-07-05

*/

#ifndef __ACTORS_H__
#define __ACTORS_H__

#include "rowSort.h"
#include "scale.h"

#ifdef FULL
	#include "combine.h"
	#include "shuffleFly.h"
	#include "shuffle.h"
	#include "final.h"
	#include "transpose.h"
	#include "shift.h"
	#include "reTrans.h"
	#include "clip.h"
#endif

// Instantiate the actor pointers
typedef struct{
	rowSort_t* rowSort;
	scale_t* scale; 

#ifdef FULL
	// idct1d-row
	combine_t* combineRow;
	shuffleFly_t* shuffleFlyRow;
	shuffle_t* shuffleRow;
	final_t* finalRow;
	
	// idct1d-col
	scale_t* scaleCol;
	combine_t* combineCol;
	shuffleFly_t* shuffleFlyCol;
	shuffle_t* shuffleCol;
	final_t* finalCol;

	transpose_t* transpose;
	shift_t* shift;
	reTrans_t* reTrans;
	clip_t* clip;

#endif
}actors_t;


#ifndef __HOST__
extern volatile actors_t actors;
#endif






#endif //__ACTORS_H__
