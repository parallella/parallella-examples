#include "common.h"

// Input data
#define MODP_E_SIEVE_SIZE (15872*8)
typedef struct 
{
  // bits set indicate pbase + bit_index*2 should be calculated
  unsigned sieve[MODP_E_SIEVE_SIZE>>5];

  volatile mp_limb_t pbase;
  mp_size_t nn;
  mp_fixed_len_num n;
} modp_indata_t;

#define MODP_RESULTS_PER_PAGE 3999
typedef struct 
{
#ifdef MODP_RESULT_DEBUG
  unsigned p;
  unsigned q;
  unsigned x;
  unsigned y;
#endif

  // r = (n*q^-1)%p
  unsigned r;
  unsigned twoqinv;
} modp_result_t;

typedef struct 
{
  // Results status: 0 for page ready for write
  // Set to 1 when page is being written
  // Set to 2 when page is ready to be read
  volatile unsigned results_status;
  unsigned num_results;  // Normally results per page, but not on last page.
                         // This could be inferred, but it's padding anyway.
  modp_result_t result[MODP_RESULTS_PER_PAGE];
} modp_outdata_t;

