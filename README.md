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

wasi-sdk 21

    curl -sL https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-21/wasi-sdk-21.0-linux.tar.gz | sudo tar -xz -C /opt/ && sudo mv /opt/wasi-sdk-21.0 /opt/wasi-sdk

musl-cross

    curl -sL https://musl.cc/x86_64-linux-musl-cross.tgz | sudo tar -xz -C /opt/
    sudo ln -s /opt/x86_64-linux-musl-cross/x86_64-linux-musl/lib/libc.so /lib/ld-musl-x86_64.so.1

wasmtime-cli 16.0.0

    curl -sL https://github.com/bytecodealliance/wasmtime/releases/download/v16.0.0/wasmtime-v16.0.0-x86_64-linux.tar.xz | sudo tar -xJ -C /opt/

iwasm(wamr) 1.3.1

    sudo mkdir /opt/iwasm-1.3.1 && curl -sL https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-1.3.1/iwasm-1.3.1-x86_64-ubuntu-22.04.tar.gz | sudo tar -xz -C /opt/iwasm-1.3.1

wasmer 4.2.3

    sudo mkdir /opt/wasmer-4.2.3 && curl -sL https://github.com/wasmerio/wasmer/releases/download/v4.2.3/wasmer-linux-amd64.tar.gz | sudo tar -xz -C /opt/wasmer-4.2.3

rust

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    sudo apt install build-essential

cmake

    sudo apt install cmake
  

# Artifact Execution:

In each section, the setup allows for easy compilation provided that all required software has been installed in the paths indicated above. Upon compilation, multiple executables will be generated for each program: the native executable linked to glibc (without extension), the native executable linked to musl (with the .musl extension), and the WebAssembly executable (with the .wasm extension).

Additionally, within each section, a ```run_benchmark``` script is provided. These scripts facilitate the compilation and execution of various experiments. They enable users to select the number of threads for application execution, as well as the number of replicas or the applications to be evaluated.

During execution, multiple .csv files will be generated containing the experiment results.

Furthermore, each section includes a ```generate_plot.m``` script for generating plots based on the obtained results.

Due to the current instability of wasm and its runtimes, some executions may become stuck. This has been taken into consideration, and all execution scripts are equipped with timeouts to address this issue. The maximum timeout duration can be configured in each of the scripts.


