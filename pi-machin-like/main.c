/*
 * Author: Noémien Kocher
 * Date: january 2016
 * Licence: MIT
 * Purpose:
 *   Computes an approximation of PI using machin-like formula.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h> /* memset */

#include <e-hal.h>  // Epiphany Hardware Abstraction Layer
                    // functionality for communicating with epiphany chip when
                    // the application runs on a host, typically the ARM µp

#define BUFOFFSET (0x01000000) // SDRAM offset for shared buffers
#define MAIN_ITERATION 10000   // Default number of main iterations
#define SUB_ITERATION  1000    // Default number of sub iterations
#define NB_CORES       16      // Default numner of eCores

static unsigned main_iteration = MAIN_ITERATION;
static unsigned sub_iteration  = SUB_ITERATION;
static unsigned nb_cores       = NB_CORES;

float f(unsigned x);
float second();

/*
 * Main entry
 */
int main(int argc, char * argv[]) {

  // Arguments handling
  switch(argc) {
    case 4: nb_cores       = atoi(argv[3]);
    case 3: sub_iteration  = atoi(argv[2]);
    case 2: main_iteration = atoi(argv[1]);
    case 1: break;
    default:
      printf("Wrong number of args\nUsage: ./main.elf [main iterations] [sub iteration] [nb cores]\n");
      return 0;
  }

  // Init the epiphany platform
  e_platform_t platform;
  e_epiphany_t dev;
  e_init(NULL);
  e_reset_system();
  e_get_platform_info(&platform);
  e_open(&dev, 0, 0, 4, 4);
  e_load_group("emain.srec", &dev, 0, 0, 4, 4, E_FALSE); // don't start immediately
  e_start_group(&dev); // Start workgroup

  unsigned ncores = nb_cores; if(ncores>16) exit(0);
  unsigned k;
  for(k = 0; k < ncores; k++) {
    e_write(&dev, k/4, k%4, 0x400c, &sub_iteration, sizeof(unsigned));
  }

  // >>>>> Begin benchamrk
  float start_t = second();

  unsigned i,j;
  float res = 0;
  unsigned go = 1;
  unsigned free_not_found = 1;
  i = j = 0;

  for(; i < main_iteration; i++) {
    free_not_found = 1;
    while(free_not_found) {
      unsigned state;
      e_read(&dev, j/4, j%4, 0x4008, &state, sizeof(unsigned));
      if(state == 0) { // 1 busy, 0 free
        float temp_res;
        e_read(&dev, j/4, j%4, 0x4004, &temp_res, sizeof(float));
        res += temp_res;
        unsigned instruction = i; // copy i
        e_write(&dev, j/4, j%4, 0x4000, &instruction, sizeof(unsigned));
        e_write(&dev, j/4, j%4, 0x4008, &go, sizeof(unsigned));
        free_not_found = 0;
      }
      j = (++j)%ncores;
    }
  }
  // Be sure not to leave a core still working
  for(j = 0; j < ncores; j++) {
    unsigned state;
    e_read(&dev, j/4, j%4, 0x4008, &state, sizeof(unsigned));
    while(state == 1) {
      e_read(&dev, j/4, j%4, 0x4008, &state, sizeof(unsigned));
    }
    float temp_res;
    e_read(&dev, j/4, j%4, 0x4004, &temp_res, sizeof(float));
    res += temp_res;
  }

  res *= 4;

  float end_t   = second();
  // <<<<< End benchmark

  float spent_t = end_t - start_t;
  #ifdef STAT
    printf("%i,\t%i,\t%f, \t%f\n", main_iteration, sub_iteration, spent_t, res);
  #else
    printf("PI = %f\ttime spent %fs\n", res, spent_t);
  #endif
  return 0;
}

/*
 * Compute part of PI sum
 */
float f(unsigned x) {
  float res = 0;
  unsigned a = x * sub_iteration;
  unsigned b = a + sub_iteration;
  for(; a < b; a++) {
    res += pow(-1,a) / (2*a + 1);
  }
  return res;
}

/*
 * Get seconds spent from the beginning
 */
float second() {
	#include <sys/time.h>
	#include <sys/resource.h>

	struct rusage ru;
	float t;
	getrusage(RUSAGE_SELF,&ru) ;
  // user CPU time used in second + system CPU time used in second
  // + the same but in microseconds
	t = (float) (ru.ru_utime.tv_sec+ru.ru_stime.tv_sec) +
	    ((float) (ru.ru_utime.tv_usec+ru.ru_stime.tv_usec))/1.0e6 ;
	 return t ;
}
