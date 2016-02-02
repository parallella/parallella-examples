/*
 * Author: Noémien Kocher
 * Date: january 2016
 * Licence: MIT
 * Purpose:
 *   Computes a game of life where each core is an independent cell.
 *   The main program reads for a certain number of iterations the status of the
 *   cells and displays it. Outputs at the end the number of iterations for each
 *   cell (eCore) and the status of the sticky overflow flag.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <e-hal.h>  // Epiphany Hardware Abstraction Layer
                    // functionality for communicating with epiphany chip when
                    // the application runs on a host, typically the ARM µp

#define BUFOFFSET (0x01000000)  // SDRAM is at 0x8f00'0000,
                                // offset in e_read starts at 0x8e00'0000
#define GAME_ITERATIONS 100

unsigned rows, cols, i, j, ncores, row, col;
unsigned game_iteration = GAME_ITERATIONS;

/*
 * Init the epiphany platform
 */
void init_epiphany(e_platform_t * platform) {
  e_init(NULL);
  e_reset_system();
  e_get_platform_info(platform);
}

/*
 * Create the workgroup and load programs into it
 */
init_workgroup(e_epiphany_t * dev) {
  e_return_stat_t result;
  e_open(dev, 0, 0, rows, cols); // Create an epiphany cores workgroup
  e_reset_group(dev);
  // load programs into cores workgroup, do not execute it immediately
  result = e_load_group("emain.srec", dev, 0, 0, rows, cols, E_FALSE);
  if(result != E_OK) {
    printf("Error Loading the Epiphany Application %i\n", result);
  }
  e_start_group(dev);
}

/*
 * Main entry
 */
int main(int argc, char * argv[]) {

  // Arguments handling
  switch(argc) {
    case 2: game_iteration = atoi(argv[1]);
    case 1: break;
    default:
      printf("Wrong number og arguments\nUsage: ./mail.elf [nb iterations]\n");
      return 0;
  }

  e_platform_t platform;  // platform infos
  e_epiphany_t dev;       // provides access to cores workgroup
  e_mem_t emem;           // shared memory buffer

  init_epiphany(&platform);

  rows = platform.rows;
  cols = platform.cols;
  ncores = rows * cols;
  char result[ncores];     // to store the results, size of cores
  // allocate a space to share data between e_cores and here
  // offset starts from 0x8e00'0000
  // sdram (shared space) is at 0x8f00'0000
  // so 0x8e00'0000 + 0x0100'0000 = 0x8f00'0000
  e_alloc(&emem, BUFOFFSET, ncores*sizeof(char) +
                            ncores*sizeof(uint32_t) +
                            ncores*sizeof(uint32_t)); // *2 'cause we store result and number of iterations

  init_workgroup(&dev);
  // we read from the allocated space and store it to the result array
  for(i = 0; i < game_iteration; i++) {
    usleep(1000);
    e_read(&emem, 0, 0, 0x0, &result, ncores * sizeof(char)); // reads what's ben put in buffer
    fprintf(stdout, "X\tX\tX\tX\tX\tX\n");
    for(row = 0; row < rows; row++) {
      fprintf(stdout, "X\t");
      for(col = 0; col < cols; col++) {
        fprintf(stdout, "%c\t", result[row*cols+col]);
      }
      fprintf(stdout, "X\t");
      fprintf(stdout, "\n");
    }
    fprintf(stdout, "X\tX\tX\tX\tX\tX\n");
    fprintf(stdout, "\n");
    fflush(stdout);
  }
  // read iterations
  uint32_t iterations[ncores*2];
  // offset of ncores
  e_read(&emem, 0, 0, ncores, &iterations, ncores * sizeof(uint32_t) + ncores * sizeof(uint32_t));
  for(i = 0; i < ncores; i++) {
    fprintf(stdout, "eCore %02i:\titeration %i,\tiof %i\n", i, iterations[i],iterations[ncores+i]);
  }
  e_close(&dev);
  return 0;
}
