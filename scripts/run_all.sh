#!/usr/bin/env bash
# No set -e here, we handle errors manually

source scripts/env.sh
ROOT_DIR=$(pwd)

echo "=== Running all benchmarks ==="

run_step() {
    local desc="$1"
    shift
    echo -e "\n--- $desc ---"
    "$@" > >(tee -a logs/${desc// /_}.log) 2>&1
    local status=$?
    if [ $status -ne 0 ]; then
        echo "⚠️  [WARNING] Step '$desc' failed with exit code $status, continuing..."
    fi
    return 0  # always return success so the script continues
}

# Create logs folder
mkdir -p logs

# --- instance_pre-overhead ---
pushd instance_pre-overhead > /dev/null
run_step "instance_pre-overhead: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

# --- trampoline-overhead ---
pushd trampoline-overhead > /dev/null
run_step "trampoline-overhead: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

# --- wasi-malloc-benchmarks ---
pushd wasi-malloc-benchmarks > /dev/null
run_step "wasi-malloc-benchmarks: build.sh" ./build.sh
pushd build > /dev/null
run_step "wasi-malloc-benchmarks: run_benchmark allt allr" ../run_benchmark allt allr
popd > /dev/null
popd > /dev/null

# --- wasi-threads-benchmarks ---
pushd wasi-threads-benchmarks/parsec > /dev/null
run_step "wasi-threads-benchmarks/parsec: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

pushd wasi-threads-benchmarks/pthread_create > /dev/null
run_step "wasi-threads-benchmarks/pthread_create: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

pushd wasi-threads-benchmarks/pthread_create_RSS > /dev/null
run_step "wasi-threads-benchmarks/pthread_create_RSS: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

# --- wasi-threads-microbenchmarks ---
pushd wasi-threads-microbenchmarks/concurrent-software-benchmarks > /dev/null
run_step "wasi-threads-microbenchmarks/concurrent-software-benchmarks: compile.sh" ./compile.sh
run_step "wasi-threads-microbenchmarks/concurrent-software-benchmarks: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

pushd wasi-threads-microbenchmarks/pthread_mutex > /dev/null
run_step "wasi-threads-microbenchmarks/pthread_mutex: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

echo -e "\n=== All benchmarks finished (some may have failed) ==="
echo "Check the logs/ directory for details."
