/*
Copyright (c) 2013, Shodruky Rhyammer
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
#define MAXI 255
#define ROWS 4
#define COLS 4
#define BPP 4

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
  unsigned int xres = 512;
  unsigned int yres = 512;
  unsigned int xoff = 480;
  unsigned int yoff = 32;
  float resx = 2.0f / (float)xres;
  float resy = 2.0f / (float)yres;
  while (1)
  {
    msg->msg_d2h[core].coreid = coreid;
    msg->msg_d2h[core].value = frame;
    frame++;
    __asm__ __volatile__ ("trap 4");
    unsigned int x, y;
    float z0x = resx * zoom;
    float z0y = resy * zoom;
    float zx = CX - zoom;
    float zy = CY - zoom;
    for (y = 0; y < yres; y += cores)
    {
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
        *(unsigned int *)(PAGE_OFFSET + page * PAGE_SIZE + x * BPP) = (unsigned int)(color * color * color * color);
      }
      e_dma_copy((char *)(msg->fbinfo.smem_start + xoff * BPP + (y + core + yoff) * msg->fbinfo.line_length), (char *)(PAGE_OFFSET + page * PAGE_SIZE), xres * BPP);
      page = page ^ 1;
    }
    zoom *= zf;
    zf = (zoom < 0.00002f) ? 1.0417f : zf;
    zf = (zoom > 5.0f) ? 0.96f : zf;
  }
  return 0;
}
