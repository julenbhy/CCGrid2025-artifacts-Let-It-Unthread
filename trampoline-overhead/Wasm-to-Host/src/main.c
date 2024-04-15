#include <stdio.h>
#include <time.h>

#define N_ITERS 100000


__attribute__((import_module("")))
void noop();


int main(int argc, char *argv[]) {
    struct timespec start_time, end_time;
    double elapsed_time;

    clock_gettime(CLOCK_MONOTONIC, &start_time);

    for (int i = 0; i < N_ITERS; i++) {
        noop();
    }

    clock_gettime(CLOCK_MONOTONIC, &end_time);

    // Print the average time per call in nano-seconds
    elapsed_time = (end_time.tv_sec - start_time.tv_sec) * 1e9 + (end_time.tv_nsec - start_time.tv_nsec);
    printf("%fns\n", elapsed_time / N_ITERS);


    return 0;
}