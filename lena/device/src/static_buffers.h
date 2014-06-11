/*
  static_buffers.h

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


#ifndef __STATIC_BUFFERS_H__
#define __STATIC_BUFFERS_H__

#include <e_common.h>
#include "fft2d.h"
#include "dmalib.h"

extern volatile cfloat       AA[_Score][_Sfft]; // local operand array (ping)
extern volatile cfloat       BB[_Score][_Sfft]; // local operand array (pong)
extern volatile cfloat       Wn[_Sfft/2];       // local Wn twiddles array
extern core_t                me;                // core data structure
extern shared_buf_ptr_t      Mailbox;           // Mailbox pointers
extern volatile e_dma_desc_t tcb;               // TCB structure for DMA
extern float                 recipro[16];       // 1/n     LUT
extern float                 recipro_2_by[16];  // 1/(2^n) LUT
extern float                 Cw_lg[16];         // Cos(2 * Pi / 2^N)
extern float                 Sw_lg[16];         // Sin(2 * Pi / 2^N)

#endif // __STATIC_BUFFERS_H__
