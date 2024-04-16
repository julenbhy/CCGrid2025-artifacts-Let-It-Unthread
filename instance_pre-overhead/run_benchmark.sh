#!/bin/bash

funcs_list=(1 10)
threads_list=(1 3)

nun_runs=3

WASMTIME="./wasmtime/target/release/wasmtime -S threads"
TARGET="main.wasm"

output_csv="result.csv"


for n_funcs in "${funcs_list[@]}"
do
  echo "Functions: $n_funcs"
  # Generate code for n_funcs functions
  ./generate_code.sh $n_funcs

  for n_threads in "${threads_list[@]}"
  do
    echo "Threads: $n_threads"

    for ((i=1; i<=$nun_runs; i++))
    do
      echo "Run $i"
      result=$($WASMTIME $TARGET $n_threads 2>&1)
      echo "$result"
      
      # Extract numeric value from result 
      result=$(echo $result | grep -oP '(?<=Elapsed time: )\d+.\d+')

      # Calculate average (the result contains multiple values (each value in a separete line), one for each thread)
      avg=$(echo "scale=2; $avg + $result" | bc)
      

    done

    avg=$(echo "scale=2; $avg / $nun_runs" | bc)
  done
done
