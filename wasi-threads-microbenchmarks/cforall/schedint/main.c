/*
 * Multi-threaded Benchmarking Program
 * -----------------------------------
 *
 * This C program demonstrates a simple multi-threaded application utilizing POSIX threads (pthread).
 * It includes a benchmarking mechanism to measure the performance of a specific operation involving
 * condition variables, signals and mutexes for synchronization.
 * 
* Description:
 * This C program demonstrates a simple multi-threaded application utilizing POSIX threads (pthread).
 * It includes a benchmarking mechanism to measure the performance of a specific operation involving
 * condition variables, signals and mutexes for synchronization. The program assesses the efficiency of
 * synchronizing threads using a combination of mutexes and condition variables.
 * 
 * - The efficiency of synchronization mechanisms is crucial for optimizing multi-threaded
 *   applications. This benchmark provides insights into the performance of mutex and
 *   condition variable-based synchronization in a multi-threaded context.
 * - The use of signals and 'sched_yield()' in the program:
 *   - The 'go' variable serves as a signal between threads. The waiting thread uses 'sched_yield()'
 *     to yield the CPU until the signaling thread sets 'go' to a non-zero value.
 *   - The 'call()' function signals the condition variable 'c' to wake up the waiting thread.
 *     This allows for efficient communication between threads, ensuring synchronized execution.
 *
 *
 * Key Components:
 * - Global Variables: 'go', 'm' (mutex), and 'c' (condition variable).
 * - Functions: 'call()' and 'wait()' for synchronization.
 * - Thread Function: 'thread_main()' for benchmarking the 'call()' function.
 * - Main Function: Creates a thread, waits for synchronization, and measures performance.
 *
 * Note: Benchmarking details are defined in an external file 'bench.h'.
 *
 * Original code from: https://cforall.uwaterloo.ca/trac/browser/benchmark?rev=2c3562ded40923b5043ab4ad639620e9eada1ff9&order=name
 * Modified by: Julen Bohoyo
 * Date: 12/01/2024
 */




#include <pthread.h>
#include <stdio.h>

#include "bench.h"

volatile int go = 0;

pthread_mutex_t m;
pthread_cond_t c;

void __attribute__((noinline)) call() {
	pthread_mutex_lock( &m );
	pthread_cond_signal( &c );
	pthread_mutex_unlock( &m );
}

void __attribute__((noinline)) wait() {
	pthread_mutex_lock(&m);
	go = 1;
	for ( size_t i = 0; i < times; i++ ) {
		pthread_cond_wait( &c, &m );
	}
	go = 0;
	pthread_mutex_unlock( &m );
}

void * thread_main( __attribute__((unused)) void * arg ) {
	while ( go == 0 ) { sched_yield(); } // waiter must start first
	// barging for lock acquire => may not execute N times
	BENCH(
		while ( go == 1 ) { call(); },
		result
	)
	printf( "%g\n", result );
	return NULL;
}

int main( int argc, char * argv[] ) {
	BENCH_START()
	pthread_t thread;
	if ( pthread_create( &thread, NULL, thread_main, NULL ) < 0 ) {
		perror( "failure" );
		return 1;
	}
	wait();
	if ( pthread_join( thread, NULL ) < 0 ) {
		perror( "failure" );
		return 1;
	}
}
