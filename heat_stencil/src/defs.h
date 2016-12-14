//Configure the parameters
//T_EDGE - temperature of edge grid points
//MAX_ITER - maximum number of iterations
//CORE_DATA_X/CORE_DATA_Y - defines grid size per eCore
//group_rows/group_cols - defines the number of eCores to run

//Turn on/off printing of result
#define PRINT                   

// Uncomment for Epiphany-IV
//#define CONFIG_60_60_64

// Uncomment for Epiphany-III
#define CONFIG_60_60_16

#define CLOCK 600

#ifdef CONFIG_60_60_64
    #define group_rows 8
    #define group_cols 8
    #define start_row 0
    #define start_col 0
    #define CORE_DATA_X 60
    #define CORE_DATA_Y 60
    #define STRIPE_WIDTH 20
#endif
#ifdef CONFIG_60_60_16
    #define group_rows 4
    #define group_cols 4
    #define start_row 0
    #define start_col 0
    #define CORE_DATA_X 60
    #define CORE_DATA_Y 60
    #define STRIPE_WIDTH 20
#endif

#define NUM_CORES (group_rows * group_cols) 
#define CORE_GRID_X (CORE_DATA_X + 2)             
#define CORE_GRID_Y (CORE_DATA_Y + 2)             
#define CORE_GRID_SIZE (CORE_GRID_X * CORE_GRID_Y)
#define CHIP_GRID_X (CORE_DATA_X * group_cols + 2)
#define CHIP_GRID_Y (CORE_DATA_Y * group_rows + 2)
#define CHIP_GRID_SIZE (CHIP_GRID_X * CHIP_GRID_Y)

#define T_EDGE 100.0                          
#define MAX_ITER 50 

typedef struct 
{
    int from_core; 
    int core_row,core_col;
    unsigned int clocks,measure_clock_event;
    int debug,iters;
    float total_time,mean_time,std_time,bandwidth;
    float *t_new,*t_old;
} Output;

typedef struct
{
    int finish_flag,start_flag;
    Output output;
} Mailbox;

