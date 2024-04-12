/*
 * Mutex Benchmarking Program
 * --------------------------
 *
 * Description:
 * This C program serves as a benchmarking tool to measure the performance of acquiring
 * and releasing a mutex using POSIX threads (pthread) in a single threaded program.
 * The efficiency of mutex operations is crucial for ensuring effective synchronization
 * in multi-threaded applications.
 *
 * Key Components:
 * - Global Variable: 'mutex' - A mutex used for synchronization.
 * - Function: 'call()' - Acquires and releases the mutex.
 * - Main Function: Measures the performance of the 'call()' function using the 'BENCH' macro.
 *
 * Benchmark Details:
 * - The benchmark is wrapped using the 'BENCH' macro, measuring the time taken for the
 *   repeated acquisition and release of a mutex within a loop.
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

pthread_mutex_t mutex;

void call() {

	pthread_mutex_lock( &mutex );
	pthread_mutex_unlock( &mutex );
}


int main( int argc, char * argv[] ) {
	BENCH_START() // Read input parameter


	BENCH(
	        for ( size_t i = 0; i < times; i++ ) {
                        call();
		},
		result
	)
	printf( "%g\n", result );

}
