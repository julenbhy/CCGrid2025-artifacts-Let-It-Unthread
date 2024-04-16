/*
 * Multi-threaded Benchmarking Program for Thread Creation and Joining
 * -------------------------------------------------------------------
 *
 * This C program serves as a simple benchmarking tool to measure the performance
 * of creating and joining multiple threads using POSIX threads (pthread).
 *
 * Key Components:
 * - Function: 'foo()' - A basic function executed by each thread, returning its argument.
 * - Main Function: Creates and joins threads in a loop, measuring the performance.
 *
 * Benchmark Details:
 * - The benchmark is wrapped using the 'BENCH' macro, and the specific operation being
 *   measured is thread creation and joining within a loop.
 *
 * Note: Benchmarking configuration is specified in an external file 'bench.h'.
 *
 * Original code from: https://cforall.uwaterloo.ca/trac/browser/benchmark?rev=2c3562ded40923b5043ab4ad639620e9eada1ff9&order=name
 * Modified by: Julen Bohoyo
 * Date: 12/01/2024
 */


#include <pthread.h>
#include <stdio.h>

#include "bench.h"

static void * foo(void *arg) {
    return arg;
}

int main( int argc, char * argv[] ) {
	BENCH_START()
	BENCH(
		for (size_t i = 0; i < times; i++) {
			pthread_t thread;
			if (pthread_create(&thread, NULL, foo, NULL) < 0) {
				printf( "ERROR: could not create thread %zu", i);
				return 1;
			}
			if (pthread_join( thread, NULL) < 0) {
				printf( "ERROR: could not join thread %zu", i);
				return 1;
			}
		},
		result
	)
	printf( "%g\n", result );
}
