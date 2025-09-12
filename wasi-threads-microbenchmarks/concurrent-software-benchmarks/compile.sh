#!/bin/bash

path="build"

mkdir -p "$path"

musl_gcc=$(find "$MUSL/bin" -name "*-musl-gcc" | head -n1)


for file in src/*.c; do
    if [ -f "$file" ]; then
        basename=$(basename "$file" .c)

        ofile="$dir/$basename.x"
        cmd=("gcc" "-o" "$ofile" "$file" "-pthread" "-g" "-O0")
        echo "${cmd[*]}"
        "${cmd[@]}"

        ofile="$dir/$basename.musl"
        cmd=("$musl_gcc" "-o" "$ofile" "$file" "-pthread" "-g" "-O0")
        echo "${cmd[*]}"
        "${cmd[@]}"

        ofile="$dir/$basename.wasm"
        cmd=("$WASI_SDK/bin/clang" "--target=wasm32-wasi-threads" "-Wl,--import-memory,--export-memory,--max-memory=3221225472" "-DWASM" "-o" "$ofile" "$file" "-pthread" "-g" "-O0")
        echo "${cmd[*]}"
        if ! "${cmd[@]}"; then
            echo -e "\033[91mFailed to compile $basename\033[0m"
        fi
    fi
done
