SUBDIRS := $(wildcard slides/lectures/week*)
HWDIRS := $(wildcard assignments/HW/week*)
OUTDIR=docs


lectures: $(SUBDIRS) ## Compile lecture slides
$(SUBDIRS):
	cp make_subdirs $@/Makefile; $(MAKE) -C $@

homework: FORCE
	cd assignments/HW; $(MAKE) -C . ; cd ../..

slides_web: FORCE ## Create website for slides
	Rscript -e "rmarkdown::render_site('slides')"
	cp -r docs/slides_top/* docs/slides

hw_web: FORCE
	Rscript -e "rmarkdown::render_site('assignments')"
	cp -r docs/hw_top* docs/assignments

toplevel: FORCE ## Create top level website
	Rscript -e "rmarkdown::render_site('.')"
	cp -r docs/toplevel/* docs

all: lectures homework slides_web hw_web toplevel

.PHONY: $(SUBDIRS) FORCE
.PHONY: $(HWDIRS) FORCE

.PHONY: dirs
dirs:
	@echo $(SUBDIRS)

FORCE:

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST
