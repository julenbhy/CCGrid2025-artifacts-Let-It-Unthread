# wasi-threads-benchmarks

This benchmark aims to assess the performance of [wasi-threads](https://bytecodealliance.org/articles/wasi-threads) 


# Execution:

For each of the subdirectories:

1: Set WASI-SDK, MUSL, WASMTIME, IWASM and WASMER paths on ```run_benchmark.py``` (if not defaults)

2: Run ```python3 run_benchmark.py```

3: run ```generate_plot.m``` for generating plots.


# Benchmarks
## parsec

Adaptation of certain benchmarks from [parsec](https://github.com/bamos/parsec-benchmark) for WASM.

## pthread_create

Benchmark for pthread creation from [cforall](https://cforall.uwaterloo.ca/trac/browser/benchmark?rev=2c3562ded40923b5043ab4ad639620e9eada1ff9&order=name) to measure thread creation time.

## pthread_create_RSS

This benchmark creates multiple threads that remain active simultaneously using a barrier to measure the maximum resident set size in relation to the number of concurrently active threads.
