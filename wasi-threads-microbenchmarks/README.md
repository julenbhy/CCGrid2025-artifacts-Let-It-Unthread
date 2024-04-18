# wasi-threads-microbenchmarks

This benchmark aims to assess the performance of [wasi-threads](https://bytecodealliance.org/articles/wasi-threads) 


# Execution:

For each of the subdirectories:

1: Set WASI-SDK, MUSL, WASMTIME, IWASM and WASMER paths on ```run_benchmark.py``` (if not defaults)

2: Run ```python3 run_benchmark.py```

3: Run ```generate_plot.m``` for generating plots.


# Benchmarks
## concurrent-software-benchmarks

Adaptation of certain benchmarks from [sctbench](https://github.com/mc-imperial/sctbench/tree/master/benchmarks/concurrent-software-benchmarks) for WASM.


## pthread_mutex

This benchmark compares the performance of wasi-threads in a low contention scenario against a high contention scenario by intensive use of mutexes.