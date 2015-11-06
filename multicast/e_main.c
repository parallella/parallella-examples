//
// Copyright 2015 Patrick D. M. Siegl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#include <e-lib.h>
#include "config_t.h"
#include "e_methods.h"
#include "b_hw.h"

volatile unsigned test;

int main( void ) {
  test = 0;

  e_ctimer_set(E_CTIMER_0, E_CTIMER_MAX);

  unsigned c_id = e_group_config.core_row * e_group_config.group_cols + e_group_config.core_col;

  hw_barrier_init();

  mbox_t * mbox = (mbox_t *) e_emem_config.base;
  mbox->ready = 1;
  if( ! c_id ) {
    mbox->ready = 1;
    while( ! mbox->go );
    mbox->ready = 0;
  }

  e_ctimer_start(E_CTIMER_0, E_CTIMER_CLK);

/*
  Multicast register

  MULTICAST: 0xF0704 // <- manual is wrong!
  Bits      Name           Function
  [11:0]    MULTICAST_ID   ID to match to destination address[31:20] in the case of an incoming multicast write transaction
  [31:12]   RESERVED       N/A

        E_REG_COREID            = 0xf0704,
        E_REG_MULTICAST         = 0xf0708,
*/

  // set for all the capability to recognize a multicast with id 1 << 11
  unsigned multicast_id = 1 << 11; // push it to the top, so that it does not interfear with regular ld/st to mesh
  unsigned * multicast_reg = ((unsigned*) get_remote_ptr( c_id, (void*) 0xF0708 /* E_REG_MULTICAST */ ));
  unsigned multicast_original = *multicast_reg;
  *multicast_reg = multicast_id;
  volatile unsigned * p_test = (volatile unsigned *)(multicast_id << 20 | (unsigned) &test);

  unsigned reg_cfg = 0;
  if( ! c_id ) { /* does only work for 0,1,2,3 */
    // read current config register and set c_id wants to send a MULTICAST
    reg_cfg = _e_reg_read_config();
    unsigned reg_cfg_mmr = ((~(0xF << 12)) & reg_cfg) | (0x3 << 12);
    _e_reg_write_config( reg_cfg_mmr );
  }

  hw_barrier();

// -------------- test ----------------------
  unsigned time_start = _e_get_ctimer0();
  if( ! c_id ) {
    *p_test = 1; // this will be broadcasted as multicast
  }
  else {
    while( ! test ); // listening for multicast
  }
  unsigned time_end = _e_get_ctimer0();
// -------------- test ----------------------

  if( ! c_id )
    _e_reg_write_config( reg_cfg );
  *multicast_reg = multicast_original;

  mbox->clocks[ c_id ] = time_start - time_end; // parallella is ticking down

  hw_barrier();

  if( ! c_id ) {
    mbox->go    = 0;
    mbox->ready = 1;
  }

  return 0;
}
