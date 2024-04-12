TARGET = fluidanimate

LIBS = -pthread pthreads.cpp cellpool.cpp parsec_barrier.cpp

# Compilation with gcc
CC = g++
CFLAGS = -g -funroll-loops -fprefetch-loop-arrays -fpermissive -fno-exceptions -static-libgcc -DPARSEC_VERSION=3.0-beta-20150206  -Wno-invalid-offsetof -DENABLE_THREADS -D_GNU_SOURCE -D__XOPEN_SOURCE=600
LDFLAGS = -lstdc++ -L/usr/lib64 -L/usr/lib

# Compilation with musl-gcc
MUSL ?= /opt/x86_64-linux-musl-cross
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-g++
MUSL_FLAGS =-Wl,-rpath,$(MUSL)/x86_64-linux-musl/lib


# Compilation with wasi-sdk/clang
WASI_SDK_20 ?= /opt/wasi-sdk-20.0
WASI_CC = $(WASI_SDK_20)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads
WASI_CFLAGS += -g -funroll-loops -fpermissive -fno-exceptions -DPARSEC_VERSION=3.0-beta-20150206  -Wno-invalid-offsetof -DENABLE_THREADS -D_GNU_SOURCE -D__XOPEN_SOURCE=600
WASI_LDFLAGS = -Wl,--import-memory,--export-memory,--max-memory=4294901760 -lwasi-emulated-process-clocks
WASI_LDFLAGS += -lstdc++ -L/usr/lib64 -L/usr/lib 
# -lstdc++ to avoid undefined references



.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm 

$(TARGET):
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@

$(TARGET).musl:
	$(MUSL_CC) $(MUSL_FLAGS) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@

$(TARGET).wasm:
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@


inputs/in_300K.fluid:
	tar -xvf inputs/input_simlarge.tar -C inputs

inputs/in_100K.fluid:
	tar -xvf inputs/input_simmedium.tar -C inputs

inputs/in_35K.fluid: inputs/input_simsmall.tar
	tar -xvf inputs/input_simsmall.tar -C inputs/




# threadnum framenum input output
THREADS ?= 16
SIZE = inputs/in_35K.fluid
INPUT = $(THREADS) 500 $(SIZE) out.fluid
# Small: in_35K.fluid		Medium: in_100K.fluid		Large: in_300K.fluid
# Must descompress the input files first

WASMTIME ?= /home/julen/.wasmtime/bin/wasmtime
IWASM ?= /usr/local/bin/iwasm
WASMER ?= /home/julen/.wasmer/bin/wasmer


run: $(TARGET) $(SIZE)
	./$(TARGET) $(INPUT)

runmusl: $(TARGET).musl $(SIZE)
	./$(TARGET).musl $(INPUT)

runwasmtime: $(TARGET).wasm $(SIZE)
	$(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)
	
runiwasm: $(TARGET).wasm $(SIZE)
	$(IWASM) --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm $(SIZE)
	$(WASMER) --dir=. $(TARGET).wasm $(INPUT)



PARAMS_MULTITIME ?= -q -n 3

multitime: $(TARGET) $(SIZE)
	multitime $(PARAMS_MULTITIME) ./$(TARGET) $(INPUT)

multitime_musl: $(TARGET).musl $(SIZE)
	multitime $(PARAMS_MULTITIME) ./$(TARGET).musl $(INPUT)

multitime_wasmtime: $(TARGET).wasm $(SIZE)
	multitime $(PARAMS_MULTITIME) $(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)

multitime_iwasm: $(TARGET).wasm $(SIZE)
	multitime $(PARAMS_MULTITIME) $(IWASM) --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)

multitime_wasmer: $(TARGET).wasm $(SIZE)
	multitime $(PARAMS_MULTITIME) $(WASMER) --dir=. $(TARGET).wasm $(INPUT)



clean:
	find . -name $(TARGET) -delete
	find . -name $(TARGET).musl -delete
	find . -name '*.wasm' -delete
	find . -name '*.time' -delete
	find . -name '*.txt' -delete
	find . -name '*.fluid' -delete
