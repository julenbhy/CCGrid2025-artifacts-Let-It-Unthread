# trampoline-overhead

This benchmark aims to assess the overhead when a function call crosses the boundary between a WebAssembly instance and the hosting VM. We measure the overhead introduced by calling a host function from a wasm module, the overhead introduced by calling a wasm function from a host runtime, and the overhead introduced by calling a host function from within the wasm module itself.


# Execution:

1: Set WASI-SDK, MUSL and WASMTIME paths on ```run_benchmark.py``` (if not defaults)

2: Run ```python3 run_benchmark.py```

3: run ```generate_plot.m``` for generating plots.
