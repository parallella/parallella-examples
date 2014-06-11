/*
  dram_buffers.h

  Copyright (C) 2012 Adapteva, Inc.
  Contributed by Yainv Sapir <yaniv@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program, see the file COPYING.  If not, see
  <http://www.gnu.org/licenses/>.
*/


#ifndef __GLOBAL_BUFFERS_H__
#define __GLOBAL_BUFFERS_H__

#ifdef __HOST__
#define SECTION(x)
volatile shared_buf_t Mailbox;
#else // __HOST__
#include <e_common.h>
#endif // __HOST__

//volatile shared_buf_t Mailbox SECTION(".shared_dram");
extern const unsigned _SHARED_DRAM_;
#define SHARED_DRAM   ((unsigned)(&_SHARED_DRAM_))

#endif // __GLOBAL_BUFFERS_H__
