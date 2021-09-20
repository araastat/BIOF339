OUTDIR = $(shell Rscript -e "cat(fs::path_rel(here::here('docs', fs::path_rel(getwd(), start=here::here())), getwd()))")
SLIDES := $(wildcard week*.Rmd)
SLIDES_OUT = $(patsubst %.Rmd, $(OUTDIR)/%.html, $(SLIDES))

.PHONY: all
all: $(SLIDES_OUT)

$(OUTDIR)/%.html: %.Rmd 
	Rscript -e "rmarkdown::render('$(*F).Rmd', output_dir = '$(OUTDIR)')"
	rm -rf $(OUTDIR)/$(*F)_files
#	mv $(*F).html $(OUTDIR)
#	mv -f $(*F)_files $(OUTDIR)

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
