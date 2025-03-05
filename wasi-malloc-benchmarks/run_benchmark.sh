#!/bin/bash
# Copyright 2018-2022, Microsoft Research, Daan Leijen, Julien Voisin, Matthew Parkinson


# --------------------------------------------------------------------
# Allocators and tests
# --------------------------------------------------------------------

readonly alloc_all="glibc musl wasmtime wasmtime_mimalloc iwasm iwasm_mimalloc wasmer wasmer_mimalloc"
alloc_run=""           # allocators to run (expanded by command line options)

readonly tests="cfrac espresso malloc-large bench-malloc-simple"
readonly thread_tests="larson-sized larson mstress xmalloc-test mleak t-test1 bench-malloc-threads"
readonly tests_all="$tests $thread_tests"

tests_run=""

# Set the paths to the runtimes
wasmtime="/opt/wasmtime-v16.0.0-x86_64-linux/wasmtime"
iwasm="/opt/iwasm-1.3.1/iwasm"
wasmer="/opt/wasmer-4.2.3/bin/wasmer"




# --------------------------------------------------------------------
# Environment
# --------------------------------------------------------------------

verbose="no"
timecmd="$(type -P time)"  # the shell builtin doesn't have all the options we need
extso=".so"
procs=64
repeats=1          # repeats of all tests
test_repeats=30     # repeats per test
sleep=0            # mini sleeps between tests seem to improve stability
max_time=900            # max time for timeout

libc=`ldd --version 2>&1 | head -n 1` || true
libc="${libc#ldd }"
if command -v nproc > /dev/null; then 
  procs=`nproc`
fi


# --------------------------------------------------------------------
# Check directories
# --------------------------------------------------------------------

readonly curdir=`pwd`
if ! test -f ../run_benchmark.sh; then
  echo "error: you must run this script from the 'build' directory!"
  exit 1
fi

pushd "../bench" > /dev/null
readonly benchdir=`pwd`
popd > /dev/null



# --------------------------------------------------------------------
# Helper functions
# --------------------------------------------------------------------

function warning { # <message> 
  echo ""
  echo -e "\033[0;31mwarning:\033[0m $1"
  echo ""
}

function contains {  # <string> <substring>   does string contain substring?
  for s in $1; do
    if test "$s" = "$2"; then
      return 0
    fi
  done
  return 1
}

function alloc_run_add {  # <allocator>   :add to runnable
  alloc_run="$alloc_run $1"
}

function tests_run_add {  # <tests>   :add to runnable tests
  tests_run="$tests_run $1"
}



# --------------------------------------------------------------------
# Parse command line
# --------------------------------------------------------------------

while : ; do
  # set flag and flag_arg
  flag="$1"
  case "$flag" in
    *=*)  flag_arg="${flag#*=}"
          flag="${flag%=*}=";;
    no-*) flag_arg="0"
          flag="${flag#no-}";;
    none) flag_arg="0" ;;
    *)    flag_arg="1" ;;
  esac
  case "$flag_arg" in
    yes|on|true)  flag_arg="1";;
    no|off|false) flag_arg="0";;
  esac

  # If the flag is an allocator, add it to the list of allocators to run
  if contains "$alloc_all" "$flag"; then
    alloc_run_add "$flag" "$flag_arg"
  # If the flag is a test, add it to the list of tests to run 
  else if contains "$tests_all" "$flag"; then
      tests_run_add "$flag" "$flag_arg"
  else
      case "$flag" in
        "") break;;
        allr) # Use all runtimes
            for alloc in $alloc_all; do 
              alloc_run_add "$alloc" "$flag_arg"
            done;;
        allt) # Use all tests
            for tst in $tests_all; do
              tests_run_add "$tst" "$flag_arg"
            done;;
        -j=*|--procs=*)
            procs="$flag_arg";;
        -r=*)
            repeats="$flag_arg";;
        -n=*)
            test_repeats="$flag_arg";;
        -s=*|--sleep=*)
            sleep="$flag_arg";;
        -v|--verbose)
            verbose="yes";;
        -h|--help|-\?|help|\?)
            echo "./run_benchmark [options]"
            echo ""
            echo "options:"
            echo "  -h, --help                   show this help"  
            echo "  -v, --verbose                be verbose (=$verbose)"
            echo "  -j=<n>, --procs=<n>          concurrency level (=$procs)"
            echo "  -r=<n>                       number of repeats of the full suite (=$repeats)"
            echo "  -n=<n>                       number of repeats of each individual test (=$test_repeats)"
            echo "  -s=<n>, --sleep=<n>          seconds of sleep between each test (=$sleep)"
            echo "  --external=<file>            read external allocators from <file>, one per line, in the format <name> <path>"
            echo ""
            echo "  allt                         run all tests"
            echo "  allr                         run all runtimes"
            echo ""

            echo ""
            echo "tests included in 'allt':"
            echo "  $tests_all"
            echo ""
            echo "allocators included in 'allr':"
            echo "  $alloc_all"
            echo ""
            exit 0;;
        *) warning "unknown option \"$1\"." 1>&2
      esac
    fi
  fi
  shift
done

echo "benchmarking on $procs cores."
echo "use '-h' or '--help' for help on configuration options."
echo ""
export verbose

echo "runtimes: $alloc_run"
echo "tests     : $tests_run"


if [ -z "$tests_run" ]; then
  warning "no tests are specified."
  exit 1
fi
if [ -z "$alloc_run" ]; then
  warning "no allocators are specified."
  exit 1
fi



# --------------------------------------------------------------------
# Run a test
# --------------------------------------------------------------------
readonly allocfill="     "
readonly benchfill="           "

mkdir -p "$curdir/../result"
readonly benchres="$curdir/../result/$procs.csv"

function run_test_env_cmd { # <test name> <allocator name> <environment args> <command> <repeat>
  if ! [ -z "$sleep" ]; then
    sleep "$sleep"
  fi

  echo
  echo "run $4: $1 $2: $3"

  # clear temporary output
  if [ -f "$benchres.line" ]; then
    rm "$benchres.line"
  fi

  outfile="$curdir/$1-$2-out.txt"
  infile="/dev/null"

  case "$1" in
    larson*|xmalloc*)
      outfile="$1-$2-out.txt";;
    barnes)
      infile="$benchdir/barnes/input";;
  esac

  # Execute the benchmark
  $timecmd -a -q -o "$benchres.line" -f "$1${benchfill:${#1}} $2${allocfill:${#2}} %e %M %U %S %F %R" timeout $max_time $3 < "$infile" > "$outfile"
  exit_status=$?

  if [ $exit_status -eq 124 ]; then
    # Timeout
    warning "$1 $2 times out after $max_time seconds"
    cat "$benchres.line" | sed -E -e "s/($1  *$2  *)[^ ]*/\1timeout/" > "$benchres.line.tmp"
    mv "$benchres.line.tmp" "$benchres.line"
  elif [ $exit_status -ne 0 ]; then
    # Error
    warning "$1 $2 failed with error code $exit_status"
    echo "$1 $2 error" > "$benchres.line"
  fi

  # fixup with relative time
  case "$1" in
    larson*)
      rtime=$(sed -n 's/.* time: \([0-9\.]*\).*/\1/p' "$1-$2-out.txt")
      if [ -n "$rtime" ]; then
        echo "$1,$2, relative time: ${rtime}s"
        sed -E -i.bak "s/($1  *$2  *)[^ ]*/\10:$rtime/" "$benchres.line"
      fi
      ;;
    xmalloc*)
      rtime=$(sed -n 's/rtime: \([0-9\.]*\).*/\1/p' "$1-$2-out.txt")
      if [ -n "$rtime" ]; then
        echo "$1,$2, relative time: ${rtime}s"
        sed -E -i.bak "s/($1  *$2  *)[^ ]*/\10:$rtime/" "$benchres.line"
      fi
      ;;
    glibc-thread)
      ops=$(sed -n 's/\([0-9\.]*\).*/\1/p' "$1-$2-out.txt")
      if [ -n "$ops" ]; then
        rtime=$(echo "scale=3; (1000000000 / $ops)" | bc)
        echo "$1,$2: iterations: ${ops}, relative time: ${rtime}s"
        sed -E -i.bak "s/($1  *$2  *)[^ ]*/\10:$rtime/" "$benchres.line"
      fi
      ;;
  esac

  # Append results
  test -f "$benchres.line" && cat "$benchres.line" | tee -a $benchres
}


function run_test_cmd {  # <test name> <command>
  echo ""
  echo "---- $repeat: $1"

  wasmtime_args=""
  iwasm_args=""
  # if threaded test, add thread params
  if contains "$thread_tests" "$1"; then
    wasmtime_thread_args="-S threads"
    iwasm_thread_args="--max-threads=128" #"--max-threads=$(($procs+1))" #xmalloc-test needs a lot more threads
  fi


  for alloc in $alloc_run; do     # use order as given on the command line
    if contains "$alloc_run" "$alloc"; then
      for ((i=$test_repeats; i>0; i--)); do
        case "$alloc" in
          glibc) run_test_env_cmd $1 "glibc" "./$1 $2" $i;;
          musl) run_test_env_cmd $1 "musl" "./$1.musl $2" $i;;
          wasmtime) run_test_env_cmd $1 "wasmtime" "$wasmtime $wasmtime_thread_args --dir .. ./$1.wasm $2" $i;;
          wasmtime_mimalloc) run_test_env_cmd $1 "wasmtime_mimalloc" "$wasmtime $wasmtime_thread_args --dir .. ./$1_mimalloc.wasm $2" $i;;
          iwasm) run_test_env_cmd $1 "iwasm" "$iwasm $iwasm_thread_args --dir=.. ./$1.wasm $2" $i;;
          iwasm_mimalloc) run_test_env_cmd $1 "iwasm_mimalloc" "$iwasm $iwasm_thread_args --dir=.. ./$1_mimalloc.wasm $2" $i;;
          wasmer) run_test_env_cmd $1 "wasmer" "$wasmer ./$1.wasm -- $2" $i;;
          wasmer_mimalloc) run_test_env_cmd $1 "wasmer_mimalloc" "$wasmer ./$1_mimalloc.wasm -- $2" $i;;
        esac
      done
    fi
  done             
}


# --------------------------------------------------------------------
# Run all tests
# --------------------------------------------------------------------

echo "test runtime time rss user sys page-faults page-reclaims" > $benchres

function run_test {  # <test>
  case $1 in
    cfrac)
      run_test_cmd "cfrac" "17545186520507317056371138836327483792789528";;
    espresso)
      run_test_cmd "espresso" "../bench/espresso/largest.espresso";;
    barnes)
      run_test_cmd "barnes" " ";;
    larson)
      run_test_cmd "larson" "5 8 1000 5000 100 4141 $procs";;
    larson-sized)
      run_test_cmd "larson-sized" "5 8 1000 5000 100 4141 $procs";;
    xmalloc-test)
      run_test_cmd "xmalloc-test" "-w $procs -t 5 -s 64";;
    malloc-large)
      run_test_cmd "malloc-large" " ";;
    mstress)
      run_test_cmd "mstress" "$procs 50 25";;
    mleak)
      run_test_cmd "mleak"  "5 $procs";;
    t-test1)
      run_test_cmd "t-test1" "500 $procs";;
    bench-malloc-simple)
      run_test_cmd "bench-malloc-simple" " ";;
    bench-malloc-threads)
      run_test_cmd "bench-malloc-threads" "$procs";;


    *)
    warning "skipping unknown test: $1";;
  esac
}

# Clear previous results
#rm "$benchres"
rm -f ./security-*-out.txt

for ((repeat=$repeats; repeat>0; repeat--)); do
  for tst in $tests_run; do
    run_test "$tst"
  done
done


# --------------------------------------------------------------------
# Wrap up
# --------------------------------------------------------------------
if test -f "$benchres"; then

  sed -i.bak "s/ 0:/ /" $benchres
  echo ""
  echo "results written to: $benchres"
  echo ""
  echo "#------------------------------------------------------------------"
  awk 'BEGIN{printf "%-20s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n", "test", "runtime", "time", "rss", "user", "sys", "page-faults", "page-reclaims"}\
            {printf "%-20s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n", $1, $2, $3, $4, $5, $6, $7, $8}' "$benchres"
  echo ""
  # Remove all temporary files using metacharacters
  rm -f "$benchres.line" "$benchres.line.bak" "$benchres.bak"

fi

for file in security-*-out.txt
do
  if [ -f "$file" ]; then
    cat "$file"
    echo ""
  fi
done
