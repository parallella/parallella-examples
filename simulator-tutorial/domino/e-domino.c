/*
# mach: all
# sim: -r 32 -c 32 --ext-ram-size 0 --ext-ram-base 0
# output: Got 1024 messages\n
*/

/*
  e-domino.c

  Copyright (C) 2015 Adapteva, Inc.
  Contributed by Ola Jeppsson <ola@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program, see the file COPYING.  If not, see
  <http://www.gnu.org/licenses/>.
*/

// This is the EPIPHANY side of the domino example

/* Tests dma / dma message mode / dma interrupts */

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include "e-lib-inl.h"

#define BUF_ADDR 0x8e000000

/* Make linker allocate memory for message box. Same binary, so same address
 * on all cores. */
uint16_t _msg_box[1024];
#define MSG_BOX _msg_box

volatile uint32_t _global_mutex;
volatile uint32_t _start_sync[1024] = { 0, };
#define START_SYNC _start_sync

volatile uint32_t multicast_dummy;

e_dma_desc_t __attribute__((section(".data_bank0"))) dma_descriptor = {
  .config = E_DMA_ENABLE | E_DMA_MASTER | E_DMA_HWORD | E_DMA_IRQEN |
	    E_DMA_MSGMODE,
  .inner_stride = 0x00020002,
  /* .count computed in code */
  .outer_stride = 0xdeadbeef, /* not used */
  .src_addr = (void *) _msg_box,
  /* .dst_addr computed in code */
};


/* Can't hook up to sync since e-server traps it */
void message_isr () __attribute__ ((interrupt ("message")));
/* For waiting for dma completion */
void dma0_isr () __attribute__ ((interrupt ("dma0")));


void pass_message ();
void print_route ();
void print_n_messages ();
void report_route ();

static void
mutex_lock (volatile uint32_t *p)
{
  const int32_t zero = 0;
  uint32_t val;

  do
    {
      val = 1;
      __asm__ __volatile__ (
	  "testset	%[val], [%[p], %[zero]]"
	  : [val] "+r" (val)
	  : [p] "r" (p), [zero] "r" (zero)
	  : "memory");
    }
  while (val);
}

static void
mutex_unlock (volatile uint32_t *p)
{
  *p = 0;
}


static uint32_t
addfetch(volatile uint32_t *p, uint32_t val)
{
  uint32_t new;

  uint32_t *global_mutex = (uint32_t *)
    e_get_global_address (0, 0, (void *) &_global_mutex);

  mutex_lock(global_mutex);

  new = *p + val;
  *p = new;

  mutex_unlock(global_mutex);

  return new;
}

inline static void
start_barrier ()
{
  volatile uint32_t *start_sync;
  uint32_t now;
  uint32_t size;
  uint32_t leader_rank = e_group_leader_rank ();

  start_sync = (uint32_t *)
    e_group_global_address (leader_rank, (void *) START_SYNC);

  now = addfetch (start_sync, 1);

  size = e_group_size ();
  if (e_group_config.group_id == 0)
    size--;

  if (e_group_leader_p ())
    {
      if (now == size)
	{
	  e_irq_global_mask (true);
	  return;
	}

      e_irq_global_mask (true);
      e_irq_mask (E_MESSAGE_INT, false);
      start_sync[1] = 1;
      e_idle ();
      e_irq_global_mask (true);
      e_irq_mask (E_MESSAGE_INT, true);
      e_irq_global_mask (true);
    }
  else
    {
      if (now == size)
	e_irq_set (e_group_row (leader_rank),
		   e_group_col (leader_rank),
		   E_MESSAGE_INT);
    }
}


int
main ()
{
  e_irq_global_mask (true);

  e_irq_mask (E_MESSAGE_INT, true);
  e_irq_mask (E_DMA0_INT, true);

  e_irq_attach (E_MESSAGE_INT, message_isr);
  e_irq_attach (E_DMA0_INT, dma0_isr);

  /* One sided barrier, leaders waits on slaves */
  start_barrier ();

  e_irq_mask (E_MESSAGE_INT, true);
  e_irq_mask (E_DMA0_INT, true);

  if (e_group_leader_p ())
    pass_message ();

  e_irq_global_mask (true);
  e_irq_mask (E_MESSAGE_INT, false);
  e_irq_global_mask (true);
  e_idle ();
  e_irq_mask (E_MESSAGE_INT, true);
  e_irq_global_mask (true);

  if (e_group_leader_p ())
    report_route ();  /* Report route message took to host */
    //print_route ();  /* Print route message took */
    //print_n_messages ();
  else
    pass_message (); /* Pass message to next core in path */

  return 0;
}

void message_isr ()
{
  /* Do nothing, returning from the interrupt is enough. */
}

void dma0_isr ()
{
  /* Do nothing, returning from the interrupt is enough. */
}

uint32_t next_hop ()
{
  enum direction_t { LEFT, RIGHT } direction;

  unsigned myrow, mycol, lastrow, lastcol;

  myrow = e_group_my_row ();
  mycol = e_group_my_col ();
  lastrow = e_group_last_row ();
  lastcol = e_group_last_col ();

  /* Go left on odd rel row, right on even */
  direction = (myrow & 1) ? LEFT : RIGHT;

  if (e_group_leader_p ())
    {
      if (mycol < lastcol)
	return e_group_rank (myrow, mycol+1);
      else if (myrow < lastrow)
	return e_group_rank (myrow + 1, mycol);
      else
	return e_group_leader_rank ();
    }

  if (mycol == 0 && e_group_cols () > 1)
    {
      if (myrow <= 1)
	return e_group_leader_rank ();
      else
	return e_group_rank (myrow-1, mycol);
    }

  switch (direction)
    {
    case LEFT:
      if (mycol == 1 && myrow != lastrow)
	return e_group_rank (myrow+1, mycol);
      else if (mycol != 0)
	return e_group_rank (myrow, mycol-1);
      else if (myrow != lastrow)
	return e_group_rank (myrow+1, mycol);
      else
	return e_group_leader_rank ();

    case RIGHT:
      if (myrow == lastrow && mycol == lastcol)
	{
	  if (lastrow == 0)
	    return e_group_leader_rank ();
	  else
	    return e_group_rank (myrow, 0);
	}
      else if (mycol == lastcol)
	return e_group_rank (myrow+1, mycol);
      else
	return e_group_rank (myrow, mycol+1);
    }

  /* BUG */
  //printf("%#x: next_hop: BUG", e_get_coreid ());
  abort ();
}

void pass_message ()
{
  uint32_t next;
  uint16_t n;
  uint16_t *next_msgbox;
  uint16_t *msgbox = (uint16_t *) MSG_BOX;

  if (e_group_leader_p ())
    *msgbox = 0;

  msgbox[0]++;
  n = msgbox[0];

  /* Add 1 to rank to distinguish between passed message / no message from
   * leader */
  msgbox[n] = (uint16_t) ((e_group_my_rank () + 1) & 0xffff);

  next = next_hop ();
  next_msgbox = (uint16_t *) e_group_global_address (next, (void *) MSG_BOX);

  e_irq_global_mask(true);

#ifdef NO_DMA
  memcpy ((void *) next_msgbox, (void *) msgbox, (n+1)*sizeof (msgbox[0]));
  e_irq_set (e_group_row (next), e_group_col (next), E_MESSAGE_INT);
#else
  dma_descriptor.dst_addr = next_msgbox;
  dma_descriptor.count = (1 << 16) | (n+1);

  e_irq_global_mask (true);
  e_irq_mask (E_DMA0_INT, false);
  e_irq_global_mask (true);
  e_dma_start (&dma_descriptor, E_DMA_0);
  e_irq_global_mask (true);

  /* Wait for dma completion */
  e_idle ();

#endif
}

//static void print_path (uint16_t *path, uint16_t row, uint16_t col)
//{
//  signed north, east, south, west;
//  uint16_t next, prev;
//
//  north = row == 0                   ? -2 : path[e_group_rank (row-1, col  )];
//  west  = col == 0                   ? -2 : path[e_group_rank (row  , col-1)];
//  south = row == e_group_last_row () ? -2 : path[e_group_rank (row+1, col  )];
//  east  = col == e_group_last_col () ? -2 : path[e_group_rank (row  , col+1)];
//
//  next = path[e_group_rank(row, col)] + 1;
//  prev = path[e_group_rank(row, col)] - 1;
//
//  if (!prev)
//    fputs ("○", stdout);
//  else if (north == next)
//    if (south == prev) fputs ("|", stdout); else fputs ("▲", stdout);
//  else if (south == next)
//    if (north == prev) fputs ("|", stdout); else fputs ("▼", stdout);
//  else if (west == next)
//    if (east == prev)  fputs ("—", stdout); else fputs ("◀", stdout);
//  else if (east == next)
//    if (west == prev)  fputs ("—", stdout); else fputs ("▶", stdout);
//  else
//    fputs ("⚫", stdout);
//}

//void
//print_n_messages ()
//{
//  uint16_t *msgbox = (uint16_t *) MSG_BOX;
//
//  printf ("Got %d messages\n", msgbox[0]);
//}

void
report_route ()
{
  uint16_t *buf = (uint16_t *) BUF_ADDR;
  uint16_t *msgbox = (uint16_t *) MSG_BOX;

  uint16_t nmessages = msgbox[0];

  memcpy (&buf[1], msgbox, (nmessages + 1) * sizeof(msgbox[0]));

  // Assume no write reordering, then this compiler barrier is enough.
  asm volatile ("" ::: "memory");

  // set done flag
  buf[0] = 1;
}

//void print_route ()
//{
//  unsigned i,j;
//  uint32_t rank1; /* rank + 1 */
//  uint16_t path[e_group_size ()];
//  uint16_t *msgbox = (uint16_t *) MSG_BOX;
//
//  path[0] = 0;
//
//  printf ("Got %d messages\n", msgbox[0]);
//  printf ("Message path:\n");
//  for (i=0; i < msgbox[0]; i++)
//    {
//      rank1 = msgbox[i+1];
//      if (rank1)
//	path[rank1 - 1] = i+1;
//    }
//  for (i=0; i < e_group_rows (); i++)
//    {
//      for (j=0; j < e_group_cols (); j++)
//	{
//	  if (path[e_group_rank (i, j)])
//	    print_path (path, i, j);
//	  else
//	    fputs ("⨯", stdout);
//	}
//
//      fputs ("\n", stdout);
//    }
//}
