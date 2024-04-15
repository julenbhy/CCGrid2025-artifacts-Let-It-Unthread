TARGET = main

LIBS =

# Compilation with gcc
CC = gcc
CFLAGS =
LDFLAGS =

# Compilation with wasi-sdk/clang
WASI_SDK_DIR ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK_DIR)/bin/clang
WASI_CFLAGS =
WASI_LDFLAGS =  -Wl,--allow-undefined


.PHONY: all clean

all: $(TARGET).wasm

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@ $(TARGET).c



# Add any additional wasmtime flags here
WASMTIME ?= /opt/wasmtime-v16.0.0-x86_64-linux/wasmtime
WASMTIME_FLAGS =

INPUT ?=
run: $(TARGET)
	./$(TARGET) $(INPUT)

runwasmtime: $(TARGET).wasm
	$(WASMTIME) $(WASMTIME_FLAGS) $(TARGET).wasm $(INPUT)




# In order to make perf work:
#	sudo apt-get install linux-tools-6.2.0-36-generic linux-cloud-tools-6.2.0-36-generic	
#	sudo apt-get install linux-tools-generic linux-cloud-tools-generic
#	sudo sysctl -w kernel.perf_event_paranoid=-1
#	echo 0 | sudo tee /proc/sys/kernel/kptr_restrict

	
perfmap:
	perf record -k mono wasmtime $(WASMTIME_FLAGS) --profile=perfmap $(TARGET).wasm
	perf report --input perf.data
	rm perf.data

jitdump:
	perf record -k mono wasmtime $(WASMTIME_FLAGS) --profile=jitdump $(TARGET).wasm
	perf inject --jit --input perf.data --output perf.jit.data
	perf report --input perf.jit.data
	rm *so perf.data perf.jit.data *.dump
	

VMLINUX = --vmlinux /sys/kernel/btf/vmlinux
jitdump-anotate:	
	perf record -k mono wasmtime $(WASMTIME_FLAGS) --profile=jitdump $(TARGET).wasm
	perf inject --jit --input perf.data --output perf.jit.data
	perf annotate $(VMLINUX) --input perf.jit.data --stdio
	rm *so perf.data perf.jit.data *.dump




clean:
	rm -f $(TARGET) *.wasm
