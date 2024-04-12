/*
 * Mutex Benchmarking Program with Multiple Threads
 * ------------------------------------------------
 *
 * This C program serves as a benchmarking tool to measure the performance of acquiring
 * and releasing a mutex in the presence of multiple threads using POSIX threads (pthread).
 *
 * Key Components:
 * - Global Variables: 'mutex' - A mutex used for synchronization, and 'go' - A volatile
 *   boolean variable acting as a synchronization flag.
 * - Functions: 
 *	'call()' A routine for the threads that competes with the main thread for the mutex. Acquires and releases the mutex in a loop
 *	'thread_main()' Acquires and releases the mutex in a loop
 * - Main Function: Measures the performance of the 'call()' function with varying numbers
 *   of threads using the 'BENCH' macro.
 *
 * Benchmark Details:
 * - The benchmark is wrapped using the 'BENCH' macro, measuring the time taken for
 *   repeated acquisition and release of a mutex within a loop, with multiple competing threads.
 * - The number of iterations is modified and the number of threads is varied based on the
 *   command line argument (default is 1 thread).
 * - The 'sleep(1)' ensures that threads are ready before starting the benchmark.
 *
 * Note: Benchmarking configuration is specified in an external file 'bench.h'.
 *
 * Original code from: https://cforall.uwaterloo.ca/trac/browser/benchmark?rev=2c3562ded40923b5043ab4ad639620e9eada1ff9&order=name
 * Modified by: Julen Bohoyo
 * Date: 12/01/2024
 */


#include <pthread.h>
#include <stdio.h>
#include <stdbool.h>

#include "bench.h"

pthread_mutex_t mutex;

volatile bool go = false;


void call() {

	go=true;
	for ( size_t i = 0; i < times; i += 1 ) {
		pthread_mutex_lock( &mutex );
		pthread_mutex_unlock( &mutex );
	}
	go = false;
}
void * thread_main( __attribute__((unused)) void * arg ) {

	while( !go );
	while ( go ) {
		pthread_mutex_lock( &mutex );
		pthread_mutex_unlock( &mutex );
	}
	return NULL;
}
int main( int argc, char * argv[] ) {
	BENCH_START() // Read input parameter

/*
	pthread_t thread;
	if ( pthread_create( &thread, NULL, thread_main, NULL ) < 0 ) {
		perror( "failure" );
		return EXIT_FAILURE;
	}
*/

	/** Modified by Julen Bohoyo
	 * Fix the number of iterations
	 * Variate the number of threads compiting for the mutex
	 */
	times = 10000;	
	int N_THREADS = argc > 1 ? atoi( argv[ 1 ] ) : 8;
	pthread_t threads[ N_THREADS ];
	for ( int i = 0; i < N_THREADS; i++ ) {
		if ( pthread_create( &threads[ i ], NULL, thread_main, NULL ) < 0 ) {
			perror( "failure" );
			return EXIT_FAILURE;
		}
	}

	sleep(1); // Ensure thread is ready
	BENCH(
		call(),
		result
	)
	printf( "%g\n", result );

/*
	if ( pthread_join( thread, NULL ) < 0 ) {
		perror( "failure" );
		return EXIT_FAILURE;
	}
*/

	for ( int i = 0; i < N_THREADS; i++ ) {
		if ( pthread_join( threads[ i ], NULL ) < 0 ) {
			perror( "failure" );
			return EXIT_FAILURE;
		}
	}

}
