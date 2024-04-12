TARGET = main

LIBS = -pthread

# Compilation with gcc
CC ?= /usr/bin/gcc
CFLAGS =
LDFLAGS = -I..

MUSL ?= /opt/x86_64-linux-musl-cross
MUSL_CC = $(MUSL)/bin/x86_64-linux-musl-gcc

# Compilation with wasi-sdk/clang
WASI_SDK ?= /opt/wasi-sdk
WASI_CC = $(WASI_SDK)/bin/clang
WASI_CFLAGS = --target=wasm32-wasi-threads
WASI_LDFLAGS = -I.. -Wl,--import-memory,--export-memory,--max-memory=4294901760




.PHONY: all clean

all: $(TARGET) $(TARGET).musl $(TARGET).wasm

$(TARGET).musl: $(TARGET).c
	$(MUSL_CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) -o $@ $(TARGET).c

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
	$(IWASM) --max-threads=100  $(TARGET).wasm $(INPUT)
	
runwasmer: $(TARGET).wasm
	$(WASMER) $(TARGET).wasm $(INPUT)






# In order to make perf work:
#	sudo apt-get install linux-tools-6.5.0-14-generic linux-cloud-tools-6.5.0-14-generic	
#	sudo apt-get install linux-tools-generic linux-cloud-tools-generic
#	sudo sysctl -w kernel.perf_event_paranoid=-1
#	echo 0 | sudo tee /proc/sys/kernel/kptr_restrict

VMLINUX = --vmlinux /sys/kernel/btf/vmlinux

disassembly:$(TARGET).wasm
	
	$(CC) --static $(CFLAGS) $(LDFLAGS) $(LIBS) -o $(TARGET).glibc $(TARGET).c
	objdump --disassemble=___pthread_mutex_lock $(TARGET).glibc > ___pthread_mutex_lock.GLIBC.s
	objdump --disassemble=___pthread_mutex_unlock $(TARGET).glibc > ___pthread_mutex_unlock.GLIBC.s
	
	musl-gcc --static $(CFLAGS) $(LDFLAGS) $(LIBS) -o $(TARGET).musl $(TARGET).c
	objdump --disassemble=__pthread_mutex_lock $(TARGET).musl > __pthread_mutex_lock.MUSL.s
	objdump --disassemble=__pthread_mutex_unlock $(TARGET).musl > __pthread_mutex_unlock.MUSL.s
	
	perf record -k mono $(WASMTIME) -S threads --profile=jitdump $(TARGET).wasm
	perf inject --jit --input perf.data --output perf.jit.data
	#perf annotate $(VMLINUX) --input perf.jit.data
	perf annotate $(VMLINUX) --input perf.jit.data -s __pthread_mutex_lock --stdio > __pthread_mutex_lock.WASM.s
	perf annotate $(VMLINUX) --input perf.jit.data -s __pthread_mutex_unlock --stdio > __pthread_mutex_unlock.WASM.s
	rm *so perf.data perf.jit.data *.dump $(TARGET).glibc $(TARGET).musl $(TARGET).wasm 





	
PARAMS_STRACE=-f
strace: $(TARGET) $(TARGET).musl $(TARGET).wasm
	# run c
	strace $(PARAMS_STRACE) ./$(TARGET) $(INPUT) 2>&1 | sed '1,2d' > glibc.strace;

	# run c with musl
	strace $(PARAMS_STRACE) ./$(TARGET).musl $(INPUT) 2>&1 | sed '1,2d' > musl.strace;
	
	# run wasm compiler and runtime combinations
	strace $(PARAMS_STRACE) $(WASMTIME) -S threads $(TARGET).wasm 2>&1 | sed '1,2d' > wasm.strace;


clean:
	find . -name $(TARGET) -delete
	find . -name $(TARGET).musl -delete
	find . -name '*.wasm' -delete
	find . -name '*.strace' -delete
