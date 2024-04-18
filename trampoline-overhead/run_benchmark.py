import argparse
import os
import subprocess
import re


# Number of runs for each benchmark
num_runs = 30

# Verbose output
verbose = False

# Time limit for each benchmark
time_limit = 60

# Set the environment variables for the WASI SDK, MUSL and WASMTIME
WASI_SDK = "/opt/wasi-sdk"
MUSL = "/opt/x86_64-linux-musl-cross"
WASMTIME = "/opt/wasmtime-v16.0.0-x86_64-linux/wasmtime"


def compile():
    # Compile all benchmarks
    print("Compiling benchmarks...")

    subprocess.run(["ls"])

    subprocess.run(["cargo", "build", "--release", "--manifest-path", "Wasm-to-Host/Cargo.toml"])
    subprocess.run(["make", "-C", "Wasm-to-Host/src"])
    subprocess.run(["cargo", "build", "--release", "--manifest-path", "Host-to-Wasm/Cargo.toml"])
    subprocess.run(["make", "-C", "standard_function"])

    subprocess.run(["ls"])


def extract_numerical_values(line):
    # Split the line by whitespace and extract numerical values
    values = [word.strip('ms') for word in line.split() if word.strip('ms').replace('.', '', 1).isdigit()]
    return ','.join(values)

def run_bench(command):
    result = ""

    for i in range(num_runs):

        print("\n", " ".join(command))

        completed_process=subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=time_limit)

        if(verbose): print(f"\n\tstdout: {completed_process.stdout} \n\tstderr: {completed_process.stderr}")
            
        # Extract the numerical values from the output
        numerical_values = ','.join(re.findall(r"(\d+\.\d+|\d+)", completed_process.stdout))

        # Add the real mean and real stddev to the result
        result += f",{numerical_values}"



    return result




def main():

    # Export the paths so the Makefiles can use them
    os.environ["WASI_SDK"] = WASI_SDK
    os.environ["MUSL"] = MUSL
    os.environ["WASMTIME"] = WASMTIME


    # Compile all benchmarks
    compile()
    
    # Create CSV file for current benchmark and thread number
    csv_file = f"result.csv"
    with open(csv_file, "w") as file:
        file.write("Bench")
        for i in range(num_runs): file.write(f",Time(ms)")

        print("\nRunning Wasm-to-Host...")
        file.write(f"\nWasm-to-Host")
        os.chdir("Wasm-to-Host") # Must change the directory so as not to break the hardcoded path to wasm module
        command = ["cargo", "run", "--release"]
        file.write(run_bench(command))
        os.chdir("..")

        print("\nRunning Host-to-Wasm...")
        file.write(f"\nHost-to-Wasm")
        command = ["cargo", "run", "--release", "--manifest-path", "Host-to-Wasm/Cargo.toml"]
        file.write(run_bench(command))

        print("\nRunning standard_function(glibc)...")
        file.write(f"\nstandard_function(glibc)")
        command = ["make", "-s", "-C", "standard_function", "run"]
        file.write(run_bench(command))

        print("\nRunning standard_function(musl)...")
        file.write(f"\nstandard_function(musl)")
        command = ["make", "-s", "-C", "standard_function", "runmusl"]
        file.write(run_bench(command))

        print("\nRunning standard_function(wasm)...")
        file.write(f"\nstandard_function(wasm)")
        command = ["make", "-s", "-C", "standard_function", "runwasmtime"]
        file.write(run_bench(command))

    
                
    

# Parse the input arguments
def parse_arguments():
    global num_runs, verbose
    parser = argparse.ArgumentParser(description='Arguments for benchmarking')

    parser.add_argument('-n', '--num_runs', type=int, default=num_runs,
                        help='Number of runs for each benchmark (default: {})'.format(num_runs))
    
    parser.add_argument('-v', '--verbose', action='store_true', default=verbose,
                        help='Enable verbose output (default: {})'.format(verbose))


    args = parser.parse_args()

    num_runs = args.num_runs
    verbose = args.verbose



if __name__ == '__main__':
    parse_arguments()
    main()