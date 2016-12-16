#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <e-hal.h> //HOST side ; mandatory

#include "C_common.h"  //common definitions for C
#include "e2_common.h" //common definitions for EII project

// from mandelbrot example
//static inline void nano_wait(uint32_t sec, uint32_t nsec) {  struct timespec ts;  ts.tv_sec = sec;  ts.tv_nsec = nsec;  nanosleep(&ts, NULL); }

void Epiphany_Boot(e_platform_t *epiphany) {
  e_init(NULL); // initialise the system, establish connection to the device
  e_reset_system(); // reset the Epiphany chip
  e_get_platform_info(epiphany);// get the configuration info for the parallella platform
}

// GOAL: avoid copy paste errors ; this automation can only work with the associated build.sh&run.sh batches, facilitating maintenance. 
//       Other said: automation process for the name of the ELF file
// IN:   arg is argv[0], example: "something.elf"
// OUT:  "e_something.elf"
void Epiphany_Elf_Format(char *str, char *arg) {
  uint fn1=2, fn2=2;
	str[0]='e'; str[1]='_';
	while(arg[fn1] != '.') { str[fn2++]=arg[fn1++]; }
	str[fn2]=0;
	strcat(str, ".elf");
}

//#######################################
//printf("%-2d"...) -> left align
//GOAL: display an array of node numbers
void Node_Board_Print(uint64_t *tsolN) {
  uint fn1, fn2, fn3=0, place;

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
        pf("   %012llu", tsolN[fn3]);
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
uint64_t Output_Print(Soutput out) {
  uint64_t l1=0;
  uint fn1;
  
  Node_Board_Print(out.globaltsolN);
  LOOP1(78) l1+=out.globaltsolN[fn1];
  pf("\n   %012llu nodes\n", l1);
  pf("\n   res: %09u\n", out.globalres);
  return l1 + out.globalres;
}

//#######################################
//#######################################

int main(int argc, char *argv[]){
  e_platform_t epiphany;// Epiphany platform configuration
	char str_elf[64]; // Epiphany knows only "srec" format ; automation of the name of the loading application for Epiphany
  e_epiphany_t tdev[CORE_N];
  e_mem_t io;
  e_return_stat_t res;
  uint64_t l1, done;//uint64_t done because I want to show that it may be used with a 64-core Epiphany too ;)
  uint32_t i,j,k,l,fn1,fn2,byteN;
  uc t17[17]={0};
	uc *tdam=calloc(1, 180);
  //Epiphany input/output through shared RAM ; details: e2_common.h
  uint    fromcmd[CORE_N];
  Sinput  fromin;
  Soutput fromout;
  Sio     fromio;

const uc tbench[16][17]={
  { 0xFF,0xED,0xDF,0xFC,0xFF,0xF4,0xFF,0xFF,0x25,0x7E,0xEB,0xEF,0x79,0x02,0x05,0x84,0x43 },
  { 0xE5,0xFF,0xFB,0xFB,0xEF,0xFE,0xFF,0xFB,0xF5,0xFA,0x56,0xBE,0x39,0x19,0x17,0x15,0x44 },
  { 0xFE,0xBF,0xFF,0xDF,0xEC,0xFB,0xFF,0xFE,0x8D,0x1F,0xAF,0xBF,0x82,0x23,0x45,0x50,0x23 },
  { 0xFF,0xF5,0xFF,0xFF,0x6E,0xFF,0xFF,0x3B,0x5C,0x0F,0xDF,0xF7,0x32,0x79,0x03,0x97,0x23 },
  { 0xBF,0xFF,0xFF,0xF9,0x7F,0xF7,0xDE,0xDF,0x3C,0x3E,0x9D,0xFF,0x55,0x58,0x03,0x46,0x33 },
  { 0xE6,0xD7,0xDF,0xFF,0xFF,0xFF,0xEF,0xFD,0xDD,0x6E,0x5B,0x6F,0x79,0x13,0x30,0x83,0x43 },
  { 0xFE,0xFB,0xF3,0xEB,0xFF,0x7F,0xFD,0xFF,0xF9,0xE7,0xC8,0xFD,0x63,0x00,0x35,0x33,0x34 },
  { 0xEF,0xF7,0xFD,0xF7,0xFE,0xF1,0xFF,0xFF,0xF8,0xBB,0x4F,0xAF,0x27,0x50,0x62,0x30,0x13 },
  { 0xFE,0xF7,0xF7,0xF0,0xFB,0xFF,0xFF,0xFF,0xF9,0x3E,0x5F,0x4F,0x55,0x53,0x10,0x57,0x43 },
  { 0xBF,0xF6,0xDF,0xEF,0xFF,0xFE,0xBF,0xF7,0x6C,0x9E,0x9B,0xFF,0x33,0x22,0x22,0x98,0x23 },
  { 0xFF,0xEF,0x4F,0xBB,0xBF,0xBF,0xFF,0xFF,0x68,0xFC,0xEF,0xE7,0x69,0x31,0x02,0x93,0x13 },
  { 0xBB,0xFD,0xF7,0xFF,0x9F,0xFF,0xFB,0xFE,0xE1,0xFB,0xAD,0xDD,0x22,0x37,0x15,0x60,0x34 },
  { 0x7F,0xCE,0xFF,0xBD,0xFF,0xFE,0xEF,0xFF,0xE5,0x7A,0x78,0xFF,0x13,0x50,0x07,0x00,0x34 },
  { 0xFC,0xFF,0x7F,0xFE,0xDF,0xFD,0x3F,0xFF,0x64,0xFA,0xE7,0x7F,0x82,0x58,0x99,0x05,0x14 },
  { 0xFF,0x7B,0xF7,0xB3,0xFF,0xFF,0xFE,0xBF,0xB7,0x36,0xEC,0xFE,0x64,0x57,0x11,0x06,0x44 },
  { 0xFD,0xEF,0xDF,0xFB,0x7F,0xFF,0xF2,0xFF,0xF2,0x73,0x3F,0x3F,0x19,0x96,0x07,0x19,0x14 },
};

  printf("Eternity II running under Parallella :) \n\n\n");

	Epiphany_Boot(&epiphany);

	Epiphany_Elf_Format(str_elf, argv[0]);// automation process for the name of the SREC file -- facilitating maintenance 

  //a safe way for passing data to eCore is thru the SDRAM ; let's do it for giving orders to the eCore, its input too
  e_alloc(&io, SHARED_RAM, sizeof(Sio));//<!> e_alloc(): NEVER, NEVER BEFORE e_init(NULL), i.e. Epiphany's boot <!>
  
	//init the EII board
	LOOP1(180) tdam[fn1]=0;//LOOPx() is a personal macro for simple loops, writing "for(fn1=0; fn1<something; fn1++)" is so lengthy)

  //prepare writing to shared memory, all at once
  LOOP1(CORE_N) {
    fromio.tcmd[fn1]=CMD_INIT;
  }
  LOOP2(CORE_N) {
    LOOP1(17)
      t17[fn1]=tbench[0][fn1];//just a demo ; replace tbench[fn2] with tbench[0] or tbench[15] for instance: you'll see 16 parallel solvers ending synchronously :)
    LOOP1(180) 
      fromio.tin[fn2].tdam[fn1]=tdam[fn1];
    LOOP1(8)
      fromio.tin[fn2].tdam[C2N + fn1] = (t17[12 + (fn1/2)] >> (4 * (fn1&1))) & 15;
    fromio.tin[fn2].tdam[C1N] =t17[16] & 15;
    fromio.tin[fn2].tdam[C10N]=t17[16] >> 4;
    fromio.tin[fn2].tuile2do=*(uint64_t *)&t17[0];
    fromio.tin[fn2].bordertuile2do=*(uint *)&t17[8];
    pf("0x%016llX tiles\n", fromio.tin[fn2].tuile2do);
    pf("0x%08X       borders\n", fromio.tin[fn2].bordertuile2do);
    
    LOOP1(160) fromio.tout[fn2].globaltsolN[fn1]=0;
    fromio.tout[fn2].globalres=0;
  }

  byteN=e_write(&io, 0, 0, 0x0, &fromio, sizeof(Sio));
  if(byteN != sizeof(Sio)) fprintf(stderr, "\nShared RAM write error, byteN %u\n", byteN);
  LOOP1(CORE_N) pf("0x%08X ", fromio.tcmd[fn1]);
  print
  pf("Written to shared RAM.\n\n");

  byteN=e_read(&io, 0, 0, 0x0, &fromio, sizeof(Sio));
  if(byteN != sizeof(Sio)) fprintf(stderr, "\nShared RAM read error, byteN %u\n", byteN);
  LOOP1(CORE_N) pf("0x%08X ", fromio.tcmd[fn1]);
  print
  pf("I've just read the shared RAM, useless check but hey it's a demo !\n\n");

  //copy data from host to Epiphany local memory
  for(i=0; i<4; i++) {   //or platform.rows, but we assume a custom config with CORE_N = 16
    for(j=0; j<4; j++) { //or platform.cols, but we assume a custom config with CORE_N = 16
      k=i*4+j;
      e_open(&tdev[k], i, j, 1, 1); //open a single core workgroup, core position (i,j)
      e_reset_group(&tdev[k]);
      pf("Let's load the workgroup, eCore (%u,%u)...\n", i, j);
      res=e_load(str_elf, &tdev[k], 0, 0, E_FALSE);
      if(res != E_OK) {
        printf("Error loading the Epiphany application, core (%u,%u)\n", i, j);
      }
      //usleep(1000);//actually usleep may be heavily delayed by CPU's activity, nanosleep() is certainly much more precise. Just for information.
      e_start_group(&tdev[k]);// may be used to start the group after e_load(..., E_FALSE) ; E_TRUE starts the group without any delay
    }
  }

  done=0; l1=0;
  while(done != (1U<<CORE_N) - 1) { //once again, this is a demo. For yield you'd better feed the beast each time it's hungry ! (hungry == CMD_DONE)
    usleep(1000000);
    
    LOOP1(CORE_N) {
      ifzbool64(done, fn1) {
        byteN=e_read(&io, 0, 0, fn1*sizeof(uint), &fromcmd[fn1], sizeof(uint));
        if(byteN != sizeof(uint)) fprintf(stderr, "\nShared RAM read error, byteN %u\n", byteN);
        if(fromcmd[fn1] != CMD_INIT) {//== CMD_DONE) {
          pf("eCore (%u,%u), cmd = 0x%08X\n", fn1/4, fn1&3, fromcmd[fn1]);
          byteN=e_read(&io, 0, 0, CMD_LEN + (CORE_N * sizeof(Sinput)) + (fn1 * sizeof(Soutput)), (void *)&fromout, sizeof(Soutput));
          if(byteN != sizeof(Soutput)) pf("read byteN %u :'(\n", byteN);
          
          pf("eCore (%u,%u): done ; read Epiphany's output thru shared external memory\n", fn1/4, fn1&3);
          pf("fromout.globalres = %u\n", fromout.globalres);
          l1+=Output_Print(fromout);
          done |= (1ULL<<fn1);
          pf("eCore status: 0x%04X ; total: %012llu nodes\n", (unsigned short)done, l1);//CORE_N=16
        }
        //else printf("eCore (%u,%u): not achieved yet or failure.\n", fn1/4, fn1&3);
      }
    }
  }
    
  printf("\nThat's all folks ! from %s\n", argv[0]);
  LOOP1(CORE_N) e_close(&tdev[fn1]);// close down Epiphany device, 'free' shared RAM buffers
  e_free(&io);
  e_finalize();
  return 0;
}
