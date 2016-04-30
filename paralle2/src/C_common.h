//avoid stdint.h
#define uint8_t		unsigned char
#define uint16_t	unsigned short
#define uint32_t	unsigned int
#define uint64_t	unsigned long long

#define int8_t		char
#define int16_t		short
#define int32_t		int
#define int64_t		long long

//my semantic
#define uc     unsigned char
#define ull    unsigned long long //bof ! mais dans mymacros.h :(
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

//#######################################
//think x86 asm, think jz... setz... cmovz... think flags...

#define ifz(x) if(!(x))
#define ifnz(x) if(x)
#define ife(x) if(!(x))
#define ifne(x) if(x)
//booleans
#define ifzbool(x,bit) ifz((x)&((uint64_t)1<<(bit))) 
#define ifnzbool(x,bit) if((x)&((uint64_t)1<<(bit))) 
#define ifbool(x,bit) ifnzbool(x,bit)
#define ifzbool64(x,bit) ifz((ull)(x)&((ull)1<<(ull)(bit)))
#define ifnzbool64(x,bit) if((ull)(x)&((ull)1<<(ull)(bit)))
#define ifbool64(x,bit) ifnzbool64(x,bit)

//__asm__ __volatile__ ("idle");//repos !

/* pense-bete
#define ALIGN(x) __attribute__ ((aligned (x))) 
#define PACKED __attribute__ ((packed)) 
#define SECTION(x) __attribute__ ((section (x)))
*/
