import argparse
import os
import subprocess
import re
import time

# Number of runs for each benchmark
num_runs = 30

# Time limit for each benchmark
time_limit = 600

# Verbose output
verbose = False

# Array of benchmarks
benchmarks = ["blackscholes", "fluidanimate", "swaptions"]

# Array of thread numbers to run the benchmarks with
num_threads = [32, 64]

# Export the paths so the Makefiles can use them
os.environ["CC"] = "/usr/bin/gcc"
os.environ["MUSL"] = "/opt/x86_64-linux-musl-cross"
os.environ["WASI_SDK"] = "/opt/wasi-sdk"
os.environ["WASI_SDK_20"] = "/opt/wasi-sdk-20.0" # Fluidanimate does't compile with wasi-sdk 21

os.environ["WASMTIME"] = "/opt/wasmtime-v16.0.0-x86_64-linux/wasmtime"   
os.environ["IWASM"] = "/opt/iwasm-1.3.1/iwasm"
os.environ["WASMER"] = "/opt/wasmer-4.2.3/bin/wasmer"


# Define a function to extract values from the multitime results
def extract_values(results):
    values = {}

    # Use regular expressions to match and capture the values
    pattern = re.compile(r"(\w+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)")

    matches = pattern.findall(results)
    for match in matches:
        label, mean, stddev, min_val, median, max_val = match
        values[label.lower() + '_mean'] = float(mean)
        values[label.lower() + '_stddev'] = float(stddev)
        values[label.lower() + '_min'] = float(min_val)
        values[label.lower() + '_median'] = float(median)
        values[label.lower() + '_max'] = float(max_val)

    return values



def run_bench(command):
    result = ""

    print("\n", " ".join(command))

    try:
        completed_process=subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=time_limit)

        if(verbose): print(f"\n\tstdout: {completed_process.stdout} \n\tstderr: {completed_process.stderr}")

        # Get the row for real time
        values = extract_values(completed_process.stderr)

        # Add the real mean and real stddev to the result
        result += f",{values['real_mean']},{values['real_stddev']}"
        
    except Exception as e:
        # To do: Better handling of non finished processes
        # Kill the process in case it has not been ended properly
        subprocess.run(["pkill", "wasmtime"])
        subprocess.run(["pkill", "iwasm"])
        subprocess.run(["pkill", "wasmer"])

        print(f"\033[91mError:\033[0m {e}")
        result += ",x,x"

    return result


def main():

    # Compile all benchmarks
    print("Compiling benchmarks...")
    subprocess.run(["make"])

    # Create directory for benchmark results
    os.makedirs(f"result", exist_ok=True)

    # Iterate over benchmarks
    for benchmark in benchmarks:

        # Create CSV file for current benchmark and thread number
        csv_file = f"result/{benchmark}.csv"
        with open(csv_file, "w") as file:
            file.write("Threads,Runtime,Time,StdDev")

            # Iterate over thread numbers
            for i in range(len(num_threads)):      

                # Run native c with glibc.
                file.write(f"\n{num_threads[i]},native(glibc)")
                command = ["make", "multitime", "-C", benchmark, f"THREADS={num_threads[i]}", f"PARAMS_MULTITIME= -qq -n {num_runs}"]
                file.write(run_bench(command))

                # Run musl if the benchmark is supported (fluidanimate and swaptions are not supported musl-cc cannot be used with g++)
                file.write(f"\n{num_threads[i]},native(musl)")
                command = ["make", "multitime_musl", "-C", benchmark, f"THREADS={num_threads[i]}", f"PARAMS_MULTITIME= -qq -n {num_runs}"]
                file.write(run_bench(command))

                # Run wasmtime.
                file.write(f"\n{num_threads[i]},wasmtime")
                command = ["make", "multitime_wasmtime", "-C", benchmark, f"THREADS={num_threads[i]}", f"PARAMS_MULTITIME= -qq -n {num_runs}"]
                file.write(run_bench(command))

                # Run iwasm.
                file.write(f"\n{num_threads[i]},iwasm")
                command = ["make", "multitime_iwasm", "-C", benchmark, f"THREADS={num_threads[i]}", f"PARAMS_MULTITIME= -qq -n {num_runs}"]
                file.write(run_bench(command))
                
                # Run wasmer.
                file.write(f"\n{num_threads[i]},wasmer")
                command = ["make", "multitime_wasmer", "-C", benchmark, f"THREADS={num_threads[i]}", f"PARAMS_MULTITIME= -qq -n {num_runs}"]
                file.write(run_bench(command))           
                


    print("\nCleaning executables...")
    subprocess.run(["make", "clean"])



# Parse the input arguments
def parse_arguments():
    global num_runs, verbose, time_limit
    parser = argparse.ArgumentParser(description='Arguments for benchmarking')

    parser.add_argument('-n', '--num_runs', type=int, default=num_runs,
                        help='Number of runs for each benchmark (default: {})'.format(num_runs))
    
    parser.add_argument('-v', '--verbose', action='store_true', default=verbose,
                        help='Enable verbose output (default: {})'.format(verbose))
    
    parser.add_argument('-t', '--time_limit', type=int, default=time_limit,
                        help='Time limit(s) for each benchmark (default: {})'.format(time_limit))


    args = parser.parse_args()

    num_runs = args.num_runs
    verbose = args.verbose
    time_limit = args.time_limit


if __name__ == '__main__':
    parse_arguments()
    main()


