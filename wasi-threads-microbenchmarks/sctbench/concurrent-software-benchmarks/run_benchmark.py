import argparse
import os
import subprocess
import time
import numpy as np

# Number of runs for each benchmark
num_runs = 10

# Verbose output
verbose = False

# Time limit for each benchmark
time_limit = 60


# Array of benchmarks
benchmarks = [
    "account_ok",
    "arithmetic_prog_ok",
    "circular_buffer_ok",
    "fanger01_ok",
    "fsbench_ok",
    "indexer_ok",
    "lazy01_ok",
    "micro_10_ok",
    "micro_2_ok",
    "micro_3_ok",
    "phase01_ok",
    "queue_ok",
    "stack_ok",
    "stateful01_ok",
    "stateful06_ok",
    "stateful20_ok",
    "sync01_ok",
    "sync02_ok"
]

# Paths to runtimes
wasmtime = "/opt/wasmtime-v16.0.0-x86_64-linux/wasmtime"
iwasm = "/opt/iwasm-1.3.1/iwasm"
wasmer = "/opt/wasmer-4.2.3/bin/wasmer"
    


def run_bench(command):
    result = []
    for j in range(1, num_runs + 1):
        print("\n", " ".join(command))

        try:
            start_time = time.time()
            completed_process=subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=time_limit)
            end_time = time.time()
        except subprocess.TimeoutExpired:
            print("Timeout expired")
            # Add a null to the result array
            #result.append('x') # Breaks np.mean
            continue

        execution_time = end_time - start_time
        # Add the execution time to the result array
        result.append(execution_time)
        
        if(verbose): print(f"\n\tstdout: {completed_process.stdout} \tstderr: {completed_process.stderr}")

    return result


def main():

    # Compile all benchmarks
    print("Compiling benchmarks...")
    subprocess.run(["./compile.sh"])
    
    # Create directory for benchmark results
    os.makedirs(f"result", exist_ok=True)

    # Iterate over benchmarks
    for benchmark in benchmarks:

        # Create CSV file for current benchmark and thread number
        timecsv_file = f"result/{benchmark}.csv"        

        with open(timecsv_file, "w") as time_file:

            # Write headers: runtime, time1, time2, ..., timeN
            time_file.write("Runtime,Mean,StDev")

            # Run naive with glibc
            command = [f"./build/{benchmark}.x"]
            results = run_bench(command)
            time_file.write(f"\nnative(glibc),{np.mean(results)},{np.std(results)}")

            # Run naive with musl
            command = [f"./build/{benchmark}.musl"]
            results = run_bench(command)
            time_file.write(f"\nnative(musl),{np.mean(results)},{np.std(results)}")

            # Run wasmtime.
            command = [wasmtime, "-S", "threads", f"build/{benchmark}.wasm"]
            results = run_bench(command)
            time_file.write(f"\nwasmtime,{np.mean(results)},{np.std(results)}")

            # Run iwasm.
            command = [iwasm, "--max-threads=32", f"build/{benchmark}.wasm"]
            results = run_bench(command)
            time_file.write(f"\niwasm,{np.mean(results)},{np.std(results)}")
            
            # Run wasmer.
            command = [wasmer, f"build/{benchmark}.wasm"]
            results = run_bench(command)
            time_file.write(f"\nwasmer,{np.mean(results)},{np.std(results)}")




# Parse the input arguments
def parse_arguments():
    global num_runs, verbose, time_limit, wasmtime, iwasm, wasmer
    parser = argparse.ArgumentParser(description='Arguments for benchmarking')

    parser.add_argument('-n', '--num_runs', type=int, default=num_runs,
                        help='Number of runs for each benchmark (default: {})'.format(num_runs))
    
    parser.add_argument('-v', '--verbose', action='store_true', default=verbose,
                        help='Enable verbose output (default: {})'.format(verbose))
    
    parser.add_argument('-t', '--time_limit', type=int, default=time_limit,
                        help='Time limit(s) for each benchmark (default: {})'.format(time_limit))
    
    parser.add_argument('--wasmtime', type=str, default=wasmtime,
                        help='Path to wasmtime (default: {})'.format(wasmtime))
    
    parser.add_argument('--iwasm', type=str, default=iwasm,
                        help='Path to iwasm (default: {})'.format(iwasm))
    
    parser.add_argument('--wasmer', type=str, default=wasmer,
                        help='Path to wasmer (default: {})'.format(wasmer))
    

    args = parser.parse_args()

    num_runs = args.num_runs
    verbose = args.verbose
    time_limit = args.time_limit
    wasmtime = args.wasmtime
    iwasm = args.iwasm
    wasmer = args.wasmer



if __name__ == '__main__':
    parse_arguments()
    main()


