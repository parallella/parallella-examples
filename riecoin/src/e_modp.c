// Epiphany implementation for reduction of n mod p for large n and small 
// primes p (currently < 2^30, although raising this limit to 2^31 would be 
// reasonably simple).
// A bitfield representing the odd numbers that are primes above a certain base
// is read in from shared memory by DMA transfer, along with n.
// n % p is computed and returned back to shared memory in pages.
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

#include "modp_data.h"

#include "e_common.c"

static modp_indata_t inbuf;
static volatile unsigned wait_flag;

// CLZ algorithm from Hacker's delight implemented in Epiphany asm.  
// This variant assumes there is at least one leading zero, but tolerates
// a zero input.
#define gmp_clz(count, xx) do {                                         \
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
  } while (0)

#define gmp_udiv_rnnd_preinv(r, nh, nl, d, di)                      \
  do {                                                                  \
    mp_limb_t _qh, _ql, _r, _mask;                                      \
    gmp_umul_ppmm (_qh, _ql, (nh), (di));                               \
    gmp_add_ssaaaa (_qh, _ql, _qh, _ql, (nh) + 1, (nl));                \
    _r = (nl) - _qh * (d);                                              \
    _mask = -(mp_limb_t) (_r > _ql); /* both > and >= are OK */         \
    _qh += _mask;                                                       \
    _r += _mask & (d);                                                  \
    if (_r >= (d))                                                      \
      {                                                                 \
        _r -= (d);                                                      \
        _qh++;                                                          \
      }                                                                 \
                                                                        \
    (r) = _r;                                                           \
  } while (0)

#define mpn_invert_limb(x) mpn_invert_3by2 ((x), 0)

static mp_limb_t
mpn_div_r_1_preinv_ns(mp_srcptr np, mp_size_t nn,
                      const struct gmp_div_inverse *inv)
{
  mp_limb_t d, di;
  mp_limb_t r = 0;

  d = inv->d1;
  di = inv->di;

  unsigned vl, vh;
  vl = di & GMP_LLIMB_MASK;
  vh = di >> (GMP_LIMB_BITS / 2);

  while (nn-- > 0)
    {
      mp_limb_t qh, ql, x0, x1, x2, x3;
	  unsigned ul, uh;
	  
	  ul = r & GMP_LLIMB_MASK;
	  uh = r >> (GMP_LIMB_BITS / 2);
	  
	  x0 = (mp_limb_t) ul * vl;
	  x1 = (mp_limb_t) ul * vh;
	  x2 = (mp_limb_t) uh * vl;
	  x3 = (mp_limb_t) uh * vh;
	  
	  x1 += x0 >> (GMP_LIMB_BITS / 2);/* this can't give carry */
	  x1 += x2;               /* but this indeed can */
	  if (x1 < x2) x3 += GMP_HLIMB_BIT;
	  
	  qh = x3 + (x1 >> (GMP_LIMB_BITS / 2));
	  ql = (x1 << (GMP_LIMB_BITS / 2)) + (x0 & GMP_LLIMB_MASK);
	  
	  x0 = ql + np[nn];
	  qh = qh + r + 1 + (x0 < ql);

      r = np[nn] - qh * d;
      if (r > x0) r += d;
      if (r >= d) r -= d;
    }

  return r >> inv->shift;
}

static void
mpn_div_r_1_preinv_ns_2(mp_limb_t* rp1, mp_limb_t* rp2,
                        mp_srcptr np, mp_size_t nn,
                        const struct gmp_div_inverse *inv1,
                        const struct gmp_div_inverse *inv2)
{
  mp_limb_t d1, di1, d2, di2;
  mp_limb_t r1, r2;

  assert(inv1->shift == inv2->shift);

  d1 = inv1->d1;
  di1 = inv1->di;
  d2 = inv2->d1;
  di2 = inv2->di;

  unsigned vl1, vh1, vl2, vh2;
  vl1 = di1 & GMP_LLIMB_MASK;
  vh1 = di1 >> (GMP_LIMB_BITS / 2);
    vl2 = di2 & GMP_LLIMB_MASK;
    vh2 = di2 >> (GMP_LIMB_BITS / 2);
  unsigned* _np = &np[nn-1];

  //while (nn-- > 0)
    {
      unsigned lowmask = 0xffff;
      unsigned one = 1;
      unsigned halfbit = 0x10000;
      unsigned x0c, x1c, x4c, x5c;
      mp_limb_t qh1, ql1, x1, x2, x3;
      mp_limb_t qh2, ql2, x5, x6, x7;

#define REG(x) [x] "+r"(x)
#define TMP(x) [x] "=&r"(x)
#define OUTREG(x) [x] "=&r"(x)
#define INREG(x) [x] "r"(x)
#define CNST(x) [x] "r"(x)
	  
        asm volatile("\n\
	mov %[ql1], %%low(1f) \n\
	  isub %[r1], %[lowmask], %[lowmask] \n\
	mov %[ql2], %%low(2f) \n\
	  isub %[r2], %[lowmask], %[lowmask] \n\
	movts ls, %[ql1] \n\
	movts le, %[ql2] \n\
	movts lc, %[nn] \n\
	gid \n\
.balignw 8,0x01a2 \n\
1: \n\
	and %[x1], %[r1], %[lowmask]    \n\
	  isub %[x1c], %[lowmask], %[lowmask] \n\
	lsr %[x3], %[r1], #16           \n\
	  isub %[x5c], %[lowmask], %[lowmask] \n\
	and %[x6], %[r2], %[lowmask]  \n\
	  imul %[ql1], %[x1], %[vl1]   \n\
	lsr %[x7], %[r2], #16         \n\
          imul %[x1], %[x1], %[vh1]     \n\
	add %[r1], %[r1], #1  \n\
          imul %[ql2], %[x6], %[vl2]   \n\
	add %[r2], %[r2], #1 \n\
          imul %[x2], %[x3], %[vl1]     \n\
	lsr %[x0c], %[ql1], #16        \n\
          imul %[x3], %[x3], %[vh1]     \n\
	add %[x1], %[x1], %[x0c]      \n\
          imul %[x5], %[x6], %[vh2]   \n\
	and %[ql1], %[ql1], %[lowmask] \n\
          imul %[x6], %[x7], %[vl2]   \n\
	lsr %[x4c], %[ql2], #16        \n\
          imul %[x7], %[x7], %[vh2]   \n\
	add %[x1], %[x1], %[x2]       \n\
	  isub %[x0c], %[lowmask], %[lowmask]  \n\
	movgteu %[x1c], %[halfbit]    \n\
	add %[x5], %[x5], %[x4c]      \n\
	  imadd %[ql1], %[x1], %[halfbit]  \n\
	and %[ql2], %[ql2], %[lowmask]  \n\
	  iadd %[x3], %[x3], %[x1c]  \n\
	lsr %[qh1], %[x1], #16  \n\
	  isub %[x4c], %[lowmask], %[lowmask]  \n\
	add %[x5], %[x5], %[x6]   \n\
	movgteu %[x5c], %[halfbit]  \n\
	add %[qh1], %[qh1], %[x3]  \n\
	lsr %[qh2], %[x5], #16  \n\
	  imadd %[ql2], %[x5], %[halfbit]  \n\
	add %[x7], %[x7], %[x5c]  \n\
	  iadd %[qh1], %[qh1], %[r1]  \n\
	ldr %[x3], [%[np]], #-1  ; x3 reused for np[nn] \n\
	add %[qh2], %[qh2], %[x7]  \n\
	add %[ql1], %[ql1], %[x3]  \n\
	movgteu %[x0c], %[one]  \n\
	  iadd %[qh2], %[qh2], %[r2]  \n\
	add %[qh1], %[qh1], %[x0c]  \n\
	add %[ql2], %[ql2], %[x3]  \n\
	movgteu %[x4c], %[one]  \n\
	  imul %[x2], %[qh1], %[d1]  \n\
	add %[qh2], %[qh2], %[x4c]  \n\
	mov %[x1], #0  \n\
	mov %[x5], #0  \n\
	  imul %[x6], %[qh2], %[d2]  \n\
	sub %[r1], %[x3], %[x2]  \n\
	sub %[ql1], %[r1], %[ql1]  \n\
	movgtu %[x1], %[d1]  \n\
	sub %[r2], %[x3], %[x6]  \n\
	sub %[ql2], %[r2], %[ql2]  \n\
	movgtu %[x5], %[d2]  \n\
	add %[r1], %[r1], %[x1]  \n\
	add %[r2], %[r2], %[x5]  \n\
	sub %[x1], %[r1], %[d1]  \n\
	movgteu %[r1], %[x1]  \n\
	  isub %[x2], %[lowmask], %[lowmask] ; For alignment \n\
.balignw 8,0x01a2 \n\
	sub %[x5], %[r2], %[d2]  \n\
2: \n\
	movgteu %[r2], %[x5] \n\
	gie" :
  TMP(x1), TMP(x2), TMP(x3), TMP(x5), TMP(x6), TMP(x7),
  TMP(x1c), TMP(x5c), TMP(x0c), TMP(x4c),
  TMP(ql1), TMP(ql2), TMP(qh1), TMP(qh2),
  OUTREG(r1), OUTREG(r2), [np] "+r" (_np), [nn] "+r" (nn) :
  INREG(vl1), INREG(vl2), INREG(vh1), INREG(vh2),
  INREG(d1), INREG(d2),
  CNST(lowmask), CNST(one), CNST(halfbit) : "cc");

#undef REG
#undef TMP
#undef INREG
#undef OUTREG
#undef CNST

    }

  *rp1 = r1 >> inv1->shift;
  *rp2 = r2 >> inv1->shift;
}
	  
static void
mpn_div_qr_1_invert (struct gmp_div_inverse *inv, mp_limb_t d)
{
  unsigned shift;

  assert (d > 0);
  gmp_clz (shift, d);
  inv->shift = shift;
  inv->d1 = d << shift;
  inv->di = mpn_invert_limb (inv->d1);
}


// return t such that at = 1 mod b
// a, b < 2^30.
// Algorithm from http://www.ucl.ac.uk/~ucahcjm/combopt/ext_gcd_python_programs.pdf
// with modification to keep s, t in bounds.
static unsigned int inverse(unsigned int a, unsigned int b)
{
  int alpha, beta;
  int u, v, s, t;
  u = 1; v = 0; s = 0; t = 1;
  alpha = a; beta = b;

  if (a == 0)
    return 0;

  // Keep a = u * alpha + v * beta
  while ((a&1) == 0)
  {
    a >>= 1;
    if ((u|v) & 1)
    {
      u = (u + beta) >> 1;
      v = (v - alpha) >> 1;
    }
    else
    {
      u >>= 1;
      v >>= 1;
    }
  }
  while (a!=b)
  {
    if ((b&1)==0)
    {
      b >>= 1;
      if ((s|t) & 1)
      {
        s = (s + beta) >> 1;
        t = (t - alpha) >> 1;
      }
      else
      {
        s >>= 1;
        t >>= 1;
      }
    }
    else if (b < a)
    {
      int tmp;
      tmp = a;
      a = b;
      b = tmp;
      tmp = u;
      u = s;
      s = tmp;
      tmp = v;
      v = t;
      t = tmp;
    }
    else
    {
      b = b - a;
      s = s - u;
      t = t - v;

      // Fix up to avoid out of range s,t
      if (u > 0)
      {
        if (s <= -beta)
        {
          s += beta;
          t -= alpha;
        }
      }
      else
      {
        if (s >= beta)
        {
          s -= beta;
          t += alpha;
        }
      }
    }
  }
  if (s < 0) s += beta;
  return s;
}

static unsigned mulmod(mp_limb_t a, mp_limb_t b, struct gmp_div_inverse* inv)
{
  mp_limb_t th, tl, r;

  // th:tl = a*b
  gmp_umul_ppmm(th, tl, a, b);

  // Shift to inverse normalized form
  // Can't overflow if a, b < p.
  th = (th << inv->shift) | (tl >> (GMP_LIMB_BITS - inv->shift));
  tl <<= inv->shift;

  // Divide
  {
    mp_limb_t d1, di;
    d1 = inv->d1;
    di = inv->di;
    gmp_udiv_rnnd_preinv(r, th, tl, d1, di);
  }

  return r >> inv->shift;
}

void null_isr();

static void doshift(mp_ptr nshifted, mp_size_t* nshiftedn, 
                    mp_ptr qshifted, mp_size_t* qshiftedn, unsigned shift)
{
              mp_limb_t h;
              h = mpn_lshift(nshifted, inbuf.n, inbuf.nn, shift);
              if (h) 
              {
                nshifted[inbuf.nn] = h;
                *nshiftedn = inbuf.nn + 1;
              }
              else
                *nshiftedn = inbuf.nn;

              h = mpn_lshift(qshifted, primorial, Q_LEN, shift);
              if (h) 
              {
                qshifted[Q_LEN] = h;
                *qshiftedn = Q_LEN + 1;
              }
              else
                *qshiftedn = Q_LEN;
}

int main()
{
  e_coreid_t coreid;
  coreid = e_get_coreid();
  unsigned int row, col, core;
  e_coords_from_coreid(coreid, &row, &col);
  core = row * 4 + col;

  modp_indata_t* in = (modp_indata_t*)(0x8f000000+(SHARED_MEM_PER_CORE*core));
  modp_outdata_t* outbufs[2];
  outbufs[0] = (modp_outdata_t*)((char*)in + sizeof(modp_indata_t));
  outbufs[1] = (modp_outdata_t*)((char*)outbufs[0] + sizeof(modp_outdata_t));
  int buffer;

  // Must set up a null interrupt routine to allow host to wake us from idle
  e_irq_attach(E_SYNC, null_isr);
  e_irq_mask(E_SYNC, E_FALSE);
  e_irq_global_mask(E_FALSE);
  
  while (1)
  {
    buffer = 0;
    e_dma_copy(&inbuf, in, sizeof(modp_indata_t));

    // Ensure we don't run this block again.
    in->pbase = 0;

    unsigned num_results;
    unsigned i = 0;
    mp_fixed_len_num nshifted, qshifted;
    mp_size_t nshiftedn = 0, qshiftedn = 0;
    unsigned lastshift = 0xffffffff;

    do
    {
      modp_outdata_t* out = outbufs[buffer];
      buffer ^= 1;

      // Wait for buffer ready, without spamming reads to the
      // off core memory.
      while(out->results_status != 0)
      {
        wait_flag = 1;
        while (wait_flag == 1);
      }

      // Writing
      out->results_status = 1;
      num_results = 0;
      mp_limb_t p[2];
      unsigned pidx = 0;
      for (; i < MODP_E_SIEVE_SIZE && num_results + pidx < MODP_RESULTS_PER_PAGE; ++i)
      {
        if ((inbuf.sieve[i>>5] & (1<<(i&0x1f))) == 0)
        {
          p[pidx++] = inbuf.pbase + (i<<1);
          if (pidx == 2)
          {
            struct gmp_div_inverse inv1, inv2;
            mpn_div_qr_1_invert (&inv1, p[0]);
            mpn_div_qr_1_invert (&inv2, p[1]);

            if (inv1.shift != lastshift)
            {
              doshift(nshifted, &nshiftedn, qshifted, &qshiftedn, inv1.shift);
              lastshift = inv1.shift;
            }

            if (inv1.shift == inv2.shift)
            {
              modp_result_t result1, result2;
              mpn_div_r_1_preinv_ns_2(&result1.r, &result2.r, nshifted, nshiftedn, &inv1, &inv2);
              mp_limb_t q1, q2;
              mpn_div_r_1_preinv_ns_2(&q1, &q2, qshifted, qshiftedn, &inv1, &inv2);
#ifdef MODP_RESULT_DEBUG
              result1.p = p[0];
              result2.p = p[1];
              result1.q = q1;
              result2.q = q2;
              result1.x = result1.r;
              result2.x = result2.r;
#endif
              q1 = inverse(q1, p[0]);
              q2 = inverse(q2, p[1]);
              result1.r = mulmod(result1.r, q1, &inv1);
              result2.r = mulmod(result2.r, q2, &inv2);
              q1 <<= 1;
              if (q1 >= p[0]) q1 -= p[0];
              q2 <<= 1;
              if (q2 >= p[1]) q2 -= p[1];
              result1.twoqinv = q1;
              result2.twoqinv = q2;
              out->result[num_results++] = result1;
              out->result[num_results++] = result2;

              pidx = 0;
            }
            else
            {
              modp_result_t result;
              result.r = mpn_div_r_1_preinv_ns(nshifted, nshiftedn, &inv1);
              mp_limb_t q = mpn_div_r_1_preinv_ns(qshifted, qshiftedn, &inv1);
#ifdef MODP_RESULT_DEBUG
              result.p = p[0];
              result.q = q;
              result.x = result.r;
#endif
              q = inverse(q, p[0]);
              result.r = mulmod(result.r, q, &inv1);
              q <<= 1;
              if (q >= p[0]) q -= p[0];
              result.twoqinv = q;
              out->result[num_results++] = result;

              p[0] = p[1];
              pidx = 1;
            }
          }
        }
      }

      if (pidx == 1)
      {
        struct gmp_div_inverse inv;
        mpn_div_qr_1_invert (&inv, p[0]);
        if (lastshift != inv.shift)
        {
          doshift(nshifted, &nshiftedn, qshifted, &qshiftedn, inv.shift);
          lastshift = inv.shift;
        }
        modp_result_t result;
        result.r = mpn_div_r_1_preinv_ns(nshifted, nshiftedn, &inv);
        mp_limb_t q = mpn_div_r_1_preinv_ns(qshifted, qshiftedn, &inv);
#ifdef MODP_RESULT_DEBUG
        result.p = p[0];
        result.q = q;
        result.x = result.r;
#endif
        q = inverse(q, p[0]);
        result.r = mulmod(result.r, q, &inv);
        q <<= 1;
        if (q >= p[0]) q -= p[0];
        result.twoqinv = q;
        out->result[num_results++] = result;
      }

      out->num_results = num_results;
      out->results_status = 2;
    } while(num_results == MODP_RESULTS_PER_PAGE);

    while (in->pbase == 0) __asm__ __volatile__ ("idle");
  }

  return 0;
}

void __attribute__((interrupt)) null_isr() 
{ 
  wait_flag = 0;
  return;
}
