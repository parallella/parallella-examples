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
#include <e-loader.h>
#include <fluidsynth.h>
#include <linux/input.h>
#include "common.h"
#include "keymap.h"

#define TRUE 1
#define FALSE 0
#define SCALE_SIZE 4
#define SCALE_PATTERN 8
#define NOTES_SIZE 48
#define DEST_CLIENT 128
#define DEST_PORT 0
#define F_AUDIO_DRIVER "alsa"
#define F_SF_PATH "/usr/share/sounds/sf2/FluidR3_GM.sf2"

#define BUF_OFFSET 0x01000000
#define MAXCORES 16
#define FBDEV "/dev/fb0"
#define EVDEV "/dev/input/event0"
#define ROWS 4
#define COLS 4
#define MODE_AUTO 0
#define MODE_PLAY 1

typedef struct
{
  e_platform_t eplat;
  e_epiphany_t edev;
  e_mem_t emem;
} ep_context_t;

typedef struct
{
  fluid_settings_t *f_settings;
  fluid_synth_t *f_synth;
  fluid_audio_driver_t *f_adriver;
} seq_context_t;

static uint32_t notes[SCALE_PATTERN][NOTES_SIZE];
static uint32_t scales[SCALE_PATTERN][SCALE_SIZE] = {
  {0,4,7,9,},
  {0,5,7,9,},
  {2,4,7,11,},
  {2,5,7,9,},
  {2,5,7,11,},
  {0,2,4,7,},
  {0,2,5,7,},
  {0,2,5,9,},
};
static uint32_t instruments[] = {
  0, 4, 5, 6, 8, 9, 11, 14, 15, 16, 17, 19, 24,
  25, 26, 30, 40, 42, 46, 48, 51, 52, 56, 57, 60,
  61, 63, 64, 65, 68, 69, 70, 73, 88, 89, 91, 93,
  94, 95, 98, 99, 103, 104, 110,
};
static uint32_t insts = sizeof(instruments) / sizeof(uint32_t);
static seq_context_t seq;
static rt_context_t rtx;
static uint32_t scale = 0;

static inline float get_elapsed(struct timespec ts_start)
{
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
  return (float)(ts.tv_sec - ts_start.tv_sec) + (float)(ts.tv_nsec - ts_start.tv_nsec) * 1.0e-9f;
}

static inline float randf()
{
  return (float)rand() / (float)RAND_MAX;
}

static inline void nano_wait(uint32_t sec, uint32_t nsec)
{
  struct timespec ts;
  ts.tv_sec = sec;
  ts.tv_nsec = nsec;
  nanosleep(&ts, NULL);
}

int open_sequencer(seq_context_t *seq)
{
  int err;
  seq->f_settings = new_fluid_settings();
  seq->f_synth = new_fluid_synth(seq->f_settings);
  if (seq->f_synth == NULL)
  {
    perror("failed: new_fluid_synth");
    return FALSE;
  }
  err = fluid_synth_system_reset(seq->f_synth);
  if (err == FLUID_FAILED)
  {
    perror("failed: fluid_synth_system_reset");
    return FALSE;
  }
  fluid_settings_setstr(seq->f_settings, "audio.driver", F_AUDIO_DRIVER);
  seq->f_adriver = new_fluid_audio_driver(seq->f_settings, seq->f_synth);
  if (seq->f_adriver == NULL)
  {
    perror("failed: new_fluid_audio_driver");
    return FALSE;
  }
  if (fluid_is_soundfont(F_SF_PATH) == FALSE)
  {
    perror("failed: fluid_is_soundfont");
    return FALSE;
  }
  err = fluid_synth_sfload(seq->f_synth, F_SF_PATH, 1);
  if (err == FLUID_FAILED)
  {
    perror("failed: fluid_synth_sfload");
    return FALSE;
  }
  return TRUE;
}

void note_on(seq_context_t *seq, uint32_t ch, uint32_t note, uint32_t vel)
{
  fluid_synth_noteon(seq->f_synth, ch, note, vel);
}

void note_off(seq_context_t *seq, uint32_t ch, uint32_t note)
{
  fluid_synth_noteoff(seq->f_synth, ch, note);
}

void program_change(seq_context_t *seq, uint32_t ch, uint32_t program)
{
  fluid_synth_program_change(seq->f_synth, ch, program);
}

void control_change(seq_context_t *seq, uint32_t ch, uint32_t control, uint32_t value)
{
  fluid_synth_cc(seq->f_synth, ch, control, value);
}

void close_sequencer(seq_context_t *seq)
{
  delete_fluid_audio_driver(seq->f_adriver);
  delete_fluid_synth(seq->f_synth);
  delete_fluid_settings(seq->f_settings);
}

int init_epiphany(ep_context_t *e, msg_block_t *msg, rt_context_t *rtx)
{
  e_init(NULL);
  e_reset_system();
  e_get_platform_info(&e->eplat);
  e_open(&e->edev, 0, 0, ROWS, COLS);
  e_alloc(&e->emem, BUF_OFFSET, sizeof(msg_block_t) + sizeof(rt_context_t));
  if (e_load_group("epiphany.elf", &e->edev, 0, 0, ROWS, COLS, E_FALSE) == E_ERR)
  {
    perror("e_load failed");
    return FALSE;
  }
  e_write(&e->emem, 0, 0, 0, (void *)msg, sizeof(msg_block_t));
  e_write(&e->emem, 0, 0, sizeof(msg_block_t), (void *)rtx, sizeof(rt_context_t));
  e_start_group(&e->edev);
  return TRUE;
}

void release_epiphany(ep_context_t *e)
{
  e_close(&e->edev);
  e_free(&e->emem);
  e_finalize();
}

void obj_note_on(uint32_t note)
{
  uint32_t e = rtx.curobj + 1;
  rtx.obj[e].pos = vec3_set(randf()*8.0f-4.0f, randf()*6.0f-1.0f, randf()*8.0+0.0f);
  rtx.obj[e].col = vec3_set(randf(), randf(), randf());
  rtx.obj[e].spd = vec3_set(randf()*0.1f-0.05f,randf()*0.1f-0.05f,randf()*0.1f-0.05f);
  note_off(&seq, 0, rtx.obj[e].note);
  rtx.obj[e].note = notes[scale][note];
  note_on(&seq, 0, rtx.obj[e].note, 127 - rtx.obj[e].note);
  rtx.curobj = ((rtx.curobj + 1) % (rtx.objnum - 1));
}

int main(int argc, char ** argv)
{
  ep_context_t ep_context;
  static msg_block_t msg;
  memset((void *)&msg, 0, sizeof(msg));
  struct timespec time;
  double time0, time1;
  uint32_t mode = MODE_AUTO;

  int fb = open(FBDEV, O_RDWR);
  if (fb > 0)
  {
    struct fb_fix_screeninfo fbfsi;
    struct fb_var_screeninfo fbvsi;
    if (ioctl(fb, FBIOGET_FSCREENINFO, &fbfsi) == 0)
    {
      msg.fbinfo.smem_start = fbfsi.smem_start;
      msg.fbinfo.smem_len = fbfsi.smem_len;
      msg.fbinfo.line_length = fbfsi.line_length;
    }
    else
    {
      exit(EXIT_FAILURE);
    }
    if (ioctl(fb, FBIOGET_VSCREENINFO, &fbvsi) == 0)
    {
      msg.fbinfo.xres = fbvsi.xres;
      msg.fbinfo.yres = fbvsi.yres;
      msg.fbinfo.xres_virtual = fbvsi.xres_virtual;
      msg.fbinfo.yres_virtual = fbvsi.yres_virtual;
      msg.fbinfo.xoffset = fbvsi.xoffset;
      msg.fbinfo.yoffset = fbvsi.yoffset;
      msg.fbinfo.bits_per_pixel = fbvsi.bits_per_pixel;
    }
    else
    {
      exit(EXIT_FAILURE);
    }
    close(fb);
  }
  else
  {
    exit(EXIT_FAILURE);
  }

  uint32_t row = 0;
  uint32_t col = 0;
  uint32_t vepiphany[MAXCORES];
  uint32_t vcoreid = 0;
  uint32_t vhost[MAXCORES];

  struct timespec time_start;
  clock_gettime(CLOCK_MONOTONIC_RAW, &time_start);
  srand((uint32_t)time_start.tv_nsec);

  if (open_sequencer(&seq) == FALSE)
  {
    exit(EXIT_FAILURE);
  }
  program_change(&seq, 0, 48);
  control_change(&seq, 0, 91, 127);

  memset((void *)&rtx, 0, sizeof(rtx));

  int width = msg.fbinfo.xres_virtual;
  int height = msg.fbinfo.yres_virtual;
  rtx.objnum = OBJNUM;
  rtx.light.pos = vec3_set(-4.0f, 8.0f, 2.0f);
  rtx.light.col = vec3_set(1.0f, 1.0f, 1.0f);
  rtx.eye = vec3_set(0.0f, 0.0f, -7.0f);
  rtx.swidth = 10.0f * (float)width / (float)height;
  rtx.sheight = 10.0f;
  rtx.xdiv = 1;
  rtx.width = width / (rtx.xdiv * SCALE);
  rtx.height =  height / SCALE;
  rtx.xoff = 0;
  rtx.yoff = 0;
  rtx.ax = rtx.swidth / (float)rtx.width / (float)rtx.xdiv;
  rtx.ayc = rtx.sheight / (float)rtx.height;
  rtx.ay = rtx.sheight / (float)rtx.height * (float)(ROWS * COLS);
  rtx.curobj = 1;

  uint32_t i, j;
  for (i = 0; i < SCALE_PATTERN; i++)
  {
    for (j = 0; j < NOTES_SIZE; j++)
    {
      notes[i][j] = scales[i][j % SCALE_SIZE] + (j / SCALE_SIZE) * 12;
    }
  }

  for (i = 0; i < rtx.objnum; i++)
  {
    rtx.obj[i].type = SPHERE;
    rtx.obj[i].pos = vec3_set(0.0f, -100.0f, 0.0f);
    rtx.obj[i].rad = 1.0f;
    rtx.obj[i].col = vec3_set(randf(), randf(), randf());
    rtx.obj[i].flag_shadow = TRUE;
    rtx.obj[i].flag_refrect = TRUE;
    rtx.obj[i].spd = vec3_set(0.0f, 0.0f, 0.0f);
    rtx.obj[i].note = 0;
  }

  rtx.obj[0].type = PLANE;
  rtx.obj[0].norm = normalize(vec3_set(0.0f, 1.0f, 0.0f));
  rtx.obj[0].dist = 2.0f;
  rtx.obj[0].col = vec3_set(0.1f, 0.3f, 0.6f);
  rtx.obj[0].flag_shadow = TRUE;
  rtx.obj[0].flag_refrect = TRUE;
  rtx.obj[0].spd = vec3_set(0.0f, 0.0f, 0.0f);

  if (init_epiphany(&ep_context, &msg, &rtx) == FALSE)
  {
    exit(EXIT_FAILURE);
  }

  for (row = 0; row < ROWS; row++)
  {
    for (col = 0; col < COLS; col++)
    {
      uint32_t core = row * COLS + col;
      vepiphany[core] = 0;
      vhost[core] = 0;
    }
  }

  float next_note_time = get_elapsed(time_start) + 3.0f;
  float next_scale_time = get_elapsed(time_start) + 15.0f + randf() * 15.0f;
  float time_now = get_elapsed(time_start);
  float time_quit = time_now + 36000.0f;
  uint32_t retry_count = 0;
  uint32_t counter = 0;
  float time_prev = 0.0f;
  int evdev;
  evdev = open(EVDEV, O_RDONLY | O_NONBLOCK);

  while(time_now < time_quit)
  {
    for (row = 0; row < ROWS; row++)
    {
      for (col = 0; col < COLS; col++)
      {
        uint32_t core = row * COLS + col;
        uint32_t wait_count = 0;
        while (1)
        {
          e_read(&ep_context.emem, 0, 0, (off_t)((char *)&msg.msg_d2h[core] - (char *)&msg), (void *)&msg.msg_d2h[core], sizeof(msg_dev2host_t));
          vepiphany[core] = msg.msg_d2h[core].value;
          if (vhost[core] - vepiphany[core] > ((~(uint32_t)0) >> 1))
          {
            break;
          }
          nano_wait(0, 1000000);
          wait_count++;
          if (wait_count > 2000)
          {
            retry_count++;
            printf(".\n");
            if (retry_count > 2)
            {
              printf("Tuning...\n");
              release_epiphany(&ep_context);
              nano_wait(1, 0);
              init_epiphany(&ep_context, &msg, &rtx);
              uint32_t row2, col2;
              for (row2 = 0; row2 < ROWS; row2++)
              {
                for (col2 = 0; col2 < COLS; col2++)
                {
                  uint32_t core2 = row2 * COLS + col2;
                  vepiphany[core2] = 0;
                  vhost[core2] = 0;
                }
              }
              retry_count = 0;
            }
            break;
          }
        }
        vhost[core] = vepiphany[core];
        vcoreid = msg.msg_d2h[core].coreid;
      }
    }

    uint32_t e;
    for (e = 1; e < rtx.objnum; e++)
    {
      rtx.obj[e].pos = vec3_add(rtx.obj[e].pos, rtx.obj[e].spd);
    }
    time_now = get_elapsed(time_start);
    if (mode == MODE_AUTO)
    {
      if (time_now > next_note_time)
      {
        obj_note_on((uint32_t)(randf() * 17.0f) + 12);
        float len = (randf() + 0.5f);
        next_note_time = time_now + len * len * len;
      }
      if (time_now > next_scale_time)
      {
        scale = (uint32_t)(randf() * (float)SCALE_PATTERN);
        program_change(&seq, 0, instruments[(uint32_t)(randf() * ((float)insts + 0.99f))]);
        rtx.obj[0].col = vec3_set(randf(), randf(), randf());
        rtx.light.pos = vec3_set(randf() * 8.0f - 4.0f, 8.0f, randf() * 4.0f);
        next_scale_time = time_now + (randf() + 0.1f) * 40.0f;
      }
    }
    struct input_event event;
    ssize_t readbytes;
    float len;
    while (1)
    {
      readbytes = read(evdev, &event, sizeof(event));
      if (readbytes < 1)
      {
        break;
      }
      
      if (readbytes == sizeof(event))
      {
        switch (event.type)
        {
          case EV_KEY:
            if ((event.value == 1) && (mode == MODE_PLAY))
            {
              if (event.code < 0x100)
              {
                if (keymap[event.code] < 0x10)
                {
                  scale = keymap[event.code] % SCALE_PATTERN;
                  rtx.obj[0].col = vec3_set(randf(), randf(), randf());
                }
                else if (keymap[event.code] < 0x30)
                {
                  obj_note_on(keymap[event.code] - 4);
                }
                else if (keymap[event.code] < 0x40)
                {
                  program_change(&seq, 0, instruments[keymap[event.code] - 0x30]);
                  rtx.light.pos = vec3_set(randf() * 8.0f - 4.0f, 8.0f, randf() * 4.0f);
                }
                else if (keymap[event.code] == 0x80)
                {
                  unsigned int i;
                  for (i = 1; i < rtx.objnum; i++)
                  {
                    rtx.obj[i].pos = vec3_set(0.0f, -100.0f, 0.0f);
                    rtx.obj[i].spd = vec3_set(0.0f, 0.0f, 0.0f);
                    note_off(&seq, 0, rtx.obj[i].note);
                  }
                }
              }
            }
            switch (event.code)
            {
              case KEY_ESC:
                time_quit = time_now;
                break;
              case KEY_ENTER:
                if (event.value == 1)
                {
                  mode = (mode == MODE_AUTO) ? MODE_PLAY : MODE_AUTO;
                }
                break;
              default:
                break;
            }
            break;
          default:
            break;
        }
      }
    }

    // render
    e_write(&ep_context.emem, 0, 0, sizeof(msg), (void *)&rtx, sizeof(rtx));

    for (row = 0; row < ROWS; row++)
    {
      for (col = 0; col < COLS; col++)
      {
        e_resume(&ep_context.edev, row, col);
      }
    }
    counter++;
    if (counter > 100)
    {
      //printf("FPS: %.2f\n", 100.0f / (time_now - time_prev));
      time_prev = time_now;
      counter = 0;
    }
  }

  close(evdev);
  close_sequencer(&seq);
  release_epiphany(&ep_context);
  return 0;
}
