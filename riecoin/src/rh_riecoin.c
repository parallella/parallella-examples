/*
 * Copyright 2011 ArtForz
 * Copyright 2011-2013 pooler
 * Copyright 2013 gatra
 * Copyright 2015 Mike Bell
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.  See COPYING for more details.
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <gmp.h>

#include <e-hal.h>
#include <e-loader.h>

#include "rh_riecoin.h"

#undef REPORT_TESTS
//#define REPORT_TESTS

// Find primes b + x + k.q# + 16057 + {0,4,6,10,12,16}, given b, q.
// b = 2^(z+264) + a * 2^z where a is 256-bits and z > 256.
// x+k.q#+16057 must be < 256-bits => limit on q# of say 220-bits => q=167 pi(q)=39.

#define MAX_SIEVE_PRIME  979270213 // Should be just < multiple of MODP_E_SIEVE_SIZE<<5 + prime[LOW_PRIME_INDEX]
#define PRIME_TABLE_SIZE 49846420  // Not including 2.
#define LOW_PRIME_IDX    3372
//#define MAX_SIEVE_PRIME  162529309  // Should be just > multiple of MODP_E_SIEVE_SIZE<<5
//#define PRIME_TABLE_SIZE 9108221  // Not including 2.
//#define LOW_PRIME_IDX    2506
//#define SIEVE_SIZE       (MAX_SIEVE_PRIME+(2400000-(MAX_SIEVE_PRIME%2400000)))
#define SIEVE_SIZE       (8*2400000)
#define OFFSETS_SIZE     ((SIEVE_SIZE>>3) < PRIME_TABLE_SIZE ? (SIEVE_SIZE>>3) : PRIME_TABLE_SIZE)

static unsigned int *primeTable;
static unsigned int *primeTableInverses;
static unsigned int *primeSieve;
static unsigned int *sieveOffsets[6];
static unsigned int *sieve;
static unsigned int *sieveHighPrime;

#define FIRST_PRIME_INDEX 39 // First prime index to use in sieving (not including 2).
static unsigned int qGenMult[8] = { 223092870, 2756205443, 907383479, 4132280413, 121330189, 257557397, 490995677, 27221 };

#define SEXTUPLET_MOD_PRIMORIAL 16057

// b = 2^(trailingBits+264) + hash * 2^trailingBits
// q# = primorial
// x + 16057 = xPlus16057
static mpz_t base, hashnum, primorial, xPlus16057;

// Epiphany data
#include "modp_data.h"
#include "ptest_data.h"
#define EPIP_SREC_DIR "bin/"
static e_platform_t epip_platform;
static e_epiphany_t epip_dev;
static e_mem_t epip_mem;
#define EPIP_OFFSET(CORE)  ((CORE)*SHARED_MEM_PER_CORE)
#define EPIP_MODP_IN_OFFSET(CORE)  EPIP_OFFSET(CORE)
#define EPIP_MODP_OUT_OFFSET(CORE, BUF) (EPIP_OFFSET(CORE) + sizeof(modp_indata_t) + (BUF)*sizeof(modp_outdata_t))
#define EPIP_PTEST_IN_OFFSET(CORE)  EPIP_OFFSET(CORE)
#define EPIP_PTEST_OUT_OFFSET(CORE) (EPIP_OFFSET(CORE) + sizeof(ptest_indata_t))

static reportSuccess_t reportSuccess;
static checkRestart_t checkRestart;
static volatile unsigned cancelEverything;
static volatile unsigned lowSieveDone;
static pthread_t test_tid[2];

#define SIEVE_BLOCK_SIZE 80000
#define START_BLOCK 5
static volatile unsigned nextSieveIdx;

// return t such that at = 1 mod m
// a, m < 2^31.
static unsigned inverse(unsigned a, unsigned m)
{
  int t = 0, newt = 1, r = m, newr = a;
  while (newr != 0)
  {
    int q = r / newr;
    int x = t - q * newt;
    t = newt;
    newt = x;
    x = r - q * newr;
    r = newr;
    newr = x;
  }
  if (r > 1) return 0;
  if (t < 0) t += m;
  return t;
}

static unsigned mulmod64(unsigned a, unsigned b, unsigned m)
{
  return (uint32_t)((((uint64_t)a) * ((uint64_t)b)) % m);
}

static void initpattern(unsigned* pattern)
{
  for (int i = 0; i < 5; ++i)
  {
    unsigned offset = primeTable[i] >> 1;
    while (offset < (15015 << 5))
    {
      pattern[offset >> 5] |= 1<<(offset&0x1f);
      offset += primeTable[i];
    }
  }
}

void rh_oneTimeInit(reportSuccess_t _reportSuccess, checkRestart_t _checkRestart)
{
  reportSuccess = _reportSuccess;
  checkRestart = _checkRestart;

  e_init(NULL);
  e_reset_system();
  e_get_platform_info(&epip_platform);

  // Allocate a buffer in shared external memory
  // for message passing from eCore to host.
  e_alloc(&epip_mem, 0x01000000, 16*SHARED_MEM_PER_CORE);

  // Open a workgroup
  e_open(&epip_dev, 0, 0, epip_platform.rows, epip_platform.cols);

  unsigned int p, s, i, j;
  mpz_init(hashnum);
  mpz_init(base);
  mpz_init(xPlus16057);

  printf("Initialize prime table size %d\n", PRIME_TABLE_SIZE);

  primeTable = malloc(sizeof(unsigned int) * PRIME_TABLE_SIZE);
#ifdef MODP_RESULT_DEBUG
  primeTableInverses = malloc(sizeof(unsigned int) * PRIME_TABLE_SIZE);
#else
  primeTableInverses = malloc(sizeof(unsigned int) * LOW_PRIME_IDX);
#endif

  for (i = 0; i < 6; ++i)
    sieveOffsets[i] = malloc(sizeof(unsigned int) * OFFSETS_SIZE);

  sieve = malloc(SIEVE_SIZE >> 3);
  sieveHighPrime = malloc(SIEVE_SIZE >> 3);

  // Do something simple to gen low primes.
  primeTable[0] = 3;
  primeTable[1] = 5;
  p = 7;
  s = 3;
  i = 2;
  while (i < LOW_PRIME_IDX)
  {
    for (j=0; primeTable[j] <= s; ++j)
    {
      if (p%primeTable[j] == 0)
        break;
    }
    if (primeTable[j] > s)
    {
      primeTable[i++] = p;
    }
    p += 2;
    if (s*s < p) ++s;
  }
  j = i;

  // Now sieve
  unsigned int pattern[15015] = {0};
  initpattern(pattern);

  primeSieve = malloc((MAX_SIEVE_PRIME+63)>>4);
  memset(primeSieve, 0, (MAX_SIEVE_PRIME+63)>>4);
  for (i = 0; i + 15015 < ((MAX_SIEVE_PRIME+63)>>6); i+=15015)
  {
    memcpy(&primeSieve[i], pattern, 15015 * sizeof(int));
  }
  memcpy(&primeSieve[i], pattern, sizeof(int) * (((MAX_SIEVE_PRIME+63)>>6) - i));

  for (i = 5; i < LOW_PRIME_IDX; ++i)
  {
    unsigned offset = primeTable[i] >> 1;
    while (offset < (MAX_SIEVE_PRIME+63)>>1)
    {
      primeSieve[offset >> 5] |= 1<<(offset&0x1f);
      offset += primeTable[i];
    }
    //fprintf(stderr, "%d\r", primeTable[i]);
  }
  for (i = 1; i < (MAX_SIEVE_PRIME+63)>>1 && j < PRIME_TABLE_SIZE; ++i)
  {
    if ((primeSieve[i>>5] & (1 << (i&0x1f))) == 0)
    {
      primeTable[j++] = (i<<1) + 1;
    }
  }

  printf("Initialized prime table, max prime: %d\n", primeTable[PRIME_TABLE_SIZE-1]);
  if ( primeTable[PRIME_TABLE_SIZE-1] != MAX_SIEVE_PRIME) 
  {
    printf("Configuration error, max prime != defined constant\n");
    exit(-1);
  }

  mpz_init_set_ui(primorial, qGenMult[0]);
  for (i = 1; i < sizeof(qGenMult) / sizeof(qGenMult[0]); ++i)
    mpz_mul_ui(primorial, primorial, qGenMult[i]);

  //struct timespec tv;
  //double start, end;
  //clock_gettime(CLOCK_MONOTONIC, &tv);
  //start = tv.tv_sec + (tv.tv_nsec / 1000000000.0);
#ifdef MODP_RESULT_DEBUG
  for (j = FIRST_PRIME_INDEX; j < PRIME_TABLE_SIZE; ++j)
#else
  for (j = FIRST_PRIME_INDEX; j < LOW_PRIME_IDX; ++j)
#endif
  {
    unsigned int p = primeTable[j];
    unsigned primmodp = mpz_fdiv_ui(primorial, p);
    primeTableInverses[j] = inverse(primmodp, p);
  }

  //clock_gettime(CLOCK_MONOTONIC, &tv);
  //end = tv.tv_sec + (tv.tv_nsec / 1000000000.0);
  //printf("Computed inverses in %.3f\n", end - start);
}
// end of init

static modp_indata_t modp_inbuf;
static modp_outdata_t modp_outbuf;

static int epip_waitfor(unsigned row, unsigned col)
{
  struct timespec sleeptime;
  sleeptime.tv_sec = 0;
  sleeptime.tv_nsec = 100000;

    int sleeps = 0;
      while (1)
      {
        unsigned status;
        e_read(&epip_dev, row, col, E_REG_STATUS, &status, sizeof(status));
        if ((status & 1) == 0)
          break;
        nanosleep(&sleeptime, NULL);
        ++sleeps;
        if (sleeps == 100000) {
          fprintf(stderr, "Core (%d,%d) stuck\n", row, col);
	  exit(-1);
          return -1;
        }
      }

  return sleeps;
}

static void* testThread(void*);

static void* lowSieve(void* void_maxj)
{
  volatile unsigned* maxjptr = void_maxj;
  unsigned minj = FIRST_PRIME_INDEX;
  unsigned maxj = *maxjptr;

  while (primeTable[minj] < SIEVE_SIZE)
  {
          for (unsigned l = 0; l < SIEVE_SIZE && !cancelEverything; l += 2400000)
          {
            for (unsigned j = minj; j < maxj; ++j)
            {
              unsigned p = primeTable[j];
              for (unsigned i = 0; i < 6; ++i)
              {
                unsigned k;
                for (k = sieveOffsets[i][j]; k < 2400000; k += p)
                {
                  __builtin_prefetch(&sieve[(l+k+(p<<2))>>5], 0, 1);
                  sieve[(l+k)>>5] |= (1 << ((l+k)&0x1f));
                }
                sieveOffsets[i][j] = k - 2400000;
              }
            }
          }
    if (cancelEverything) break;
    minj = maxj;
    while (*maxjptr == maxj);
    maxj = *maxjptr;
    while (primeTable[maxj-1] > SIEVE_SIZE) --maxj;
    //fprintf(stderr, "Low sieved to %d (%d)\n", minj, primeTable[minj]);
  }

  lowSieveDone = 1;

  // Start one tester immediately, even though epip hasn't finished sieving.
  if (!cancelEverything)
    pthread_create(&test_tid[0], NULL, testThread, NULL);

  return NULL;
}

static void singleTest(unsigned i, mpz_t candidate, mpz_t testpow, mpz_t testres, mpz_t two)
{
        unsigned primes = 0;

        mpz_mul_ui(candidate, primorial, i);
        mpz_add(candidate, candidate, xPlus16057);

        //gmp_printf("Candidate: %Zd\n", candidate);
        mpz_sub_ui(testpow, candidate, 1);
        mpz_powm(testres, two, testpow, candidate);
        if (mpz_cmp_ui(testres, 1) == 0) primes++;
        if (primes < 1) return;

        mpz_add_ui(testpow, testpow, 4);
        mpz_add_ui(candidate, candidate, 4);
        mpz_powm(testres, two, testpow, candidate);
        if (mpz_cmp_ui(testres, 1) == 0) primes++;

        mpz_add_ui(testpow, testpow, 2);
        mpz_add_ui(candidate, candidate, 2);
        mpz_powm(testres, two, testpow, candidate);
        if (mpz_cmp_ui(testres, 1) == 0) primes++;

        mpz_add_ui(testpow, testpow, 4);
        mpz_add_ui(candidate, candidate, 4);
        mpz_powm(testres, two, testpow, candidate);
        if (mpz_cmp_ui(testres, 1) == 0) primes++;
        if (primes < 2) return;

        mpz_add_ui(testpow, testpow, 2);
        mpz_add_ui(candidate, candidate, 2);
        mpz_powm(testres, two, testpow, candidate);
        if (mpz_cmp_ui(testres, 1) == 0) primes++;

        if (primes >= 3)
        {
          mpz_add_ui(testpow, testpow, 4);
          mpz_add_ui(candidate, candidate, 4);
          mpz_powm(testres, two, testpow, candidate);
          if (mpz_cmp_ui(testres, 1) == 0) primes++;

          mpz_sub_ui(candidate, candidate, 16);
        }
	else
	{
	  mpz_sub_ui(candidate, candidate, 12);
	}

        reportSuccess(candidate, primes);
}

// Assumes hash, primorial, trailingBits are set.
// Re-inits sieve, finds xPlus16057 and inits offsets.
static void initSieve()
{
  int i, j;
  struct timespec sleeptime;
  sleeptime.tv_sec = 0;
  sleeptime.tv_nsec = 10000;

  //printf("Load epiphany with x mod p program\n");
  e_load_group(EPIP_SREC_DIR "e_modp.srec", &epip_dev, 0, 0, epip_platform.rows, epip_platform.cols, E_FALSE);

  memset(sieve, 0, SIEVE_SIZE>>3);
  memset(sieveHighPrime, 0, SIEVE_SIZE>>3);
  nextSieveIdx = START_BLOCK*SIEVE_BLOCK_SIZE;

  mpz_fdiv_r(xPlus16057, base, primorial);     // Actually b mod q#
  mpz_sub(xPlus16057, primorial, xPlus16057);  // Now x
  mpz_add_ui(xPlus16057, xPlus16057, 16057);
  mpz_add(xPlus16057, base, xPlus16057);

  modp_inbuf.nn = mpz_size(xPlus16057);
  memcpy(modp_inbuf.n, xPlus16057->_mp_d, sizeof(mp_limb_t)*modp_inbuf.nn);

  struct timespec tv;
  double start, end;
  clock_gettime(CLOCK_MONOTONIC, &tv);
  start = tv.tv_sec + (tv.tv_nsec / 1000000000.0);
  for (j = FIRST_PRIME_INDEX; j < LOW_PRIME_IDX; ++j)
  {
    // Find b + x + 16057 mod p
    unsigned p = primeTable[j];
    unsigned qinv = primeTableInverses[j];
    unsigned result = mpz_fdiv_ui(xPlus16057, p);

    if (result >= p) result -= p;
    
    unsigned k = p - mulmod64(result, qinv, p);
    unsigned qinv2 = qinv << 1;
    if (qinv2 >= p) qinv2 -= p;
    unsigned qinv4 = qinv2<< 1;
    if (qinv4 >= p) qinv4 -= p;

    sieveOffsets[0][j] = k;
    if (k < qinv4) k += p;
    k -= qinv4;
    sieveOffsets[1][j] = k;
    if (k < qinv2) k += p;
    k -= qinv2;
    sieveOffsets[2][j] = k;
    if (k < qinv4) k += p;
    k -= qinv4;
    sieveOffsets[3][j] = k;
    if (k < qinv2) k += p;
    k -= qinv2;
    sieveOffsets[4][j] = k;
    if (k < qinv4) k += p;
    k -= qinv4;
    sieveOffsets[5][j] = k;
  }

  //printf("Low sieve initialized to %d (j=%d)\n", primeTable[j], j);
  lowSieveDone = 0;

  pthread_t lowsievethread;
  pthread_create(&lowsievethread, NULL, lowSieve, &j);

  mpz_t candidate, testpow, testres, two;
  mpz_init(candidate);
  mpz_init(testpow);
  mpz_init(testres);
  mpz_init_set_ui(two, 2);
  unsigned testi = 0;

  unsigned pbase = primeTable[j] - (primeTable[j] & 0x3e);
  while (pbase + (MODP_E_SIEVE_SIZE<<(1+4)) < MAX_SIEVE_PRIME)
  {
    unsigned corej[17];
    corej[0] = j;
    for (unsigned core = 0; core < 16; ++core)
    {
      modp_inbuf.pbase = pbase;
      corej[core+1] = corej[core];
      pbase += MODP_E_SIEVE_SIZE<<1;

      // Memcpy manually doing a popcount to determine how many primes
      // are in this section of sieve.
      unsigned sieveOffset = modp_inbuf.pbase>>6;
      for (unsigned k = 0; k < MODP_E_SIEVE_SIZE>>5; ++k)
      {
        // Probably faster using NEON
        unsigned sieveVal = primeSieve[sieveOffset+k];
        corej[core+1] += 32 - __builtin_popcount(sieveVal);
        modp_inbuf.sieve[k] = sieveVal;
      }
  
      unsigned status = 0;

      e_write(&epip_mem, 0, 0, EPIP_MODP_IN_OFFSET(core), &modp_inbuf, sizeof(modp_indata_t));
      e_write(&epip_mem, 0, 0, EPIP_MODP_OUT_OFFSET(core,0), &status, sizeof(unsigned));
      e_write(&epip_mem, 0, 0, EPIP_MODP_OUT_OFFSET(core,1), &status, sizeof(unsigned));
      e_start(&epip_dev, core>>2, core&3);
    }

    if (lowSieveDone)
    {
      //fprintf(stderr, "T");
      for (; testi < START_BLOCK*SIEVE_BLOCK_SIZE; ++testi)
      {
        if (((sieve[testi>>5] & (1<<(testi&0x1f))) == 0) &&
            ((sieveHighPrime[testi>>5] & (1<<(testi&0x1f))) == 0))
        {
          singleTest(testi, candidate, testpow, testres, two);
          ++testi;
          break;
        }
      }
    }

    unsigned coredone = 0;
    for (unsigned buf = 0;; buf ^= 1)
    {
      for (unsigned core = 0; core < 16; ++core)
      {
        if (coredone & (1<<core)) continue;

        unsigned status;
        unsigned sleeps = 0;
        do
        {
          e_read(&epip_mem, 0, 0, EPIP_MODP_OUT_OFFSET(core,buf), &status, sizeof(unsigned));
          if (status == 2) break;

          nanosleep(&sleeptime, NULL);

          if (++sleeps > 1000000)
          {
            // Seen this once in over 50 hours.  Cancel everything and break out.
            printf("Error: Core %d stuck while sieving\n", core);
	    exit(-1);
            cancelEverything = 1;
            pthread_join(lowsievethread, NULL);
            return;
          }
        } while(1);
    
        e_read(&epip_mem, 0, 0, EPIP_MODP_OUT_OFFSET(core,buf), &modp_outbuf, 8);
        e_read(&epip_mem, 0, 0, EPIP_MODP_OUT_OFFSET(core,buf)+8, &modp_outbuf.result[0], modp_outbuf.num_results*sizeof(modp_result_t));
        status = 0;
        e_write(&epip_mem, 0, 0, EPIP_MODP_OUT_OFFSET(core,buf), &status, sizeof(unsigned));
        e_start(&epip_dev, core>>2, core&3);
#ifdef MODP_RESULT_DEBUG
        printf("Read from core %d buf %d firstp=%d\n", core, buf, modp_outbuf.result[0].p);
#endif
 
        unsigned endj = corej[core] + modp_outbuf.num_results;
        for (i = 0; corej[core] < endj; ++i, ++corej[core])
        {
          // Find b + x + 16057 mod p
          unsigned p = primeTable[corej[core]];
#ifdef MODP_RESULT_DEBUG
          unsigned q = mpz_fdiv_ui(primorial, p);
          unsigned qinv = primeTableInverses[corej[core]];
          unsigned result = mpz_fdiv_ui(xPlus16057, p);
          unsigned invresult = mulmod64(result, qinv, p);

          if (result >= p) result -= p;
          if (p != modp_outbuf.result[i].p) printf("Bad p: p=%d should be %d (core %d)\n", modp_outbuf.result[i].p, p, core);
          if (q != modp_outbuf.result[i].q) printf("Bad q: q=%d should be %d p=%d/%d (core %d)\n", modp_outbuf.result[i].q, q, modp_outbuf.result[i].p, p, core);
          if (result != modp_outbuf.result[i].x) printf("Bad x: x=%d should be %d p=%d/%d (core %d)\n", modp_outbuf.result[i].x, result, modp_outbuf.result[i].p, p, core);
          if (invresult != modp_outbuf.result[i].r) printf("Bad r: r=%d should be %d p=%d/%d (core %d)\n", modp_outbuf.result[i].r, invresult, modp_outbuf.result[i].p, p, core);
#else
          unsigned invresult = modp_outbuf.result[i].r;
#endif

          unsigned k = p - invresult;

#ifdef MODP_RESULT_DEBUG
          unsigned qinv2 = qinv << 1;
          if (qinv2 >= p) qinv2 -= p;

          if (qinv2 != modp_outbuf.result[i].twoqinv) printf("Bad qinv2: %d should be %d p=%d\n", modp_outbuf.result[i].twoqinv, qinv2, p);
#else
          unsigned qinv2 = modp_outbuf.result[i].twoqinv;
#endif
          unsigned qinv4 = qinv2<< 1;
          if (qinv4 >= p) qinv4 -= p;

          if (p < SIEVE_SIZE)
          {
            sieveOffsets[0][corej[core]] = k;
            if (k < qinv4) k += p;
            k -= qinv4;
            sieveOffsets[1][corej[core]] = k;
            if (k < qinv2) k += p;
            k -= qinv2;
            sieveOffsets[2][corej[core]] = k;
            if (k < qinv4) k += p;
            k -= qinv4;
            sieveOffsets[3][corej[core]] = k;
            if (k < qinv2) k += p;
            k -= qinv2;
            sieveOffsets[4][corej[core]] = k;
            if (k < qinv4) k += p;
            k -= qinv4;
            sieveOffsets[5][corej[core]] = k;
          }
          else
          {
            if (k < SIEVE_SIZE) sieveHighPrime[k>>5] |= 1<<(k&0x1f);
            if (k < qinv4) k += p;
            k -= qinv4;
            if (k < SIEVE_SIZE) sieveHighPrime[k>>5] |= 1<<(k&0x1f);
            if (k < qinv2) k += p;
            k -= qinv2;
            if (k < SIEVE_SIZE) sieveHighPrime[k>>5] |= 1<<(k&0x1f);
            if (k < qinv4) k += p;
            k -= qinv4;
            if (k < SIEVE_SIZE) sieveHighPrime[k>>5] |= 1<<(k&0x1f);
            if (k < qinv2) k += p;
            k -= qinv2;
            if (k < SIEVE_SIZE) sieveHighPrime[k>>5] |= 1<<(k&0x1f);
            if (k < qinv4) k += p;
            k -= qinv4;
            if (k < SIEVE_SIZE) sieveHighPrime[k>>5] |= 1<<(k&0x1f);
          }
        }
        if (modp_outbuf.num_results != MODP_RESULTS_PER_PAGE) 
        {
          //printf("Core %d complete\n", core);
          coredone |= 1<<core;
        }
      }
      if (checkRestart())
      {
        cancelEverything = 1;
        pthread_join(lowsievethread, NULL);
        return;
      }
      if (coredone==0xffff) 
      {
        j = corej[15];
        //fprintf(stderr, ".");
        //printf("Done to j=%d p=%d\n", j, primeTable[j]);
        break;
      }
    }
  }

  pthread_join(lowsievethread, NULL);

  //exit(0);

  clock_gettime(CLOCK_MONOTONIC, &tv);
  end = tv.tv_sec + (tv.tv_nsec / 1000000000.0);
  printf("Sieved in %.3f\n", end - start);

  for (; testi < START_BLOCK*SIEVE_BLOCK_SIZE; ++testi)
  {
    if (((sieve[testi>>5] & (1<<(testi&0x1f))) == 0) &&
        ((sieveHighPrime[testi>>5] & (1<<(testi&0x1f))) == 0))
    {
      fprintf(stderr, "T");
      singleTest(testi, candidate, testpow, testres, two);
    }
  }
  //printf("Finished first block on sieve thread\n");
  mpz_clear(candidate);
  mpz_clear(testpow);
  mpz_clear(testres);
  mpz_clear(two);
}

static void* testThread(__attribute__ ((unused)) void* unused)
{
  mpz_t candidate, testpow, testres, two;
  mpz_init(candidate);
  mpz_init(testpow);
  mpz_init(testres);
  mpz_init_set_ui(two, 2);

  while (1)
  {
    unsigned section = __atomic_fetch_add(&nextSieveIdx, SIEVE_BLOCK_SIZE, __ATOMIC_RELAXED);
    if (section >= SIEVE_SIZE) break;
    //printf("A: Start %d\n", section);

    for (unsigned i = section; i < section + SIEVE_BLOCK_SIZE; ++i)
    {
      if ((i & 0xff) == 0)
      {
        if (cancelEverything) return NULL;
        __builtin_prefetch(&sieve[(i+256)>>5]);
        __builtin_prefetch(&sieveHighPrime[(i+256)>>5]);
      }
      if (((sieve[i>>5] & (1<<(i&0x1f))) == 0) &&
          ((sieveHighPrime[i>>5] & (1<<(i&0x1f))) == 0))
      {
        singleTest(i, candidate, testpow, testres, two);
      }
    }
  }
  //printf("Test thread complete\n");
  mpz_clear(candidate);
  mpz_clear(testpow);
  mpz_clear(testres);
  mpz_clear(two);
  return NULL;
}

static unsigned epipReadTestResults(unsigned numCores)
{
  mpz_t candidate;
  mpz_init(candidate);
  ptest_outdata_t ptest_outbuf;
  unsigned totalSleeps = 0;
  int sleeps;

  //printf("Reading results\n");
  for (unsigned core = 0; core < numCores; ++core)
  {
    //fprintf(stderr, ".");
    if ((sleeps = epip_waitfor(core>>2, core&3)) < 0) 
    {
      printf("Ignoring stuck core %d\n", core);
      exit(-1);
      continue;
    }
    totalSleeps += sleeps;
    if (e_read(&epip_mem, 0, 0, EPIP_PTEST_OUT_OFFSET(core), &ptest_outbuf, sizeof(ptest_outdata_t)) != sizeof(ptest_outdata_t)) printf("Read error on core %d\n", core);

    for (unsigned i = 0; i < ptest_outbuf.num_results; ++i)
    {
      if (ptest_outbuf.result[i].primes < 2 ||
          ptest_outbuf.result[i].primes > 6)
      {
        printf("Error - %d prime report from core %d\n", ptest_outbuf.result[i].primes, core);
        break;
      }
      {
        mpz_mul_ui(candidate, primorial, ptest_outbuf.result[i].k);
        mpz_add(candidate, candidate, xPlus16057);
        reportSuccess(candidate, ptest_outbuf.result[i].primes|0x10);
      }
    } 
  }  
  mpz_clear(candidate);
  return totalSleeps;
}

static void epipTester()
{
  //printf("Load epiphany with primetest program\n");
  e_load_group(EPIP_SREC_DIR "e_primetest.srec", &epip_dev, 0, 0, epip_platform.rows, epip_platform.cols, E_FALSE);

  ptest_indata_t inbuf[16];

  for (unsigned i = 0; i < 16; ++i)
  {
    inbuf[i].nn = mpz_size(xPlus16057);
    memcpy(inbuf[i].n, xPlus16057->_mp_d, sizeof(mp_limb_t)*inbuf[i].nn);
    inbuf[i].num_candidates = 0;
  }

  unsigned core = 0;

  while (1)
  {
    unsigned section = __atomic_fetch_add(&nextSieveIdx, SIEVE_BLOCK_SIZE, __ATOMIC_RELAXED);
    if (section >= SIEVE_SIZE) break;
    //printf("E: Start %d\n", section);

    for (unsigned i = section; i < section + SIEVE_BLOCK_SIZE; ++i)
    {
      if (((sieve[i>>5] & (1<<(i&0x1f))) == 0) &&
          ((sieveHighPrime[i>>5] & (1<<(i&0x1f))) == 0))
      {
        inbuf[core].k[inbuf[core].num_candidates++] = i;
        if (inbuf[core].num_candidates == PTEST_NUM_CANDIDATES)
        {
          //printf("Start core %d\n", core);
          e_write(&epip_mem, 0, 0, EPIP_PTEST_IN_OFFSET(core), &inbuf[core], sizeof(ptest_indata_t));
          e_start(&epip_dev, core>>2, core&3);
          if (core == 15)
          {
            epipReadTestResults(16);
            if (checkRestart())
            {
              cancelEverything = 1;
              goto CANCEL;
            }
          }
          inbuf[core].num_candidates = 0;
        }
        core = (core + 1) & 0xf;
      }
    }
  }

  for (core = 0; core < 16; core++)
  {
    //printf("Send %d candidates to core %d\n", inbuf[core].num_candidates, core);
    e_write(&epip_mem, 0, 0, EPIP_PTEST_IN_OFFSET(core), &inbuf[core], sizeof(ptest_indata_t));
    e_start(&epip_dev, core>>2, core&3);
  }
  epipReadTestResults(16);

CANCEL:
  pthread_join(test_tid[0], NULL);
  pthread_join(test_tid[1], NULL);
}

void rh_search(mpz_t target)
{
  struct timespec tv;
  double start, end;
  clock_gettime(CLOCK_MONOTONIC, &tv);
  start = tv.tv_sec + (tv.tv_nsec / 1000000000.0);

  cancelEverything = 0;

  mpz_set(base, target);
 
  initSieve();
  if (cancelEverything || checkRestart())
  {
    cancelEverything = 1;
    pthread_join(test_tid[0], NULL);
    return;
  }

  // First thread was kicked off already.
  pthread_create(&test_tid[1], NULL, testThread, NULL);
  epipTester(test_tid);

  clock_gettime(CLOCK_MONOTONIC, &tv);
  end = tv.tv_sec + (tv.tv_nsec / 1000000000.0);
  printf("Tested in %.3f\n", end - start);
}
