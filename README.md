# CCGrid2025
Artifacts related to [Let It Unthread: The Good, The Bad and The Ugly
within WebAssembly Portable Multithreading](https://)


# Artifact Overview

The GitHub repository is structured into five distinct sections: 

  - ```wasi-malloc-benchmarks:``` This section comprises benchmarks aimed to measure the performance of malloc through applications that heavily rely on this function. It evaluates both single-threaded and multi-threaded applications to asses the impact of employing the default allocator without thread arenas, offering insights into memory allocation efficiency across different usage scenarios. Additionally, we have tested linking a different allocator with thread arenas to evaluate its performance improvement compared to the default allocator in wasi-libc.
    
  - ```wasi-threads-microbenchmarks:``` Within this section, benchmarks are aimed to evaluate thread synchronization. It includes small-scale applications that heavily utilize synchronization mechanisms, facilitating a detailed examination of thread coordination efficiency.
    
  - ```wasi-threads-benchmarks:``` Here, more intricate multi-threaded applications are featured. These applications are more representative of real-world scenarios, providing insights into the actual performance of applications used on a daily basis.
    
  - ```trampoline-overhead:``` This section compares the overhead of calling a function exported by a wasm module from an embedder and the overhead of calling a function exported by an embedder from a wasm module, against a call to a "conventional" function.
    
  - ```instance_pre-overhead:``` Wasmtime employs the 'instance_pre()' method to avoid instantiating the wasm module with each generation of a wasi-thread. This section assesses the additional overhead introduced by this method in relation to the number of functions imported by the wasm module.

    

# Artifact Setup

We provide an automated installation script to simplify the setup process.

## Quick Setup

Run the following commands:

```bash
./scripts/setup.sh
```

This script will automatically install all the dependencies (wasi-sdk, musl-cross, wasmtime, iwasm, wasmer, rust, and other tools) according to your architecture (x86_64 or aarch64).

You can also install individual components by passing them as arguments to the script. For example:

```bash
./scripts/setup.sh wasmtime iwasm
```

If any error occurs during the automated installation, you can install the dependencies manually.

# Artifact Execution:

In each section, the setup allows for easy compilation provided that all required software has been installed in the paths indicated on env.sh. Upon compilation, multiple executables will be generated for each program: the native executable linked to glibc (without extension), the native executable linked to musl (with the .musl extension), and the WebAssembly executable (with the .wasm extension).

We provide a script that automates the execution of all experiments across the different sections. This script compiles and runs everything and stores the generated logs under the logs/ directory for easier inspection. Remember to set the paths using source ./scipts/env.sh
```bash
./scripts/run_all.sh
```

Additionally, within each section, a ```run_benchmark``` script is provided. These scripts facilitate the compilation and execution of various experiments. They enable users to select the number of threads for application execution, as well as the number of replicas or the applications to be evaluated.

During execution, multiple .csv files will be generated containing the experiment results.


# Figures List

The following table correlates the figures presented in the paper *“Let It Unthread: The Good, The Bad and The Ugly within WebAssembly Portable Multithreading”* with their corresponding directories in the artifact repository:

- **Fig. 3** – Performance of the wasi-libc allocator for non-threaded benchmarks  
  **Fig. 4** – Performance of the wasi-libc allocator for threaded benchmarks  
  → [wasi-malloc-benchmarks](https://github.com/julenbhy/CCGrid2025-artifacts-Let-It-Unthread/tree/ARM64-port/wasi-malloc-benchmarks)

- **Fig. 5** – Latency slowdown of the wasi-libc mutex relative to glibc` 
  → [wasi-threads-microbenchmarks/pthread_mutex](https://github.com/julenbhy/CCGrid2025-artifacts-Let-It-Unthread/tree/ARM64-port/wasi-threads-microbenchmarks/pthread_mutex)

- **Fig. 6** – Average execution time slowdown relative to glibc in the SCTBench benchmark  
  → [wasi-threads-microbenchmarks/concurrent-software-benchmarks](https://github.com/julenbhy/CCGrid2025-artifacts-Let-It-Unthread/tree/ARM64-port/wasi-threads-microbenchmarks/concurrent-software-benchmarks)

- **Fig. 7(a)** – Efficiency of the WebAssembly runtimes: Maximum RSS  
  → [wasi-threads-benchmarks/pthread_create_RSS](https://github.com/julenbhy/CCGrid2025-artifacts-Let-It-Unthread/tree/ARM64-port/wasi-threads-benchmarks/pthread_create_RSS)

- **Fig. 7(b)** – Efficiency of the WebAssembly runtimes: Cumulative time for spawning 10k threads  
  → [wasi-threads-benchmarks/pthread_create](https://github.com/julenbhy/CCGrid2025-artifacts-Let-It-Unthread/tree/ARM64-port/wasi-threads-benchmarks/pthread_create)

- **Fig. 8** – Time to create a child instance in Wasmtime as a function of the number of imports  
  → [instance_pre-overhead](https://github.com/julenbhy/CCGrid2025-artifacts-Let-It-Unthread/tree/ARM64-port/instance_pre-overhead)

- **Fig. 9** – Average execution time slowdown relative to glibc in three PARSEC applications  
  **Fig. 10** – Comparison of the wasi-libc allocator vs. mimalloc for multithreaded benchmarks on Wasmtime (64 threads)  
  → [wasi-threads-benchmarks/parsec](https://github.com/julenbhy/CCGrid2025-artifacts-Let-It-Unthread/tree/ARM64-port/wasi-threads-benchmarks/parsec)



## Acknowledgements

<img width="80px" src="https://cloudskin.eu/assets/img/europe.jpg" alt="European flag" />

CLOUDSKIN has received funding from the European Union’s Horizon research and innovation programme under grant agreement No 101092646.

https://cloudskin.eu
