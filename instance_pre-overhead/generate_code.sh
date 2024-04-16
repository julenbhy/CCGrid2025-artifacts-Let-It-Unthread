#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <number_of_foos>"
  exit 1
fi

num_foos=$1

####################################################
### modify wasi-threads lib.rs to link functions ###
####################################################

rm -rf wasmtime-modified
cp -r wasmtime wasmtime-modified

lib_path="./wasmtime-modified/crates/wasi-threads/src/lib.rs"

for ((i=1; i<=num_foos; i++)); do
  generated_code+="    linker.func_wrap(\"functions\", \"foo$i\", |x: i32, y: i32| x + y)?;\n"
done
generated_code+="\n"
generated_code+="    Ok(())"

sed -i "s#Ok(())#$generated_code#" "$lib_path"

################################################################
### modify wasi-threads lib.rs to measure instantiation time ###
################################################################

### compile wasmtime-modified ###
cargo build --release --manifest-path wasmtime-modified/Cargo.toml




#######################
### generate main.c ###
#######################

output_c="./main.c"
cat <<EOF > "$output_c"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

__attribute__((import_module("functions")))
int foo1(int a, int b);

EOF

for ((i=2; i<=num_foos; i++)); do
  echo "__attribute__((import_module(\"functions\")))" >> "$output_c"
  echo "int foo$i(int a, int b);" >> "$output_c"
done

cat <<EOF >> "$output_c"

void *thread_func(void *arg) {
    int id = *(int*)arg;
    int a = id, b = id * 2;

    // Call "foo" functions
EOF

for ((i=1; i<=num_foos; i++)); do
  echo "    int result$i = foo$i(a, b);" >> "$output_c"
  echo "    printf(\"Thread %d: foo$i(%d, %d) = %d\\n\", id, a, b, result$i);" >> "$output_c"
done

cat <<EOF >> "$output_c"

    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <number_of_threads>\n", argv[0]);
        return 1;
    }

    int num_threads = atoi(argv[1]);
    pthread_t threads[num_threads];
    int thread_ids[num_threads];

    for (int i = 0; i < num_threads; i++) {
        thread_ids[i] = i + 1;
        pthread_create(&threads[i], NULL, thread_func, &thread_ids[i]);
    }

    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    return 0;
}
EOF


### compile main.c###
/opt/wasi-sdk/bin/clang --target=wasm32-wasi-threads\
   -Wl,--import-memory,--export-memory,--max-memory=4294901760 -Wl,--allow-undefined\
   -pthread -o main.wasm main.c





