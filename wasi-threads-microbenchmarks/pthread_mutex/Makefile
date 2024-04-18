TARGET ?= main

LIBS = -pthread

# Compilation with gcc
CC ?= /usr/bin/gcc
CFLAGS =
LDFLAGS =

MUSL ?= /opt/x86_64-linux-musl-cross
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-gcc
MUSL_FLAGS =-Wl,-rpath,$(MUSL)/x86_64-linux-musl/lib

# Compilation with wasi-sdk/clang
WASI_SDK ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads
WASI_LDFLAGS = -Wl,--import-memory,--export-memory,--max-memory=4294901760


.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o build/$@ $(TARGET).c

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o build/$@ $(TARGET).c

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o build/$@ $(TARGET).c



INPUT ?= 10

WASMTIME ?= /opt/wasmtime-v16.0.0-x86_64-linux/wasmtime
IWASM ?= /opt/iwasm-1.3.1/iwasm
WASMER ?= /opt/wasmer-4.2.3/bin/wasmer


run: build/$(TARGET)
	./build/$(TARGET) $(INPUT)

runmusl: build/$(TARGET).musl
	./build/$(TARGET).musl $(INPUT)

runwasmtime: build/$(TARGET).wasm
	$(WASMTIME) -S threads build/$(TARGET).wasm $(INPUT)
	
runiwasm: build/$(TARGET).wasm
	$(IWASM) --max-threads=100 build/$(TARGET).wasm $(INPUT)
	
runwasmer: build/$(TARGET).wasm
	$(WASMER) build/$(TARGET).wasm $(INPUT)
	
	
	
PARAMS_STRACE=--summary-only --follow-forks
strace: build/$(TARGET)
	strace $(PARAMS_STRACE) ./build/$(TARGET) $(INPUT)

strace_musl: build/$(TARGET).musl
	strace $(PARAMS_STRACE) ./build/$(TARGET).musl $(INPUT)

strace_wasmtime: build/$(TARGET).wasm
	strace $(PARAMS_STRACE) $(WASMTIME) -S threads build/$(TARGET).wasm $(INPUT);

strace_iwasm: build/$(TARGET).wasm
	strace $(PARAMS_STRACE) $(IWASM) --max-threads=100 build/$(TARGET).wasm $(INPUT);

strace_wasmer: build/$(TARGET).wasm
	strace $(PARAMS_STRACE) $(WASMER) build/$(TARGET).wasm $(INPUT);







NUM_RUNS ?= 10
PARAMS_MULTITIME = -qq -n $(NUM_RUNS)

multitime: build/$(TARGET)
	multitime $(PARAMS_MULTITIME) ./build/$(TARGET) $(INPUT)

multitime_musl: build/$(TARGET).musl
	multitime $(PARAMS_MULTITIME) ./build/$(TARGET).musl $(INPUT)

multitime_wasmtime: build/$(TARGET).wasm	
	multitime $(PARAMS_MULTITIME) $(WASMTIME) -S threads build/$(TARGET).wasm $(INPUT)

multitime_iwasm: build/$(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(IWASM) --max-threads=64 build/$(TARGET).wasm $(INPUT)
	
multitime_wasmer: build/$(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(WASMER) build/$(TARGET).wasm $(INPUT)


clean:
