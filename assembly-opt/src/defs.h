//Configure parameters for single core matmul
//M,N,K - matrix sizes

#define CLOCK 600

typedef struct
{
    int result;
    int flag,coreid;
    char operation[20];
    unsigned int clocks1,clocks2,flops1,flops2;
    float *c_o,*c_n,*a,*b;
} Mailbox;

#define N (32)
#define K (N)
#define ROWS (N)
