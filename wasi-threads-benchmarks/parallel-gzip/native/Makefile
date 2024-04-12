
all: build random.original.bin

build:
	mkdir src
	git clone https://github.com/madler/pigz src
	make -C src

random.original.bin:
	head -c 104857600 </dev/urandom >$@  # 100M


random.bin: random.original.bin
	@cp $< $@


NUM_THREADS ?= 8

benchmark: random.bin
	@rm -f random.bin.gz
	time ./src/pigz -p $(NUM_THREADS) ./random.bin -f
	@gzip --decompress --stdout random.bin.gz >/dev/null


run: random.bin
	./src/pigz -p $(NUM_THREADS) ./random.bin --force --keep


PARAMS_MULTITIME ?= -q -n 3

multitime: random.bin
	multitime $(PARAMS_MULTITIME) ./src/pigz -p $(NUM_THREADS) ./random.bin --force --keep
	
	
clean:
	rm -f random.*
	rm -rf src 
