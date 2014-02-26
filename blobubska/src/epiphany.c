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

#include "e-lib.h"
#include "common.h"

#define BPP 4
#define EPSILON 0.0001f
#define NOHIT 0xffffffff
#define FARDIST 1.0e+18f
#define TRUE 1
#define FALSE 0

#define BUF_ADDRESS 0x8f000000
#define PAGE_OFFSET 0x2000
#define PAGE_SIZE 0x2000
#define MAXREF 4

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

int main(void)
{
  msg_block_t msg;
  msg_block_t *shared_msg = (msg_block_t *)(BUF_ADDRESS);
  rt_context_t rtx;
  rt_context_t *shared_rtx = (rt_context_t *)(BUF_ADDRESS + sizeof(msg_block_t));
  e_coreid_t coreid = e_get_coreid();
  unsigned int row, col, core, cores;
  e_coords_from_coreid(coreid, &row, &col);
  core = row * e_group_config.group_cols + col;
  cores = e_group_config.group_rows * e_group_config.group_cols;
  unsigned int frame = 1;
  unsigned int page = 0;

  e_dma_copy(&msg, shared_msg, sizeof(msg_block_t));
  e_dma_copy(&rtx, shared_rtx, sizeof(rt_context_t));

  while (1)
  {
    msg.msg_d2h[core].coreid = coreid;
    msg.msg_d2h[core].value = frame;
    e_dma_copy(&shared_msg->msg_d2h[core], &msg.msg_d2h[core], sizeof(msg_dev2host_t));

    frame++;
    __asm__ __volatile__ ("trap 4");

    e_dma_copy(&rtx, shared_rtx, sizeof(rt_context_t));

    unsigned int *pixel;
    float sy = rtx.sheight * 0.5f - rtx.ayc * (float)core;
    unsigned int y;
    for (y = 0; y < rtx.height; y += cores)
    {
      float sx = rtx.swidth * -0.5f;
      unsigned int xl;
      for (xl = 0; xl < rtx.xdiv; xl++)
      {
        char *src = (char *)(PAGE_OFFSET + page * PAGE_SIZE);
        pixel = (unsigned int *)src;
        unsigned int x;
        for (x = 0; x < rtx.width; x++)
        {
          rtx.ray.pos = rtx.eye;
          rtx.ray.dir = normalize(vec3_sub(vec3_set(sx, sy, 0.0f), rtx.eye));
          vec3_t col = vec3_set(0.0f, 0.0f, 0.0f);
          unsigned int j;
          for (j = 0; j < MAXREF; j++)
          {
            trace_ray(&rtx);
            if (rtx.hit != NOHIT)
            {
              vec3_t p, n;
              ray_t next;
              p = vec3_add(rtx.ray.pos, vec3_scale(rtx.ray.dir, rtx.dist));
              switch (rtx.obj[rtx.hit].type)
              {
                case SPHERE:
                  n = normalize(vec3_sub(p, rtx.obj[rtx.hit].pos));
                  break;
                case PLANE:
                  n = rtx.obj[rtx.hit].norm;
                  break;
                default:
                  break;
              }
              next.pos = vec3_add(p, vec3_scale(n, EPSILON));
              vec3_t lv = vec3_sub(rtx.light.pos, p);
              vec3_t l = normalize(lv);
              next.dir = rtx.ray.dir;
              int prev_hit_index = rtx.hit;
              vec3_t hit_obj_col = rtx.obj[rtx.hit].col;
              float diffuse = dot(n, l);
              float specular = dot(rtx.ray.dir, vec3_sub(l, vec3_scale(n, 2.0f * diffuse)));
              diffuse = max(diffuse, 0.0f);
              specular = max(specular, 0.0f);
              specular = power_spec(specular);
              float s1 = 1.0f;
              float s2 = 1.0f;
              if (rtx.obj[rtx.hit].flag_shadow)
              {
                rtx.ray.dir = l;
                rtx.ray.pos = next.pos;
                trace_ray(&rtx);
                int shadow = (rtx.dist < norm(lv));
                s1 = shadow ? 0.5f : s1;
                s2 = shadow ? 0.0f : s2;
              }
              col = vec3_add(col, vec3_add(vec3_scale(rtx.light.col, specular * s2), vec3_scale(hit_obj_col, diffuse * s1)));
              if (!rtx.obj[prev_hit_index].flag_refrect)
              {
                break;
              }
              rtx.ray.dir = vec3_sub(next.dir, vec3_scale(n, dot(next.dir, n) * 2.0f));
              rtx.ray.pos = next.pos;
            }
            else
            {
              break;
            }
          }
          col = vec3_min(vec3_max(col, 0.0f), 1.0f);
          uint32_t col2 = 0xff000000 + ((unsigned int)(col.x * 255.0f) << 16) + ((unsigned int)(col.y * 255.0f) << 8) + (unsigned int)(col.z * 255.0f);
          unsigned int k;
          for (k = 0; k < SCALE; k++)
          {
            *(pixel + k) = col2;
          }
/*
          *pixel = col2;
#if SCALE > 1
          *(pixel + 1) = col2;
#endif
#if SCALE > 3
          *(pixel + 2) = col2;
          *(pixel + 3) = col2;
#endif
*/
          pixel += SCALE;
          sx += rtx.ax;
        }
        char *dst = (char *)(msg.fbinfo.smem_start + (rtx.xoff + xl * rtx.width * SCALE) * BPP + ((y + core) * SCALE + rtx.yoff) * msg.fbinfo.line_length);
        uint32_t size = rtx.width * BPP * SCALE;
        unsigned int i;
        for (i = 0; i < SCALE; i++)
        {
          e_dma_copy(dst + i * msg.fbinfo.line_length, src, size);
        }
        page = page ^ 1;
      }
      sy -= rtx.ay;
    }
  }
  return 0;
}
