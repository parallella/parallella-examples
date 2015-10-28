#include <stdio.h>

main(int argc, char* argv[]){
  FILE *fin1;
  FILE *fin2;
  int input1, input2, i;
  int errorCounter = 0;
  int inputNumber = atoi(argv[1]);

  fin1 = fopen("out.txt", "r");
  fin2 = fopen("expected_output.txt", "r");

  if(fin1 == NULL || fin2 == NULL){
    printf("Could not open file");
    return;
  }

  printf("Number of inputs: %d \n", inputNumber);

  for(i = 0; i < inputNumber; i++){
    
    fscanf(fin1, "%d", &input1);
    fscanf(fin2, "%d", &input2);

    if(input1 != input2)
      errorCounter++;
  }
  fclose(fin1);
  fclose(fin2);

  printf("Number of mismatch: %d \n", errorCounter);
}
