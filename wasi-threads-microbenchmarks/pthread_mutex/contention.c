#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>


pthread_mutex_t mutex;

void * thread_foo(void * arg) {
	int times = 100;
	
	printf("Thread %ld\n", pthread_self());
	
	for ( int i = 0; i < times; i++ ) {
		pthread_mutex_lock( &mutex );
		int res = 0;
		for (int j = 0; j < 1000000; j++) {
		    res += rand();
		}
		pthread_mutex_unlock( &mutex );
	}
	
	printf("Thread %ld ending\n", pthread_self());

	return NULL;
}


int main( int argc, char * argv[] ) {

	int N_THREADS = argc > 1 ? atoi( argv[ 1 ] ) : 2;

	pthread_t threads[ N_THREADS ];
	pthread_mutex_init(&mutex, NULL);

	for ( int i = 0; i < N_THREADS; i++ ) {
		pthread_create( &threads[ i ], NULL, thread_foo, NULL );
	}

	for ( int i = 0; i < N_THREADS; i++ ) {
		pthread_join( threads[ i ], NULL );
	}

	pthread_mutex_destroy(&mutex);

	return 0;
}
