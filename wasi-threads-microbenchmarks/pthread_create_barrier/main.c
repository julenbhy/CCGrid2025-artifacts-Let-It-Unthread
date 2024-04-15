#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define MAX_THREADS 1024

pthread_barrier_t barrier;



void *foo(void *arg) {
    pthread_barrier_wait(&barrier);
    return NULL;
}

int main( int argc, char * argv[] ) {
    pthread_t threads[MAX_THREADS];

	// Get thread number as input parameter (default 8)
	int N_THREADS = argc > 1 ? atoi( argv[ 1 ] ) : 8;


    pthread_barrier_init(&barrier, NULL, N_THREADS + 1);

    for (int i = 0; i < N_THREADS; i++) pthread_create(&threads[i], NULL, foo, NULL);

    pthread_barrier_wait(&barrier);

    for (int i = 0; i < N_THREADS; i++) pthread_join(threads[i], NULL);

    pthread_barrier_destroy(&barrier);

    return 0;
}