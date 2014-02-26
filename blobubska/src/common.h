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

#define OBJNUM 9
#define CORES 16
#define ALIGN8 8
// SCALE: 1, 2, or 4
#define SCALE 2

typedef struct __attribute__((aligned(ALIGN8)))
{
  uint32_t value;
  uint32_t coreid;
} msg_dev2host_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  uint32_t value;
} msg_host2dev_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  uint32_t smem_start;
  uint32_t smem_len;
  uint32_t line_length;
  uint32_t xres;
  uint32_t yres;
  uint32_t xres_virtual;
  uint32_t yres_virtual;
  uint32_t xoffset;
  uint32_t yoffset;
  uint32_t bits_per_pixel;
} fbinfo_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  msg_dev2host_t msg_d2h[CORES];
  fbinfo_t fbinfo;
} msg_block_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  float x;
  float y;
  float z;
} vec3_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  vec3_t pos;
  vec3_t dir;
} ray_t;

typedef enum __attribute__((aligned(ALIGN8)))
{
  SPHERE,
  PLANE,
  LIGHT,
} obj_type_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  union
  {
    vec3_t pos;
    vec3_t norm;
  };
  union
  {
    float rad;
    float dist;
  };
  vec3_t spd;
  vec3_t col;
  int32_t flag_shadow;
  int32_t flag_refrect;
  uint32_t note;
  obj_type_t type;
} obj_t;

typedef struct __attribute__((aligned(ALIGN8)))
{
  obj_t obj[OBJNUM];
  obj_t light;
  ray_t ray;
  vec3_t eye;
  float swidth;
  float sheight;
  float ax;
  float ay;
  float ayc;
  uint32_t width;
  uint32_t height;
  uint32_t xoff;
  uint32_t yoff;
  uint32_t xdiv;
  uint32_t objnum;
  float dist;
  int32_t hit;
  uint32_t curobj;
} rt_context_t;

static inline float min(float a, float b)
{
  float r;
  r = (a < b) ? a : b;
  return r;
}

static inline float max(float a, float b)
{
  float r;
  r = (a > b) ? a : b;
  return r;
}

static inline float fast_inv_sqrt(float a)
{
  union fi32_u
  {
    float f;
    int32_t i;
  };
  union fi32_u x;
  x.f = a;
  x.i = 0x5f3759df - (x.i >> 1);
  x.f = x.f * (1.5f - x.f * x.f * 0.5f * a);
  x.f = x.f * (1.5f - x.f * x.f * 0.5f * a);
  return x.f;
}

static inline float fast_sqrt(float a)
{
  union fu32_u
  {
    float f;
    uint32_t u;
  };
  union fu32_u x;
  x.f = a;
  x.u += 0x7f << 23;
  x.u >>= 1;
  return x.f;
}

static inline float fast_inv(float a)
{
  union fu32_u
  {
    float f;
    uint32_t u;
  };
  union fu32_u x;
  x.f = a;
  x.u = 0x7eeeeeee - x.u;
  x.f = x.f * (2.0f - a * x.f);
  return x.f;
}

static inline vec3_t vec3_set(float x, float y, float z)
{
  vec3_t r;
  r.x = x;
  r.y = y;
  r.z = z;
  return r;
}

static inline vec3_t vec3_add(vec3_t a, vec3_t b)
{
  vec3_t r;
  r.x = a.x + b.x;
  r.y = a.y + b.y;
  r.z = a.z + b.z;
  return r;
}

static inline vec3_t vec3_sub(vec3_t a, vec3_t b)
{
  vec3_t r;
  r.x = a.x - b.x;
  r.y = a.y - b.y;
  r.z = a.z - b.z;
  return r;
}

static inline vec3_t vec3_scale(vec3_t a, float b)
{
  vec3_t r;
  r.x = a.x * b;
  r.y = a.y * b;
  r.z = a.z * b;
  return r;
}

static inline vec3_t vec3_min(vec3_t a, float b)
{
  vec3_t r;
  r.x = (a.x < b) ? a.x : b;
  r.y = (a.y < b) ? a.y : b;
  r.z = (a.z < b) ? a.z : b;
  return r;
}

static inline vec3_t vec3_max(vec3_t a, float b)
{
  vec3_t r;
  r.x = (a.x > b) ? a.x : b;
  r.y = (a.y > b) ? a.y : b;
  r.z = (a.z > b) ? a.z : b;
  return r;
}

static inline float dot(vec3_t a, vec3_t b)
{
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

static inline float norm2(vec3_t a)
{
  return a.x * a.x + a.y * a.y + a.z * a.z;
}

static inline float norm(vec3_t a)
{
  return fast_sqrt(norm2(a));
}

static inline vec3_t cross(vec3_t a, vec3_t b)
{
  vec3_t r;
  r.x = a.y * b.z - a.z * b.y;
  r.y = a.z * b.x - a.x * b.z;
  r.z = a.x * b.y - a.y * b.x;
  return r;
}

static inline vec3_t normalize(vec3_t a)
{
  vec3_t r;
  float b = fast_inv_sqrt(norm2(a));
  r.x = a.x * b;
  r.y = a.y * b;
  r.z = a.z * b;
  return r;
}

static inline float power_spec(float a)
{
  float b = a * a;
  float c = b * b;
  return c * c;
}
