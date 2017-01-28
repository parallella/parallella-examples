#include "e-lib.h" // mandatory even for a minimalist design -- e_get_coreid(), e_read(), e_write()

//from notzed on the forum, "...gcc extended inline asm, 'cc' clobber_php.htm"
//volatile needed, the compiler may mix code without taking care of the condition flags :/ 
unsigned int bitrev(unsigned int val) {
  unsigned int res;

  __asm__ volatile ("bitr %[res],%[val]"
    : [res] "=r" (res)
    : [val] "r" (val)
    : "cc");

  return res;
}

//#include "C_common2.h"  // common definitions for C
// avoid stdint.h
#define uint8_t		unsigned char
#define uint16_t	unsigned short
#define uint32_t	unsigned int
#define uint64_t	unsigned long long // <!> unsigned long = 4 bytes under 32-bit ARM

#define int8_t		char
#define int16_t		short
#define int32_t		int
#define int64_t		long long

// my semantic
#define uc     unsigned char
#define ull    unsigned long long
#define pf      printf
#define print   printf("\n");
#define pfv(x)  printf("v: %d\n",x);
#define LOOP1(x) for(fn1=0;fn1<(x);fn1++)
#define LOOP2(x) for(fn2=0;fn2<(x);fn2++)
#define LOOP3(x) for(fn3=0;fn3<(x);fn3++)
#define LOOP4(x) for(fn4=0;fn4<(x);fn4++)
#define LOOP5(x) for(fn5=0;fn5<(x);fn5++)
#define LOOP6(x) for(fn6=0;fn6<(x);fn6++)
#define LOOP7(x) for(fn7=0;fn7<(x);fn7++)
#define LOOP8(x) for(fn8=0;fn8<(x);fn8++)
#define LOOP(x,y) for(x=0;x<y;x++)

// #######################################
// think x86 asm, think jz... setz... cmovz... think flags...
#define ifz(x) if(!(x))
#define ifnz(x) if(x)
#define ife(x) if(!(x))
#define ifne(x) if(x)
// booleans
#define ifzbool32(x,bit) ifz((x)&(1U<<(bit))) 
#define ifbool32(x,bit)  if((x)&(1U<<(bit))) 
#define ifzbool64(x,bit) ifz((uint64_t)(x)&(1ULL<<(bit)))
#define ifbool64(x,bit)  if((uint64_t)(x)&(1ULL<<(bit)))

#include "e2g_common.h" // common definitions for EII project

//#######################################
//INPUT/OUTPUT DATA

/* previous code was:
    
   volatile Sinput  in  SECTION(".data_bank3"); // SHARED_IN
   volatile Soutput out SECTION(".data_bank3"); // SHARED_OUT
  
  this way of coding is BAD: the linker will NOT necessarily place 'in' at offset 0x6000 and 'out' just AFTER 'in' (actually it places 'out' BEFORE 'in' !)
  
   => ONE reliable way of coding is ONE structure for exchanging with the rest of the world
*/

volatile Sio  io  SECTION(".data_bank3");

#define in  io.in
#define out io.out

//#######################################

Stmp    tmp;

//#######################################
//THE 'COMPUTE KERNEL'
//#include "e2c_solver.c"

void BorderWest(const int, const int);
void InnerTile0(const int, const int);
void InnerTile1(const int, const int);
void InnerTile(const int, const int);
void InnerRow(const int, const int);
void InnerRow2(const int, const int); // with tinner_Upd
void BorderEast(const int, const int);
void BorderEastUpdate(const int, const int);
void Special_H10(const int, const int);
void Special_I1(const int, const int);
void Special_I10(const int, const int);
void BorderEastBottom(const int, const int);
void Special_J2(const int, const int);
void Special_Debug(const int, const int); // for debugging purpose

void __attribute__ ((noinline)) Input_Copy(int, int *);

//#######################################
//STATIC DATA

const int tlscouleur_B2016[BORDERCOLOR_N+1]={   
  0x00000000, 
  0x0870809A, 0x91032001, 0x42845140, 0x24080E24, 
  0x000000FF, 0x00007F00, 0x00FF8000, 0xFF000000, 
  0x00000001, 0x00018300, 0x03000406, 0x00000008, 0x00020830, 0x04041040, 0x38080000, 0x40100000, 0x00202000, 0x80C04080, 
  0x00000000
};

//<!> colors 0-3 for D and G, 0-9 for I
const int tbordureD[32]={ 0x01, 0x00, 0x03, 0x00, 0x00, 0x03, 0x02, 0x00, 0x02, 0x03, 0x03, 0x03, 0x02, 0x01, 0x02, 0x00, 0x01, 0x01, 0x02, 0x03, 0x00, 0x00, 0x00, 0x02, 0x01, 0x02, 0x03, 0x00, 0x01, 0x03, 0x02, 0x01 };
const int tbordureG[32]={ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03 };
const int tbordureI[32]={ 0x00, 0x02, 0x02, 0x03, 0x04, 0x04, 0x05, 0x09, 0x01, 0x01, 0x02, 0x04, 0x05, 0x08, 0x09, 0x01, 0x01, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x09, 0x02, 0x02, 0x05, 0x06, 0x06, 0x06, 0x07, 0x09 };

const int ttileN[100]={
   1,  4,  3,  2,  1,  4,  4,  5,  2,  3,  5,  2,  5,  3,  0,  3,  3,  2,  0,  3,
   1,  5,  3,  5,  2,  0,  1,  2,  3,  3,  6,  1,  4,  3,  6,  1,  2,  1,  3,  2,
   2,  2,  2,  2,  4,  1,  0,  1,  4,  6,  5,  3,  2,  1,  1,  2,  4,  1,  1,  4,
   3,  0,  2,  5,  3,  5,  0,  1,  4,  1,  1,  4,  1,  5,  2,  4,  1,  6,  2,  0,
   0,  4,  1,  0,  4,  2,  7,  4,  3,  1,  5,  1,  2,  3,  1,  2,  2,  3,  4,  0
};

// color format: G + 4*D (i.e tbordureG + 4*tbordureD)
const int tGDN[16]={ 4, 0, 4, 1, 1, 1, 2, 3, 1, 3, 2, 2, 2, 3, 1, 2 };

const int tGD[16][8]={ 
  {  1, 2,  3, 3,  4, 4,  7, 9 },
  {  },
  { 15, 1, 20, 7, 21, 8, 22, 9 },
  { 27, 6, },
  {  0, 0, },
  { 13, 8, },
  { 16, 1, 17, 4, },
  { 24, 2, 28, 6, 31, 9, },
  {  6, 5, },
  {  8, 1, 12, 5, 14, 9, },
  { 18, 5, 23, 9, },
  { 25, 2, 30, 7, },
  {  2, 2,  5, 4, },
  {  9, 1, 10, 2, 11, 4, },
  { 19, 6, },
  { 26, 5, 29, 6, }
};

#define VOIDTILE 64
#define VOIDSOUTH 0

//tcount(11) = 2 tcount(19) = 2 tcount(22) = 3  tcount(27) = 2  tcount(36) = 2  tcount(38) = 2
//const int tbordereast_uniquecolor[20]={ 1, 4, 5, 6, 7, 8, 9, 10, 12, 16, 17, 23, 24, 25, 28, 30, 32, 33, 37, }; //19 actually
//const int tbordereast_uniquetile[20]={ 0, 0, 4, 1, 24, 0, 27, 28, 0, 15, 17, 0, 29, 20, 0, 30, 0, 0, 0, }; //19 actually

//from tmpbordure*.c
const int t14[100][8]={ // format: LSB = tile, 2nd byte = east, 3rd byte = south, MSB = 0
  { 0x00060500, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000901, 0x00020308, 0x00010613, 0x0009030C, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000506, 0x00010915, 0x0004030A, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0004040D, 0x00080510, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00010307, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00050103, 0x00050918, 0x00000206, 0x00020102, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000712, 0x00080511, 0x00050000, 0x00020614, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00040917, 0x00000612, 0x00030309, 0x00070104, 0x0007050F, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00070105, 0x00010916, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000101, 0x0006030B, 0x0006040E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00050503, 0x00090001, 0x00080705, 0x00070704, 0x00050202, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00050919, 0x00060013, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00070823, 0x00030008, 0x0001051A, 0x00090720, 0x0001071B, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000407, 0x0006021C, 0x0004041E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00060822, 0x00090119, 0x0001021A, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000113, 0x0007051F, 0x00050821, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0006031D, 0x0001021B, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000816, 0x00000215, 0x0003000C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00050006, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00090015, 0x0005011A, 0x00000502, 0x0003061C, 0x0007011B, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00030325, 0x00020924, 0x00090224, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00030225, 0x00000108, 0x00020826, 0x00020927, 0x00040328, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0007072C, 0x0003000A, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000614, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00080123, 0x00050429, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0006052B, 0x0006042A, 0x00020326, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00020224, 0x00020327, 0x00070120, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0009060B, 0x00070309, 0x00010208, 0x00040107, 0x0001090C, 0x0002040A, 0x00000040, 0x00000040 },
  { 0x0007061D, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00020325, 0x00080226, 0x00090227, 0x00030428, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00020225, 0x0007072D, 0x00000709, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0004000D, 0x00080732, 0x00040935, 0x0005062F, 0x00030228, 0x0004011E, 0x00000040, 0x00000040 },
  { 0x00090734, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00080631, 0x0002011C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0007032D, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00040936, 0x00050010, 0x0006052E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00050630, 0x00080733, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0003040D, 0x0009060E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00030007, 0x0003041E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00070529, 0x0008062A, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00020328, 0x0000020A, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0000030D, 0x00090335, 0x00080737, 0x0001031E, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0006032F, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0007022C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00070332, 0x00060839, 0x00070437, 0x0006093C, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000717, 0x00030435, 0x0008083B, 0x00030836, 0x00050638, 0x0007083A, 0x00000040, 0x00000040 },
  { 0x00060811, 0x00020006, 0x00000600, 0x00030810, 0x0007070F, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000503, 0x0002011A, 0x0006071F, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0008062B, 0x00010002, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0008062E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00020729, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00010003, 0x00090018, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00080122, 0x00030930, 0x0003042F, 0x00040938, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0007073E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00010621, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000518, 0x00070334, 0x00010119, 0x0008063D, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00070012, 0x00010113, 0x00060214, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00060014, 0x0001031C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00090530, 0x0000090B, 0x00060831, 0x0001071D, 0x0004052F, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0000090E, 0x0002082A, 0x00090538, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0002082B, 0x00000000, 0x0009083D, 0x0003082E, 0x00080121, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0005011F, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00010522, 0x00050011, 0x00060331, 0x00040839, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0004083C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00060012, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000805, 0x00000704, 0x00020920, 0x0002011B, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0004072C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00040832, 0x0003072D, 0x00030009, 0x00050934, 0x00090833, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00090017, 0x00040837, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0007073E, 0x00040229, 0x0001061F, 0x0000070F, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0003011D, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0007053E, 0x0005073E, 0x0003032D, 0x00010004, 0x0002042C, 0x0005000F, 0x00000040, 0x00000040 },
  { 0x00010223, 0x0004093A, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00050622, 0x00020723, 0x00090016, 0x00060521, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00030226, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00080639, 0x0009083B, 0x00090336, 0x0009073A, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000611, 0x00000310, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0005022B, 0x00030631, 0x00080439, 0x0005093D, 0x0009043C, 0x0004022A, 0x0005032E, 0x00000040 },
  { 0x00030432, 0x00010005, 0x00040437, 0x00030933, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0004093B, 0x0008093F, 0x0009083F, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0008083F, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00010001, 0x00070417, 0x00080116, 0x00050518, 0x00020115, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00010519, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00020224, 0x00030227, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00040435, 0x00080436, 0x0000010C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0008063C, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00060330, 0x00060438, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0003000B, 0x0004000E, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00030534, 0x00010220, 0x0008043A, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x0008043B, 0x00070333, 0x0006053D, 0x0008083F, 0x00000040, 0x00000040, 0x00000040, 0x00000040 },
  { 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040, 0x00000040 }
};

ALIGN(8)
int ttileN_upd[100]={0}; // ? does not work yet

static inline void TileN_Update(void) {
  int fn1;
  LOOP1(100) ttileN_upd[fn1]=ttileN[fn1];
  
  ttileN_upd[1]=tmp.ttiles[0];
	//modele : tmp.ttileN_upd[1]=tmp.ttiles[0];
	/*
  ttileN_upd[1]=tmp.ttiles[0];
	ttileN_upd[4]=tmp.ttiles[15];
	ttileN_upd[5]=tmp.ttiles[16];
	ttileN_upd[6]=tmp.ttiles[8];
	ttileN_upd[7]=tmp.ttiles[9];
	ttileN_upd[8]=tmp.ttiles[1];
	ttileN_upd[9]=tmp.ttiles[24];
	ttileN_upd[10]=tmp.ttiles[25];
	ttileN_upd[12]=tmp.ttiles[3];
	ttileN_upd[16]=tmp.ttiles[4];
	ttileN_upd[17]=tmp.ttiles[17];
	ttileN_upd[23]=tmp.ttiles[26];
	ttileN_upd[24]=tmp.ttiles[27];
	ttileN_upd[25]=tmp.ttiles[28];
	ttileN_upd[28]=tmp.ttiles[20];
	ttileN_upd[30]=tmp.ttiles[30];
	ttileN_upd[32]=tmp.ttiles[21];
	ttileN_upd[33]=tmp.ttiles[13];
	ttileN_upd[37]=tmp.ttiles[31];
  */
}

//typedef void (*ptrFonction) (const signed int, const signed int);

ALIGN(8)
void (* tfncall[78]) (const int, const int) ={
   BorderWest,
   InnerRow,
   Special_Debug, // only for clean stats
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
	 BorderEast, // C10
    //Special_Debug, 
  
   BorderWest,
   InnerRow, // replaces InnerTile() * 8
   Special_Debug, // only for clean stats
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   BorderEast, //	 BorderEastUpdate, // D10   // ? fail
  
   BorderWest,
   InnerRow, 
   Special_Debug, // only for clean stats
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
	 BorderEast, // E10
  
   BorderWest,
   InnerRow, 
   Special_Debug, // only for clean stats
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
	 BorderEast, // F10
  
//Special_Debug,
  
   BorderWest,
   InnerRow, 
   Special_Debug, // only for clean stats
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
	 BorderEast, // G10
  
   BorderWest,
   InnerRow, 
   Special_Debug, // only for clean stats
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
	 Special_H10,    // H10
   
   Special_I1, 
   InnerRow, 
   Special_Debug, // only for clean stats
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
   Special_Debug,
	 Special_I10,    // I10
   
   BorderEastBottom, // J9
   BorderEastBottom, // J8
   BorderEastBottom, // J7
   BorderEastBottom, // J6
   BorderEastBottom, // J5
   BorderEastBottom, // J4
   BorderEastBottom, // J3
   Special_J2, // J2, last square
};

//dynamic
int tborderwestN[4]={0};
int tbordereastN[40]={0};

int tborderwestT[4][9]={0}; 
int tborderwestE[4][9]={0}; 
int tborderwestS[4][9]={0};

int tbordereastT[40][4]={0};
int tbordereastS[40][4]={0};

// sandwiched BorderWest ; J1N=0 or 3 for this specific problem
void Special_I1(const int north, const int northI) {
  int couleur, tuileN, fn1, tuile, east;
  void (*ptr)(const int, const int);
  macro_globaltrace2(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];

  couleur=north + 4*0; 
  tmp.j9e=3;
  tuileN=tGDN[couleur];
  LOOP1(tuileN) {
    tuile=tGD[couleur][fn1*2 + 0];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      east=tGD[couleur][fn1*2 + 1];
      tmp.ttiles[64+1 + tuile]=0;
      out.fn_idx++;
      (*ptr)(east, northI+1);
      out.fn_idx--;
      tmp.ttiles[64+1 + tuile]=1;
    }
  }

  couleur=north + 4*3; 
  tmp.j9e=0;
  tuileN=tGDN[couleur];
  LOOP1(tuileN) {
    tuile=tGD[couleur][fn1*2 + 0];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      east=tGD[couleur][fn1*2 + 1];
      tmp.ttiles[64+1 + tuile]=0;
      out.fn_idx++;
      (*ptr)(east, northI+1);
      out.fn_idx--;
      tmp.ttiles[64+1 + tuile]=1;
    }
  }
}

void BorderWest(const int north, const int northI) {
  int couleur, tuileN, fn1, tuile, east;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];
  out.fn_idx++;

  couleur=north; // in.tdam[C1N];
  tuileN=tborderwestN[couleur];
  LOOP1(tuileN) {
    tuile=tborderwestT[couleur][fn1];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      east=tborderwestE[couleur][fn1];
      in.tdam[northI+10]=tborderwestS[couleur][fn1];
      tmp.ttiles[64+1 + tuile]=0;
      (*ptr)(east, northI+1);
      tmp.ttiles[64+1 + tuile]=1;
    }
  }

  out.fn_idx--;
}

void InnerTile(const int eastcolor, const int northI) {
  int couleur, tuileN, fn1, fn2, tuile, east;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];

  couleur=eastcolor + 10*in.tdam[northI];
  tuileN=ttileN[couleur];
  LOOP1(tuileN) {
    fn2=t14[couleur][fn1];
    tuile=fn2 & 0xff;
    ifnz(tmp.ttiles[tuile]) {
      east=(fn2>>8) & 0xff;
      in.tdam[northI+10]=fn2>>16;
      tmp.ttiles[tuile]=0;
      out.fn_idx++;
      (*ptr)(east, northI+1);
      out.fn_idx--;
      tmp.ttiles[tuile]=1;
    }
  }
}

void BorderEast(const int eastcolor, const int northI) {
  int couleur, tuileN, fn1, tuile;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];
  out.fn_idx++;

  couleur=eastcolor*4 + in.tdam[northI];
  tuileN=tbordereastN[couleur];
  LOOP1(tuileN) {
    tuile=tbordereastT[couleur][fn1];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      in.tdam[northI+10]=tbordereastS[couleur][fn1];
      tmp.ttiles[64+1 + tuile]=0;
      (*ptr)(in.tdam[northI+1], northI+1);
      tmp.ttiles[64+1 + tuile]=1;
    }
  }

  out.fn_idx--;
}

// BorderEast for the bottom line ; from J9 to J2 excluded ; only change to these tags '//#'
void BorderEastBottom(const int northI, const int eastcolor) {
  int couleur, tuileN, fn1, tuile, nexteast;
  void (*ptr)(const int, const int);
  macro_globaltrace2(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];

  couleur=in.tdam[northI] * 4 + eastcolor; //#
  tuileN=tbordereastN[couleur];
  LOOP1(tuileN) {
    tuile=tbordereastT[couleur][fn1];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      tmp.ttiles[64+1 + tuile]=0;
      out.fn_idx++;
      (*ptr)(northI-1, tbordureG[tuile]); //#
      out.fn_idx--;
      tmp.ttiles[64+1 + tuile]=1;
    }
  }
}

// BorderEastBottom with final check for J2 the last square
void Special_J2(const int northI, const int eastcolor) {
  int couleur, tuileN, fn1, tuile, nexteast;
  void (*ptr)(const int, const int);
  macro_globaltrace2(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];

  couleur=in.tdam[northI] * 4 + eastcolor; //#
  tuileN=tbordereastN[couleur];
  LOOP1(tuileN) {
    tuile=tbordereastT[couleur][fn1];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      if(tbordureG[tuile] != 1) continue; // tdam[J1E] == 1 for this specific problem
      
      out.globalres++; // O_O reach this point after about 10^17 nodes...
      
    }
  }
}

// BorderEast with I10 checkup
void Special_H10(const int eastcolor, const int northI) {
  int couleur, tuileN, fn1, tuile;
  void (*ptr)(const int, const int);
  macro_globaltrace2(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];
  out.fn_idx++;

  couleur=eastcolor*4 + in.tdam[northI];
  tuileN=tbordereastN[couleur];
  LOOP1(tuileN) {
    tuile=tbordereastT[couleur][fn1];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      if(tbordureG[tuile] == 0) continue; // borders 0/1/x/0 do not exist on this specific problem
      //in.tdam[northI+10]=tbordereastS[couleur][fn1];
      
      tmp.ttiles[64+1 + tuile]=0;
      (*ptr)(in.tdam[northI+1], northI+1);
      tmp.ttiles[64+1 + tuile]=1;
    }
  }

  out.fn_idx--;
}

// BorderEast with I10 strong constraint
void Special_I10(const int eastcolor, const int northI) {
  int couleur, tuileN, fn1, tuile;
  void (*ptr)(const int, const int);
  macro_globaltrace2(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];
  out.fn_idx++;

  couleur=eastcolor*4 + in.tdam[northI];
  tuileN=tbordereastN[couleur];
  LOOP1(tuileN) {
    tuile=tbordereastT[couleur][fn1];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      if(tbordureG[tuile] != 2) continue; // J10N == 2 for this specific problem
      
      tmp.ttiles[64+1 + tuile]=0;
      (*ptr)(northI+9, tmp.j9e);
      tmp.ttiles[64+1 + tuile]=1;
    }
  }

  out.fn_idx--;
}

//??? why does it NOT work ? should be 10 % faster
void BorderEastUpdate(const int eastcolor, const int northI) {
  int couleur, tuileN, fn1, tuile;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];

  TileN_Update();

  out.fn_idx++;

  couleur=eastcolor*4 + in.tdam[northI];
  tuileN=tbordereastN[couleur];
  LOOP1(tuileN) {
    tuile=tbordereastT[couleur][fn1];
    ifnz(tmp.ttiles[64+1 + tuile]) {
      in.tdam[northI+10]=tbordereastS[couleur][fn1];
      tmp.ttiles[64+1 + tuile]=0;
      (*ptr)(in.tdam[northI+1], northI+1);
      tmp.ttiles[64+1 + tuile]=1;
    }
  }

  out.fn_idx--;
}

void InnerTile0(const int eastcolor, const int northI) {
  int couleur, tuileN, fn1, fn2, tuile, east;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];

  couleur=eastcolor + 10*in.tdam[northI];
  tuileN=ttileN[couleur];
  LOOP1(tuileN) {
    fn2=t14[couleur][fn1];
    tuile=fn2 & 0xff;
    ifnz(tmp.ttiles[tuile]) {
      east=(fn2>>8) & 0xff;
      in.tdam[northI+10]=fn2>>16;
      tmp.ttiles[tuile]=0;
      out.fn_idx++;
      (*ptr)(east, northI+1);
      out.fn_idx--;
      tmp.ttiles[tuile]=1;
    }
  }
}

void InnerTile1(const int eastcolor, const int northI) {
  int couleur, tuileN, fn1, fn2, tuile, east;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];
  out.fn_idx++;

  couleur=eastcolor + 10*in.tdam[northI];
  tuileN=ttileN_upd[couleur];
  LOOP1(tuileN) {
    fn2=t14[couleur][fn1];
    tuile=fn2 & 0xff;
    ifnz(tmp.ttiles[tuile]) {
      east=(fn2>>8) & 0xff;
      in.tdam[northI+10]=fn2>>16;
      tmp.ttiles[tuile]=0;
      (*ptr)(east, northI+1);
      tmp.ttiles[tuile]=1;
    }
  }

  out.fn_idx--;
}

//point de vigilance : teast[idx - 1] ; le reste : std
#define macro_innerrow_loop(idx)\
			macro_globaltrace(out.fn_idx - 8 + idx);\
			tcouleur[idx]=teast[idx - 1] + 10*in.tdam[northI +idx];\
			ttuileN[idx]=ttileN[tcouleur[idx]];\
			LOOP(tfn1[idx], ttuileN[idx]) {\
				tfn2[idx]=t14[tcouleur[idx]][tfn1[idx]];\
				ttuile[idx]=tfn2[idx] & 0xff;\
				ifnz(tmp.ttiles[ttuile[idx]]) {\
					teast[idx]=(tfn2[idx]>>8) & 0xff;\
					in.tdam[south + idx]=tfn2[idx] >> 16;\
					tmp.ttiles[ttuile[idx]]=0;
					
#define macro_innerrow_loopz(idx) tmp.ttiles[ttuile[idx]]=1; } }


void InnerRow(const int eastcolor, const int northI) {
  int tcouleur[8], ttuileN[8], tfn1[8], tfn2[8], ttuile[8], teast[8];
	int south=northI+10;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);

	out.fn_idx +=8;
  ptr=tfncall[out.fn_idx];
	
  tcouleur[0]=eastcolor + 10*in.tdam[northI];
  ttuileN[0]=ttileN[tcouleur[0]];
  LOOP(tfn1[0], ttuileN[0]) {
    tfn2[0]=t14[tcouleur[0]][tfn1[0]];
    ttuile[0]=tfn2[0] & 0xff;
    ifnz(tmp.ttiles[ttuile[0]]) {
      teast[0]=(tfn2[0]>>8) & 0xff;
      in.tdam[south +0]=tfn2[0] >> 16;
      tmp.ttiles[ttuile[0]]=0;
      
			// (*ptr)(teast[0], northI+1);
			/*
			tcouleur[1]=teast[0] + 10*in.tdam[northI +1];
			ttuileN[1]=ttileN[tcouleur[1]];
			LOOP(tfn1[1], ttuileN[1]) {
				tfn2[1]=t14[tcouleur[1]][tfn1[1]];
				ttuile[1]=tfn2[1] & 0xff;
				ifnz(tmp.ttiles[ttuile[1]]) {
					teast[1]=(tfn2[1]>>8) & 0xff;
					in.tdam[south +1]=tfn2[1] >> 16;
					tmp.ttiles[ttuile[1]]=0;
					out.fn_idx++;
			*/
			macro_innerrow_loop(1)
				macro_innerrow_loop(2)
					macro_innerrow_loop(3)
						macro_innerrow_loop(4)
							macro_innerrow_loop(5)
								macro_innerrow_loop(6)
									macro_innerrow_loop(7)
									
									(*ptr)(teast[7], northI + 8);
									
									macro_innerrow_loopz(7)
								macro_innerrow_loopz(6)
							macro_innerrow_loopz(5)
						macro_innerrow_loopz(4)
					macro_innerrow_loopz(3)
				macro_innerrow_loopz(2)
			macro_innerrow_loopz(1)
      
      tmp.ttiles[ttuile[0]]=1;
    }
  }

	out.fn_idx -=8;
}


//point de vigilance : teast[idx - 1] ; le reste : std
#define macro_innerrow_loop2(idx)\
			macro_globaltrace(out.fn_idx - 8 + idx);\
			tcouleur[idx]=teast[idx - 1] + 10*in.tdam[northI +idx];\
			ttuileN[idx]=ttileN_upd[tcouleur[idx]];\
			LOOP(tfn1[idx], ttuileN[idx]) {\
				tfn2[idx]=t14[tcouleur[idx]][tfn1[idx]];\
				ttuile[idx]=tfn2[idx] & 0xff;\
				ifnz(tmp.ttiles[ttuile[idx]]) {\
					teast[idx]=(tfn2[idx]>>8) & 0xff;\
					in.tdam[south + idx]=tfn2[idx] >> 16;\
					tmp.ttiles[ttuile[idx]]=0;


void InnerRow2(const int eastcolor, const int northI) {
  int tcouleur[8], ttuileN[8], tfn1[8], tfn2[8], ttuile[8], teast[8];
	int south=northI+10;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);

	out.fn_idx +=8;
  ptr=tfncall[out.fn_idx];
	
  tcouleur[0]=eastcolor + 10*in.tdam[northI];
  ttuileN[0]=ttileN_upd[tcouleur[0]];
  LOOP(tfn1[0], ttuileN[0]) {
    tfn2[0]=t14[tcouleur[0]][tfn1[0]];
    ttuile[0]=tfn2[0] & 0xff;
    ifnz(tmp.ttiles[ttuile[0]]) {
      teast[0]=(tfn2[0]>>8) & 0xff;
      in.tdam[south +0]=tfn2[0] >> 16;
      tmp.ttiles[ttuile[0]]=0;

			macro_innerrow_loop(1)
				macro_innerrow_loop(2)
					macro_innerrow_loop(3)
						macro_innerrow_loop(4)
							macro_innerrow_loop(5)
								macro_innerrow_loop(6)
									macro_innerrow_loop(7)
									
									(*ptr)(teast[7], northI + 8);
									
									macro_innerrow_loopz(7)
								macro_innerrow_loopz(6)
							macro_innerrow_loopz(5)
						macro_innerrow_loopz(4)
					macro_innerrow_loopz(3)
				macro_innerrow_loopz(2)
			macro_innerrow_loopz(1)
      
      tmp.ttiles[ttuile[0]]=1;
    }
  }

	out.fn_idx -=8;
}


/* super BIDE ou BUG de nouveau
void InnerTile0(const int eastcolor, const int northI) {
  int64_t tfn2[4];
  int couleur, tuileN, fn1, fn2, tuile, east;
  void (*ptr)(const int, const int);
  macro_globaltrace(out.fn_idx);
  ptr=tfncall[out.fn_idx+1];

  couleur=eastcolor + 10*in.tdam[northI];

  tfn2[0]=*(int64_t *)&t14[couleur][0];
  tfn2[1]=*(int64_t *)&t14[couleur][2];
  tfn2[2]=*(int64_t *)&t14[couleur][4];
  tfn2[3]=*(int64_t *)&t14[couleur][6];

  tuileN=ttileN[couleur];
  LOOP1(tuileN) {
    fn2=*(int *)(&tfn2 + fn1*4); //t14[couleur][fn1];
    tuile=fn2 & 0xff;
    ifnz(tmp.ttiles[tuile]) {
      east=(fn2>>8) & 0xff;
      in.tdam[northI+10]=fn2>>16;
      tmp.ttiles[tuile]=0;
      out.fn_idx++;
      (*ptr)(east, northI+1);
      out.fn_idx--;
      tmp.ttiles[tuile]=1;
    }
  }
}
*/

void Special_Debug(const int north, const int northI) {
  macro_globaltrace(out.fn_idx);
}

//#######################################

// prevent inlining this trivial function: we may need some room
void __attribute__ ((noinline)) Input_Copy(int tiles, int *dest) {
  int fn1;
  LOOP1(32) {
    dest[fn1]=tiles & 1;
    tiles>>=1;
  }
}

//void __attribute__((interrupt)) null_isr() { return; }

//#######################################

int main(void) {
e_start:;
  
  int fn1, westcolor, eastcolor, tiles;

  volatile signed int *inputP  = (void *)SHARED_IN;  // pointer for input
  //volatile signed int *cmdP    = (void *)SHARED_CMD; // pointer for output command

  // init compute kernel
  tiles=*(inputP+0); Input_Copy(tiles, &tmp.ttiles[ 0]); // 1st 32 tiles
  tiles=*(inputP+1); Input_Copy(tiles, &tmp.ttiles[32]);
  tiles=*(inputP+2); Input_Copy(tiles, &tmp.ttiles[VOIDTILE+1]); // 32 borders
  tmp.ttiles[VOIDTILE]=0; // VOIDTILE == 64
    
  LOOP1(4)
    tborderwestN[fn1]=0;
  LOOP1(40)
    tbordereastN[fn1]=0;

  LOOP1(32) {
    if(tmp.ttiles[64+1 +fn1]) {
      westcolor=tbordureG[fn1];
      tborderwestT[westcolor] [tborderwestN[westcolor]]=fn1;
      tborderwestE[westcolor] [tborderwestN[westcolor]]=tbordureI[fn1];
      tborderwestS[westcolor] [tborderwestN[westcolor]]=tbordureD[fn1];
      tborderwestN[westcolor]++;
      
      eastcolor=tbordureI[fn1]*4 + tbordureD[fn1];
      tbordereastT[eastcolor] [tbordereastN[eastcolor]]=fn1;
      tbordereastS[eastcolor] [tbordereastN[eastcolor]]=tbordureG[fn1];
      tbordereastN[eastcolor]++;
    }
  }

  out.fn_idx=0;
  BorderWest(in.tdam[C1N], C1N);

  out.cmd=CMD_DONE; // *cmdP=CMD_DONE;
  
  //return 0;
  __asm__ __volatile__ ("idle"); // experience: can you idle an Epiphany core until ARM wakes it up ?  Answer: empirically, yes ; use e_start() to reload the core
  //goto e_start; // wake by IVT # 0
  
}
