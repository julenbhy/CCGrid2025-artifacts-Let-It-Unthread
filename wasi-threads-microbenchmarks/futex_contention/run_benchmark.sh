#!/bin/bash

# Number of runs for each benchmark
num_runs=30

# Time limit for each benchmark
time_limit=60

# Verbose output
verbose=true

# Array of benchmarks
benchmarks=("no_contention" "contention")
benchmarks=("contention")

# Array of thread numbers to run the benchmarks with
num_threads=(8 16 32 64)


# Define a function to extract values from the multitime results
extract_values() {
    local results=$1

    echo
    echo "output: $results"

    # Extract values using awk
    mean=$(echo "$results" | awk 'NR==5 {print $2}')
    stddev=$(echo "$results" | awk 'NR==5 {print $3}')
    min=$(echo "$results" | awk 'NR==5 {print $4}')
    median=$(echo "$results" | awk 'NR==5 {print $5}')
    max=$(echo "$results" | awk 'NR==5 {print $6}')

    # Print extracted values
    #echo "Mean: $mean"
    #echo "Std.Dev.: $stddev"
    #echo "Min: $min"
    #echo "Median: $median"
    #echo "Max: $max"

    # Return the values
    real_mean=$mean
    real_stddev=$stddev
}



# Create directory for compiled files and benchmark results
mkdir -p "build"
mkdir -p "result"

# Iterate over benchmarks
for benchmark in "${benchmarks[@]}"; do

    make -f Makefile TARGET=${benchmark}


	# Create CSV file for current benchmark and thread number
	csv_file="result/${benchmark}.csv"
	echo "Threads,Runtime,Mean,StdDev" > "$csv_file"


	# Iterate over thread numbers
    for threads in "${num_threads[@]}"; do
        echo "Running benchmark $benchmark with $threads threads..."
        
	    # Run native c with glibc.
	    echo -n -e "$threads,native(glibc)" >> "$csv_file"
	    command=("make multitime NUM_RUNS=$num_runs TARGET=$benchmark INPUT=$threads 2>&1")
        # run the command and extract the results and write them to the csv file
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ",$real_mean,$real_stddev" >> "$csv_file"

	    # Run musl
	    echo -n -e "$threads,native(musl)" >> "$csv_file"
        command=("make multitime_musl NUM_RUNS=$num_runs TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ",$real_mean,$real_stddev" >> "$csv_file"

	    # Run wasmtime.
	    echo -n -e "$threads,wasmtime" >> "$csv_file"
        command=("make multitime_wasmtime NUM_RUNS=$num_runs TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ",$real_mean,$real_stddev" >> "$csv_file"

	    # Run iwasm.
	    echo -n -e "$threads,iwasm" >> "$csv_file"
        command=("make multitime_iwasm NUM_RUNS=$num_runs TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ",$real_mean,$real_stddev" >> "$csv_file"

	    # Run wasmer.
	    echo -n -e "$threads,wasmer" >> "$csv_file"
        command=("make multitime_wasmer NUM_RUNS=$num_runs TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ",$real_mean,$real_stddev" >> "$csv_file"

	done
done

echo -e "\nCleaning executables..."
make clean


