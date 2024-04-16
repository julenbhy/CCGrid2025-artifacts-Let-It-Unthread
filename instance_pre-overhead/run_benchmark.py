import subprocess

funcs_list = [1, 10, 100, 1000]
threads_list = [1, 16]

num_runs = 3

WASMTIME = "./wasmtime/target/release/wasmtime"
TARGET = "main.wasm"

output_csv = "result.csv"
result = subprocess.run('ls')


for n_funcs in funcs_list:
    print("Functions:", n_funcs)
    # Generate code for n_funcs functions
    subprocess.run(["./generate_code.sh", str(n_funcs)])

    for n_threads in threads_list:
        print("Threads:", n_threads)

        elapsed_times = []
        for i in range(1, num_runs + 1):
            print("Run", i)
            command = [WASMTIME, "-S", "threads", TARGET, str(n_threads)]
            result = subprocess.run(command, capture_output=True, text=True)
            print(result.stdout)

            # Get each line of the result
            lines = result.stdout.split("\n")

            # Extract numeric value from each line (Line formar: Elapsed time: 28.684µs)
            elapsed_times += [line.split(":")[1].split("µ")[0] for line in lines if "Elapsed time" in line]

        # Calculate average elapsed time
        avg_elapsed_time = sum([float(time) for time in elapsed_times]) / len(elapsed_times)
        std_dev = (sum([(float(time) - avg_elapsed_time) ** 2 for time in elapsed_times]) / len(elapsed_times)) ** 0.5

        # Write the result to the output file
        with open(output_csv, "a") as f:
            f.write(f"{n_funcs},{n_threads},{avg_elapsed_time},{std_dev}\n")




