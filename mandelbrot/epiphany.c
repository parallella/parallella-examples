/*
Copyright (c) 2013-2014, Shodruky Rhyammer
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


#include "e_lib.h"
#include "shared_data.h"

#define BUF_ADDRESS 0x8f000000
#define PAGE_OFFSET 0x2000
#define PAGE_SIZE 0x2000
#define CX -0.6510976f
#define CY 0.4920654f
#define MAXI 64
#define ROWS 4
#define COLS 4
#define BPP 4

typedef struct
{
  float x;
  float y;
} center_t;

int main(void)
{
  e_coreid_t coreid;
  coreid = e_get_coreid();
  unsigned int row, col, core, cores;
  e_coords_from_coreid(coreid, &row, &col);
  core = row * COLS + col;
  cores = ROWS * COLS;
  unsigned int frame = 1;
  unsigned int page = 0;
  volatile msg_block_t *msg = (msg_block_t *)BUF_ADDRESS;
  float zoom = 5.0f;
  float zf = 0.97f;
  unsigned int xres = msg->fbinfo.xres_virtual / SCALE;
  xres = (xres > 1920) ? 1920 : xres;
  unsigned int yres = msg->fbinfo.yres_virtual / SCALE;
  unsigned int xoff = 0;
  unsigned int yoff = 0;
  float resx = 2.0f / (float)xres;
  float resy = 2.0f / (float)yres;
  float aspect = resy / resx;
  center_t center[] = {
    {-1.7919611f, 0.0f},
    {-1.2963551f, 0.4418516f},
    {-0.4003391f, 0.6823806f},
    { 0.2802601f,-0.0081061f},
    {-0.4910717f,-0.6303451f},
    {-0.8011453f, 0.18482280f},
  };
  unsigned int points = (sizeof(center) / sizeof(center_t)) - 1;
  unsigned int point = 0;
  while (1)
  {
    msg->msg_d2h[core].coreid = coreid;
    msg->msg_d2h[core].value = frame;
    frame++;
    __asm__ __volatile__ ("trap 4");
    unsigned int x, y;
    float z0x = resx * zoom * aspect;
    float z0y = resy * zoom;
    float zx = center[point].x - zoom * aspect;
    float zy = center[point].y - zoom;
    for (y = 0; y < yres; y += cores)
    {
      char *src = (char *)(PAGE_OFFSET + page * PAGE_SIZE);
      unsigned int *pixel = (unsigned int *)src;
      for (x = 0; x < xres; x++)
      {
        float x0 = (float)x * z0x + zx;
        float y0 = (float)(y + core) * z0y + zy;
        float q = x0 - 0.25f;
        float q0 = q * q + y0 * y0;
        float q1 = q0 * (q0 + (x0 - 0.25f));
        float q2 = 0.25f * y0 * y0;
        unsigned int i = (q1 < q2) ? MAXI : 0;
        float a = 0.0f;
        float b = 0.0f;

        while ((a * a + b * b < 4.0f) && (i < MAXI))
        {
          float a1 = a * a - b * b + x0;
          b = 2.0f * a * b + y0;
          a = a1;
          i++;
        }

        float color = (i >= MAXI) ? 0.0f : (float)i;
        uint32_t col2 = (uint32_t)(color * color * color * color);
        *pixel = col2;
#if SCALE > 1
        *(pixel + 1) = col2;
#endif
#if SCALE > 3
        *(pixel + 2) = col2;
        *(pixel + 3) = col2;
#endif
        pixel += SCALE;
      }
      char *dst = (char *)(msg->fbinfo.smem_start + xoff * BPP + ((y + core) * SCALE + yoff) * msg->fbinfo.line_length);
      uint32_t size = xres * BPP * SCALE;
      unsigned int i;
      for (i = 0; i < SCALE; i++)
      {
        e_dma_copy(dst + i * msg->fbinfo.line_length, src, size);
      }
      page = page ^ 1;
    }
    zoom *= zf;
    zf = (zoom < 0.0001f) ? 1.111111f : zf;
    if (zoom > 4.0f)
    {
      zf = 0.9f;
      point++;
      if (point > points)
      {
        point = 0;
      }
      //p = (p > points) ? 0 : p;
    }
  }
  return 0;
}
