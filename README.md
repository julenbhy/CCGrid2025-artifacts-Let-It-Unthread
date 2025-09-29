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
scripts/setup.sh
```

This script will automatically install all the dependencies (wasi-sdk, musl-cross, wasmtime, iwasm, wasmer, rust, and other tools) according to your architecture (x86_64 or aarch64).

You can also install individual components by passing them as arguments to the script. For example:

```bash
scripts/setup.sh wasmtime iwasm
```

If any error occurs during the automated installation, you can install the dependencies manually.

# Artifact Execution:

In each section, the setup allows for easy compilation provided that all required software has been installed in the paths indicated on env.sh. Upon compilation, multiple executables will be generated for each program: the native executable linked to glibc (without extension), the native executable linked to musl (with the .musl extension), and the WebAssembly executable (with the .wasm extension).

We provide a script that automates the execution of all experiments across the different sections. This script compiles and runs everything and stores the generated logs under the logs/ directory for easier inspection.
```bash
scripts/run_all.sh
```

Additionally, within each section, a ```run_benchmark``` script is provided. These scripts facilitate the compilation and execution of various experiments. They enable users to select the number of threads for application execution, as well as the number of replicas or the applications to be evaluated.

During execution, multiple .csv files will be generated containing the experiment results.


