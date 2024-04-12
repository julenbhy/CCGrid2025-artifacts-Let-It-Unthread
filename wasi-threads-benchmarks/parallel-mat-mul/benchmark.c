#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "datasets.h"

#define MAX_THREADS 1000


int num_threads;

int matrix_a[SIZE][SIZE];
int matrix_b[SIZE][SIZE];
int matrix_c[SIZE][SIZE];


void print_matrix(int matrix[][SIZE]){
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      printf("%d ", matrix[i][j]);
    }
    printf("\n");
  }
  printf("\n");
}

void *multiply_matrices(void *arg) {
  int thread_id = *(int*) arg;
  int start = thread_id * SIZE/num_threads;
  int end = (thread_id + 1) * SIZE/num_threads;
  
  if(thread_id==num_threads) end=SIZE; //in case SIZE not divisible by num_threads
  
  
  printf("Thread %d multiplying from %d to %d\n", thread_id, start, end);

  for (int i = start; i < end; i++) {
    for (int j = 0; j < SIZE; j++) {
      int sum = 0;
      for (int k = 0; k < SIZE; k++) {
        sum += matrix_a[i][k] * matrix_b[k][j];
      }
      matrix_c[i][j] = sum;
    }
  }

  return(NULL);
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage: %s <num_threads>\n", argv[0]);
    exit(1);
  }

  num_threads = atoi(argv[1]); 
  if (num_threads > MAX_THREADS) {
    printf("Error: Maximum number of threads is %d\n", MAX_THREADS);
    exit(1);
  }

  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      matrix_a[i][j] = rand() % 10;
      matrix_b[i][j] = rand() % 10;
      matrix_c[i][j] = 0;
    }
  }
  printf("Matrix a:\n");
  //print_matrix(matrix_a);
  printf("Matrix b:\n");
  //print_matrix(matrix_b);


  pthread_t threads[num_threads];
  int thread_ids[MAX_THREADS];
  for (int i = 0; i < num_threads; i++) {
    thread_ids[i] = i;
    pthread_create(&threads[i], NULL, multiply_matrices, (void*) &thread_ids[i]);
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_join(threads[i], NULL);
  }

  printf("Result:\n");
  //print_matrix(matrix_c);
  printf("Multiplyed %dx%d matrices using %d threads\n", SIZE, SIZE, num_threads);

  return 0;
}
