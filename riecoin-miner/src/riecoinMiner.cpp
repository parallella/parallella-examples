// xptMiner interface to wrap generic rh_riecoin implementation
// Originally based on dga and jh00's code but almost completely re-written
// by Mike Bell.  
// Modifications copyright Mike Bell 2015.

#include "global.h"
#include <assert.h>
#include "rh_riecoin.h"

#define zeroesBeforeHashInPrime	8

//#define DEBUG 1

#if DEBUG
#define DPRINTF(fmt, args...) do { printf("line %d: " fmt, __LINE__, ##args); fflush(stdout); } while(0)
#else
#define DPRINTF(fmt, ...) do { } while(0)
#endif

minerRiecoinBlock_t* verify_block;
mpz_t z_target;

CRITICAL_SECTION success_lock;

unsigned checkRestart()
{
//  DPRINTF("Check restart\n");
    if( verify_block->height != monitorCurrentBlockHeight ) {
      DPRINTF("Restart (height)\n");
      return 1;
    }
  return 0;
}

void reportSuccess(mpz_t candidate, unsigned nPrimes)
{
  EnterCriticalSection(&success_lock);
  DPRINTF("Success %c %d\n", (nPrimes & 0x10) ? 'E' : 'A', nPrimes&0xf);
  nPrimes &= 0xf;
#if 1
  mpz_t testpow, testres, three;
  mpz_init(testpow);
  mpz_init(testres);
  mpz_init_set_ui(three, 3);

  unsigned vPrimes = 0;
  mpz_sub_ui(testpow, candidate, 1);
  mpz_powm(testres, three, testpow, candidate);
  if (mpz_cmp_ui(testres, 1) == 0) vPrimes++;

  mpz_add_ui(testpow, testpow, 4);
  mpz_add_ui(candidate, candidate, 4);
  mpz_powm(testres, three, testpow, candidate);
  if (mpz_cmp_ui(testres, 1) == 0) vPrimes++;

  mpz_add_ui(testpow, testpow, 2);
  mpz_add_ui(candidate, candidate, 2);
  mpz_powm(testres, three, testpow, candidate);
  if (mpz_cmp_ui(testres, 1) == 0) vPrimes++;

  mpz_add_ui(testpow, testpow, 4);
  mpz_add_ui(candidate, candidate, 4);
  mpz_powm(testres, three, testpow, candidate);
  if (mpz_cmp_ui(testres, 1) == 0) vPrimes++;

  mpz_add_ui(testpow, testpow, 2);
  mpz_add_ui(candidate, candidate, 2);
  mpz_powm(testres, three, testpow, candidate);
  if (mpz_cmp_ui(testres, 1) == 0) vPrimes++;

  if (vPrimes >= 3)
  {
    mpz_add_ui(testpow, testpow, 4);
    mpz_add_ui(candidate, candidate, 4);
    mpz_powm(testres, three, testpow, candidate);
    if (mpz_cmp_ui(testres, 1) == 0) vPrimes++;
  }

  mpz_clear(testpow);
  mpz_clear(testres);
  mpz_clear(three);

  DPRINTF("Verified: %d, reported: %d\n", vPrimes, nPrimes);
  if (vPrimes < nPrimes)
  {
    printf("ERROR!! Verified: %d, reported: %d\n", vPrimes, nPrimes);
    LeaveCriticalSection(&success_lock);
    return;
  }
#endif
  mpz_t reportValue;
  mpz_init(reportValue);
  mpz_sub(reportValue, candidate, z_target);
  if (reportValue->_mp_size > 8)
  {
    DPRINTF("Report too large: %d limbs\n", reportValue->_mp_size);
    return;
  }

	if (nPrimes >= 2) total2ChainCount++;
	if (nPrimes >= 3) total3ChainCount++;
	if (nPrimes >= 4) total4ChainCount++;
	
	if (nPrimes < 4) goto EXIT_LABEL;

	// submit share
	uint8 nOffset[32];
	memset(nOffset, 0x00, 32);
	for(int d=0; d<std::min(32/4, reportValue->_mp_size); d++)
	  {
	    *(uint32*)(nOffset+d*4) = reportValue->_mp_d[d];
	  }
	totalShareCount++;
    DPRINTF("Submitting share\n");
	xptMiner_submitShare(verify_block, nOffset);
EXIT_LABEL:
    mpz_clear(reportValue);
    LeaveCriticalSection(&success_lock);
}

void riecoin_init(uint64_t, int)
{
  DPRINTF("Init Entry\n");
  InitializeCriticalSection(&success_lock);
  rh_oneTimeInit(reportSuccess, checkRestart);
}

void riecoin_process(minerRiecoinBlock_t* block)
{
	uint32 searchBits = block->targetCompact;
	verify_block = block;

	// test data
	// getblock 16ee31c116b75d0299dc03cab2b6cbcb885aa29adf292b2697625bc9d28b2b64
	//debug_parseHexStringLE("c59ba5357285de73b878fed43039a37f85887c8960e66bcb6e86bdad565924bd", 64, block->merkleRoot);
	//block->version = 2;
	//debug_parseHexStringLE("c64673c670fb327c2e009b3b626d2def01d51ad4131a7a1040e9cef7bfa34838", 64, block->prevBlockHash);
	//block->nTime = 1392151955;
	//block->nBits = 0x02013000;
	//debug_parseHexStringLE("0000000000000000000000000000000000000000000000000000000070b67515", 64, block->nOffset);
	// generate PoW hash (version to nBits)
	uint8 powHash[32];
	sha256_ctx ctx;
	sha256_init(&ctx);
	sha256_update(&ctx, (uint8*)block, 80);
	sha256_final(&ctx, powHash);
	sha256_init(&ctx);
	sha256_update(&ctx, powHash, 32);
	sha256_final(&ctx, powHash);
	// generatePrimeBase
	uint32* powHashU32 = (uint32*)powHash;

	mpz_init_set_ui(z_target, 1);
	mpz_mul_2exp(z_target, z_target, zeroesBeforeHashInPrime);
	for(uint32 i=0; i<256; i++)
	{
		mpz_mul_2exp(z_target, z_target, 1);
		if( (powHashU32[i/32]>>(i%32))&1 )
			z_target->_mp_d[0]++;
	}
	unsigned int trailingZeros = searchBits - 1 - zeroesBeforeHashInPrime - 256;
  DPRINTF("Process Entry %lx %d\n", z_target->_mp_d[0], trailingZeros);
	mpz_mul_2exp(z_target, z_target, trailingZeros);

	rh_search(z_target);

	mpz_clear(z_target);
}
