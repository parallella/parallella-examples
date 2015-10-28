#include <stdio.h>

#define NUMBER_OF_CORES 15
#define NUMBER_OF_ITERATIONS 10
#define NUMBER_OF_INPUTS_PER_CORE 2
#define NUMBER_OF_INPUTS NUMBER_OF_CORES * NUMBER_OF_ITERATIONS * NUMBER_OF_INPUTS_PER_CORE

main(){

  int i, j;
  FILE *fin = fopen("timerDataRaw.txt", "r");
  FILE *fout = fopen("timerDataAverage.txt", "w");
  int temp;
  int input[NUMBER_OF_INPUTS];
  int output[NUMBER_OF_CORES * NUMBER_OF_INPUTS_PER_CORE];


  for(i = 0; i < (NUMBER_OF_CORES * NUMBER_OF_INPUTS_PER_CORE); i++)
    output[i] = 0;

  if(fin == NULL || fout == NULL)
    printf("Problem while opening the files\n");

  //Read all the inputs
  for(i = 0; i < NUMBER_OF_INPUTS; i++){
    fscanf(fin, "%d", &input[i]);
  }

  // Average the inputs
  for(i = 0; i < NUMBER_OF_CORES * NUMBER_OF_INPUTS_PER_CORE; i++){
    for(j = 0; j < NUMBER_OF_ITERATIONS; j++){
      output[i]+=  input[j * (NUMBER_OF_CORES * NUMBER_OF_INPUTS_PER_CORE) + i];
    }
  }

  for(i = 0; i < NUMBER_OF_CORES * NUMBER_OF_INPUTS_PER_CORE; i++){
    output[i] = output[i] / NUMBER_OF_ITERATIONS;
  }

  fprintf(fout, "Number of iterations: %d \n\n", NUMBER_OF_ITERATIONS);
  fprintf(fout, "Timer0 - Average setup cycles  \n\n");

  for(i = 0; i < NUMBER_OF_CORES; i++)
    fprintf(fout,"Timer0[%d]: %d\n", i, output[i]);

  fprintf(fout, "\n\nTimer1 - Average computation + communication cycles\n\n");

  for(i = NUMBER_OF_CORES; i < NUMBER_OF_CORES * NUMBER_OF_INPUTS_PER_CORE; i++)
    fprintf(fout,"Timer1[%d]: %d\n", i-NUMBER_OF_CORES, output[i]);

  fclose(fin);
  fclose(fout);


}
