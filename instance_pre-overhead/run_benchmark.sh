#!/bin/bash

# Lista de valores para n_threads y n_funcs
threads_list=(1 10 100 1000)
funcs_list=(1 10 100 1000)

git clone  --recurse-submodules -b release-16.0.0 https://github.com/bytecodealliance/wasmtime.git

# Bucle externo para n_threads
for n_threads in "${threads_list[@]}"
do
  # Bucle interno para n_funcs
  for n_funcs in "${funcs_list[@]}"
  do
    # Nombre del archivo CSV de salida
    output_csv="times/${n_funcs}_funcs_${n_threads}_threads.csv"

    # Número de veces que se ejecutará grep
    n=1000
    WASMTIME_MODIFIED="./wasmtime-modified/target/release/wasmtime"
    TARGET="main"
    WASMTIME_FLAGS="--wasm-features=threads --wasi-modules=experimental-wasi-threads"

    bash code_generator.sh $n_funcs $n_threads

    # Bucle para ejecutar grep y procesar los resultados n veces
    for ((i=1; i<=$n; i++))
    do
      # Ejecutar grep y almacenar la línea de resultado en una variable
      result=$(make modified)
  
      # Extraer los valores numéricos usando awk y agregarlos al archivo CSV
      echo "$result" | tail -n +3 | awk '{gsub(/[^0-9,]/,""); print}' >> $output_csv
    done
  done
done
