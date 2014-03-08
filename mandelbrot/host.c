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


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <stdint.h>
#include <time.h>
#include <e-hal.h>
#include "shared_data.h"

#define BUF_OFFSET 0x01000000
#define MAXCORES 16
#define FBDEV "/dev/fb0"
#define ROWS 4
#define COLS 4
#define FRAMES 2000000

static inline void nano_wait(uint32_t sec, uint32_t nsec)
{
  struct timespec ts;
  ts.tv_sec = sec;
  ts.tv_nsec = nsec;
  nanosleep(&ts, NULL);
}

int main(int argc, char *argv[])
{
  e_platform_t eplat;
  e_epiphany_t edev;
  e_mem_t emem;
  static msg_block_t msg;
  memset(&msg, 0, sizeof(msg));
  struct timespec time;
  double time0, time1;

  int fb = open(FBDEV, O_RDWR);
  if (fb > 0)
  {
    struct fb_fix_screeninfo fbfsi;
    struct fb_var_screeninfo fbvsi;
    if (ioctl(fb, FBIOGET_FSCREENINFO, &fbfsi) == 0)
    {
      msg.fbinfo.smem_start = fbfsi.smem_start;
      //printf("smem_start: %x\n", msg.fbinfo.smem_start);
      msg.fbinfo.smem_len = fbfsi.smem_len;
      //printf("smem_len: %d\n", msg.fbinfo.smem_len);
      msg.fbinfo.line_length = fbfsi.line_length;
      //printf("line_length: %d\n", msg.fbinfo.line_length);
    }
    if (ioctl(fb, FBIOGET_VSCREENINFO, &fbvsi) == 0)
    {
      msg.fbinfo.xres = fbvsi.xres;
      //printf("xres: %d\n", msg.fbinfo.xres);
      msg.fbinfo.yres = fbvsi.yres;
      //printf("yres: %d\n", msg.fbinfo.yres);
      msg.fbinfo.xres_virtual = fbvsi.xres_virtual;
      //printf("xres_virtual: %d\n", msg.fbinfo.xres_virtual);
      msg.fbinfo.yres_virtual = fbvsi.yres_virtual;
      //printf("yres_virtual: %d\n", msg.fbinfo.yres_virtual);
      msg.fbinfo.xoffset = fbvsi.xoffset;
      //printf("xoffset: %d\n", msg.fbinfo.xoffset);
      msg.fbinfo.yoffset = fbvsi.yoffset;
      //printf("yoffset: %d\n", msg.fbinfo.yoffset);
      msg.fbinfo.bits_per_pixel = fbvsi.bits_per_pixel;
    }
    close(fb);
  }

  e_init(NULL);
  e_reset_system();
  e_get_platform_info(&eplat);
  e_alloc(&emem, BUF_OFFSET, sizeof(msg_block_t));
  unsigned int row = 0;
  unsigned int col = 0;
  volatile unsigned int vepiphany[MAXCORES];
  volatile unsigned int vcoreid = 0;
  unsigned int vhost[MAXCORES];
  e_open(&edev, 0, 0, ROWS, COLS);
  e_write(&emem, 0, 0, 0, &msg, sizeof(msg));
  e_reset_group(&edev);
  e_load_group("epiphany.srec", &edev, 0, 0, ROWS, COLS, E_TRUE);
  for (row = 0; row < ROWS; row++)
  {
    for (col = 0; col < COLS; col++)
    {
      unsigned int core = row * COLS + col;
      vepiphany[core] = 0;
      vhost[core] = 0;
    }
  }
  nano_wait(0, 100000000);
  clock_gettime(CLOCK_REALTIME, &time);
  time0 = time.tv_sec + time.tv_nsec * 1.0e-9;

  unsigned int frame = 0;
  while (1)
  {
    for (row = 0; row < ROWS; row++)
    {
      for (col = 0; col < COLS; col++)
      {
        unsigned int core = row * COLS + col;
        while (1)
        {
          e_read(&emem, 0, 0, (off_t)((char *)&msg.msg_d2h[core] - (char *)&msg), &msg.msg_d2h[core], sizeof(msg_dev2host_t));
          vepiphany[core] = msg.msg_d2h[core].value;
          if (vhost[core] - vepiphany[core] > ((~0u) >> 1))
          {
            break;
          }
          nano_wait(0, 1000000);
        }
        vhost[core] = vepiphany[core];
        vcoreid = msg.msg_d2h[core].coreid;
        //printf("%x row:%d col:%d\n", vepiphany[core], (vcoreid >> 6), (vcoreid & 0x3f));
      }
    }
    frame++;
    if (frame > FRAMES)
    {
      break;
    }
    for (row = 0; row < ROWS; row++)
    {
      for (col = 0; col < COLS; col++)
      {
        e_resume(&edev, row, col);
      }
    }
  }

  clock_gettime(CLOCK_REALTIME, &time);
  time1 = time.tv_sec + time.tv_nsec * 1.0e-9;
  //printf("frames: %d\n", FRAMES);
  //printf("time: %f sec\n", time1 - time0);

  e_close(&edev);
  e_free(&emem);
  e_finalize();
  return 0;
}
