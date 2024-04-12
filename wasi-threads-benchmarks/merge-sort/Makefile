TARGET = merge_sort

LIBS = -pthread merge_sort_mt.c

# Compilation with gcc
CC = gcc
CFLAGS =
LDFLAGS =

# Compilation with musl-gcc
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-gcc
MUSL_FLAGS =-Wl,-rpath,$(MUSL)/x86_64-linux-musl/lib

# Compilation with wasi-sdk/clang
WASI_SDK ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads -D_WASI_EMULATED_PROCESS_CLOCKS
WASI_LDFLAGS = -Wl,--import-memory,--export-memory,--max-memory=4294901760 -lwasi-emulated-process-clocks




.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(MUSL_FLAGS) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@ $(TARGET).c



THREADS ?= 8	# In this case the input is the depth of the algorithm, not the threads
INPUT = 50000000 $(THREADS)

WASMTIME ?= /home/julen/.wasmtime/bin/wasmtime
IWASM ?= /usr/local/bin/iwasm
WASMER ?= /home/julen/.wasmer/bin/wasmer


run: $(TARGET)
	./$(TARGET) $(INPUT)

runmusl: $(TARGET).musl
	./$(TARGET).musl $(INPUT)	

runwasmtime: $(TARGET).wasm
	$(WASMTIME) -S threads $(TARGET).wasm $(INPUT)
	
runiwasm: $(TARGET).wasm
	$(IWASM) --max-threads=64 $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm
	$(WASMER) $(TARGET).wasm $(INPUT)
	
	

PARAMS_MULTITIME ?= -q -n 10

multitime: $(TARGET)
	multitime $(PARAMS_MULTITIME) ./$(TARGET) $(INPUT)

multitime_musl: $(TARGET).musl
	multitime $(PARAMS_MULTITIME) ./$(TARGET).musl $(INPUT)	

multitime_wasmtime: $(TARGET).wasm	
	multitime $(PARAMS_MULTITIME) $(WASMTIME) -S threads $(TARGET).wasm $(INPUT)

multitime_iwasm: $(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(IWASM) --max-threads=64 $(TARGET).wasm $(INPUT)

multitime_wasmer: $(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(WASMER) $(TARGET).wasm $(INPUT)
	
	

clean:
	find . -name $(TARGET) -delete
	find . -name $(TARGET).musl -delete
	find . -name '*.wasm' -delete
	find . -name '*.time' -delete
