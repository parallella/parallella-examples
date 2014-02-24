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
#include <fluidsynth.h>
#include "common.h"

#define EPSILON 0.0001f
#define NOHIT 0xffffffff
#define FARDIST 1.0e+18f
#define MAXREF 4
#define TRUE 1
#define FALSE 0
#define SCALE_SIZE 4
#define SCALE_PATTERN 8
#define NOTES_SIZE 48
#define DEST_CLIENT 128
#define DEST_PORT 0
#define F_AUDIO_DRIVER "alsa"
#define F_SF_PATH "/usr/share/sounds/sf2/FluidR3_GM.sf2"

#define FBDEV "/dev/fb0"
#define MEMDEV "/dev/mem"

typedef struct
{
  fluid_settings_t *f_settings;
  fluid_synth_t *f_synth;
  fluid_audio_driver_t *f_adriver;
} seq_context_t;

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

static inline int intersect_sphere(rt_context_t *rtx, unsigned int index)
{
  int r = FALSE;
  vec3_t v = vec3_sub(rtx->ray.pos, rtx->obj[index].pos);
  float b, d;
  b = -dot(v, rtx->ray.dir);
  float rad = rtx->obj[index].rad;
  d = b * b - dot(v, v) + rad * rad;
  if (d > 0.0f)
  {
    float dsqr = fast_sqrt(d);
    float t0 = b - dsqr;
    if ((t0 > 0.0f) && (t0 < rtx->dist))
    {
      rtx->dist = t0;
      r = TRUE;
    }
  }
  return r;
}

static inline int intersect_plane(rt_context_t *rtx, unsigned int index)
{
  int r = FALSE;
  float d = dot(rtx->ray.dir, rtx->obj[index].norm);
  float t = -(dot(rtx->ray.pos, rtx->obj[index].norm) + rtx->obj[index].dist) * fast_inv(d);
  if ((t < rtx->dist) && (t > 0.0f))
  {
    rtx->dist = t;
    r = TRUE;
  }
  return r;
}

static inline void trace_ray(rt_context_t *rtx)
{
  rtx->dist = FARDIST;
  rtx->hit = NOHIT;
  unsigned int i;
  for (i = 0; i < rtx->objnum; i++)
  {
    int hit = 0;
    switch (rtx->obj[i].type)
    {
      case SPHERE:
        hit = intersect_sphere(rtx, i);
        break;
      case PLANE:
        hit = intersect_plane(rtx, i);
        break;
      default:
        break;
    }
    rtx->hit = (hit == 1) ? i : rtx->hit;
  }
}

void render(msg_block_t *msg, rt_context_t *rtx, uint32_t *frame_buffer)
{
  uint32_t *pixel;
  float sy = rtx->sheight * 0.5f - rtx->ayc;
  unsigned int y;
  for (y = 0; y < rtx->height; y++)
  {
    uint32_t *src = frame_buffer + (y * SCALE + rtx->yoff) * msg->fbinfo.line_length / sizeof(uint32_t) + rtx->xoff;
    pixel = src;
    float sx = rtx->swidth * -0.5f;
    unsigned int x;
    for (x = 0; x < rtx->width; x++)
    {
      rtx->ray.pos = rtx->eye;
      rtx->ray.dir = normalize(vec3_sub(vec3_set(sx, sy, 0.0f), rtx->eye));
      vec3_t col = vec3_set(0.0f, 0.0f, 0.0f);
      unsigned int j;
      for (j = 0; j < MAXREF; j++)
      {
        trace_ray(rtx);
        if (rtx->hit != NOHIT)
        {
          vec3_t p, n;
          ray_t next;
          p = vec3_add(rtx->ray.pos, vec3_scale(rtx->ray.dir, rtx->dist));
          switch (rtx->obj[rtx->hit].type)
          {
            case SPHERE:
              n = normalize(vec3_sub(p, rtx->obj[rtx->hit].pos));
              break;
            case PLANE:
              n = rtx->obj[rtx->hit].norm;
              break;
            default:
              break;
          }
          next.pos = vec3_add(p, vec3_scale(n, EPSILON));
          vec3_t lv = vec3_sub(rtx->light.pos, p);
          vec3_t l = normalize(lv);
          next.dir = rtx->ray.dir;
          int prev_hit_index = rtx->hit;
          vec3_t hit_obj_col = rtx->obj[rtx->hit].col;
          float diffuse = dot(n, l);
          float specular = dot(rtx->ray.dir, vec3_sub(l, vec3_scale(n, 2.0f * diffuse)));
          diffuse = max(diffuse, 0.0f);
          specular = max(specular, 0.0f);
          specular = power_spec(specular);
          float s1 = 1.0f;
          float s2 = 1.0f;
          if (rtx->obj[rtx->hit].flag_shadow)
          {
            rtx->ray.dir = l;
            rtx->ray.pos = next.pos;
            trace_ray(rtx);
            int shadow = (rtx->dist < norm(lv));
            s1 = shadow ? 0.5f : s1;
            s2 = shadow ? 0.0f : s2;
          }
          col = vec3_add(col, vec3_add(vec3_scale(rtx->light.col, specular * s2), vec3_scale(hit_obj_col, diffuse * s1)));
          if (!rtx->obj[prev_hit_index].flag_refrect)
          {
            break;
          }
          rtx->ray.dir = vec3_sub(next.dir, vec3_scale(n, dot(next.dir, n) * 2.0f));
          rtx->ray.pos = next.pos;
        }
        else
        {
          break;
        }
      }
      col = vec3_min(vec3_max(col, 0.0f), 1.0f);
      uint32_t col2 = 0xff000000 + ((unsigned int)(col.x * 255.0f) << 16) + ((unsigned int)(col.y * 255.0f) << 8) + (unsigned int)(col.z * 255.0f);
      *pixel = col2;
#if SCALE > 1
      *(pixel + 1) = col2;
#endif
#if SCALE > 3
      *(pixel + 2) = col2;
      *(pixel + 3) = col2;
#endif
      pixel += SCALE;
      sx += rtx->ax;
    }
    uint32_t size = rtx->width * SCALE;
    unsigned int i;
    for (i = 1; i < SCALE; i++)
    {
      uint32_t *dst = src + i * msg->fbinfo.line_length / sizeof(uint32_t);
      unsigned int j;
      for (j = 0; j < size; j++)
      {
        dst[j] = src[j];
      }
    }
    sy -= rtx->ay;
  }
}

int main(int argc, char ** argv)
{
  static msg_block_t msg;
  memset((void *)&msg, 0, sizeof(msg));
  struct timespec time;
  double time0, time1;
  uint32_t notes[SCALE_PATTERN][NOTES_SIZE];
  uint32_t scales[SCALE_PATTERN][SCALE_SIZE] = {
    {0,4,7,9,},
    {0,5,7,9,},
    {2,4,7,11,},
    {2,5,7,9,},
    {2,5,7,11,},
    {0,2,4,7,},
    {0,2,5,7,},
    {0,2,5,9,},
  };
  uint32_t instruments[] = {
    0, 4, 5, 6, 8, 9, 11, 14, 15, 16, 17, 19, 24,
    25, 26, 30, 40, 42, 46, 48, 51, 52, 56, 57, 60,
    61, 63, 64, 65, 68, 69, 70, 73, 88, 89, 91, 93,
    94, 95, 98, 99, 103, 104, 110, 
  };
  uint32_t insts = sizeof(instruments) / sizeof(uint32_t);

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
    close(fb);
  }

  long pagesize = (sysconf(_SC_PAGESIZE));
  int fdmem = open(MEMDEV, O_RDWR | O_SYNC);
  uint32_t *frame_buffer = NULL;
  size_t mapsize = 0;
  if ((fdmem > 0) && (msg.fbinfo.smem_start != 0))
  {
    off_t physical_page = msg.fbinfo.smem_start & (~(pagesize - 1));
    unsigned long offset = msg.fbinfo.smem_start - (unsigned long)physical_page;
    mapsize = msg.fbinfo.smem_len + offset;
    frame_buffer = mmap(NULL, mapsize, PROT_READ | PROT_WRITE, MAP_SHARED, fdmem, physical_page);
    if (frame_buffer == MAP_FAILED)
    {
      perror("Framebuffer Map Failed");
    }
  }

  struct timespec time_start;
  clock_gettime(CLOCK_MONOTONIC_RAW, &time_start);
  srand((uint32_t)time_start.tv_nsec);

  seq_context_t seq;

  if (open_sequencer(&seq) == FALSE)
  {
    exit(EXIT_FAILURE);
  }
  program_change(&seq, 0, 48);
  control_change(&seq, 0, 91, 127);

  static rt_context_t rtx;
  memset((void *)&rtx, 0, sizeof(rtx));

  int width = msg.fbinfo.xres_virtual;
  int height = msg.fbinfo.yres_virtual;
  rtx.objnum = OBJNUM;
  rtx.light.pos = vec3_set(-4.0f, 8.0f, 2.0f);
  rtx.light.col = vec3_set(1.0f, 1.0f, 1.0f);
  rtx.eye = vec3_set(0.0f, 0.0f, -7.0f);
  rtx.swidth = 10.0f * (float)width / (float)height;
  rtx.sheight = 10.0f;
  rtx.width = width / SCALE;
  rtx.height = height / SCALE;
  rtx.xoff = 0;
  rtx.yoff = 0;
  rtx.ax = rtx.swidth / (float)rtx.width;
  rtx.ayc = rtx.sheight / (float)rtx.height;
  rtx.ay = rtx.sheight / (float)rtx.height;

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

  uint32_t scale = 0;
  uint32_t curobj = 0;
  float next_note_time = get_elapsed(time_start) + 3.0f;
  float next_scale_time = get_elapsed(time_start) + 15.0f + randf() * 15.0f;
  float time_now = get_elapsed(time_start);
  float time_quit = time_now + 3600.0f;
  uint32_t retry_count = 0;
  uint32_t counter = 0;
  float time_prev = 0.0f;
  while(time_now < time_quit)
  {
    uint32_t e;
    for (e = 1; e < rtx.objnum; e++)
    {
      rtx.obj[e].pos = vec3_add(rtx.obj[e].pos, rtx.obj[e].spd);
    }
    time_now = get_elapsed(time_start);
    if (time_now > next_note_time)
    {
      e = (curobj % (rtx.objnum - 1)) + 1;
      rtx.obj[e].pos = vec3_set(randf()*8.0f-4.0f, randf()*6.0f-1.0f, randf()*8.0+0.0f);
      rtx.obj[e].col = vec3_set(randf(), randf(), randf());
      rtx.obj[e].spd = vec3_set(randf()*0.1f-0.05f,randf()*0.1f-0.05f,randf()*0.1f-0.05f);
      note_off(&seq, 0, rtx.obj[e].note);
      rtx.obj[e].note = notes[scale][(uint32_t)(randf() * 17.0f) + 12];
      note_on(&seq, 0, rtx.obj[e].note, 127 - rtx.obj[e].note);
      curobj++;
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

    render(&msg, &rtx, frame_buffer);

    counter++;
    if (counter > 100)
    {
      //printf("FPS: %.2f\n", 100.0f / (time_now - time_prev));
      time_prev = time_now;
      counter = 0;
    }
  }

  close_sequencer(&seq);
  munmap(frame_buffer, mapsize);
  close(fdmem);
  return 0;
}
