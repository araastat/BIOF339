SUBDIRS := $(wildcard week*)
OUTDIR=docs


homework: $(SUBDIRS) ## Compile homework slides
$(SUBDIRS):
	cp make_subdirs $@/Makefile; $(MAKE) -C $@


all: homework

.PHONY: $(SUBDIRS) FORCE

.PHONY: dirs
dirs:
	@echo $(SUBDIRS)

FORCE:

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)
