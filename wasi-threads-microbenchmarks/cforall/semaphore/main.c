/*
 * Semaphore Benchmarking Program with Multiple Threads
 * ----------------------------------------------------
 *
 * This C program serves as a benchmarking tool to measure the performance of acquiring
 * and releasing a semaphore in the presence of multiple threads using POSIX threads (pthread).
 *
 * Key Components:
 * - Global Variables: 'semaphore' - A semaphore used for synchronization, and 'go' - A volatile
 *   boolean variable acting as a synchronization flag.
 * - Functions: 
 *	'call()' A routine for the threads that competes with the main thread for the semaphore. Acquires and releases the semaphore in a loop
 *	'thread_main()' Acquires and releases the semaphore in a loop
 *   - A thread routine that competes for the semaphore.
 * - Main Function: Measures the performance of the 'call()' function with varying numbers
 *   of threads using the 'BENCH' macro.
 *
 * Benchmark Details:
 * - The benchmark is wrapped using the 'BENCH' macro, measuring the time taken for
 *   repeated acquisition and release of a semaphore within a loop, with multiple competing threads.
 * - The number of iterations is modified, and the number of threads is varied based on the
 *   command line argument (default is 1 thread).
 * - The 'sleep(1)' ensures that threads are ready before starting the benchmark.
 * - The semaphore is initialized with an initial value of 1, making it a binary semaphore.
 *
 * Note: Benchmarking configuration is specified in an external file 'bench.h'.
 *
 * Author: Julen Bohoyo
 * Date: 12/01/2024
 */

#include <pthread.h>
#include <stdio.h>
#include <stdbool.h>
#include <semaphore.h>

#include "bench.h"

sem_t semaphore;

volatile bool go = false;


void call() {

	go = true;
	for (size_t i = 0; i < times; i += 1) {
		sem_wait(&semaphore);
		sem_post(&semaphore);
	}
	go = false;
}

void *thread_main(__attribute__((unused)) void *arg) {

	while ( !go );
	while (go) {
		sem_wait(&semaphore);
		sem_post(&semaphore);
	}
	return NULL;
}

int main(int argc, char *argv[]) {
	BENCH_START()
    
	sem_init(&semaphore, 0, 1);

	times = 10000;	
	int N_THREADS = argc > 1 ? atoi( argv[ 1 ] ) : 1;

	pthread_t threads[ N_THREADS ];
	for ( int i = 0; i < N_THREADS; i++ ) {
		if ( pthread_create( &threads[ i ], NULL, thread_main, NULL ) < 0 ) {
			perror( "failure" );
			return EXIT_FAILURE;
		}
	}

	sleep(1); //Ensure thread is ready
	
	BENCH(
		call(),
		result
	)
	printf("%g\n", result);


	for ( int i = 0; i < N_THREADS; i++ ) {
		if ( pthread_join( threads[ i ], NULL ) < 0 ) {
			perror( "failure" );
			return EXIT_FAILURE;
		}
	}


// Destroy the semaphore when it's no longer needed
	if (sem_destroy(&semaphore) != 0) {
		perror("Error destroying semaphore");
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
