#!/usr/bin/env bash
# No set -e here, we handle errors manually

source scripts/env.sh
ROOT_DIR=$(pwd)

echo "=== Running all benchmarks ==="

# Ensure logs folder exists
mkdir -p logs


LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

PASSED=()
FAILED=()

run_step() {
    local desc="$1"
    shift
    local log_name=$(echo "$desc" | tr '/: ' '__')
    echo -e "\n--- $desc ---"
    "$@" > >(tee "${LOG_DIR}/${log_name}.log") 2>&1
    local status=$?
    if [ $status -ne 0 ]; then
        echo "⚠️  [WARNING] Step '$desc' failed with exit code $status, continuing..."
        FAILED+=("$desc")
    else
        PASSED+=("$desc")
    fi
    return 0
}

# --- instance_pre-overhead ---
pushd instance_pre-overhead > /dev/null
run_step "instance_pre-overhead: run_benchmark.py" python3 run_benchmark.py
popd > /dev/null

# --- trampoline-overhead ---
pushd trampoline-overhead > /dev/null
run_step "trampoline-overhead: run_benchmark.py" python3 run_benchmark.py -v
popd > /dev/null

# --- wasi-malloc-benchmarks ---
pushd wasi-malloc-benchmarks > /dev/null
run_step "wasi-malloc-benchmarks: compile.sh" ./compile.sh
pushd build > /dev/null
run_step "wasi-malloc-benchmarks: run_benchmark.sh allt allr" ../run_benchmark.sh allt allr
popd > /dev/null
popd > /dev/null

# --- wasi-threads-benchmarks ---
pushd wasi-threads-benchmarks/parsec > /dev/null
run_step "wasi-threads-benchmarks/parsec: run_benchmark.py" python3 run_benchmark.py -v
popd > /dev/null

pushd wasi-threads-benchmarks/pthread_create > /dev/null
run_step "wasi-threads-benchmarks/pthread_create: run_benchmark.py" python3 run_benchmark.py -v
popd > /dev/null

pushd wasi-threads-benchmarks/pthread_create_RSS > /dev/null
run_step "wasi-threads-benchmarks/pthread_create_RSS: run_benchmark.py" python3 run_benchmark.py -v
popd > /dev/null

# --- wasi-threads-microbenchmarks ---
pushd wasi-threads-microbenchmarks/concurrent-software-benchmarks > /dev/null
run_step "wasi-threads-microbenchmarks/concurrent-software-benchmarks: compile.sh" ./compile.sh
run_step "wasi-threads-microbenchmarks/concurrent-software-benchmarks: run_benchmark.py" python3 run_benchmark.py -v
popd > /dev/null

pushd wasi-threads-microbenchmarks/pthread_mutex > /dev/null
run_step "wasi-threads-microbenchmarks/pthread_mutex: run_benchmark.py -v" python3 run_benchmark.py -v
popd > /dev/null


# --- Summary ---
echo -e "\n=== Benchmark Summary ==="

if [ ${#PASSED[@]} -gt 0 ]; then
    echo "PASSED:"
    for step in "${PASSED[@]}"; do
        echo "   - $step"
    done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    echo -e "\nFAILED:"
    for step in "${FAILED[@]}"; do
        echo "   - $step"
    done
else
    echo -e "\nAll steps passed!"
fi

echo -e "\nLogs for each step are stored in ./logs/"
