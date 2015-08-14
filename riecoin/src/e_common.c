// Common epiphany code between prime testing and mod p calculation.
//
// Multiprecision code is taken from the GMP library, mostly from mini-gmp.
// Additionally the unsigned division is a modification of the epiphany
// udivsi3 implementation in GCC.
// All other code and modifications to the above are copyright Mike Bell 2015.
//
// You may use this source in accordance with the GPLv3 license
// For portions of source code authored by Mike Bell that are not derived works
// of GPL licensed code, Mike Bell grants permission for them to be reused
// freely in any projects (commercial or open source) under any license.
// Please contact him if you would like clarification on that.

struct gmp_div_inverse
{
  /* Normalization shift count. */
  unsigned shift;
  /* Normalized divisor (d0 unused for mpn_div_qr_1) */
  mp_limb_t d1, d0;
  /* Inverse, for 2/1 or 3/2. */
  mp_limb_t di;
};

#define CHAR_BIT 8
#define GMP_LIMB_BITS (sizeof(mp_limb_t) * CHAR_BIT)

#define GMP_LIMB_MAX (~ (mp_limb_t) 0)
#define GMP_LIMB_HIGHBIT ((mp_limb_t) 1 << (GMP_LIMB_BITS - 1))

#define GMP_HLIMB_BIT ((mp_limb_t) 1 << (GMP_LIMB_BITS / 2))
#define GMP_LLIMB_MASK (GMP_HLIMB_BIT - 1)

#define Q_LEN 7
mp_limb_t primorial[Q_LEN] = { 3990313926u, 1301064672u, 203676164u, 3309914335u, 2220064684u, 2929319840u, 153406374u };

#define gmp_add_ssaaaa(sh, sl, ah, al, bh, bl) \
  do {                                                                  \
    mp_limb_t __x;                                                      \
    __x = (al) + (bl);                                                  \
    (sh) = (ah) + (bh) + (__x < (al));                                  \
    (sl) = __x;                                                         \
  } while (0)

#define gmp_umul_ppmm(w1, w0, u, v)                                     \
  do {                                                                  \
    mp_limb_t __x0, __x1, __x2, __x3;                                   \
    unsigned __ul, __vl, __uh, __vh;                                    \
    mp_limb_t __u = (u), __v = (v);                                     \
                                                                        \
    __ul = __u & GMP_LLIMB_MASK;                                        \
    __uh = __u >> (GMP_LIMB_BITS / 2);                                  \
    __vl = __v & GMP_LLIMB_MASK;                                        \
    __vh = __v >> (GMP_LIMB_BITS / 2);                                  \
                                                                        \
    __x0 = (mp_limb_t) __ul * __vl;                                     \
    __x1 = (mp_limb_t) __ul * __vh;                                     \
    __x2 = (mp_limb_t) __uh * __vl;                                     \
    __x3 = (mp_limb_t) __uh * __vh;                                     \
                                                                        \
    __x1 += __x0 >> (GMP_LIMB_BITS / 2);/* this can't give carry */     \
    __x1 += __x2;               /* but this indeed can */               \
    if (__x1 < __x2)            /* did we get it? */                    \
      __x3 += GMP_HLIMB_BIT;    /* yes, add it in the proper pos. */    \
                                                                        \
    (w1) = __x3 + (__x1 >> (GMP_LIMB_BITS / 2));                        \
    (w0) = (__x1 << (GMP_LIMB_BITS / 2)) + (__x0 & GMP_LLIMB_MASK);     \
  } while (0)

#define mpn_invert_limb(x) mpn_invert_3by2 ((x), 0)

// Divide algorithm modified version of the builtin udivsi3
// original source: libgcc/config/epiphany/udivsi3-float.c
static unsigned int
udiv (unsigned int a, unsigned int b)
{
  unsigned int d, t, s0, s1, r0, r1;

  if (a < b)
    return 0;
  if (b & 0x80000000)
    return 1;

  /* Assuming B is nonzero, compute S0 such that 0 <= S0,
     (B << S0+1) does not overflow,
     A < 4.01 * (B << S0), with S0 chosen as small as possible
     without taking to much time calculating.  */
#if 1
  {
    unsigned config = 0x1;
    asm volatile (
      "movts config, %[config]\n\t"
      "mov %[r0], #1\n\t"
      "  float %[s0], %[a]\n\t"
      "movt %[config], #8\n\t"
      "  float %[s1], %[b]\n\t"
      "mov %[d], #1\n\t"
      "lsr %[s0], %[s0], #23\n\t"
      "lsr %[s1], %[s1], #23\n\t"
      "movts config, %[config]\n\t"
      "sub %[s0], %[s0], #1\n\t"
      "  isub %[r1], %[config], %[config]\n\t"
      "sub %[s0], %[s0], %[s1]\n\t"
      "lsl %[b], %[b], %[s0]\n\t"
      "lsl %[r0], %[r0], %[s0]\n\t"
      "sub %[s1], %[a], %[b]\n\t"
      "  isub %[d], %[b], %[d]\n\t"
      "bltu .aina%=\n\t" 
      "sub %[a], %[s1], %[b]\n\t"
      "  iadd %[r1], %[r1], %[r0]\n\t"
      "bltu .ains1%=\n\t" 
      "lsl %[r1], %[r0], #1\n\t"
      "sub %[s1], %[a], %[b]\n\t"
      "bltu .aina%=\n\t" 
      "  iadd %[r1], %[r1], %[r0]\n"
  ".ains1%=:\tmov %[a], %[s1]\n"
  ".aina%=:\t\n\t"
      
 :
      [config] "+r" (config), [s0] "=r" (s0), [s1] "=r" (s1), [d] "=r" (d),
      [a] "+r" (a), [b] "+r" (b), [r0] "=r" (r0), [r1] "=r" (r1));
  }
#else
  gmp_clz(s0, a);
  gmp_clz(s1, b);
  s0 = 32 - s0;
  s1 = (32 - s1) + 1;
  s0 -= s1;

  b <<= s0;
  r1 = 0;

  r0 = 1 << s0;
  a = ((t=a) - b);
  if (a <= t)
    {
      r1 += r0;
      a = ((t=a) - b);
      if (a <= t)
      {
        r1 += r0;
        a = ((t=a) - b);
        if (a <= t)
        {
          r1 += r0;
          a = ((t=a) - b);
        }
      }
    }
  a += b;
  d = b - 1;
#endif

#define STEP(n) case n: a += a; t = a - d; if (t <= a) a = t;
  switch (s0)
    {
    STEP (30)
    STEP (29)
    STEP (28)
    STEP (27)
    STEP (26)
    STEP (25)
    STEP (24)
    STEP (23)
    STEP (22)
    STEP (21)
    STEP (20)
    STEP (19)
    STEP (18)
    STEP (17)
    STEP (16)
    STEP (15)
    STEP (14)
    STEP (13)
    STEP (12)
    STEP (11)
    STEP (10)
    STEP (9)
    STEP (8)
    STEP (7)
    STEP (6)
    STEP (5)
    STEP (4)
    STEP (3)
    STEP (2)
    STEP (1)
    case 0: ;
    }
#undef STEP
  r0 = r1 | ((r0-1) & a);
  return r0;
}

static mp_limb_t
mpn_invert_3by2 (mp_limb_t u1, mp_limb_t u0)
{
  mp_limb_t r, p, m;
  unsigned ul, uh;
  unsigned ql, qh;

  /* First, do a 2/1 inverse. */
  /* The inverse m is defined as floor( (B^2 - 1 - u1)/u1 ), so that 0 <
   * B^2 - (B + m) u1 <= u1 */
  assert (u1 >= GMP_LIMB_HIGHBIT);

  ul = u1 & GMP_LLIMB_MASK;
  uh = u1 >> (GMP_LIMB_BITS / 2);

  qh = udiv(~u1, uh);
  r = ((~u1 - (mp_limb_t) qh * uh) << (GMP_LIMB_BITS / 2)) | GMP_LLIMB_MASK;

  p = (mp_limb_t) qh * ul;
  /* Adjustment steps taken from udiv_qrnnd_c */
  if (r < p)
    {
      qh--;
      r += u1;
      if (r >= u1) /* i.e. we didn't get carry when adding to r */
        if (r < p)
          {
            qh--;
            r += u1;
          }
    }
  r -= p;

  /* Do a 3/2 division (with half limb size) */
  p = (r >> (GMP_LIMB_BITS / 2)) * qh + r;
  ql = (p >> (GMP_LIMB_BITS / 2)) + 1;

  /* By the 3/2 method, we don't need the high half limb. */
  r = (r << (GMP_LIMB_BITS / 2)) + GMP_LLIMB_MASK - ql * u1;

  if (r >= (p << (GMP_LIMB_BITS / 2)))
    {
      ql--;
      r += u1;
    }
  m = ((mp_limb_t) qh << (GMP_LIMB_BITS / 2)) + ql;
  if (r >= u1)
    {
      m++;
      r -= u1;
    }

  if (u0 > 0)
    {
      mp_limb_t th, tl;
      r = ~r;
      r += u0;
      if (r < u0)
        {
          m--;
          if (r >= u1)
            {
              m--;
              r -= u1;
            }
          r -= u1;
        }
      gmp_umul_ppmm (th, tl, u0, m);
      r += th;
      if (r < th)
        {
          m--;
          m -= ((r > u1) | ((r == u1) & (tl > u0)));
        }
    }

  return m;
}

static mp_limb_t
mpn_lshift (mp_ptr rp, mp_srcptr up, mp_size_t n, unsigned int cnt)
{
  mp_limb_t high_limb, low_limb;
  unsigned int tnc, cntmul;
  mp_size_t i;
  mp_limb_t retval;

  assert (n >= 1);
  assert (cnt >= 1);
  assert (cnt < GMP_LIMB_BITS);

  up += n;
  rp += n;

  tnc = GMP_LIMB_BITS - cnt;
  cntmul = 1<<cnt;
  low_limb = *--up;
  retval = low_limb >> tnc;
  high_limb = (low_limb * cntmul);

  for (i = n; --i != 0;)
    {
      low_limb = *--up;
      *--rp = high_limb | (low_limb >> tnc);
      high_limb = (low_limb * cntmul);
    }
  *--rp = high_limb;

  return retval;
}

