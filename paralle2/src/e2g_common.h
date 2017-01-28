// 2017/01/28: 103 Mn/s (Million nodes per second) C version compared to previous 81 Mn/s assembly version.
//   ELF support instead of SREC. Quicker load. File input. No more UNsigned integers, no more char loads, no more "ctz" and "popcount" instructions.
//   Removed bug from multiple 0x6000 section inputs.
//   Eagerly waiting for Epiphany V...

#define CORE_N 16       //change it if needed ; our choice for standard 16-core Epiphany
#define STATS           //undefine STATS to get full performance (from 111.2 to 103.4 s with a 16-core Parallella)
#define MAX_CORE_N 1024 //Epiphany V ready ;)

// specific to the project
#define DAM_SZ 90

// to DEVICE
#pragma pack(4)
typedef struct S_input {
	int64_t tuile2do;
	int bordertuile2do;
	int tdam[DAM_SZ];
  int east;
}Sinput;
// from DEVICE
typedef struct S_output {
	int globaltsolN[DAM_SZ]; //int64_t is twice as long to execute, you need at least 6 ic to increment a 64-bit memory value :/
  int globalres;
  int cmd;
  int fn_idx;
}Soutput;
// shared MEMORY
typedef struct S_io {
  Sinput  in;
  Soutput out;
}Sio;
// tmp variables for DEVICE, trying a workaround for the -msmall16 compilation option
typedef struct S_tmp {
  //int fn_idx;
  int ttiles[64 + 1 + 32];
  int j9e;
  int j1n;
}Stmp;

// global offset for shared RAM
#define SHARED_RAM (0x01000000)

// a whole forum post for that
#define PERFECT_ALIGN8 __asm__ (".balignw 4, 0x01a2\n"); __asm__ (".balignl 8, 0xfc02fcef\n");

// Epiphany local offsets
#define SHARED_IN  0x6000
#define SHARED_OUT (SHARED_IN  + sizeof(Sinput))
#define SHARED_RES (SHARED_OUT + DAM_SZ*4) // offset for result
#define SHARED_CMD (SHARED_OUT + DAM_SZ*4 + 4) // offset for 'cmd'
#define R_IDX      (SHARED_OUT + sizeof(Soutput))

// commands for the Epiphany core
#define CMD_INIT 0x80000000 // host init
#define CMD_DONE 0x40000000 // eCore did the job properly (probably ; some bug might crush this word but it's highly improbable)

// specific to the project
#ifdef STATS
  #define macro_globaltrace(niveau) out.globaltsolN[niveau]++;
#else
  #define macro_globaltrace(niveau)
#endif

#define macro_globaltrace2(niveau) out.globaltsolN[niveau]++;

#define NORTH 0
#define EAST  1
#define SOUTH 2
#define WEST  3

#define B1N   0
#define C1N  10
#define C2N  11
#define C3N  12
#define C4N  13
#define C5N  14
#define C6N  15
#define C7N  16
#define C8N  17
#define C9N  18
#define C10N 19
#define D1N  20 //etc

#define G1N  50
#define G2N  51
#define G3N  52
#define G4N  53
#define G5N  54
#define G6N  55
#define G7N  56
#define G8N  57
#define G9N  58
#define G10N 59

#define H1N  60
#define H2N  61
#define H3N  62
#define H4N  63
#define H5N  64
#define H6N  65
#define H7N  66
#define H8N  67
#define H9N  68
#define H10N 69

#define I1N  70
#define I2N  71
#define I3N  72
#define I4N  73
#define I5N  74
#define I6N  75
#define I7N  76
#define I8N  77
#define I9N  78
#define I10N 79

#define J1N  80
#define J2N  81
#define J3N  82
#define J4N  83
#define J5N  84
#define J6N  85
#define J7N  86
#define J8N  87
#define J9N  88
#define J10N 89

#define BORDERCOLOR_D 0
#define BORDERCOLOR_G 4
#define BORDERCOLOR_I 9
#define BORDERCOLOR_N 19 // 19 colors ; 1st one is empty, colors 1-4 stand for D(roite), 5-8 for G(auche), 9-18 for I(nterieur)
