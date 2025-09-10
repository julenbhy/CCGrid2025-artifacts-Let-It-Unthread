#!/bin/bash

# Versions
export WASI_VERSION="25"
export WASMTIME_VERSION="16.0.0"
export IWASM_VERSION="2.1.2"
export WASMER_VERSION="4.2.3"

# Instalation paths
export CC="/usr/bin/gcc"
export WASI_SDK="/opt/wasi-sdk"
export MUSL="/opt/x86_64-linux-musl-cross"
export WASMTIME="/opt/wasmtime-v${WASMTIME_VERSION}/wasmtime"
export IWASM="/opt/iwasm-${IWASM_VERSION}/iwasm"
export WASMER="/opt/wasmer-${WASMER_VERSION}/bin/wasmer"
