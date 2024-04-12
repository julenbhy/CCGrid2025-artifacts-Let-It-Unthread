TARGET = ParallelGrep

LIBS = -pthread

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

all: $(TARGET) $(TARGET).musl $(TARGET).wasm 1GB_input_file.xml

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(MUSL_FLAGS) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET).wasm: $(TARGET).c
	$(WASI_CC) $(WASI_CFLAGS) $(WASI_LDFLAGS) $(LIBS) -o $@ $(TARGET).c


enwiki-latest-abstract.xml:
	wget https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-abstract.xml.gz
	gunzip enwiki-latest-abstract.xml.gz


1GB_input_file.xml: enwiki-latest-abstract.xml
	head -c 1024M enwiki-latest-abstract.xml > $@

	


INPUT ?= "deep learning" 1GB_input_file.xml

WASMTIME ?= /home/julen/.wasmtime/bin/wasmtime
IWASM ?= /usr/local/bin/iwasm
WASMER ?= /home/julen/.wasmer/bin/wasmer


run: $(TARGET) 1GB_input_file.xml
	./$(TARGET) $(INPUT)

runmusl: $(TARGET).musl 1GB_input_file.xml
	./$(TARGET).musl $(INPUT)

runwasmtime: $(TARGET).wasm 1GB_input_file.xml
	$(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)

runiwasm: $(TARGET).wasm 1GB_input_file.xml
	$(IWASM) --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm 1GB_input_file.xml
	$(WASMER) --dir=. $(TARGET).wasm $(INPUT)
	
	

PARAMS_MULTITIME ?= -q -n 3

multitime: $(TARGET) 1GB_input_file.xml
	multitime $(PARAMS_MULTITIME) ./$(TARGET) $(INPUT)

multitime_musl: $(TARGET).musl 1GB_input_file.xml
	multitime $(PARAMS_MULTITIME) ./$(TARGET).musl $(INPUT)

multitime_wasmtime: $(TARGET).wasm 1GB_input_file.xml
	multitime $(PARAMS_MULTITIME) $(WASMTIME) --dir=. -S threads $(TARGET).wasm $(INPUT)

multitime_iwasm: $(TARGET).wasm 1GB_input_file.xml	
	multitime $(PARAMS_MULTITIME) $(IWASM) --dir=. --max-threads=64 $(TARGET).wasm $(INPUT)

multitime_wasmer: $(TARGET).wasm 1GB_input_file.xml
	multitime $(PARAMS_MULTITIME) $(WASMER) --dir=. $(TARGET).wasm $(INPUT)
	
	
clean:
	rm -f $(TARGET) $(TARGET).musl *.wasm
