/*
Copyright (c) 2014, Shodruky Rhyammer
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

  Neither the name of the copyright holders nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdint.h>

#define MAXCORES 16
#define ALIGN8 8

#pragma pack(push, 1)

typedef struct __attribute__((aligned(ALIGN8)))
{
  // framebuffer
  uint32_t smem_start;
  uint32_t line_length;
  uint32_t xres;
  uint32_t yres;
  uint32_t xres_virtual;
  uint32_t yres_virtual;
  uint32_t xoffset;
  uint32_t yoffset;
  // kinect data
  uint32_t start_offset;
  uint32_t width;
  uint32_t height;
  uint32_t pixel_bytes;
  // output
  uint32_t out_xoff;
  uint32_t out_yoff;
  uint32_t out_scale;
  uint32_t out_dummy00;
} msg_init_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  uint32_t value[3];
  uint32_t coreid;
} msg_dev2host_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  uint32_t value[8];
} msg_host2dev_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  msg_init_t msg_init;
  msg_host2dev_t msg_h2d;
  msg_dev2host_t msg_d2h[MAXCORES];
} msg_block_t;

#pragma pack(pop)

