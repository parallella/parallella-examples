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

#ifndef _E_METHODS_H_
#define _E_METHODS_H_

#include <e-lib.h> // e_group_config, e_ctimer_set(), e_ctimer_start()

ALWAYS_INLINE unsigned _e_get_ctimer0()
{
  register unsigned tmp asm("r0");
  asm volatile ("movfs %0, ctimer0;" : "=r" (tmp) :: );
  return tmp;
}

ALWAYS_INLINE unsigned _e_reg_read_config( void )
{
  register unsigned tmp asm("r0");
  asm volatile ("movfs %0, config;" : "=r" (tmp) :: );
  return tmp;
}

ALWAYS_INLINE void _e_reg_write_config( register unsigned val )
{
  asm volatile ("movts config, %0;" :: "r" (val) : );
}

ALWAYS_INLINE unsigned _e_reg_read_status( void )
{
  register unsigned tmp asm("r0");
  asm volatile ("movfs %0, status;" : "=r" (tmp) :: );
  return tmp;
}

ALWAYS_INLINE void _e_reg_write_status( register unsigned val )
{
  asm volatile ("movts status, %0;" :: "r" (val) : );
}


unsigned * get_remote_ptr( unsigned id, void * ptr ) {
// --------------------------------------------
// needs to be adjusted for the 64 core version
  unsigned col_id = id & 0x3;
  unsigned row_id = id >> 2;
  unsigned core_id = (row_id * 0x40 + col_id) + e_group_config.group_id;
// --------------------------------------------
  unsigned * new_ptr = (unsigned *)((core_id << 20) | (unsigned)ptr);
  return new_ptr;
}

#endif /* #ifndef _E_METHODS_H_ */
