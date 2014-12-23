/*Copyright (C) 2012 Adapteva, Inc.
  Contributed by Yaniv Sapir <yaniv@adapteva.com>, Aug 2013
  Modified by: Anish Varghese <anish.varghese@anu.edu.au>, May 2014

  Configure parameters for multicore matmul
*/

#define CLOCK 600


#define _Nchips 1                  // # of chips in operand matrix side
#define _Nside  8                  // # of cores in chip side
#define _Ncores (_Nside * _Nside)  // Num of cores = 64
#define _Score  32                 // side size of per-core sub-submatrix (max 32)
#define _Schip  (_Score * _Nside)  // side size of per-chip submatrix
#define _Smtx   (_Schip * _Nchips) // side size of operand matrix

#define _Nbanks 4                  // Num of SRAM banks on core

#define _BankP  0
#define _BankA  1
#define _BankB  2
#define _BankC  3
#define _PING   0
#define _PONG   1

#define N (_Score)
#define K (N)

#define group_rows_num _Nside
#define group_cols_num _Nside

typedef struct
{
    unsigned int clocks;
    float *c_o,*c_n,*a,*b;
    unsigned int dummy1,dummy2,dummy3;
} Output_t;

typedef struct
{
    int flag,dummy;
    Output_t output; 
    float  A[_Smtx * _Smtx]; // Global A matrix 
    float  B[_Smtx * _Smtx]; // Global B matrix 
    float  C[_Smtx * _Smtx]; // Global C matrix 
} Mailbox_t;


typedef struct {
    unsigned corenum;
    unsigned row;
    unsigned col;

    void  *bank_A[2]; // A Ping Pong Bank local space pointers
    void  *bank_B[2]; // B Ping Pong Bank local space pointers
    void  *bank_C;    // C Ping Pong Bank local space pointers
    void  *tgt_A[2];  // A target Bank for matrix rotate in global space
    void  *tgt_B[2];  // B target Bank for matrix rotate in global space
    void  *recv_A[2];
    void  *recv_B[2];
    void  *trans_A[2];
    void  *trans_B[2];

    int    pingpong;  // Ping-Pong bank select indicator
    float *pA,*pB,*pC; //Pointers to global matrix arrays 
} core_t;

