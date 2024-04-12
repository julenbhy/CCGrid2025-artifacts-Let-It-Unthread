/*
 * Barrier Benchmarking Program with Multiple Threads
 * ----------------------------------------------------
 *
 * This C program serves as a benchmarking tool to measure the performance of acquiring
 * and releasing a semaphore in the presence of multiple threads using POSIX threads (pthread).
 *
 * Key Components:
 * - Global Variables: 'barrier' - A pthread barrier used for synchronization.
 * - Functions:
 *   'thread_foo()' A routine for the threads that waits at a barrier in a loop.
 *   'call()' A routine for the main thread that waits at a barrier in a loop.
 * - Main Function: Measures the performance of the 'call()' function with varying numbers
 *   of threads using the 'BENCH' macro.
 *
 * Benchmark Details:
 * - The benchmark is wrapped using the 'BENCH' macro, measuring the time taken for
 *   repeated waiting at a barrier within a loop, with multiple competing threads.
 * - The number of iterations is modified, and the number of threads is varied based on the
 *   command line argument (default is 1 thread).
 * - The barrier is initialized with a count of N_THREADS + 1 to include the main thread.
 *
 * Note: Benchmarking configuration is specified in an external file 'bench.h'.
 *
 * Author: Julen Bohoyo
 * Date: 18/03/2024
 */

#include <pthread.h>
#include <stdio.h>
#include <stdbool.h>

#include "bench.h"

pthread_barrier_t barrier;



void *thread_foo(void *arg) {

    for (size_t i = 0; i < times; i += 1) {
		pthread_barrier_wait(&barrier);
	}
    return NULL;
}

void call() {
    for (size_t i = 0; i < times; i += 1) {
		pthread_barrier_wait(&barrier);
	}

    return;
}



int main(int argc, char *argv[]) {
	BENCH_START()
    

	times = 100;	
	int N_THREADS = argc > 1 ? atoi( argv[ 1 ] ) : 1;

	pthread_t threads[ N_THREADS ];
    pthread_barrier_init(&barrier, NULL, N_THREADS+1);


    for ( int i = 0; i < N_THREADS; i++ ) {
        if ( pthread_create( &threads[ i ], NULL, thread_foo, NULL ) < 0 ) {
            perror( "failure" );
            return EXIT_FAILURE;
        }
    }
	BENCH(
        call(),
		result
	)

    for ( int i = 0; i < N_THREADS; i++ ) {
        if ( pthread_join( threads[ i ], NULL ) < 0 ) {
            perror( "failure" );
            return EXIT_FAILURE;
        }
    }

    printf("%g\n", result);


	return EXIT_SUCCESS;
}