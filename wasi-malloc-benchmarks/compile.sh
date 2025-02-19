#!/bin/bash

# Set the paths to the cross-compilers
MUSL="/opt/x86_64-linux-musl-cross"
WASI_SDK="/opt/wasi-sdk"

# build mimalloc
if [ ! -d "mimalloc" ]; then
    echo "Building mimalloc..."
    git clone https://github.com/microsoft/mimalloc.git

    cmake -B mimalloc/build -DMI_BUILD_SHARED=OFF -DMI_BUILD_OBJECT=OFF -DMI_BUILD_TESTS=OFF ./mimalloc
    cmake --build mimalloc/build
    cmake -B mimalloc/build_wasm -DMI_BUILD_SHARED=OFF -DMI_BUILD_OBJECT=OFF -DMI_BUILD_TESTS=OFF -DWASI_SDK_PREFIX=$WASI_SDK -DCMAKE_TOOLCHAIN_FILE="$WASI_SDK/share/cmake/wasi-sdk-pthread.cmake" ./mimalloc
    cmake --build mimalloc/build_wasm
fi


# Build the benchmarks
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

cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DTHREAD_BENCHMARKS=OFF -DCOMPILE_TO_WASM=ON -DUSE_MIMALLOC=ON -DWASI_SDK_PATH=$WASI_SDK ../bench
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

cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DTHREAD_BENCHMARKS=ON -DCOMPILE_TO_WASM=ON -DUSE_MIMALLOC=ON -DWASI_SDK_PATH=$WASI_SDK ../bench
make
rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake Makefile
