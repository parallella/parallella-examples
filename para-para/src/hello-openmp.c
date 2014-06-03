#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
int main (int argc, char *argv[]) {
  
  int nthreads, tid;
  
  /*Create a thread and fork */
#pragma omp parallel private(nthreads, tid)
  {
    /* Obtain thread number */
    tid = omp_get_thread_num();
    printf("Hello World from OpenMP thread = %d\n", tid);
    
    /* Only master thread does this */
    if (tid == 0){
      nthreads = omp_get_num_threads();
      //printf("Number of threads = %d\n", nthreads);
    }  
  } /* All threads join master thread and disband */  
}
