
all: build

build:
	make -C native
	make -C wasm-parallel-gzip


NUM_THREADS ?= 16

run:
	make run -C native NUM_THREADS=$(NUM_THREADS)

runwasmtime:
	make runwasmtime -C wasm-parallel-gzip NUM_THREADS=$(NUM_THREADS)

runiwasm:
	make runiwasm -C wasm-parallel-gzip NUM_THREADS=$(NUM_THREADS)

runwasmer:
	make runwasmer -C wasm-parallel-gzip NUM_THREADS=$(NUM_THREADS)


PARAMS_MULTITIME ?= -q -n 3

multitime:
	make multitime -C native NUM_THREADS=$(NUM_THREADS)

multitime_wasmtime:
	make multitime_wasmtime -C wasm-parallel-gzip NUM_THREADS=$(NUM_THREADS)

multitime_iwasm:
	make multitime_iwasm -C wasm-parallel-gzip NUM_THREADS=$(NUM_THREADS)

multitime_wasmer:
	make multitime_wasmer -C wasm-parallel-gzip NUM_THREADS=$(NUM_THREADS)
	
clean:
	rm -f random.*
	rm -rf src 
