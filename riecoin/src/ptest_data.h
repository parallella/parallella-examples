#include "common.h"

// Input data - will test n+k*q#+{0,4,6,10,12,16}
#define PTEST_NUM_CANDIDATES 8
typedef struct 
{
  unsigned k[PTEST_NUM_CANDIDATES];

  volatile unsigned num_candidates; 
  mp_size_t nn;
  mp_fixed_len_num n;
} ptest_indata_t;

typedef struct 
{
  unsigned k;
  unsigned primes;  // Number of primes for this k
} ptest_result_t;

typedef struct 
{
  volatile unsigned results_status; // Currently unused
  unsigned num_results;
  ptest_result_t result[PTEST_NUM_CANDIDATES];
} ptest_outdata_t;

