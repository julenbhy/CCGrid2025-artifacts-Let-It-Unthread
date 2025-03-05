TARGET = swaptions

LIBS = -pthread nr_routines.cpp CumNormalInv.cpp MaxFunction.cpp RanUnif.cpp  icdf.cpp \
	HJM_SimPath_Forward_Blocking.cpp HJM.cpp HJM_Swaption_Blocking.cpp  \
	HJM_Securities.cpp

# Compilation with gcc
CC = g++
CFLAGS = -g -funroll-loops -fprefetch-loop-arrays -fpermissive -fno-exceptions -static-libgcc -DPARSEC_VERSION=3.0-beta-20150206 -DENABLE_THREADS
LDFLAGS = -L/usr/lib64 -L/usr/lib

# Compilation with musl-gcc
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-g++
MUSL_FLAGS =-Wl,-rpath,$(MUSL)/x86_64-linux-musl/lib

# Compilation with wasi-sdk/clang
WASI_SDK ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads -D_WASI_EMULATED_PROCESS_CLOCKS
WASI_CFLAGS += -g -funroll-loops -fpermissive -fno-exceptions -DPARSEC_VERSION=3.0-beta-20150206 -DENABLE_THREADS
WASI_LDFLAGS = -Wl,--import-memory,--export-memory,--max-memory=4294901760 -lwasi-emulated-process-clocks
WASI_LDFLAGS += -L/usr/lib64 -L/usr/lib


.PHONY: all clean

all: $(TARGET) $(TARGET).wasm $(TARGET).musl

$(TARGET):
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@

$(TARGET).musl:
	$(MUSL_CC) $(MUSL_FLAGS) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@

$(TARGET).wasm:
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@




THREADS = 8
INPUT ?= -ns 64 -sm 40000 -nt $(THREADS)	# Simlarge values in parsec

WASMTIME ?= /opt/wasmtime-v16.0.0-x86_64-linux/wasmtime
IWASM ?= /opt/iwasm-1.3.1/iwasm
WASMER ?= /opt/wasmer-4.2.3/bin/wasmer




run: $(TARGET)
	./$(TARGET) $(INPUT)

runmusl: $(TARGET).musl
	./$(TARGET).musl $(INPUT)

runwasmtime: $(TARGET).wasm
	$(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)
	
runiwasm: $(TARGET).wasm
	$(IWASM) --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm
	$(WASMER) --dir=. $(TARGET).wasm -- $(INPUT)
		


PARAMS_MULTITIME ?= -qq -n 3

multitime: $(TARGET)
	multitime $(PARAMS_MULTITIME) ./$(TARGET) $(INPUT)

multitime_musl: $(TARGET).musl
	multitime $(PARAMS_MULTITIME) ./$(TARGET).musl $(INPUT)

multitime_wasmtime: $(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)

multitime_iwasm: $(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(IWASM) --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)

multitime_wasmer: $(TARGET).wasm
	multitime $(PARAMS_MULTITIME) $(WASMER) --dir=. $(TARGET).wasm -- $(INPUT)


	
clean:
	find . -name $(TARGET) -delete
	find . -name '*.musl' -delete
	find . -name '*.wasm' -delete
	find . -name '*.time' -delete
	find . -name '*.txt' -delete
