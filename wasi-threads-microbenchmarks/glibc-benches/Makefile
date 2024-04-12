TARGET ?= bench-pthread-mutex-lock

LIBS = -pthread -lm 

FILES = $(TARGET).c support/json-lib.c support/support_test_main.c support/ignore_stderr.c support/check.c support/support_record_failure.c support/write_message.c 

# Compilation with gcc
CC ?= gcc
CFLAGS = -I ./sysdeps/generic  -I ./include -include ./include/libc-symbols.h -I . -DDURATION=1
LDFLAGS =

# Compilation with musl-gcc
MUSL ?= /opt/x86_64-linux-musl-cross
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-gcc

# Compilation with wasi-sdk/clang
WASI_SDK ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_MMAN
WASI_CFLAGS += -I ./sysdeps/generic  -I ./include -include ./include/libc-symbols.h -I . -DDURATION=1
WASI_LDFLAGS = -Wl,--import-memory,--export-memory,--max-memory=4294901760 -lwasi-emulated-process-clocks -lwasi-emulated-signal -lwasi-emulated-mman



.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm



$(TARGET): $(TARGET).c
	mkdir -p build
	$(CC) $(FILES) $(CFLAGS) $(LDFLAGS) $(LIBS) -o build/$@

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(FILES) $(CFLAGS) $(LDFLAGS) $(LIBS) -o build/$@

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(FILES) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o build/$@




INPUT = 

WASMTIME ?= /home/julen/.wasmtime/bin/wasmtime
IWASM ?= /usr/local/bin/iwasm
WASMER ?= /home/julen/.wasmer/bin/wasmer


run: build/$(TARGET)
	./build/$(TARGET) $(INPUT)

runmusl: build/$(TARGET).musl
	./build/$(TARGET).musl $(INPUT)

runwasmtime: build/$(TARGET).wasm
	$(WASMTIME) -S threads build/$(TARGET).wasm $(INPUT)
	
runiwasm: build/$(TARGET).wasm
	$(IWASM) --max-threads=64 build/$(TARGET).wasm $(INPUT)
	
runwasmer: build/$(TARGET).wasm
	$(WASMER) build/$(TARGET).wasm $(INPUT)
	
	

PARAMS_MULTITIME ?= -q -n 3

multitime: build/$(TARGET)
	multitime $(PARAMS_MULTITIME) ./$(TARGET) $(INPUT)

multitime_musl: build/$(TARGET).musl
	multitime $(PARAMS_MULTITIME) ./$(TARGET).musl $(INPUT)

multitime_wasmtime: build/$(TARGET).wasm	
	multitime $(PARAMS_MULTITIME) $(WASMTIME) -S threads build/$(TARGET).wasm $(INPUT)

multitime_iwasm: build/$(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(IWASM) --max-threads=64 build/$(TARGET).wasm $(INPUT)

multitime_wasmer: build/$(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(WASMER) build/$(TARGET).wasm $(INPUT)
	
	

clean:
	rm -rf build
