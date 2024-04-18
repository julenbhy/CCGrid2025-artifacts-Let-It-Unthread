# instance_pre-overhead

This benchmark aims to assess the overhead introduced by the functions imported from the host (VM or
an embedder) during WebAssembly module 
[instantiation](https://github.com/bytecodealliance/wasmtime/blob/47f2589d046f87517b26a6b373d767b31bc07a8b/crates/wasi-threads/src/lib.rs#L64).


# Execution:

1: Set WASI-SDK path on ```run_benchmark.py``` (if not /opt/wasi-sdk)

2: Run ```python3 run_benchmark.py```

3: run ```generate_plot.m``` for generating plots.

