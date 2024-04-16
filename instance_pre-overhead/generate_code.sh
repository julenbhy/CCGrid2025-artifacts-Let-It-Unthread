#!/bin/bash

wasi_sdk_path="/opt/wasi-sdk"

lib_path="wasmtime/crates/wasi-threads/src/lib.rs"


if [ $# -eq 0 ]; then
  echo "Usage: $0 <number_of_foos>"
  exit 1
fi

num_foos=$1

        ####################################################
        ### modify wasi-threads lib.rs to link functions ###
        ####################################################

# Clone wasmtime if it doesn't exists.
if [ ! -d "wasmtime" ]; then
  git clone  --recurse-submodules -b release-16.0.0 https://github.com/bytecodealliance/wasmtime.git
  cp "$lib_path" "$lib_path.original" # Save original lib.rs for future calls
fi

# Restore original lib.rs in case it was modified in a previous call
cp "$lib_path.original" $lib_path

for ((i=1; i<=num_foos; i++)); do
  generated_code+="    linker.func_wrap(\"functions\", \"foo$i\", |x: i32, y: i32| x + y)?;\n"
done
generated_code+="\n"
generated_code+="    Ok(())"

sed -i "s#Ok(())#$generated_code#" "$lib_path"

#modify wasi-threads lib.rs to measure instantiation time
sed -i '/use wasmtime_wasi::maybe_exit_on_error;/a \use std::time::{Instant};' "$lib_path"
sed -i '/let mut store = Store::new(&instance_pre.module().engine(), host);/a let instant = Instant::now();' "$lib_path"
sed -i '/let instance = instance_pre.instantiate(&mut store).unwrap();/a println!("Elapsed time: {:?}", instant.elapsed());\n' "$lib_path"

### compile wasmtime-modified ###
echo "Compiling wasmtime-modified..."
cargo build --release --manifest-path wasmtime/Cargo.toml 2>/dev/null
echo "Done."



        #######################
        ### generate main.c ###
        #######################

output_c="./main.c"
cp main_template.c "$output_c"

generated_code=""
for ((i=1; i<=num_foos; i++)); do
  generated_code+="__attribute__((import_module(\"functions\")))\n"
  generated_code+="int foo$i(int a, int b);\n"
  generated_code+="\n"
done
sed -i 's/FUNCTION_IMPORTS/'"$generated_code"'/g' "$output_c"

generated_code=""
for ((i=1; i<=num_foos; i++)); do
  generated_code+="    int result$i = foo$i(a, b);\n"
done
sed -i 's/FUNCTION_CALLS/'"$generated_code"'/g' "$output_c"

### compile main.c ###
$wasi_sdk_path/bin/clang --target=wasm32-wasi-threads\
  -Wl,--import-memory,--export-memory,--max-memory=4294901760\
  -Wl,--allow-undefined -pthread -o main.wasm "$output_c"





