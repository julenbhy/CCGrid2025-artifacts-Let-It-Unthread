CC ?= /usr/bin/gcc
MUSL ?= /opt/x86_64-linux-musl-cross
WASI_SDK ?= /opt/wasi-sdk

# List of benchmarks
SUBDIRS = barrier create mutex mutexC schedint semaphore tsd tsd

export CC MUSL WASI_SDK

#call the makefile in the create directory
all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: $(SUBDIRS)

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	
