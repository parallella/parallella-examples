#ifndef _RIECOIN_GLOBAL_H_
#define _RIECOIN_GLOBAL_H_

#ifdef _WIN32
#define NOMINMAX
#define WINVER 0x600
#define _WIN32_WINNT WINVER
//#define NTDDI_VERSION NTDDI_VISTA
//#include <winbase.h>

#include <windows.h>

#pragma comment(lib,"Ws2_32.lib")
#include <winsock2.h>
#include <ws2tcpip.h>
#include "mpir/mpir.h"

#else

#ifndef USE_MPIR
#include <gmpxx.h>
#include <gmp.h>
#else
#include <mpirxx.h>
#include <mpir.h>
#endif

// Windows-isms for compatibility in Linux
#define RtlZeroMemory(Destination,Length) std::memset((Destination),0,(Length))
#define RtlCopyMemory(Destination,Source,Length) std::memcpy((Destination),(Source),(Length))

#define _strdup(duration) strdup(duration)
#define Sleep(ms) usleep(1000*ms)
#define strcpy_s(dest,val,src) strncopy(dest,src,val)
#define __debugbreak(); raise(SIGTRAP);
#define CRITICAL_SECTION pthread_mutex_t
#define CONDITION_VARIABLE pthread_cond_t
#define EnterCriticalSection(Section) pthread_mutex_lock(Section)
#define LeaveCriticalSection(Section) pthread_mutex_unlock(Section)
#define InitializeCriticalSection(Section) pthread_mutex_init(Section, NULL)
#define InitializeConditionVariable(cv) pthread_cond_init(cv, NULL)
#define SleepConditionVariableCS(cv, Section, dwMilliseconds)  pthread_cond_wait(cv, Section)
#define WakeConditionVariable(cv) pthread_cond_signal(cv)
#define WakeAllConditionVariable(cv) pthread_cond_broadcast(cv)
#define INFINITE 0 /* notused in unix */

// lazy workaround
typedef int SOCKET;
typedef struct sockaddr_in SOCKADDR_IN;
typedef struct sockaddr SOCKADDR;
#define SOCKET_ERROR -1
#define closesocket close
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <pthread.h>

#endif

#ifndef thread_local
# if __STDC_VERSION__ >= 201112 && !defined __STDC_NO_THREADS__
#  define thread_local _Thread_local
# elif defined _WIN32 && ( \
       defined _MSC_VER || \
       defined __ICL || \
       defined __DMC__ || \
       defined __BORLANDC__ )
#  define thread_local __declspec(thread) 
/* note that ICC (linux) and Clang are covered by __GNUC__ */
# elif defined __GNUC__ || \
       defined __SUNPRO_C || \
       defined __xlC__
#  define thread_local __thread
# else
#  error "Cannot define thread_local"
# endif
#endif
#if defined(_MSC_VER)
#define _ALIGNED(x) __declspec(align(x))
#else
#if defined(__GNUC__)
#define _ALIGNED(x) __attribute__ ((aligned(x)))
#endif
#endif
#define _ALIGNED_TYPE(t,x) typedef t _ALIGNED(x)

#include<stdio.h>
#include<time.h>
#include<stdlib.h>
#include<set>

#include <iomanip>

#include"jhlib.h" // slim version of jh library

// connection info for xpt
typedef struct  
{
	char* ip;
	uint16 port;
	char* authUser;
	char* authPass;
	float donationPercent;
}generalRequestTarget_t;

#include"xptServer.h"
#include"xptClient.h"

#include"sha2.h"

#include"transaction.h"

// global settings for miner
typedef struct  
{
	generalRequestTarget_t requestTarget;
	// GPU
	bool useGPU; // enable OpenCL
	// GPU (MaxCoin specific)

	float donationPercent;
}minerSettings_t;

extern minerSettings_t minerSettings;

// block data struct


typedef struct  
{
	// block data (order and memory layout is important)
	uint32	version;
	uint8	prevBlockHash[32];
	uint8	merkleRoot[32];
	uint32	nBits; // Riecoin has order of nBits and nTime exchanged
	uint64	nTime; // Riecoin has 64bit timestamps
	uint8	nOffset[32];
	// remaining data
	uint32	uniqueMerkleSeed;
	uint32	height;
	uint8	merkleRootOriginal[32]; // used to identify work
	// uint8	target[32];
	// uint8	targetShare[32];
	// compact target
	uint32  targetCompact;
	uint32  shareTargetCompact;
}minerRiecoinBlock_t;

#include"algorithm.h"


void xptMiner_submitShare(minerRiecoinBlock_t* block, uint8* nOffset);

// stats
extern volatile uint32 totalCollisionCount;
extern volatile uint32 totalShareCount;
extern volatile uint32 totalRejectedShareCount;
extern volatile uint32 total2ChainCount;
extern volatile uint32 total3ChainCount;
extern volatile uint32 total4ChainCount;


extern volatile uint32 monitorCurrentBlockHeight;
extern volatile uint32 monitorCurrentBlockTime;

#endif /* _RIECOIN_GLOBAL_H_ */
