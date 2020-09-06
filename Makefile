
rmdfiles=$(wildcard slides/lectures/*.Rmd)
htmlfiles=$(patsubst %.Rmd, docs/%.html, $(rmdfiles))

.PHONY : variables
variables:
	@echo htmlfiles: $(htmlfiles)

lectures : $(htmlfiles)

docs/slides/lectures/%.html: slides/lectures/%.Rmd
	Rscript -e "setwd(here::here('slides/lectures')); rmarkdown::render('$(<F)', output_dir = here::here('docs/slides/lectures'))"
