OUTDIR = $(shell Rscript -e "fs::path(here::here('docs', fs::path_rel(getwd(), start=here::here())))")
SLIDES := $(wildcard *.Rmd)
SLIDES_OUT = $(patsubst %.Rmd, $(OUTDIR)/%.html, $(SLIDES))

.PHONY: all
all: $(SLIDES_OUT)

$(OUTDIR)/%.html: %.Rmd _output.yml
	Rscript -e "rmarkdown::render('$(*F).Rmd', output_yaml = '_output.yml')"
	rm -rf $(OUTDIR)/$(*F)_files
	mv $(*F).html $(OUTDIR)
	mv -f $(*F)_files $(OUTDIR)

.PHONY: files
files: 
	@echo $(OUTDIR)
	@echo $(SLIDES_OUT)
	@echo $(SLIDES)

.PHONY: clean clean_cache
clean:
	@rm -rf $(SLIDES_OUT)
clean_cache:
	@rm -rf *cache
