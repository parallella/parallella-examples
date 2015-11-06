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

#include "config_t.h"
#include "e_methods.h"

#define WAND_BIT (1 << 3)

static void __attribute__((interrupt)) wand_isr( int signum )
{
}

void hw_barrier_init( void ) {
  e_irq_global_mask( E_FALSE );
  e_irq_attach( WAND_BIT, wand_isr );
  e_irq_mask( WAND_BIT, E_FALSE );
}

ALWAYS_INLINE void hw_barrier( void ) {
  __asm__ __volatile__("wand");
  __asm__ __volatile__("idle");

  unsigned irq_state = _e_reg_read_status();
  irq_state &= ~WAND_BIT;
  _e_reg_write_status( irq_state ); // clear wand bit
}
