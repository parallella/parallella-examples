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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <e-loader.h>
#include "e-hal.h"
#include "config_t.h"

typedef struct _e_info_t e_info_t;
struct _e_info_t {
  e_epiphany_t Epiphany;
  e_mem_t DRAM;
  mbox_t * mbox;
};

#define MB( x ) ( (x)*1024*1024 )

extern e_platform_t e_platform;
void epiphany_init( e_info_t * e_info )
{
  e_init(NULL);
  e_reset_system();

  if (e_open(&e_info->Epiphany, 0, 0, e_platform.chip[0].rows, e_platform.chip[0].cols)) {
    printf( "\nERROR: Can't establish connection to Epiphany device!\n\n");
    exit(1);
  }
  if (e_alloc(&e_info->DRAM, 0x00000000, MB(32))) {
    printf( "\nERROR: Can't allocate Epiphany DRAM!\n\n");
    exit(1);
  }
  e_info->mbox = (mbox_t * )e_info->DRAM.base;
  memset( (void*)e_info->mbox, 0, MB(32) );

  e_reset_group(&e_info->Epiphany);

  if (e_load_group("e_main.srec", &e_info->Epiphany, 0, 0, 4, 4, E_FALSE ) == E_ERR) {
    printf( "\nERROR: loading Epiphany program.\n");
    exit(1);
  }

}

void epiphany_finalize( e_info_t * e_info )
{
  // Close connection to device
  if (e_close(&e_info->Epiphany)) {
    printf( "\nERROR: Can't close connection to Epiphany device!\n\n");
    exit(1);
  }
  if (e_free(&e_info->DRAM)) {
    printf( "\nERROR: Can't release Epiphany DRAM!\n\n");
    exit(1);
  }

  e_finalize();
}


int main( int argc, char * argv[] )
{
  e_info_t e_info;
  epiphany_init( &e_info );

  mbox_t * mbox = e_info.mbox;
  mbox->ready = 0;
  mbox->go = 0;

  e_start_group( &e_info.Epiphany ); // start epiphany

  printf( "start initialization\n" );
  while( ! mbox->ready ); // check if epiphany is ready

  printf( "start massive computation\n\n" );
  mbox->go = 1; // let cores run!
  while( mbox->go );

  epiphany_finalize( &e_info );

  unsigned i, sum = 0;
  for( i = 0; i < _NUM_CORES; i++ ) {
    printf("core %2d lat.: %2d cycles\n", i, mbox->clocks[i] );
    sum += mbox->clocks[i];
  }

  printf("\nMulticast average overhead: %d cycles\n\n", sum / _NUM_CORES );

  return 0;
}
