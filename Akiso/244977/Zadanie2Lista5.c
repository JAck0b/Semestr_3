#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

int iterator = 0;
pthread_mutex_t mymutex;

typedef struct {
  int **fmatrix;
  int **smatrix;
  int **rmatrix;
  int size;
} Variables;

void fillMatrix(int **matrix, int size) {
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      matrix[i][j] = rand()%2;
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

void *multiplication(void *x) {
  Variables *v = (Variables *) x;
  while (1) {
    pthread_mutex_lock(&mymutex);
    int i = iterator;
    iterator++;
    pthread_mutex_unlock(&mymutex);
    if (i >= v->size) {
      break;
    }
    for (int j = 0; j < v->size; j++) {
      for (int k = 0; k < v->size; k++) {
        v->rmatrix[i][j] = v->rmatrix[i][j] || (v->fmatrix[i][k] && v->smatrix[k][j]);
        if (v->rmatrix[i][j] == 1) {
          break;
        }
      }
    }
  }
  pthread_exit(NULL);
}

int main(int argc, char const *argv[]) {
  srand(time(NULL));
  pthread_mutex_init(&mymutex, NULL);
  int size = 0;
  int threads = 0;
  printf("%s\n", "Enter size of matrix.");
  scanf("%d", &size);
  printf("%s\n", "Enter number of threads.");
  scanf("%d", &threads);
  printf("Size = %d\n", size);
  printf("Threads = %d\n", threads);
  pthread_t t[threads];
  int **fmatrix = malloc(size*sizeof(int *));
  int **smatrix = malloc(size*sizeof(int *));
  int **rmatrix = malloc(size*sizeof(int *));
  for (int i = 0; i < size; i++) {
    fmatrix[i] = malloc(size*sizeof(int));
    smatrix[i] = malloc(size*sizeof(int));
    rmatrix[i] = malloc(size*sizeof(int));
  }
  fillMatrix(fmatrix, size);
  fillMatrix(smatrix, size);

  Variables *v = malloc(sizeof(Variables));
  v->fmatrix = fmatrix;
  v->smatrix = smatrix;
  v->rmatrix = rmatrix;
  v->size = size;

  for (int i = 0; i < threads; i++) {
    pthread_create(&t[i], NULL, multiplication, (void *) v);
  }

  for (int i = 0; i < threads; i++) {
    pthread_join(t[i], NULL);
  }

  printf("\n%s\n", "First Matrix");
  printMatrix(fmatrix, size);
  printf("\n%s\n", "Second Matrix");
  printMatrix(smatrix, size);\
  printf("\n%s\n", "Result Matrix");
  printMatrix(rmatrix, size);
  printf("\n");

  pthread_mutex_destroy(&mymutex);
  for (int i = 0; i < size; i++) {
    free(fmatrix[i]);
    free(smatrix[i]);
    free(rmatrix[i]);
  }
  free(fmatrix);
  free(smatrix);
  free(rmatrix);
}
