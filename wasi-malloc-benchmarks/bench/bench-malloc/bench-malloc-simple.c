/* Benchmark malloc and free functions.
   Copyright (C) 2019-2021 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.

   Modified by Marc Sanchez Artigas.
   Modified:   20.06.2023.
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/resource.h>
#include <sys/param.h>
#include <time.h>

/* Benchmark the malloc/free performance of a varying number of blocks of a
   given size.  This enables performance tracking of the t-cache and fastbins.
   It tests 3 different scenarios: single-threaded using main arena,
   multi-threaded using thread-arena, and main arena with SINGLE_THREAD_P
   false.  */

#define NUM_ITERS 2000000
#define NUM_ALLOCS 4
#define MAX_ALLOCS 500
#define TIMING_TYPE "clock_gettime"

/* The clock_gettime (CLOCK_MONOTONIC) has unspecified starting time,
   nano-second accuracy, and for some architectues is implemented as
   vDSO symbol.  */
# define TIMING_NOW(var) \
({								\
  struct timespec tv;						\
  clock_gettime (CLOCK_MONOTONIC, &tv);				\
  (var) = (tv.tv_nsec + UINT64_C(1000000000) * tv.tv_sec);	\
})
#define TIMING_DIFF(diff, start, end) ((diff) = (end) - (start))
#define TIMING_ACCUM(sum, diff) ((sum) += (diff))

typedef uint64_t timing_t;
typedef struct {
  size_t iters;
  size_t size;
  int n;
  timing_t elapsed;
} malloc_args;


static malloc_args tests[NUM_ALLOCS];
static int allocs[NUM_ALLOCS] = { 25, 100, 400, MAX_ALLOCS };

static void print_results() {

  fprintf(stdout, "No threads\n \t %s, \t%s, \t%s\n", \
                            "total alloc size", \
                            "divided in allocs", \
                            "elapsed time" \
  );

  for (int i = 0; i < NUM_ALLOCS; i++)
  {
    fprintf(stdout, "\t %ld, \t\t\t%d, \t\t\t%f\n", \
          tests[i].size, \
          tests[i].n, \
          tests[i].elapsed / 10e6 \
    );
  }
  fprintf(stdout, "\n");
}


static void do_benchmark (malloc_args *args, char**arr) {
  timing_t start, stop;
  // Total number of iterations
  size_t iters = args->iters;
  // This is the size of the allocated memory block, in bytes.
  size_t size = args->size;
  // Number of sequential memory allocations before free()
  int n = args->n;

  TIMING_NOW (start);

  for (int j = 0; j < iters; j++)
    {
      for (int i = 0; i < n; i++) {
        arr[i] = malloc (size);
        for(int g = 0; g < size; g++) { arr[i][g] =(char)g; }
      }

      // free half in fifo order
      for (int i = 0; i < n/2; i++) {
	      free (arr[i]);
      }

      // and the other half in lifo order
      for(int i = n-1; i >= n/2; i--) {
        free(arr[i]);
      }
  }

  TIMING_NOW (stop);

  TIMING_DIFF (args->elapsed, start, stop);
}


void bench (unsigned long size) {
  size_t iters = NUM_ITERS;
  char**arr = (char**)malloc (MAX_ALLOCS * sizeof (void*));


  for (int i = 0; i < NUM_ALLOCS; i++)
  {
	  tests[i].n = allocs[i];               // Number of sequential memory allocations before free()
	  tests[i].size = size;                 // This is the size of the allocated memory block, in bytes.
	  tests[i].iters = iters / allocs[i];   // Total number of iterations

	  /* Do a quick warmup run.  */
	   do_benchmark (&tests[i], arr);
  }


  // Run benchmark
  for (int i = 0; i < NUM_ALLOCS; i++)
    do_benchmark (&tests[i], arr);

  /* Show results */
  print_results();
  free (arr);
}

static void usage (const char *name)
{
  fprintf (stderr, "%s: <alloc_size>\n", name);
  exit (1);
}

int main (int argc, char **argv)
{
  long size = 16;

  if (argc == 2)
    size = strtol (argv[1], NULL, 0);

  if (argc > 2 || size <= 0)
    usage (argv[0]);


  puts (TIMING_TYPE);

  bench (size);
  bench (2*size);
  bench (4*size);

  return 0;
}