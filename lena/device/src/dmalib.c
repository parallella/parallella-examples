/*
  dmalib.c

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


#include "dmalib.h"
#include "fft2dlib.h"
#include "fft2d.h"


extern volatile e_dma_desc_t tcb;


int dmastart(e_dma_desc_t *tcb)
{
	int           status;
	unsigned      start;

	/* wait for the DMA engine to be idle */
	status = ~ 0x0;
	while (status)
	{
		__asm__ __volatile__ ("MOVFS %0, DMA0STATUS"  : "=r" (status) : );
		status = status & 0xf;
	}

	start = ((volatile int) (tcb) << 16) | E_DMA_STARTUP;
	__asm__ __volatile__ ("MOVTS DMA0CONFIG, %0"  : : "r" (start) );

	/* wait for the DMA engine to be idle */
	status = ~ 0x0;
	while (status)
	{
		__asm__ __volatile__ ("MOVFS %0, DMA0STATUS"  : "=r" (status) : );
		status = status & 0xf;
	}

	return 0;
}


int dmacpye(void *src, void *dst)
{
	unsigned stride_i_src;
	unsigned stride_i_dst;
	unsigned stride_o_src;
	unsigned stride_o_dst;
	unsigned count_i;
	unsigned count_o;
	unsigned config;

	config       = E_DMA_MSGMODE | E_DMA_DWORD | E_DMA_MASTER | E_DMA_ENABLE;
	stride_i_src = (1 << 3);
	stride_i_dst = (1 << 3);
	stride_o_src = 0;
	stride_o_dst = 0;
	count_i      = (_Score * _Sfft);
	count_o      = 1;

	tcb.config       = config;
	tcb.inner_stride = (stride_i_dst << 16) | (stride_i_src);
	tcb.count        = (count_o << 16)      | (count_i);
	tcb.outer_stride = (stride_o_dst << 16) | (stride_o_src);
	tcb.src_addr     = src;
	tcb.dst_addr     = dst;

	dmastart((e_dma_desc_t *) (&tcb));

	return 0;
}


int dmacpyi(void *src, void *dst)
{
	unsigned stride_i_src;
	unsigned stride_i_dst;
	unsigned stride_o_src;
	unsigned stride_o_dst;
	unsigned count_i;
	unsigned count_o;
	unsigned config;

	config       = E_DMA_DWORD | E_DMA_MASTER | E_DMA_ENABLE;
	stride_i_src = (1 << 3);
	stride_o_src = (1 << 3) * (_Sfft - _Score + 1);
	stride_i_dst = (1 << 3) * _Sfft;
	stride_o_dst = (1 << 3) * (_Sfft - _Score * _Sfft + 1);
	count_i      = _Score;
	count_o      = _Score;

	tcb.config       = config;
	tcb.inner_stride = (stride_i_dst << 16) | (stride_i_src);
	tcb.count        = (count_o << 16)      | (count_i);
	tcb.outer_stride = (stride_o_dst << 16) | (stride_o_src);
	tcb.src_addr     = src;
	tcb.dst_addr     = dst;

	dmastart((e_dma_desc_t *) (&tcb));

	return 0;
}


