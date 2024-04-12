#!/bin/bash

# Set the paths to the cross-compilers
MUSL="/opt/x86_64-linux-musl-cross"
WASI_SDK="/opt/wasi-sdk"

rm -rf build && mkdir build && cd build

# Compile non threaded benchmarks
cmake -DTHREAD_BENCHMARKS=OFF ../bench
make
rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake Makefile

cmake -DTHREAD_BENCHMARKS=OFF -DCOMPILE_WITH_MUSL=ON -DMUSL_PATH=$MUSL ../bench
make
rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake Makefile

cmake -DTHREAD_BENCHMARKS=OFF -DCOMPILE_TO_WASM=ON -DWASI_SDK_PATH=$WASI_SDK ../bench
make
rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake Makefile


# Compile threaded benchmarks
cmake -DTHREAD_BENCHMARKS=ON ../bench
make
rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake Makefile

cmake -DTHREAD_BENCHMARKS=ON -DCOMPILE_WITH_MUSL=ON -DMUSL_PATH=$MUSL ../bench
make
rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake Makefile

cmake -DTHREAD_BENCHMARKS=ON -DCOMPILE_TO_WASM=ON -DWASI_SDK_PATH=$WASI_SDK ../bench
make
rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake Makefile
