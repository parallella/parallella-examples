/*
 * Author: Noémien Kocher
 * Date: january 2016
 * Licence: MIT
 * Purpose:
 *   This file is run by each eCore, it represents the life of a cell. Until it
 *   is stopped, loops over and check its neighbor so as to update its status.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#include <e-lib.h> // Epiphany cores library

#define READY 0x1
#define DEAD  'O'
#define ALIVE 'X'
/*
 * [1] status, O = dead X = alive
 * [0] ready, 0 = not 1 = ready
 */
char swap[8] SECTION(".text_bank2");
volatile char *result;
volatile uint32_t *status;
volatile uint32_t *state;

int main(void) {

  unsigned core_row, core_col,
           group_rows, group_cols,
           core_num;
  char neighbor_status;
  uint32_t iterations = 0;
  uint32_t iof = 0; // Sticky Integer Overflow Flag

  core_row = e_group_config.core_row;
  core_col = e_group_config.core_col;
  group_rows = e_group_config.group_rows;
  group_cols = e_group_config.group_cols;

  core_num = core_row * group_cols + core_col;

  // our swap, could (should) put it in a structure
  swap[1] = DEAD;
  swap[0] = READY;

  // starts at the beginning of sdram
  result  = (volatile char *) (0x8f000000 + 0x1*core_num); // writing to external memory, writing 4bytes
  // we add offset of 0x10 = 16 = ncores * sizeof(char)
  status = (volatile uint32_t*) (0x8f000010 + 0x4*core_num);
  // we add offset of 0x50 = 16 + 16 * sizeof(uint32_t)
  state = (volatile uint32_t*) (0x8f000050 + 0x4*core_num);

  unsigned alive_neighbor;
  while(1) {
    iterations++; // increment number of iteration
    unsigned tmp_iof = e_reg_read(E_REG_STATUS);
    tmp_iof = tmp_iof & (4096); // use the sticky overflow integer flag
    iof = iof | tmp_iof;
    alive_neighbor = 0;
    // top left
    if(core_row == 0 && core_col == 0) {
      alive_neighbor += 5; // dead anyway!
    }
    // top right
    else if(core_row == 0 && core_col == group_cols-1) {
      alive_neighbor += 5; // dead anyway!
    }
    // bottom left
    else if(core_row == group_rows-1 && core_col == 0) {
      alive_neighbor += 5; // dead anyway!
    }
    // bottom right
    else if(core_row == group_rows-1 && core_col == group_cols-1) {
      alive_neighbor += 5; // dead anyway!
    }
    // top
    else if(core_row == 0) {
      alive_neighbor += 3;
      e_read(&e_group_config,&neighbor_status,core_row,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
    }
    // bottom
    else if(core_row == group_rows-1) {
      alive_neighbor += 3;
      e_read(&e_group_config,&neighbor_status,core_row,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
    }
    // left
    else if(core_col == 0) {
      alive_neighbor += 3;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row+1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row+1,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
    }
    // right
    else if(core_col == group_cols-1) {
      alive_neighbor += 3;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row+1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row+1,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
    }
    // middle
    else {
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row-1,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row+1,core_col-1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row+1,core_col,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
      e_read(&e_group_config,&neighbor_status,core_row+1,core_col+1,(char*)0x4001,1);
      if(neighbor_status == ALIVE) alive_neighbor++;
    }
    if(alive_neighbor == 3) swap[1] = ALIVE;
    else if(alive_neighbor < 2) swap[1] = DEAD;
    else if(alive_neighbor > 3) swap[1] = DEAD;
    *result = swap[1]; // store result
    *status = iterations; // store number of iterations so far
    *state = iof;
  }
}
