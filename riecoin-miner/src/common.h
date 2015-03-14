#pragma once

//#define MODP_RESULT_DEBUG
#define SHARED_MEM_PER_CORE 0x40000

#define FIXED_MP_NUM_LEN 126
#ifndef __GMP_H__
typedef unsigned mp_limb_t;
typedef int mp_size_t;
typedef mp_limb_t* mp_ptr;
typedef mp_ptr mp_srcptr;
#endif
typedef mp_limb_t mp_fixed_len_num[FIXED_MP_NUM_LEN] __attribute__ ((aligned(8)));
typedef mp_limb_t mp_double_fixed_len_num[FIXED_MP_NUM_LEN*2] __attribute__ ((aligned(8)));

