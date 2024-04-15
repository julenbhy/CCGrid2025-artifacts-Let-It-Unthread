TARGET = main

LIBS =

# Compilation with gcc
CC = gcc
CFLAGS =
LDFLAGS =


# Compilation with musl-gcc
MUSL ?= /opt/x86_64-linux-musl-cross
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-gcc
MUSL_FLAGS =-Wl,-rpath,$(MUSL)/x86_64-linux-musl/lib


# Compilation with wasi-sdk/clang
WASI_SDK_DIR ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK_DIR)/bin/clang
WASI_CFLAGS =
WASI_LDFLAGS =


.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(MUSL_FLAGS) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@ $(TARGET).c



WASMTIME ?= /opt/wasmtime-v16.0.0-x86_64-linux/wasmtime

INPUT ?=
run: $(TARGET)
	./$(TARGET) $(INPUT)

runmusl: $(TARGET).musl
	./$(TARGET).musl $(INPUT)

runwasmtime: $(TARGET).wasm
	$(WASMTIME) $(TARGET).wasm $(INPUT)
	
clean:
	find . -name $(TARGET) -delete
	find . -name '*.musl' -delete
	find . -name '*.wasm' -delete