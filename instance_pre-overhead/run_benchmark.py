import subprocess
import argparse

funcs_list = [1, 10, 100, 1000]
threads_list = [1, 16]

num_runs = 30

WASMTIME = "./wasmtime/target/release/wasmtime"
TARGET = "main.wasm"

output_csv = "result.csv"

def main():
    # Write the header of the output file
    with open(output_csv, "w") as f:
        f.write("Functions,Threads,Time(µs),StdDev\n")


    for n_funcs in funcs_list:
        print("Running for", n_funcs, "functions")
        # Generate code for n_funcs functions
        subprocess.run(["./generate_code.sh", str(n_funcs)])

        for n_threads in threads_list:
            print("Running for", n_threads, "threads")

            elapsed_times = []
            for i in range(1, num_runs + 1):
                print("Run", i)
                command = [WASMTIME, "-S", "threads", TARGET, str(n_threads)]
                result = subprocess.run(command, capture_output=True, text=True)

                # Get each line of the result
                lines = result.stdout.split("\n")

                # Extract numeric value from each line
                elapsed_times += [line.split(":")[1] for line in lines if "Elapsed time" in line]

            # Calculate average elapsed time
            avg_elapsed_time = sum([float(time) for time in elapsed_times]) / len(elapsed_times)
            std_dev = (sum([(float(time) - avg_elapsed_time) ** 2 for time in elapsed_times]) / len(elapsed_times)) ** 0.5

            # Write the result to the output file
            with open(output_csv, "a") as f:
                f.write(f"{n_funcs},{n_threads},{avg_elapsed_time},{std_dev}\n")




# Parse the input arguments
def parse_arguments():
    global num_runs
    parser = argparse.ArgumentParser(description='Arguments for benchmarking')

    parser.add_argument('-n', '--num_runs', type=int, default=num_runs,
                        help='Number of runs for each benchmark (default: {})'.format(num_runs))

    args = parser.parse_args()
    
    num_runs = args.num_runs


if __name__ == '__main__':
    parse_arguments()
    main()

