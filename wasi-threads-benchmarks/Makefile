
# List of benchmarks
SUBDIRS = blackscholes parallel-gzip fluidanimate merge_sort swaptions ParallelGrep parallel-mat-mul
#SUBDIRS = blackscholes fluidanimate merge-sort swaptions parallel-grep parallel-mat-mul

#call the makefile in the create directory
all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: $(SUBDIRS)

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
