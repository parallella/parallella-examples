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

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <stdint.h>
#include <pthread.h>
#include <e-hal.h>
#include <time.h>
#include "libfreenect/libfreenect.h"
#include "common.h"

#define BUF_OFFSET 0x01000000
#define FBDEV "/dev/fb0"
#define MEMDEV "/dev/mem"
// using only an eCore by default
#define ROWS 1
#define COLS 1
#define DEPTH_WIDTH 320
#define DEPTH_HEIGHT 240
#define DEPTH_BYTES 2

typedef struct
{
  e_platform_t eplat;
  e_epiphany_t edev;
  e_mem_t emem;
} ep_context_t;

typedef struct
{
  char *fbdev;
  int fdmem;
  uint8_t *fb;
  size_t mapsize;
  struct fb_fix_screeninfo fbfsi;
  struct fb_var_screeninfo fbvsi;
  int double_buffered;
} fb_context_t;

typedef struct
{
  pthread_t fn_thread;
  freenect_context *fnctx;
  freenect_device *fndev;
  int fndevnum;
  int quit;
  uint8_t *buf_depth;
} fn_test_context_t;


static inline void nano_wait(uint32_t sec, uint32_t nsec)
{
  struct timespec ts;
  ts.tv_sec = sec;
  ts.tv_nsec = nsec;
  nanosleep(&ts, NULL);
}


// must be as global (for depth_callback)
static fn_test_context_t fn_context;


int init_epiphany(ep_context_t *e, msg_block_t *msg, size_t buf_size)
{
  e_init(NULL);
  e_reset_system();
  e_get_platform_info(&e->eplat);
  // buf_size: sizeof(msg_block_t) + depth-buffer-size
  // emem memory map
  // emem start----
  // msg_block_t msg
  // uint8_t buf_depth[DEPTH_WIDTH * DEPTH_HEIGHT * DEPTH_BYTES]
  // emem end------
  e_alloc(&e->emem, BUF_OFFSET, buf_size);
  e_write(&e->emem, 0, 0, 0, (void *)msg, sizeof(msg_block_t));
  e_open(&e->edev, 0, 0, ROWS, COLS);
  if (e_load_group("epiphany.srec", &e->edev, 0, 0, ROWS, COLS, E_TRUE) == E_ERR)
  {
    perror("e_load failed");
    return -1;
  }

  int row, col;
  for (row = 0; row < ROWS; row++)
  {
    for (col = 0; col < COLS; col++)
    {
      e_resume(&e->edev, row, col);
    }
  }

  return 0;
}


void release_epiphany(ep_context_t *e)
{
  e_close(&e->edev);
  e_free(&e->emem);
  e_finalize();
}


// be called by freenect once per frame
// convert 11bit raw depth stream(640x480) to unsigned short(320x240)
void depth_callback(freenect_device *dev, void *v_depth, uint32_t timestamp)
{
  uint16_t *buf = (uint16_t *)fn_context.buf_depth;
  uint8_t *d = (uint8_t *)v_depth;
  unsigned int x, y;
  for (y = 0; y < 240; y++)
  {
    for (x = 0; x < 80; x++)
    {
      uint32_t mask = 0x7ff;
      buf[0] = (d[0] << 3) | (d[1] >> 5);
      buf[1] = ((d[2] << 9) | (d[3] << 1) | (d[4] >> 7)) & mask;
      buf[2] = ((d[5] << 7) | (d[6] >> 1)) & mask;
      buf[3] = ((d[8] << 5) | (d[9] >> 3)) & mask;
      d += 11;
      buf += 4;
    }
    // skip a row (480->240)
    d += 880;
  }
}


void *fn_thread_func(void *arg)
{
  while (!fn_context.quit && (freenect_process_events(fn_context.fnctx) >= 0))
  {
  }
  return NULL;
}


void fb_init(fb_context_t *fb_c, char *fbdev)
{
  memset(fb_c, 0, sizeof(fb_context_t));
  fb_c->fbdev = fbdev;
}


// open framebuffer
int fb_open(fb_context_t *fb_c)
{
  fb_c->fb = NULL;
  fb_c->fdmem = 0;
  int fd = 0;
  fd = open(fb_c->fbdev, O_RDWR);

  if (fd < 0)
  {
    perror("Error: frame buffer device open");
    return -1;
  }

  if (ioctl(fd, FBIOGET_FSCREENINFO, &fb_c->fbfsi) != 0)
  {
    perror("Error: FBIOGET_FSCREENINFO");
    close(fd);
    return -1;
  }

  if (ioctl(fd, FBIOGET_VSCREENINFO, &fb_c->fbvsi) != 0)
  {
    perror("Error: FBIOGET_VSCREENINFO");
    close(fd);
    return -1;
  }

  unsigned int yres_virtual = fb_c->fbvsi.yres_virtual;
  fb_c->fbvsi.yres_virtual = fb_c->fbvsi.yres * 2;
  fb_c->fbvsi.activate = FB_ACTIVATE_NOW;

  if (ioctl(fd, FBIOPUT_VSCREENINFO, &fb_c->fbvsi) == 0)
  {
    fb_c->double_buffered = 1;
  }
  else
  {
    fb_c->double_buffered = 0;
    fb_c->fbvsi.yres_virtual = yres_virtual;
  }

  close(fd);

  long pagesize = (sysconf(_SC_PAGESIZE));
  fb_c->fdmem = open(MEMDEV, O_RDWR | O_SYNC);

  if (fb_c->fdmem < 0)
  {
    perror("Error: open memdev");
    return -1;
  }

  off_t physical_page = fb_c->fbfsi.smem_start & (~(pagesize - 1));
  unsigned long offset = fb_c->fbfsi.smem_start - (unsigned long)physical_page;
  fb_c->mapsize = fb_c->fbfsi.smem_len + offset;
  fb_c->fb = mmap(NULL, fb_c->mapsize, PROT_READ | PROT_WRITE, MAP_SHARED, fb_c->fdmem, physical_page);

  if (fb_c->fb == MAP_FAILED)
  {
    close(fb_c->fdmem);
    fb_c->fdmem = 0;
    fb_c->fb = NULL;
    perror("Error: map memdev");
    return -1;
  }

  return 0;
}


void fb_close(fb_context_t *fb_c)
{
  if (fb_c->fb != NULL)
  {
    munmap(fb_c->fb, fb_c->mapsize);
  }
  if (fb_c->fdmem != 0)
  {
    close(fb_c->fdmem);
  }
}


// open freenect (kinect camera)
int fn_test_open(uint8_t *buf_depth)
{
  fn_context.buf_depth = buf_depth;
  fn_context.quit = 0;

  if (freenect_init(&fn_context.fnctx, NULL) < 0)
  {
    perror("Error: freenect_init");
    return -1;
  }

  freenect_select_subdevices(fn_context.fnctx, (freenect_device_flags)(FREENECT_DEVICE_MOTOR | FREENECT_DEVICE_CAMERA));

  fn_context.fndevnum = freenect_num_devices(fn_context.fnctx);

  if (fn_context.fndevnum < 1)
  {
    perror("Error: no freenect devices");
    freenect_shutdown(fn_context.fnctx);
    return -1;
  }

  if (freenect_open_device(fn_context.fnctx, &fn_context.fndev, 0) < 0)
  {
    perror("Error: freenect_open_device");
    freenect_shutdown(fn_context.fnctx);
    return -1;
  }

  freenect_set_led(fn_context.fndev, LED_YELLOW);
  freenect_set_depth_callback(fn_context.fndev, depth_callback);
  freenect_set_depth_mode(fn_context.fndev, freenect_find_depth_mode(FREENECT_RESOLUTION_MEDIUM, FREENECT_DEPTH_11BIT_PACKED));
  freenect_start_depth(fn_context.fndev);

  if (pthread_create(&fn_context.fn_thread, NULL, fn_thread_func, NULL))
  {
    perror("Error: pthread_create");
    freenect_stop_depth(fn_context.fndev);
    freenect_close_device(fn_context.fndev);
    freenect_shutdown(fn_context.fnctx);
    return -1;
  }
  return 0;
}


void fn_test_close()
{
  if (fn_context.fndev != NULL)
  {
    freenect_stop_depth(fn_context.fndev);
    freenect_close_device(fn_context.fndev);
  }
  if (fn_context.fnctx != NULL)
  {
    freenect_shutdown(fn_context.fnctx);
  }
}



int main(int argc, char *argv[])
{
  static ep_context_t ep_context;
  static fb_context_t fb_c;
  static msg_block_t msg;
  memset((void *)&msg, 0, sizeof(msg));
  static uint8_t buf_depth[DEPTH_WIDTH * DEPTH_HEIGHT * DEPTH_BYTES];
  size_t buf_size = sizeof(msg_block_t) + DEPTH_WIDTH * DEPTH_HEIGHT * DEPTH_BYTES;

  fb_init(&fb_c, FBDEV);
  if (fb_open(&fb_c) < 0)
  {
    perror("Error: fb_open");
    abort();
  }

  msg.msg_init.smem_start = fb_c.fbfsi.smem_start;
  msg.msg_init.line_length = fb_c.fbfsi.line_length;
  msg.msg_init.xres = fb_c.fbvsi.xres;
  msg.msg_init.yres = fb_c.fbvsi.yres;
  msg.msg_init.xres_virtual = fb_c.fbvsi.xres_virtual;
  msg.msg_init.yres_virtual = fb_c.fbvsi.yres_virtual;
  msg.msg_init.xoffset = fb_c.fbvsi.xoffset;
  msg.msg_init.yoffset = fb_c.fbvsi.yoffset;
  msg.msg_init.start_offset = sizeof(msg_block_t);
  msg.msg_init.width = DEPTH_WIDTH;
  msg.msg_init.height = DEPTH_HEIGHT;
  msg.msg_init.pixel_bytes = DEPTH_BYTES;
  uint32_t o_scale;
  if ((msg.msg_init.xres / msg.msg_init.width) < (msg.msg_init.yres / msg.msg_init.height))
  {
    o_scale = msg.msg_init.xres / msg.msg_init.width;
  }
  else
  {
    o_scale = msg.msg_init.yres / msg.msg_init.height;
  }
  msg.msg_init.out_scale = o_scale;
  msg.msg_init.out_xoff = (msg.msg_init.xres - msg.msg_init.width * o_scale) / 2;
  msg.msg_init.out_yoff = (msg.msg_init.yres - msg.msg_init.height * o_scale) / 2;

  if (fn_test_open(buf_depth) < 0)
  {
    perror("Error: freenect open");
    abort();
  }

  if (init_epiphany(&ep_context, &msg, buf_size) < 0)
  {
    perror("Error: init_epiphany");
    abort();
  }

  uint32_t vepiphany[MAXCORES];
  uint32_t vhost[MAXCORES];
  uint32_t i;
  for (i = 0; i < MAXCORES; i++)
  {
    vepiphany[i] = 0;
    vhost[i] = 0;
  }

  unsigned int frame;
  for (frame = 0; frame < 600; frame++)
  {
    uint32_t row, col;
    for (row = 0; row < ROWS; row++)
    {
      for (col = 0; col < COLS; col++)
      {
        uint32_t core = row * COLS + col;
        while (1)
        {
          // wait for completion (eCore job)
          e_read(&ep_context.emem, 0, 0, (off_t)((char *)&msg.msg_d2h[core] - (char *)&msg), (void *)&msg.msg_d2h[core], sizeof(msg_dev2host_t));
          vepiphany[core] = msg.msg_d2h[core].value[0];
          if (vhost[core] - vepiphany[core] > ((~(uint32_t)0) >> 1))
          {
            break;
          }
          nano_wait(0, 1000000);
        }
        vhost[core] = vepiphany[core];
      }
    }

    // transfer depth data to emem
    e_write(&ep_context.emem, 0, 0, (off_t)sizeof(msg_block_t), (void *)buf_depth, DEPTH_WIDTH * DEPTH_HEIGHT * DEPTH_BYTES);
    // wake-up eCore
    for (row = 0; row < ROWS; row++)
    {
      for (col = 0; col < COLS; col++)
      {
        e_resume(&ep_context.edev, row, col);
      }
    }
    nano_wait(0, 33000000);
  }

  release_epiphany(&ep_context);

  fn_test_close();
  fb_close(&fb_c);

  return 0;
}
