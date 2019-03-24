#include <stdio.h>
#include <sys/time.h>
#include <time.h>
#include <stdlib.h>

// I've changed all i++ into i = i + 1.
// I've also changed local references into poiters but it doen't work.

void multiplicationBeforeTransposition(int **fmatrix, int **smatrix, int **rmatrix, int size) {
  for (int i = 0; i < size; i = i + 1) {
    for (int j = 0; j < size; j = j + 1) {
      for (int k = 0; k < size; k = k + 1) {
        rmatrix[i][j] = rmatrix[i][j] + (fmatrix[i][k] * smatrix[k][j]);
      }
    }
  }
}

void multiplicationAfterTransposition(int **fmatrix, int **smatrix, int **rmatrix, int size) {
  for (int i = 0; i < size; i = i + 1) {
    for (int j = 0; j < size; j = j + 1) {
      for (int k = 0; k < size; k = k + 1) {
        rmatrix[i][j] = rmatrix[i][j] + (fmatrix[i][k] * smatrix[j][k]);
      }
    }
  }
}

int** transposition(int **smatrix, int size) {
  int **tmp = malloc(size*sizeof(int *));
  for (int i = 0; i < size; i++) {
    tmp[i] = malloc(size*sizeof(int));
  }
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      tmp[i][j] = smatrix[j][i];
    }
  }
  return tmp;
}

void fillMatrix(int **matrix, int size) {
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      matrix[i][j] = rand()%10;
    }
  }
}

void printMatrix(int **matrix, int size) {
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      printf("%d ", matrix[i][j]);
    }
    printf("\n");
  }
}

void clear(int **matrix, int size) {
  for(int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      matrix[i][j] = 0;
    }
  }
}


int main () {
  srand(time(NULL));
  struct timeval t1 ;
  struct timeval t2 ;
  int size;
  double time1, time2;
  printf("%s\n", "Enter size of matrix.");
  scanf("%d", &size);
  printf("size = %d\n", size);
  int **fmatrix = malloc(size*sizeof(int *));
  int **smatrix = malloc(size*sizeof(int *));
  int **rmatrix = malloc(size*sizeof(int *));
  int **tmatrix = malloc(size*sizeof(int *));
  for (int i = 0; i < size; i++) {
    fmatrix[i] = malloc(size*sizeof(int));
    smatrix[i] = malloc(size*sizeof(int));
    rmatrix[i] = malloc(size*sizeof(int));
    tmatrix[i] = malloc(size*sizeof(int));
  }
  fillMatrix(fmatrix, size);
  fillMatrix(smatrix, size);
  clear(rmatrix, size);

  gettimeofday(&t1, 0);
  multiplicationBeforeTransposition(fmatrix, smatrix, rmatrix, size);
  gettimeofday(&t2, 0);

  time1 = (t2.tv_sec - t1.tv_sec) + (t2.tv_usec - t1.tv_usec)*0.000001;

  tmatrix = transposition(smatrix, size);

  clear(rmatrix, size);

  gettimeofday(&t1, 0);
  multiplicationAfterTransposition(fmatrix, tmatrix, rmatrix, size);
  gettimeofday(&t2, 0);

  time2 = (t2.tv_sec - t1.tv_sec) + (t2.tv_usec - t1.tv_usec)*0.000001;

  printf("\ntime1 = %lf\n", time1);
  printf("time2 = %lf\n", time2);

  for (int i = 0; i < size; i++) {
    free(fmatrix[i]);
    free(smatrix[i]);
    free(rmatrix[i]);
    free(tmatrix[i]);
  }
  free(fmatrix);
  free(smatrix);
  free(rmatrix);
  free(tmatrix);
  return 0;
}
