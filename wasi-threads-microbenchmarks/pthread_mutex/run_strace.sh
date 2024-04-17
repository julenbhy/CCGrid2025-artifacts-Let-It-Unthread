#!/bin/bash


# Time limit for each benchmark
time_limit=60

# Verbose output
verbose=true

# Array of benchmarks
benchmarks=("contention" "no_contention")

# Array of thread numbers to run the benchmarks with
num_threads=(8 16 32 64)

# Define the syscall to trace
syscall="futex"


# Define a function to extract values from the multitime results
extract_values() {
    local results=$1

    #echo
    #echo "output: $results"

    # Extract the line containing the syscall
    syscall_line=$(echo "$results" | grep "$syscall")

    # Extract values using awk
    percentage=$(echo "$syscall_line" | awk '{print $1}')
    seconds=$(echo "$syscall_line" | awk '{print $2}')
    calls=$(echo "$syscall_line" | awk '{print $4}')
    errors=$(echo "$syscall_line" | awk '{print $5}')
    

    
    # Print extracted values
    #echo "percentage: $percentage"
    #echo "seconds: $seconds"
    #echo "calls: $calls"
    #echo "errors: $errors"

    # Return the values
    percentage=$percentage
    calls=$calls
}

# Create directory for benchmark results
mkdir -p "result"

# Create build directory
mkdir -p "build"

# Iterate over benchmarks
for benchmark in "${benchmarks[@]}"; do

    make TARGET=$benchmark

	# Create CSV file for current benchmark and thread number
	csv_file="result/${benchmark}_strace.csv"
	echo "Threads, Runtime, %Time, Calls" > "$csv_file"


	# Iterate over thread numbers
    for threads in "${num_threads[@]}"; do
        echo "Running benchmark $benchmark with $threads threads..."
        
	    # Run native c with glibc.
	    echo -n -e "$threads, native(glibc)" >> "$csv_file"
	    command=("make strace TARGET=$benchmark INPUT=$threads 2>&1")
        # run the command and extract the results and write them to the csv file
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ", $percentage, $calls" >> "$csv_file"

	    # Run musl
	    echo -n -e "$threads, native(musl)" >> "$csv_file"
        command=("make strace_musl TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ", $percentage, $calls" >> "$csv_file"

	    # Run wasmtime.
	    echo -n -e "$threads, wasmtime" >> "$csv_file"
        command=("make strace_wasmtime TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ", $percentage, $calls" >> "$csv_file"

	    # Run iwasm.
	    echo -n -e "$threads, iwasm" >> "$csv_file"
        command=("make strace_iwasm TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ", $percentage, $calls" >> "$csv_file"

	    # Run wasmer.
	    echo -n -e "$threads, wasmer" >> "$csv_file"
        command=("make strace_wasmer TARGET=$benchmark INPUT=$threads 2>&1")
        results=$(eval "${command[@]}")
        extract_values "$results"
        echo ", $percentage, $calls" >> "$csv_file"

	done
done

echo -e "\nCleaning executables..."
make clean


