#include "e_lib.h"
#include "shared_data.h"
#include "fastmath.h"

#define BUF_ADDRESS 0x8e000000
#define FRAME_ADDRESS (BUF_ADDRESS + sizeof(msg_block_t))
#define PAGE_OFFSET 0x2000
#define PAGE_SIZE 0x2000
#define ROWS 4
#define COLS 4

#define NSUBSAMPLES 1
#define NAO_SAMPLES 4

unsigned int wang_hash(unsigned int seed) {
  seed = (seed ^ 61) ^ (seed >> 16);
  seed *= 9;
  seed = seed ^ (seed >> 4);
  seed *= 0x27d4eb2d;
  seed = seed ^ (seed >> 15);
  return seed;
}

// Assume 32bit environment.
inline float fast_sign(float f) {
  float r = 1.0f;
  *((int *)(&r)) |= (*(int *)(&f) & 0x80000000); // mask sign bit in f, set it
                                                 // in r if necessary
  return r;
}

inline float fast_fabs(float x) {
  int f = ((*(int *)(&x)) & 0x7FFFFFFF);
  return *(float *)(&f);
}

// from: http://www.devmaster.net/forums/showthread.php?t=5784
inline float fast_cos(float x) {
  // bring into range [-1,1]
  x = (x + (float)M_PI_2) * (float)M_1_PI;
  // wrap around
  volatile float z =
      (x + 25165824.0f); // must be volatile else it will be optimized out
  x -= (z - 25165824.0f);
  // low precision approximation: return 4.0f * (x - x * fabs(x));
  // higher precision path
  float y = x - x * fast_fabs(x);
  // next iteration for higher precision
  const float Q = 3.1f;
  const float P = 3.6f;
  return y * (Q + P * fast_fabs(y));
}

// from: http://www.devmaster.net/forums/showthread.php?t=5784
inline float fast_sin(float x) {
  // bring into range [-1,1]
  x *= (float)M_1_PI;
  // wrap around
  volatile float z =
      (x + 25165824.0f); // must be volatile else it will be optimized out
  x -= (z - 25165824.0f);
  // low precision approximation: return 4.0f * (x - x * fabs(x));
  // higher precision path
  float y = x - x * fast_fabs(x);
  // next iteration for higher precision
  const float Q = 3.1f;
  const float P = 3.6f;
  return y * (Q + P * fast_fabs(y));
}

static inline float fast_inv_sqrt(float a) {
  union fi32_u {
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

static inline float fast_sqrt(float a) { return fast_inv_sqrt(a) * a; }

static inline float fast_inv(float a) {
  float b = fast_inv_sqrt(fast_fabs(a));
  return fast_sign(a) * b * b;
}

static unsigned long seed_x = 123456789;

void setseed(unsigned long val) { seed_x = val; }

// based on xorshift
float frandom() {
  static unsigned long y = 362436069, z = 521288629, w = 88675123;
  unsigned long x = seed_x;
  unsigned long t;
  t = (x ^ (x << 11));
  seed_x = y;
  y = z;
  z = w;
  w = (w ^ (w >> 19)) ^ (t ^ (t >> 8));

  return (w * (1.0f / 4294967296.0f));
}

typedef struct _vec {
  float x;
  float y;
  float z;
} vec;

typedef struct _Isect {
  float t;
  vec p;
  vec n;
  int hit;
} Isect;

typedef struct _Sphere {
  vec center;
  float radius;

} Sphere;

typedef struct _Plane {
  vec p;
  vec n;

} Plane;

typedef struct _Ray {
  vec org;
  vec dir;
} Ray;

Sphere spheres[3];
Plane plane;

static float vdot(vec v0, vec v1) {
  return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
}

static void vcross(vec *c, vec v0, vec v1) {

  c->x = v0.y * v1.z - v0.z * v1.y;
  c->y = v0.z * v1.x - v0.x * v1.z;
  c->z = v0.x * v1.y - v0.y * v1.x;
}

static void vnormalize(vec *c) {
  float length = fast_sqrt(vdot((*c), (*c)));

  if (fast_fabs(length) > 1.0e-6f) {
    float inv_len = fast_inv(length);
    c->x *= inv_len;
    c->y *= inv_len;
    c->z *= inv_len;
  }
}

void ray_sphere_intersect(Isect *isect, const Ray *ray, const Sphere *sphere) {
  vec rs;

  rs.x = ray->org.x - sphere->center.x;
  rs.y = ray->org.y - sphere->center.y;
  rs.z = ray->org.z - sphere->center.z;

  float B = vdot(rs, ray->dir);
  float C = vdot(rs, rs) - sphere->radius * sphere->radius;
  float D = B * B - C;

  if (D > 0.0f) {
    float t = -B - fast_sqrt(D);

    if ((t > 0.0) && (t < isect->t)) {
      isect->t = t;
      isect->hit = 1;

      isect->p.x = ray->org.x + ray->dir.x * t;
      isect->p.y = ray->org.y + ray->dir.y * t;
      isect->p.z = ray->org.z + ray->dir.z * t;

      isect->n.x = isect->p.x - sphere->center.x;
      isect->n.y = isect->p.y - sphere->center.y;
      isect->n.z = isect->p.z - sphere->center.z;

      vnormalize(&(isect->n));
    }
  }
}

void ray_plane_intersect(Isect *isect, const Ray *ray, const Plane *plane) {
  float d = -vdot(plane->p, plane->n);
  float v = vdot(ray->dir, plane->n);

  if (fast_fabs(v) < 1.0e-6f)
    return;

  float t = -(vdot(ray->org, plane->n) + d) * fast_inv(v);

  if ((t > 0.0f) && (t < isect->t)) {
    isect->t = t;
    isect->hit = 1;

    isect->p.x = ray->org.x + ray->dir.x * t;
    isect->p.y = ray->org.y + ray->dir.y * t;
    isect->p.z = ray->org.z + ray->dir.z * t;

    isect->n = plane->n;
  }
}

void orthoBasis(vec *basis, vec n) {
  basis[2] = n;
  basis[1].x = 0.0f;
  basis[1].y = 0.0f;
  basis[1].z = 0.0f;

  if ((n.x < 0.6f) && (n.x > -0.6f)) {
    basis[1].x = 1.0f;
  } else if ((n.y < 0.6f) && (n.y > -0.6f)) {
    basis[1].y = 1.0f;
  } else if ((n.z < 0.6f) && (n.z > -0.6f)) {
    basis[1].z = 1.0f;
  } else {
    basis[1].x = 1.0f;
  }

  vcross(&basis[0], basis[1], basis[2]);
  vnormalize(&basis[0]);

  vcross(&basis[1], basis[2], basis[0]);
  vnormalize(&basis[1]);
}

void ambient_occlusion(vec *col, const Isect *isect) {
  int i, j;
  int ntheta = NAO_SAMPLES;
  int nphi = NAO_SAMPLES;
  float eps = 0.0001f;

  vec p;

  p.x = isect->p.x + eps * isect->n.x;
  p.y = isect->p.y + eps * isect->n.y;
  p.z = isect->p.z + eps * isect->n.z;

  vec basis[3];
  orthoBasis(basis, isect->n);

  float occlusion = 0.0f;

  for (j = 0; j < ntheta; j++) {
    for (i = 0; i < nphi; i++) {
      float theta = fast_sqrt(frandom());
      float phi = 2.0f * 3.141592f * frandom();

      float x = fast_cos(phi) * theta;
      float y = fast_sin(phi) * theta;
      float z = fast_sqrt(1.0f - theta * theta);

      // local -> global
      float rx = x * basis[0].x + y * basis[1].x + z * basis[2].x;
      float ry = x * basis[0].y + y * basis[1].y + z * basis[2].y;
      float rz = x * basis[0].z + y * basis[1].z + z * basis[2].z;

      Ray ray;

      ray.org = p;
      ray.dir.x = rx;
      ray.dir.y = ry;
      ray.dir.z = rz;

      Isect occIsect;
      occIsect.t = 1.0e+16f;
      occIsect.hit = 0;

      ray_sphere_intersect(&occIsect, &ray, &spheres[0]);
      ray_sphere_intersect(&occIsect, &ray, &spheres[1]);
      ray_sphere_intersect(&occIsect, &ray, &spheres[2]);
      ray_plane_intersect(&occIsect, &ray, &plane);

      if (occIsect.hit)
        occlusion += 1.0f;
    }
  }

  occlusion = (ntheta * nphi - occlusion) / (float)(ntheta * nphi);

  col->x = occlusion;
  col->y = occlusion;
  col->z = occlusion;
}

inline unsigned char clamp(float f) {
  int i = (int)(f * 255.5);

  if (i < 0)
    i = 0;
  if (i > 255)
    i = 255;

  return (unsigned char)i;
}

void init_scene(float timeval) {
#if 0
    spheres[0].center.x = -2.0f;
    spheres[0].center.y =  0.0f;
    spheres[0].center.z = -3.5f;
    spheres[0].radius = 0.5f;
    
    spheres[1].center.x = -0.5f;
    spheres[1].center.y =  0.0f;
    spheres[1].center.z = -3.0f;
    spheres[1].radius = 0.5f;
    
    spheres[2].center.x =  1.0f;
    spheres[2].center.y =  0.0f;
    spheres[2].center.z = -2.2f;
    spheres[2].radius = 0.5f;
#else
  spheres[0].center.x = -1.0f + fast_sin(timeval);
  spheres[0].center.y = 1.0f;
  spheres[0].center.z = -4.5f + fast_cos(timeval);
  spheres[0].radius = 1.5f;

  spheres[1].center.x = 1.5f + fast_cos(timeval);
  spheres[1].center.y = 0.5f;
  spheres[1].center.z = -3.5f + fast_sin(timeval);
  spheres[1].radius = 1.0f;

  spheres[2].center.x = 0.5f + fast_cos(timeval * 2.3f);
  spheres[2].center.y = 0.0f;
  spheres[2].center.z = -3.2f + fast_sin(timeval * 2.3f);
  spheres[2].radius = 0.5f;

#endif

  plane.p.x = 0.0f;
  plane.p.y = -0.5f;
  plane.p.z = 0.0f;

  plane.n.x = 0.0f;
  plane.n.y = 1.0f;
  plane.n.z = 0.0f;
}

int main(void) {
  e_coreid_t coreid;
  coreid = e_get_coreid();
  unsigned int row, col, core, cores;
  e_coords_from_coreid(coreid, &row, &col);
  core = row * COLS + col;
  cores = ROWS * COLS;
  unsigned int frame = 1;
  unsigned int page = 0;
  volatile msg_block_t *msg = (msg_block_t *)BUF_ADDRESS;
  fbinfo_t fbinfo;
  unsigned int w = WIDTH;
  unsigned int h = HEIGHT;
#ifdef FB_DIRECT_COPY
  unsigned int xoff = 0;
  unsigned int yoff = 0;

  /* Cache local copy of fbinfo */
  e_dma_copy(&fbinfo, (void *) &msg->fbinfo, sizeof(fbinfo));

  /* Paint in lower right corner */
  xoff = fbinfo.xres - w - 32;
  yoff = fbinfo.yres - h - 32;
#endif

  setseed(wang_hash(cores));

  while (1) {
    msg->msg_d2h[core].coreid = coreid;
    msg->msg_d2h[core].value = frame;
    frame++;
    __asm__ __volatile__("trap 4");

    unsigned int x, y;
    unsigned int v, u;

    init_scene((float)frame * 0.1f);

    for (y = 0; y < h; y += cores) { // render scanline in parallel
      for (x = 0; x < w; x++) {

        float out_col[3] = { 0.0f, 0.0f, 0.0f };

        for (v = 0; v < NSUBSAMPLES; v++) {
          for (u = 0; u < NSUBSAMPLES; u++) {

            float px = (x + (u / (float)NSUBSAMPLES) - (w * 0.5f)) / (w * 0.5f);
            float py = -(y + core + (v / (float)NSUBSAMPLES) - (h * 0.5f)) /
                       (h * 0.5f);

            Ray ray;

            ray.org.x = 0.0f;
            ray.org.y = 0.0f;
            ray.org.z = 1.0f;

            ray.dir.x = px;
            ray.dir.y = py;
            ray.dir.z = -1.0f;
            vnormalize(&(ray.dir));

            Isect isect;
            isect.t = 1.0e+6f;
            isect.hit = 0.0f;

            ray_sphere_intersect(&isect, &ray, &spheres[0]);
            ray_sphere_intersect(&isect, &ray, &spheres[1]);
            ray_sphere_intersect(&isect, &ray, &spheres[2]);
            ray_plane_intersect(&isect, &ray, &plane);

            if (isect.hit) {
              vec col;
              ambient_occlusion(&col, &isect);

              out_col[0] += col.x;
              out_col[1] += col.y;
              out_col[2] += col.z;
            }
          }
        }

        out_col[0] /= (float)(NSUBSAMPLES * NSUBSAMPLES);
        out_col[1] /= (float)(NSUBSAMPLES * NSUBSAMPLES);
        out_col[2] /= (float)(NSUBSAMPLES * NSUBSAMPLES);

        unsigned int rgba = (clamp(out_col[0]) << 16) |
                            (clamp(out_col[1]) << 8) | (clamp(out_col[2]));

        *(unsigned int *)(PAGE_OFFSET + page *PAGE_SIZE + x *BPP) = rgba;
      }

#ifdef FB_DIRECT_COPY
      // send scanline directly to framebuffer
      e_dma_copy((char *)(fbinfo.smem_start + xoff * BPP +
                          (y + core + yoff) * fbinfo.line_length),
                 (char *)(PAGE_OFFSET + page * PAGE_SIZE), w * BPP);
#else
      // send line to intermediate host buffer
      e_dma_copy((char *)(FRAME_ADDRESS + (y + core) * w * BPP),
                 (char *)(PAGE_OFFSET + page * PAGE_SIZE), w * BPP);
#endif

      page = page ^ 1;
    }
  }
  return 0;
}
