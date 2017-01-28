#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>
#include <e-hal.h> // HOST side ; mandatory

#include "C_common2.h"  // common definitions for C
#include "e2g_common.h" // common definitions for EII project

#define BENCH_MIN 0    //min bench to start with
#define BENCH_MAX 1024 //max bench to start with
#define BENCH_N   1 //16   //16 to solve per core
#define BENCH_LIMIT 10000 //stop after x benchs done ; not implemented actually

//#######################################

void Epiphany_Boot(e_platform_t *epiphany) {
  e_init(NULL); // initialise the system, establish connection to the device
  e_reset_system(); // reset the Epiphany chip
  e_get_platform_info(epiphany);// get the configuration info for the parallella platform
}

//#######################################
//printf("%-2d"...) -> left align
//GOAL: display an array of node numbers
void Node_Board_Print2(uint *tsolN) {
  int fn1, fn2, fn3=0, place;

	print
  LOOP2(9)
    pf("              %d", 1+fn2);
  pf("             %2d\n", 1+fn2);
  //pf("  -  %c\n", 'A');
  //pf("  -  %c\n", 'B');
  
  LOOP1(8) {
    LOOP2(10) {
      place=(fn1+2)*16 + fn2;//+2 because basis is C1
      ifnz(tsolN[fn3]) {
        pf("   %012u", tsolN[fn3]);
      }
      else {
        pf("       %c%d     ", 'C'+fn1, 1+fn2);//'C' because basis is C1
        if(fn2!=9) pf(" ");
      }
      fn3++;
    }
    pf("  -  %c\n", 'C'+fn1);//basis is C1
  }
}

//#######################################
//print out result
int64_t Output_Print(Soutput out) {
  int64_t l1=0;
  int fn1;
  
  LOOP1(DAM_SZ) l1+=out.globaltsolN[fn1];
  pf("\n   %012llu nodes\n", l1);
  pf("\n   res: %09u\n", out.globalres);

  Node_Board_Print2(out.globaltsolN);

  return l1 + out.globalres;
}

//#######################################

int main(int argc, char *argv[]) {
  // Epiphany input/output through shared RAM ; details: e2g_common.h
  Sio     fromio;//Sio *fromio=(Sio *)malloc(sizeof(Sio));
  int64_t l1=0;
	int row, col, i, j, fn1, fn2, bench_start=BENCH_MIN, toccN[CORE_N]={0}, benchlimit=0;
  e_platform_t epiphany;// Epiphany platform configuration
	e_epiphany_t dev;
  FILE *fin;
  char *tbench=(char *)malloc(MAX_CORE_N * 17 * 16);;

	if(argc > 1) {
		i=atoi(argv[1]); if(i < BENCH_MAX) bench_start=i;
  }

  //get data
  fin=fopen("./bin/bench.bin", "rb");
  ifz(fin) { printf("Error reading file bin/bench.bin ; did you generate it with build_data.sh ?\n"); exit(-1); }
  fseek(fin, 17 * bench_start, 0);
  i=fread(tbench, MAX_CORE_N * 17 * 16, 1, fin);
  fclose(fin);

  printf("\n\nEternity II running under Parallella :) \n\n\n");
	
  Epiphany_Boot(&epiphany);

	// Create a workgroup using all of the cores	
	e_open(&dev, 0, 0, epiphany.rows, epiphany.cols);
	e_reset_group(&dev);

	// Load the device code into each core of the chip, and don't start it yet
	e_load_group("bin/e_e2g.elf", &dev, 0, 0, epiphany.rows, epiphany.cols, E_FALSE);

	// Set the maximum per core test value on each core at address 0x7020
	i=0;
  for(row=0;row<epiphany.rows;row++) {
		for(col=0;col<epiphany.cols;col++) {
      fromio.out.cmd=CMD_INIT;
      LOOP1(DAM_SZ) 
        fromio.in.tdam[fn1]=0;
      j=17 * bench_start; // for demo purpose

      LOOP1(8)
        fromio.in.tdam[C2N + fn1] = (tbench[j + 12 + (fn1/2)] >> (4 * (fn1&1))) & 15; //format: 2 nibbles per byte
      fromio.in.tdam[C1N] =(tbench[j + 16] & 15) - 1;
      fromio.in.tdam[C10N]=(tbench[j + 16] >> 4) - 1;
      fromio.in.tuile2do=  *(uint64_t *)&tbench[j + 0];
      fromio.in.bordertuile2do=*(uint *)&tbench[j + 8];
LOOP1(10) pf("%u ", fromio.in.tdam[C1N+fn1]); print

      pf("0x%016llX tiles\n",      fromio.in.tuile2do);
      pf("0x%08X       borders\n", fromio.in.bordertuile2do);
      pf("sz(io) = %u\n", sizeof(Sio));
      LOOP1(DAM_SZ) fromio.out.globaltsolN[fn1]=0;
      fromio.out.globalres=0;
      
			e_write(&dev, row, col, SHARED_IN, &fromio, sizeof(Sio));
pf("i %u ; in written ; C1N = %u\n", i, fromio.in.tdam[C1N]);

      i++;
		}
	}

	// Start all of the cores
  pf("Some results in a minute... starting the core workgroup...\n\n");
	e_start_group(&dev);
  pf("... core workgroup started ; the whole test will last about 120 seconds...\n\n");

	while(1) {
		usleep(100000);
    //pf("fromio.out.cmd: 0x%08X\n", fromio.out.cmd);
		int done = 0;

		// wait for the cores to complete their work
		i=0;
    for(row=0;row<epiphany.rows;row++) {
			for(col=0;col<epiphany.cols;col++) {
				// Get the number being tested by the core
				if(e_read(&dev, row, col, SHARED_CMD, &fromio.out.cmd, sizeof(uint)) != sizeof(uint))
					fprintf(stderr, "\n\nFailed to read\n\n\n");

				if ( fromio.out.cmd != CMD_INIT) { //== CMD_DONE) {
          if(e_read(&dev, row, col, SHARED_OUT, &fromio.out, sizeof(uint) * (DAM_SZ+1)) != sizeof(uint) * (DAM_SZ+1))
            fprintf(stderr, "\n\nFailed to read 2\n\n\n");
          l1 += Output_Print(fromio.out);
          pf("Crunched %015llu nodes. bench # %u ; cmd output = 0x%08X\n\n", l1, benchlimit, fromio.out.cmd);
          
          benchlimit++;
          if(benchlimit >= BENCH_LIMIT) break;
          if(toccN[i] == BENCH_N) 
            done++;
          else {
            toccN[i]++;
            pf("core %4u: done %2u times ; cmd 0x%08X.\n", i, toccN[i], fromio.out.cmd);

            fromio.out.cmd=CMD_INIT;
            LOOP1(DAM_SZ) 
              fromio.in.tdam[fn1]=0;
            j=17 * bench_start; // for demo purpose
            
            LOOP1(8)
              fromio.in.tdam[C2N + fn1] = (tbench[j + 12 + (fn1/2)] >> (4 * (fn1&1))) & 15; //format: 2 nibbles per byte
            fromio.in.tdam[C1N] =(tbench[j + 16] & 15) - 1;
            fromio.in.tdam[C10N]=(tbench[j + 16] >> 4) - 1;
            fromio.in.tuile2do=  *(uint64_t *)&tbench[j + 0];
            fromio.in.bordertuile2do=*(uint *)&tbench[j + 8];
            LOOP1(DAM_SZ) fromio.out.globaltsolN[fn1]=0;
            fromio.out.globalres=0;

            e_write(&dev, row, col, SHARED_IN, &fromio, sizeof(Sio));
pf("i %u ; in written again ; C1N = %u\n", i, fromio.in.tdam[C1N]);
//OBSOLETE ! esdk doc too :/    e_reset_core(&dev, row, col);
            e_start(&dev, row, col);
          }
        }
          
        i++;
			}
		}

		if ( done >= CORE_N ) // some benchmarks are lengthy
			break;

    if(benchlimit >= BENCH_LIMIT) break;
	}

	e_finalize();
  pf("Crunched %015llu nodes.\n\n", l1);

	return 0;
}
