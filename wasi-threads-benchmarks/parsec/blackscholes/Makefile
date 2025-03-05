TARGET = blackscholes

LIBS = -pthread

# Compilation with gcc
CC = g++
CFLAGS = -g -funroll-loops -fprefetch-loop-arrays -fpermissive -fno-exceptions -static-libgcc -DNCO=4 -DENABLE_THREADS
LDFLAGS = -L/usr/lib64 -L/usr/lib

# Compilation with musl-gcc
MUSL ?= /opt/x86_64-linux-musl-cross
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-g++
MUSL_FLAGS =-Wl,-rpath,$(MUSL)/x86_64-linux-musl/lib

# Compilation with wasi-sdk/clang
WASI_SDK ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads
WASI_CFLAGS += -g -funroll-loops -fpermissive -fno-exceptions -DNCO=4 -L/usr/lib64 -L/usr/lib -DENABLE_THREADS
WASI_LDFLAGS = -Wl,--import-memory,--export-memory,--max-memory=4294901760



.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm

$(TARGET): $(TARGET).m4.cpp
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).m4.cpp

$(TARGET).musl: $(TARGET).m4.cpp
	$(MUSL_CC) $(MUSL_FLAGS) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).m4.cpp

$(TARGET).wasm: $(TARGET).m4.cpp
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@ $(TARGET).m4.cpp
	
	
blackscholes.m4.cpp: $(TARGET).c c.m4.pthreads
	/usr/bin/m4 ./c.m4.pthreads blackscholes.c > blackscholes.m4.cpp


INPUT_SIZE = 160000
input.txt: inputgen
	./inputgen $(INPUT_SIZE) input.txt
	
inputgen: inputgen.c
	$(CC) -o $@ inputgen.c
	
	


THREADS = 8
INPUT ?= $(THREADS) input.txt output.txt

WASMTIME ?= /opt/wasmtime-v16.0.0-x86_64-linux/wasmtime
IWASM ?= /opt/iwasm-1.3.1/iwasm
WASMER ?= /opt/wasmer-4.2.3/bin/wasmer


run: $(TARGET) input.txt
	./$(TARGET) $(INPUT)

runmusl: $(TARGET).musl input.txt
	./$(TARGET).musl $(INPUT)

runwasmtime: $(TARGET).wasm input.txt
	$(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)

runiwasm: $(TARGET).wasm input.txt
	$(IWASM) --max-threads=64 --dir=. $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm input.txt
	$(WASMER) --dir=. $(TARGET).wasm $(INPUT)



PARAMS_MULTITIME ?= -q -n 3

multitime: $(TARGET) input.txt
	multitime $(PARAMS_MULTITIME) ./$(TARGET) $(INPUT)

multitime_musl: $(TARGET).musl input.txt
	multitime $(PARAMS_MULTITIME) ./$(TARGET).musl $(INPUT)

multitime_wasmtime: $(TARGET).wasm input.txt	
	multitime $(PARAMS_MULTITIME) $(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)

multitime_iwasm: $(TARGET).wasm	input.txt
	multitime $(PARAMS_MULTITIME) $(IWASM) --max-threads=64 --dir=. $(TARGET).wasm $(INPUT)
	
multitime_wasmer: $(TARGET).wasm input.txt
	multitime $(PARAMS_MULTITIME) $(WASMER) --dir=. $(TARGET).wasm $(INPUT)

	
clean:
	find . -name $(TARGET) -delete
	find . -name $(TARGET).musl -delete
	find . -name 'inputgen' -delete
	find . -name 'input.txt' -delete
	find . -name 'output.txt' -delete
	find . -name '*.wasm' -delete
	find . -name '*.time' -delete
	find . -name '*m4.cpp' -delete
