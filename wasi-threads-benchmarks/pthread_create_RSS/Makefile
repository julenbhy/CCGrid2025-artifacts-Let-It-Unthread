TARGET = main

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
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@ $(TARGET).c



INPUT ?= 10

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
	$(IWASM) --max-threads=128  $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm
	$(WASMER) $(TARGET).wasm $(INPUT)
	
	

clean:
	find . -name $(TARGET) -delete
	find . -name $(TARGET).musl -delete
	find . -name '*.wasm' -delete
