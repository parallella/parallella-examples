
#ifndef __COMMON_BUFFERS_H__
#define __COMMON_BUFFERS_H__

#include "idct.h"


#ifdef __HOST__
#define SECTION(x)
volatile mbox_t Mailbox;// SECTION(."shared_dram");

#else // __HOST__
#include <e_common.h>


//volatile core_t me;
volatile mbox_ptr_t	Mailbox			SECTION("section_core"); //

#endif // __HOST__

//volatile shared_buf_t Mailbox SECTION(".shared_dram");

#define MAILBOX_ADDRESS 0x8f000000 + 0x00000100  //the extra 0x100 is for the actors
extern const unsigned _SHARED_DRAM_;
#define SHARED_DRAM   ((unsigned)(&_SHARED_DRAM_))

#endif // __COMMON_BUFFERS_H__
