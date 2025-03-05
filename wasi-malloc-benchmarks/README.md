# wasi-malloc-benchmarks

This repository is an adaptation of [mimalloc-bench](https://github.com/daanx/mimalloc-bench/tree/master) with some modifications for WebAssembly compatibility. Visit [mimalloc-bench](https://github.com/daanx/mimalloc-bench/tree/master) and [mimalloc](https://github.com/microsoft/mimalloc) for furher information.

To demonstrate that the lack of *thread arenas* in the default **wasi-libc** allocator causes a significant performance issue on multitheaded applications, we have also compiled **mimalloc** allocator to WebAssembly and linked it with each benchmark as a potential improvement.

# Execution:

1: Set the musl-cross compiler and WASI-SDK paths on compile.sh.

2: Set the wasmtime, iwasm and wasmer paths on run_benchmark.sh.

3: Run ```compile.sh``` from the main directory. This whill genereate a ```build/``` directory

4: Run ```../run_benchmark.sh allr allt``` from the ```build/```.
  - allr: run all the runtimes (native C (glibc), native C (musl), wasmtime, iwasm, wasmer)
  - allt: run all tests
  - -j: number of threads

5: run generate_plot.m for generating plots.

# Benchmarks
## Single-Threaded

- barnes: a hierarchical n-body particle solver [4], simulating the gravitational forces between 163840 particles. It uses relatively few allocations compared to cfrac and espresso but is multithreaded.
- cfrac: by Dave Barrett, implementation of continued fraction factorization, using many small short-lived allocations.
- espresso: a programmable logic array analyzer, described by Grunwald, Zorn, and Henderson [3]. in the context of cache aware memory allocation.
- malloc-large: part of mimalloc benchmarking suite, designed to exercice large (several MiB) allocations.
- [bench-malloc-simple](https://github.com/daanx/mimalloc-bench/blob/master/bench/glibc-bench/bench-malloc-simple.c) (Not from mimalloc): benchmarks for the glibc.

## Multi-Threaded
- larsonN: by Larson and Krishnan [2]. Simulates a server workload using 100 separate threads which each allocate and free many objects but leave some objects to be freed by other threads. Larson and Krishnan observe this behavior (which they call bleeding) in actual server applications, and the benchmark simulates this.
- larsonN-sized: same as the larsonN except it uses sized deallocation calls which have a fast path in some allocators.
- bench-malloc-threads (Not from mimalloc): bench-malloc-simple adapted for using pthreads
- mleak: check that terminate threads don't "leak" memory.
- mstress: simulates real-world server-like allocation patterns, using N threads with with allocations in powers of 2
where objects can migrate between threads and some have long life times. Not all threads have equal workloads and after each phase all threads are destroyed and new threads created where some objects survive between phases.
- xmalloc-testN: by Lever and Boreham [5] and Christian Eder. We use the updated version from the SuperMalloc repository. This is a more extreme version of the larson benchmark with 100 purely allocating threads, and 100 purely deallocating threads with objects of various sizes migrating between them. This asymmetric producer/consumer pattern is usually difficult to handle by allocators with thread-local caches.
- [t-test1](https://github.com/emeryberger/Malloc-Implementations/blob/master/allocators/ptmalloc/ptmalloc3/t-test1.c)(Not from mimalloc): A multi-thread test for malloc performance, maintaining one pool of allocated bins per thread.
