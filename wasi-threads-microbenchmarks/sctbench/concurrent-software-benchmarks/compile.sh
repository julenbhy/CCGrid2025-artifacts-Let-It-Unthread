#!/bin/bash

MUSL_PATH="/opt/x86_64-linux-musl-cross"
WASI_PATH="/opt/wasi-sdk"
path="build"

mkdir -p "$path"


for file in src/*.c; do
    if [ -f "$file" ]; then
        basename=$(basename "$file" .c)
        dir="build"
        mkdir_p "$dir"

        ofile="$dir/$basename.x"
        cmd=("gcc" "-o" "$ofile" "$file" "-pthread" "-g" "-O0")
        echo "${cmd[*]}"
        "${cmd[@]}"

        ofile="$dir/$basename.musl"
        cmd=("$MUSL_PATH/bin/x86_64-linux-musl-gcc" "-o" "$ofile" "$file" "-pthread" "-g" "-O0")
        echo "${cmd[*]}"
        "${cmd[@]}"

        ofile="$dir/$basename.wasm"
        cmd=("$WASI_PATH/bin/clang" "--target=wasm32-wasi-threads" "-Wl,--import-memory,--export-memory,--max-memory=3221225472" "-DWASM" "-o" "$ofile" "$file" "-pthread" "-g" "-O0")
        echo "${cmd[*]}"
        if ! "${cmd[@]}"; then
            echo -e "\033[91mFailed to compile $basename\033[0m"
        fi
    fi
done
