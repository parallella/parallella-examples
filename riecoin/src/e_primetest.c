// Epiphany implementation for testing for prime sextuplets.
// Candidates are of the form n + k.167# + {0,4,6,10,12,16}
// where n is large, k is < 2^31 and 167# is the product of primes <= 167.
// n and a small array of k values are read from shared memory by DMA transfer,
// results are written back to shared memory as they are computed.
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

#include "e_lib.h"
#define assert(x)

#include "ptest_data.h"

#include "e_common.c"

static ptest_indata_t inbuf;
static volatile unsigned wait_flag;

#undef MPN_REDC_1
#define MPN_REDC_1(rp, up, mp, n, invm)                                 \
  do {                                                                  \
    mp_limb_t cy;                                                       \
    cy = mpn_redc_1 (rp, up, mp, n, invm);                              \
    if (cy != 0)                                                        \
      mpn_sub_n (rp, rp, mshifted, n);                                  \
  } while (0)

const unsigned char  binvert_limb_table[128] = {
  0x01, 0xAB, 0xCD, 0xB7, 0x39, 0xA3, 0xC5, 0xEF,
  0xF1, 0x1B, 0x3D, 0xA7, 0x29, 0x13, 0x35, 0xDF,
  0xE1, 0x8B, 0xAD, 0x97, 0x19, 0x83, 0xA5, 0xCF,
  0xD1, 0xFB, 0x1D, 0x87, 0x09, 0xF3, 0x15, 0xBF,
  0xC1, 0x6B, 0x8D, 0x77, 0xF9, 0x63, 0x85, 0xAF,
  0xB1, 0xDB, 0xFD, 0x67, 0xE9, 0xD3, 0xF5, 0x9F,
  0xA1, 0x4B, 0x6D, 0x57, 0xD9, 0x43, 0x65, 0x8F,
  0x91, 0xBB, 0xDD, 0x47, 0xC9, 0xB3, 0xD5, 0x7F,
  0x81, 0x2B, 0x4D, 0x37, 0xB9, 0x23, 0x45, 0x6F,
  0x71, 0x9B, 0xBD, 0x27, 0xA9, 0x93, 0xB5, 0x5F,
  0x61, 0x0B, 0x2D, 0x17, 0x99, 0x03, 0x25, 0x4F,
  0x51, 0x7B, 0x9D, 0x07, 0x89, 0x73, 0x95, 0x3F,
  0x41, 0xEB, 0x0D, 0xF7, 0x79, 0xE3, 0x05, 0x2F,
  0x31, 0x5B, 0x7D, 0xE7, 0x69, 0x53, 0x75, 0x1F,
  0x21, 0xCB, 0xED, 0xD7, 0x59, 0xC3, 0xE5, 0x0F,
  0x11, 0x3B, 0x5D, 0xC7, 0x49, 0x33, 0x55, 0xFF
};

#define binvert_limb(inv,n)                                             \
  do {                                                                  \
    mp_limb_t  __n = (n);                                               \
    mp_limb_t  __inv;                                                   \
    assert ((__n & 1) == 1);                                            \
                                                                        \
    __inv = binvert_limb_table[(__n/2) & 0x7F]; /*  8 */                \
    __inv = 2 * __inv - __inv * __inv * __n;                            \
    __inv = 2 * __inv - __inv * __inv * __n;                            \
                                                                        \
    assert ((__inv * __n) == 1);                                        \
    (inv) = __inv;                                                      \
  } while (0)

#define gmp_clz(count, xx) do {                                         \
  if (xx & 0x80000000) (count) = 0;                                     \
  else {                                                                \
    unsigned config = 0x1;                                              \
    unsigned _x = (xx);                                                 \
    unsigned half = 0x3f000000;                                         \
    unsigned _res;                                                      \
    __asm__ __volatile__ (                                              \
      "movts config, %[config]\n\t"                                     \
      "nop\n\t"                                                         \
      "float %[x], %[x]\n\t"                                            \
      "movt %[config], #8\n\t"                                          \
      "fadd %[x], %[x], %[half]\n\t"                                    \
      "mov %[res], #158\n\t"                                            \
      "lsr %[x], %[x], #23\n\t"                                         \
      "movts config, %[config]\n\t"                                     \
      "sub %[res], %[res], %[x]\n\t" :                                  \
      [res] "=r" (_res),                                                \
      [config] "+r" (config), [x] "+r" (_x) :                           \
      [half] "r" (half));                                               \
    (count) = _res;                                                     \
  }} while (0)

#define gmp_sub_ddmmss(sh, sl, ah, al, bh, bl) \
  do {                                                                  \
    mp_limb_t __x;                                                      \
    __x = (al) - (bl);                                                  \
    (sh) = (ah) - (bh) - ((al) < (bl));                                 \
    (sl) = __x;                                                         \
  } while (0)

#define gmp_udiv_qr_3by2(q, r1, r0, n2, n1, n0, d1, d0, dinv)           \
  do {                                                                  \
    mp_limb_t _q0, _t1, _t0, _mask;                                     \
    gmp_umul_ppmm ((q), _q0, (n2), (dinv));                             \
    gmp_add_ssaaaa ((q), _q0, (q), _q0, (n2), (n1));                    \
                                                                        \
    /* Compute the two most significant limbs of n - q'd */             \
    (r1) = (n1) - (d1) * (q);                                           \
    gmp_sub_ddmmss ((r1), (r0), (r1), (n0), (d1), (d0));                \
    gmp_umul_ppmm (_t1, _t0, (d0), (q));                                \
    gmp_sub_ddmmss ((r1), (r0), (r1), (r0), _t1, _t0);                  \
    (q)++;                                                              \
                                                                        \
    /* Conditionally adjust q and the remainders */                     \
    _mask = - (mp_limb_t) ((r1) >= _q0);                                \
    (q) += _mask;                                                       \
    gmp_add_ssaaaa ((r1), (r0), (r1), (r0), _mask & (d1), _mask & (d0)); \
    if ((r1) >= (d1))                                                   \
      {                                                                 \
        if ((r1) > (d1) || (r0) >= (d0))                                \
          {                                                             \
            (q)++;                                                      \
            gmp_sub_ddmmss ((r1), (r0), (r1), (r0), (d1), (d0));        \
          }                                                             \
      }                                                                 \
  } while (0)

#if 0
static mp_size_t
mpn_normalized_size (mp_srcptr xp, mp_size_t n)
{
  for (; n > 0 && xp[n-1] == 0; n--)
    ;
  return n;
}
#endif

static mp_limb_t
mpn_sub_1 (mp_ptr rp, mp_srcptr ap, mp_size_t n, mp_limb_t b)
{
  mp_size_t i;

  assert (n > 0);

  i = 0;
  do
    {
      mp_limb_t a = ap[i];
      /* Carry out */
      mp_limb_t cy = a < b;;
      rp[i] = a - b;
      b = cy;
    }
  while (++i < n);

  return b;
}

static mp_limb_t
mpn_sub_n (mp_ptr rp, mp_srcptr ap, mp_srcptr bp, mp_size_t n)
{
  mp_size_t i;
  mp_limb_t cy;

  for (i = 0, cy = 0; i < n; i++)
    {
      mp_limb_t a, b;
      a = ap[i]; b = bp[i];
      b += cy;
      cy = (b < cy);
      cy += (a < b);
      rp[i] = a - b;
    }
  return cy;
}

static mp_limb_t
mpn_add_1_inplace(mp_ptr np, mp_size_t n, mp_limb_t a)
{
  for (mp_size_t i = 0; i < n && a; ++i)
  {
    mp_limb_t b = np[i];
    mp_limb_t r = b + a;
    a = r < b;
    np[i] = r;
  }
  return a;
}

static mp_limb_t
mpn_add_n (mp_ptr rp, mp_srcptr ap, mp_srcptr bp, mp_size_t n)
{
  mp_size_t i;
  mp_limb_t cy;

  for (i = 0, cy = 0; i < n; i++)
    {
      mp_limb_t a, b, r;
      a = ap[i]; b = bp[i];
      r = a + cy;
      cy = (r < cy);
      r += b;
      cy += (r < b);
      rp[i] = r;
    }
  return cy;
}

static mp_limb_t
mpn_add_n2 (mp_ptr rp, mp_srcptr ap, mp_size_t an, mp_srcptr bp, mp_size_t bn)
{
  mp_size_t i;
  mp_limb_t cy;
  assert(an >= bn);

  for (i = 0, cy = 0; i < bn; i++)
    {
      mp_limb_t a, b, r;
      a = ap[i]; b = bp[i];
      r = a + cy;
      cy = (r < cy);
      r += b;
      cy += (r < b);
      rp[i] = r;
    }

  for (; i < an; i++)
    {
      mp_limb_t a, r;
      a = ap[i];
      r = a + cy;
      cy = (r < cy);
      rp[i] = r;
    }

  return cy;
}

static void
mpn_div_qr_invert (struct gmp_div_inverse *inv,
                   mp_srcptr dp, mp_size_t dn)
{
  assert (dn > 2);

    {
      unsigned shift;
      mp_limb_t d1, d0;

      d1 = dp[dn-1];
      d0 = dp[dn-2];
      assert (d1 > 0);
      gmp_clz (shift, d1);
      inv->shift = shift;
      if (shift > 0)
        {
          d1 = (d1 << shift) | (d0 >> (GMP_LIMB_BITS - shift));
          d0 = (d0 << shift) | (dp[dn-3] >> (GMP_LIMB_BITS - shift));
        }
      inv->d1 = d1;
      inv->d0 = d0;
      inv->di = mpn_invert_3by2 (d1, d0);
    }
}

static mp_limb_t
mpn_mul_1 (mp_ptr rp, mp_srcptr up, mp_size_t n, mp_limb_t vl)
{
  mp_limb_t ul, cl, hpl, lpl;

  assert (n >= 1);

  cl = 0;
  do
    {
      ul = *up++;
      gmp_umul_ppmm (hpl, lpl, ul, vl);

      lpl += cl;
      cl = (lpl < cl) + hpl;

      *rp++ = lpl;
    }
  while (--n != 0);

  return cl;
}

static mp_limb_t
mpn_addmul_1 (mp_ptr rp, mp_srcptr up, mp_size_t n, mp_limb_t vl)
{
  mp_limb_t ul, cl, hpl, lpl, rl;
  mp_limb_t ul2, cl2, lpl2;
  mp_size_t halfn = n>>1;

  assert (n >= 1);

  cl = 0;
  if (n & 1)
    {
      ul = *up++;
      gmp_umul_ppmm (hpl, lpl, ul, vl);

      lpl += cl;
      cl = (lpl < cl) + hpl;

      rl = *rp;
      lpl = rl + lpl;
      cl += lpl < rl;
      *rp++ = lpl;

      n--;
    }

  cl2 = 0;

  if (n != 0)
    {
    unsigned vll; // = vl & 0xffff;
    unsigned vlh; // = vl >> 16;

      unsigned lowmask; // = 0xffff;
      unsigned one; // = 1;
      unsigned halfbit; // = 0x10000;
      unsigned halfnidx; // = halfn << 2;
      unsigned x1c, x5c, clc, clc2, clc3;
      unsigned x1, x2, x3, x4, x5, x6, x7;

#define REG(x) [x] "+r"(x)
#define TMP(x) [x] "=&r"(x)
#define OUTREG(x) [x] "=&r"(x)
#define INREG(x) [x] "r"(x)
#define CNST(x) [x] "r"(x)

      asm volatile ("\n\
	mov %[one], #1 \n\
	  isub r62, r62, r62 \n\
	lsl %[halfbit], %[one], #16 \n\
	  isub %[cl2], %[cl2], %[cl2] \n\
	lsl %[halfnidx], %[halfn], #2 \n\
	lsr %[vlh], %[vl], #16 \n\
	  isub %[lowmask], %[halfbit], %[one] \n\
        mov %[x1], %%low(1f) \n\
	  iadd r62, r62, %[up] \n\
        mov %[x2], %%low(2f) \n\
	  iadd r63, %[halfnidx], %[up] \n\
        movts ls, %[x1] \n\
        movts le, %[x2] \n\
        movts lc, %[halfn] \n\
	and %[vll], %[vl], %[lowmask] \n\
        gid \n\
.balignw 8,0x01a2 \n\
1: \n\
	ldr %[ul], [r62], #1 \n\
	ldr %[ul2], [r63], #1 \n\
  " :
	TMP(x1), TMP(x2),
	OUTREG(ul), OUTREG(ul2), REG(up),
	OUTREG(lowmask), OUTREG(one), OUTREG(halfbit), OUTREG(halfnidx),
	OUTREG(vll), OUTREG(vlh), OUTREG(cl2) :
	INREG(halfn), INREG(vl) : "cc", "r62", "r63");

      asm volatile ("\n\
	and %[x1], %[ul], %[lowmask]    \n\
	  isub %[x1c], %[one], %[one]    \n\
	lsr %[x3], %[ul], #16           \n\
	and %[x6], %[ul2], %[lowmask]  \n\
	  imul %[lpl2], %[x1], %[vll] ; lpl2 reused for x0    \n\
	lsr %[x7], %[ul2], #16         \n\
	  imul %[x1], %[x1], %[vlh]     \n\
        ldr.l %[ul], [%[rp]]            ; ul reused for rl\n\
	  imul %[x4], %[x6], %[vll]   \n\
        ldr %[ul2], [%[rp],%[halfnidx]]  ; ul2 reused for rl2\n\
	  imul %[x2], %[x3], %[vll]     \n\
	lsr %[clc3], %[lpl2], #16         ; clc3 reused for x0h  \n\
	  imul %[x3], %[x3], %[vlh]     \n\
	add %[x1], %[x1], %[clc3]         \n\
	  imul %[x5], %[x6], %[vlh]   \n\
	and %[lpl], %[lpl2], %[lowmask]    \n\
	  imul %[x6], %[x7], %[vll]   \n\
	lsr %[lpl2], %[x4], #16          ; lpl2 reused for x4h \n\
	  imul %[x7], %[x7], %[vlh]   \n\
	add %[x1], %[x1], %[x2]          \n\
	  isub %[x5c], %[one], %[one]  \n\
	movgteu %[x1c], %[halfbit]       \n\
	  isub %[clc], %[one], %[one]  \n\
	add %[x5], %[x5], %[lpl2]         \n\
	  imadd %[lpl], %[x1], %[halfbit]\n\
	and %[lpl2], %[x4], %[lowmask]  \n\
	  iadd %[x3], %[x3], %[x1c]      \n\
	lsr %[x2], %[x1], #16          ; x2 reused for hpl \n\
	  isub %[clc2], %[one], %[one] \n\
	add %[x5], %[x5], %[x6]          \n\
	  isub %[clc3], %[one], %[one] \n\
	movgteu %[x5c], %[halfbit]       \n\
	  iadd %[x2], %[x2], %[x3]     \n\
	add %[lpl], %[lpl], %[cl]        \n\
	  imadd %[lpl2], %[x5], %[halfbit]\n\
	movgteu %[clc], %[one]           \n\
	  iadd %[x7], %[x7], %[x5c]      \n\
	lsr %[x6], %[x5], #16          ; x6 reused for hpl2\n\
	  iadd %[cl], %[clc], %[x2]     \n\
	add %[lpl2], %[lpl2], %[cl2]     \n\
	  isub %[clc], %[one], %[one]  \n\
	movgteu %[clc2], %[one]          \n\
	add.l %[x6], %[x6], %[x7]      \n\
	add.l %[lpl], %[lpl], %[ul]        \n\
	movgteu %[clc3], %[one]          \n\
	  iadd %[cl2], %[clc2], %[x6]  \n\
	add %[lpl2], %[lpl2], %[ul2]     \n\
	movgteu %[clc], %[one]           \n\
	  iadd %[cl], %[cl], %[clc3]        \n\
        str %[lpl2], [%[rp], %[halfnidx]] \n\
.balignw 8,0x01a2 \n\
        str %[lpl], [%[rp]], #+1       \n\
2: \n\
	  iadd %[cl2], %[cl2], %[clc] \n\
	gie" :
  TMP(lpl), TMP(lpl2),
  TMP(x1), TMP(x2), TMP(x3), TMP(x4), TMP(x5), TMP(x6), TMP(x7), 
  TMP(x1c), TMP(x5c), TMP(clc), TMP(clc2), TMP(clc3),
  REG(ul), REG(ul2), REG(cl), REG(cl2), REG(rp) :
  INREG(vll), INREG(vlh), INREG(halfnidx),
  CNST(lowmask), CNST(one), CNST(halfbit) : "cc", "r62", "r63");

#undef REG
#undef TMP
#undef INREG
#undef OUTREG
#undef CNST

    }

  cl2 += mpn_add_1_inplace(rp, halfn, cl);

  return cl2;
}

static mp_limb_t
mpn_submul_1 (mp_ptr rp, mp_srcptr up, mp_size_t n, mp_limb_t vl)
{
  mp_limb_t ul, cl, hpl, lpl, rl;

  assert (n >= 1);

  cl = 0;
  do
    {
      ul = *up++;
      gmp_umul_ppmm (hpl, lpl, ul, vl);

      lpl += cl;
      cl = (lpl < cl) + hpl;

      rl = *rp;
      lpl = rl - lpl;
      cl += lpl > rl;
      *rp++ = lpl;
    }
  while (--n != 0);

  return cl;
}

#if 0
static mp_limb_t
mpn_mul (mp_ptr rp, mp_srcptr up, mp_size_t un, mp_srcptr vp, mp_size_t vn)
{
  assert (un >= vn);
  assert (vn >= 1);

  /* We first multiply by the low order limb. This result can be
     stored, not added, to rp. We also avoid a loop for zeroing this
     way. */

  rp[un] = mpn_mul_1 (rp, up, un, vp[0]);
  rp += 1, vp += 1, vn -= 1;

  /* Now accumulate the product of up[] and the next higher limb from
     vp[]. */

  while (vn >= 1)
    {
      rp[un] = mpn_addmul_1 (rp, up, un, vp[0]);
      rp += 1, vp += 1, vn -= 1;
    }
  return rp[un - 1];
}
#endif

static mp_limb_t
mpn_redc_1 (mp_ptr rp, mp_ptr up, mp_srcptr mp, mp_size_t n, mp_limb_t invm)
{
  mp_size_t j;
  mp_limb_t cy;

  assert (n > 0);

  for (j = n - 1; j >= 0; j--)
    {
      cy = mpn_addmul_1 (up, mp, n, up[0] * invm);
      assert (up[0] == 0);
      up[0] = cy;
      up++;
    }

  cy = mpn_add_n (rp, up, up - n, n);
  return cy;
}

static void
mpn_div_r_pi1 (mp_ptr np, mp_size_t nn, mp_limb_t n1,
               mp_srcptr dp, mp_size_t dn,
               mp_limb_t dinv)
{
  mp_size_t i;

  mp_limb_t d1, d0;
  mp_limb_t cy, cy1;
  mp_limb_t q;

  assert (dn > 2);
  assert (nn >= dn);

  d1 = dp[dn - 1];
  d0 = dp[dn - 2];

  assert ((d1 & GMP_LIMB_HIGHBIT) != 0);
  /* Iteration variable is the index of the q limb.
   *
   * We divide <n1, np[dn-1+i], np[dn-2+i], np[dn-3+i],..., np[i]>
   * by            <d1,          d0,        dp[dn-3],  ..., dp[0] >
   */

  i = nn - dn;
  do
    {
      mp_limb_t n0 = np[dn-1+i];

      if (n1 == d1 && n0 == d0)
        {
          q = GMP_LIMB_MAX;
          mpn_submul_1 (np+i, dp, dn, q);
          n1 = np[dn-1+i];      /* update n1, last loop's value will now be invalid */
        }
      else
        {
          gmp_udiv_qr_3by2 (q, n1, n0, n1, n0, np[dn-2+i], d1, d0, dinv);

          cy = mpn_submul_1 (np + i, dp, dn-2, q);

          cy1 = n0 < cy;
          n0 = n0 - cy;
          cy = n1 < cy1;
          n1 = n1 - cy1;
          np[dn-2+i] = n0;

          if (cy != 0)
            {
              n1 += d1 + mpn_add_n (np + i, np + i, dp, dn - 1);
              q--;
            }
        }
    }
  while (--i >= 0);

  np[dn - 1] = n1;
}


static void
mpn_div_r_preinv_ns (mp_ptr np, mp_size_t nn,
                     mp_srcptr dp, mp_size_t dn,
                     const struct gmp_div_inverse *inv)
{
  assert (dn > 2);
  assert (nn >= dn);

    {
      mp_limb_t nh;

      assert (inv->d1 == dp[dn-1]);
      assert (inv->d0 == dp[dn-2]);
      assert ((inv->d1 & GMP_LIMB_HIGHBIT) != 0);

      nh = 0;

      mpn_div_r_pi1 (np, nn, nh, dp, dn, inv->di);
    }
}

static mp_limb_t
mpn_rshift (mp_ptr rp, mp_srcptr up, mp_size_t n, unsigned int cnt)
{
  mp_limb_t high_limb, low_limb;
  unsigned int tnc;
  mp_size_t i;
  mp_limb_t retval;

  assert (n >= 1);
  assert (cnt >= 1);
  assert (cnt < GMP_LIMB_BITS);

  tnc = GMP_LIMB_BITS - cnt;
  high_limb = *up++;
  retval = (high_limb << tnc);
  low_limb = high_limb >> cnt;

  for (i = n; --i != 0;)
    {
      high_limb = *up++;
      *rp++ = low_limb | (high_limb << tnc);
      low_limb = high_limb >> cnt;
    }
  *rp = low_limb;

  return retval;
}

static void
mpn_sqr (mp_ptr rp, mp_srcptr up, mp_size_t n)
{
  mp_size_t i;
  {
    mp_limb_t ul, lpl;
    ul = up[0];
    gmp_umul_ppmm (rp[1], lpl, ul, ul);
    rp[0] = lpl;
  }
  if (n > 1)
    {
      mp_double_fixed_len_num tp;
      mp_limb_t cy;

      cy = mpn_mul_1 (tp, up + 1, n - 1, up[0]);
      tp[n - 1] = cy;
      for (i = 2; i < n; i++)
        {
          mp_limb_t cy;
          cy = mpn_addmul_1 (&tp[2 * i - 2], up + i, n - i, up[i - 1]);
          tp[n + i - 2] = cy;
        }

      for (i = 0; i < n; i++)
      {
        mp_limb_t ul, lpl;
        ul = up[i];
        gmp_umul_ppmm (rp[2 * i + 1], lpl, ul, ul);
        rp[2 * i] = lpl;
      }
      cy = mpn_lshift (tp, tp, 2 * n - 2, 1);
      cy += mpn_add_n (rp + 1, rp + 1, tp, 2 * n - 2);
      rp[2 * n - 1] += cy;
    }
}

#if 0
static int
mpn_cmp (mp_srcptr ap, mp_srcptr bp, mp_size_t n)
{
  while (--n >= 0)
    {
      if (ap[n] != bp[n])
        return ap[n] > bp[n] ? 1 : -1;
    }
  return 0;
}
#endif

static int
my_fermat_test (const mp_srcptr msp, mp_size_t mn)
{
  mp_fixed_len_num r, ep, mshifted;
  mp_double_fixed_len_num t;
  mp_ptr mp, tp, rp;
  mp_size_t en;
  mp_limb_t startbit;
  struct gmp_div_inverse minv;
  unsigned i;

  // REDCify: r = B^n * 2 % M
  mp = msp;
  mpn_div_qr_invert (&minv, mp, mn);

  if (minv.shift > 0)
  {
    mpn_lshift(mshifted, mp, mn, minv.shift);
    mp = mshifted;
  }
  else
  {
    for (i = 0; i < mn; ++i) mshifted[i] = mp[i];
  }

  for (i = 0; i < mn; ++i) r[i] = 0;
  r[mn] = 1 << minv.shift;
  mpn_div_r_preinv_ns(r, mn+1, mp, mn, &minv);

  if (minv.shift > 0)
  {
    mpn_rshift(r, r, mn, minv.shift);
    mp = msp;
  }

  en = mn;
  mpn_sub_1(ep, mp, mn, 1);
  gmp_clz(startbit, ep[en-1]);
  startbit = GMP_LIMB_HIGHBIT >> startbit;
  mp_limb_t mi;
  binvert_limb(mi, mp[0]);
  mi = -mi;

  tp = t;
  rp = r;

  while (en-- > 0)
    {
      mp_limb_t w = ep[en];
      mp_limb_t bit;

      bit = startbit;
      startbit = GMP_LIMB_HIGHBIT;
      do
        {
          mpn_sqr (tp, rp, mn);
          MPN_REDC_1(rp, tp, mp, mn, mi);
          if (w & bit)
          {
            mp_limb_t carry = mpn_lshift (rp, rp, mn, 1);
            while (carry)
            {
              carry -= mpn_sub_n(rp, rp, mshifted, mn);
            }
          }
          bit >>= 1;
        }
      while (bit > 0);
    }

  // DeREDCify - necessary as rp can have a large
  //             multiple of m in it (although I'm not 100% sure
  //             why it can't after this redc!)
  for (i = 0; i < mn; ++i) t[i] = r[i];
  for (; i < mn*2; ++i) t[i] = 0;
  MPN_REDC_1(rp, tp, mp, mn, mi);

  if (rp[mn-1] != 0)
  {
    // Compare to m+1
    mpn_sub_1(tp, rp, mn, 1);
    for (i = 0; i < mn; ++i) if (tp[i] != mp[i]) return 0;
    return 1;
  }

  // COmpare to 1
  for (i = 1; i < mn-1; ++i) if (rp[i] != 0) return 0;
  return rp[0] == 1;
}

void null_isr();

int main()
{
  e_coreid_t coreid;
  coreid = e_get_coreid();
  unsigned int row, col, core;
  e_coords_from_coreid(coreid, &row, &col);
  core = row * 4 + col;

  ptest_indata_t* in = (ptest_indata_t*)(0x8f000000+(SHARED_MEM_PER_CORE*core));
  ptest_outdata_t* out = (ptest_outdata_t*)((char*)in + sizeof(ptest_indata_t));

  // Must set up a null interrupt routine to allow host to wake us from idle
  e_irq_attach(E_SYNC, null_isr);
  e_irq_mask(E_SYNC, E_FALSE);
  e_irq_global_mask(E_FALSE);

  while (1)
  {
    e_dma_copy(&inbuf, in, sizeof(ptest_indata_t));

    // Ensure we don't run this block again.
    in->num_candidates = 0;

    mp_fixed_len_num c;
    mp_size_t cn;
    unsigned num_results = 0;
    for (unsigned i = 0; i < inbuf.num_candidates; ++i)
    {
      unsigned primes = 0;

      c[Q_LEN] = mpn_mul_1(c, primorial, Q_LEN, inbuf.k[i]);
      if (c[Q_LEN]) cn = Q_LEN+1;
      else          cn = Q_LEN;
      mpn_add_n2(c, inbuf.n, inbuf.nn, c, cn);
      cn = inbuf.nn;

      if (my_fermat_test(c, cn)) primes++;
      if (primes < 1) continue;

      mpn_add_1_inplace(c, cn, 4);
      if (my_fermat_test(c, cn)) primes++;

      mpn_add_1_inplace(c, cn, 2);
      if (my_fermat_test(c, cn)) primes++;

      mpn_add_1_inplace(c, cn, 4);
      if (my_fermat_test(c, cn)) primes++;
      if (primes < 2) continue;

      mpn_add_1_inplace(c, cn, 2);
      if (my_fermat_test(c, cn)) primes++;

      if (primes >= 3)
      {
        mpn_add_1_inplace(c, cn, 4);
        if (my_fermat_test(c, cn)) primes++;
      }

      ptest_result_t result;
      result.k = inbuf.k[i];
      result.primes = primes;
      out->result[num_results++] = result;
    }
    out->num_results = num_results;

    while (in->num_candidates == 0) __asm__ __volatile__ ("idle");
  }

  return 0;
}

void __attribute__((interrupt)) null_isr()
{
  wait_flag = 0;
  return;
}

