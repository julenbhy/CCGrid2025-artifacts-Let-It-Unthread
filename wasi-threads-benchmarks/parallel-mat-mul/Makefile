TARGET=benchmark
SIZE?=LARGE

LIBS = -pthread

# Compilation with gcc
CC = gcc
CFLAGS = -D$(SIZE)_DATASET -O3
LDFLAGS =

# Compilation with musl-gcc
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-gcc
MUSL_FLAGS =-Wl,-rpath,$(MUSL)/x86_64-linux-musl/lib

# Compilation with wasi-sdk/clang
WASI_SDK ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads -D$(SIZE)_DATASET -O3
WASI_LDFLAGS = -Wl,--import-memory,--export-memory,--max-memory=4294901760




.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(MUSL_FLAGS) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@ $(TARGET).c



THREADS ?= 8
INPUT = $(THREADS)

WASMTIME ?= /home/julen/.wasmtime/bin/wasmtime
IWASM ?= /usr/local/bin/iwasm
WASMER ?= /home/julen/.wasmer/bin/wasmer


run: $(TARGET)
	./$(TARGET) $(INPUT)

runmusl: $(TARGET).musl
	./$(TARGET).musl $(INPUT)

runwasmtime: $(TARGET).wasm
	$(WASMTIME)  --dir=. -S threads $(TARGET).wasm $(INPUT)
	
runiwasm: $(TARGET).wasm
	$(IWASM)  --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm
	$(WASMER)  --dir=. $(TARGET).wasm $(INPUT)




PARAMS_MULTITIME ?= -q -n 3

multitime: $(TARGET)
	multitime $(PARAMS_MULTITIME) ./$(TARGET) $(INPUT)

multitime_musl: $(TARGET).musl
	multitime $(PARAMS_MULTITIME) ./$(TARGET).musl $(INPUT)

multitime_wasmtime: $(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)

multitime_iwasm: $(TARGET).wasm		
	multitime $(PARAMS_MULTITIME) $(IWASM) --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)

multitime_wasmer: $(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(WASMER) --dir=. $(TARGET).wasm $(INPUT)


clean:
	find . -name $(TARGET) -delete
	find . -name '*.musl' -delete
	find . -name '*.wasm' -delete
	find . -name '*.time' -delete
