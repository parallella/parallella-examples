//#include <stdio.h>  //the less, the best
//#include <stdlib.h> //the less, the best
//#include <stdint.h> //the less, the best (shall I repeat ?)
#include "e-lib.h" //mandatory even for a minimalist design -- e_get_coreid(), e_read(), e_write()

#include "C_common.h"  //common definitions for C
#include "e2_common.h" //common definitions for EII project

//#######################################
//TODO adapt this for Epiphany, much too slow
#define getbitN32 __builtin_popcount
#define getbitN64 __builtin_popcountll
#define getbitN   __builtin_popcountll
//__builtin_ctz(l) needs it too

//#######################################
//INPUT/OUTPUT DATA

//Sinput  in;
//Soutput out;
//forcing those input/output to this section gained 4 % O_O  their advice is true: dispatch data among the various banks if you can
volatile Sinput  in  SECTION(".data_bank3");//0x6000
volatile Soutput out SECTION(".data_bank3");//0x6000 + sizeof(Sinput)

//#######################################
//THE 'COMPUTE KERNEL'

uint fn_idx;
#include "e2_solver.c"

//#######################################

int main(void) {
	e_coreid_t coreid;
  int row, col, cmdI;
  int fn1;
  uint *Pcmd;//pointer for retrieving the shared memory

	coreid=e_get_coreid();//query the coreID from hardware
  row=(coreid>>6) - 32;//dirty but OK for MY 16-core Epiphany
  col=(coreid&15) - 8;
  cmdI=(row<<2) + col;

  // e_read((void *)&e_group_config, (void *)&in, 0, 0, (const void *)SHARED_RAM + CMD_LEN + (cmdI * sizeof(Sinput)), sizeof(Sinput));
  //   core (0,0) will NOT read it: DMA cannot operate from input core X to output core X !
  // => choose the alternate syntax e_read(...e_emem_config), it's a slower 'e_memcpy' I would say, but with no restriction at all
  e_read((void *)&e_emem_config, (void *)&in, 0, 0, (const void *)SHARED_RAM + CMD_LEN + (cmdI * sizeof(Sinput)), sizeof(Sinput));

  //trying to optimize: disabling IRQ to enable the hardware loops
  //useless, even slower ! //e_irq_global_mask(E_FALSE);

  //compute kernel
  LOOP1(160) out.globaltsolN[fn1]=0;
  out.globalres=0;
  fn_idx=0;
  Solver2016_BorderWest();

  //e_irq_global_mask(E_TRUE);

  //offset of io.tout[cmdI] is not easy to express ; fortunately you do it only once
  e_write((void *)&e_emem_config, (void *)&out, 0, 0, (void *)SHARED_RAM + CMD_LEN + (CORE_N * sizeof(Sinput)) + (cmdI * sizeof(Soutput)), sizeof(Soutput));
  Pcmd=(void *) (SHARED_RAM + (cmdI * sizeof(uint)));
  *Pcmd=CMD_DONE;
  
  return 0;
}
