/*
 * Thread-Specific Data (TSD) Benchmarking Program
 * ----------------------------------------------
 *
 * This C program serves as a benchmarking tool to measure the performance of using
 * Thread-Specific Data (TSD) with POSIX threads (pthread).
 *
 * Key Components:
 * - Global Variable: 'tsd_key' - A key for accessing thread-specific data.
 * - Function: 'call()' - Increments a counter stored in thread-specific data.
 * - Main Function: Measures the performance of the 'call()' function using the 'BENCH' macro.
 *
 * Benchmark Details:
 * - The benchmark is wrapped using the 'BENCH' macro, measuring the time taken for
 *   repeated incrementing of a counter stored in thread-specific data within a loop.
 * - The number of iterations is modified based on the 'times' parameter.
 * - Thread-specific data is used to maintain a separate counter for each thread.
 * - The 'pthread_key_create' and 'pthread_key_delete' functions are used to manage
 *   the thread-specific data key.
 *
 * Note: Benchmarking configuration is specified in an external file 'bench.h'.
 *
 * Author: Julen Bohoyo
 * Date: 12/01/2024
 */


#include <pthread.h>
#include <stdio.h>

#include "bench.h"

pthread_key_t tsd_key;


void __attribute__((noinline)) call() {


	int * value = pthread_getspecific(tsd_key);

	// Initialize TSD  at first call
	// Needed in native c, but not in WASM
	if (value == NULL) {
		value = malloc(sizeof(int));
		*value = 0;
		pthread_setspecific(tsd_key, value);
	}
	
	*value = *value + 1;
	pthread_setspecific(tsd_key, value);
	//printf("TSD value: %d\n", *value);

}


int main( int argc, char * argv[] ) {

	pthread_key_create(&tsd_key, NULL);

	BENCH_START() // Read input parameter

	BENCH(
	        for ( size_t i = 0; i < times; i++ ) {
                        call();
		},
		result
	)
	printf( "%g\n", result );

	pthread_key_delete(tsd_key);

}
