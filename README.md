# SC24_AD_AE
Artifacts related to Let It Unthread: Towards Demystifying WebAssembly Portable Multithreading


# Setup

wasi-sdk 21

```curl -sL https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-21/wasi-sdk-21.0-linux.tar.gz | sudo tar -xz -C /opt/```

musl-cross

```curl -sL https://musl.cc/x86_64-linux-musl-cross.tgz | sudo tar -xz -C /opt/```

wasmtime-cli 16.0.0

```curl -sL https://github.com/bytecodealliance/wasmtime/releases/download/v16.0.0/wasmtime-v16.0.0-x86_64-linux.tar.xz | sudo tar -xJ -C /opt/```

iwasm(wamr) 1.3.1

```sudo mkdir /opt/iwasm-1.3.1 && curl -sL https://github.com/bytecodealliance/wasm-micro-runtime/releases/download/WAMR-1.3.1/iwasm-1.3.1-x86_64-ubuntu-22.04.tar.gz | sudo tar -xz -C /opt/iwasm-1.3.1```

wasmer 4.2.3

```sudo mkdir /opt/wasmer-4.2.3 && curl -sL https://github.com/wasmerio/wasmer/releases/download/v4.2.3/wasmer-linux-amd64.tar.gz | sudo tar -xz -C /opt/wasmer-4.2.3```


# Execution:

In each section, the setup allows for easy compilation provided that all required software has been installed in the paths indicated above. Upon compilation, multiple executables will be generated for each program: the native executable linked to glibc (without extension), the native executable linked to musl (with the .musl extension), and the WebAssembly executable (with the .wasm extension).

Additionally, within each section, a ```run_benchmark``` script is provided. These scripts facilitate the compilation and execution of various experiments. They enable users to select the number of threads for application execution, as well as the number of replicas or the applications to be evaluated.

During execution, multiple .csv files will be generated containing the experiment results.

Furthermore, each section includes a ```generate_plot.m``` script for generating plots based on the obtained results.

Due to the current instability of wasm and its runtimes, some executions may become stuck. This has been taken into consideration, and all execution scripts are equipped with timeouts to address this issue. The maximum timeout duration can be configured in each of the scripts.
