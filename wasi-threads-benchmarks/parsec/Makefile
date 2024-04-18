
# List of benchmarks
SUBDIRS = blackscholes fluidanimate swaptions

#call the makefile in the create directory
all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: $(SUBDIRS)

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
