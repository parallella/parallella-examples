//#define SOFTENING 1e-9f
#define SOFTENING 1.0f
#define NUM_CORES 16

typedef struct __attribute__((aligned(8))){ 
	float x, y, z, vx, vy, vz, m, im;
} Body;
