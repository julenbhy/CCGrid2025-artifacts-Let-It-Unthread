# wasi-malloc-benchmarks

This repository is an adaptation of [mimalloc-bench](https://github.com/daanx/mimalloc-bench/tree/master) with some modifications for WebAssembly compatibility. Visit [mimalloc-bench](https://github.com/daanx/mimalloc-bench/tree/master) and [mimalloc](https://github.com/microsoft/mimalloc) for furher information.

# Setup

## instalation:
```curl -sL https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-21/wasi-sdk-21.0-linux.tar.gz | sudo tar -xz -C /opt/```

```curl -sL https://musl.cc/x86_64-linux-musl-cross.tgz | sudo tar -xz -C /opt/```

```curl https://wasmtime.dev/install.sh -sSf | bash```

``` curl -sL https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-1.3.1/iwasm-1.3.1-x86_64-ubuntu-22.04.tar.gz | sudo tar -xz -C /opt/```

```curl https://get.wasmer.io -sSfL | sh```

## versions:

wasi-sdk 21

wasmtime-cli 18.0.1

iwasm(wamr) 1.3.1

wasmer 4.2.3

cmake 3.25.2


# Execution:

1: Set the musl-cross compiler and WASI-SDK paths on compile.sh.

2: Set the wasmtime, iwasm and wasmer paths on bench.sh.

3: run ```compile.sh``` from the main directory.

4: run ```../bench.sh allr allt``` from the build directory.
  - allr: run all the runtimes (native C (glibc), native C (musl), wasmtime, iwasm, wasmer)
  - allt: run all tests
  - -j: number of threads

5: run generate_plots.m for generating plots.

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
