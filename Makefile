
rmdfiles=$(wildcard slides/lectures/*.Rmd)
htmlfiles=$(patsubst %.Rmd, docs/%.html, $(rmdfiles))
slidewebfiles=$(wildcard slides/*.Rmd)

.PHONY : variables
variables:
	@echo htmlfiles: $(htmlfiles)
	@echo slidewebfiles: $(slidewebfiles)

lectures : $(htmlfiles)

docs/slides/lectures/%.html: slides/lectures/%.Rmd
	Rscript -e "setwd(here::here('slides/lectures')); rmarkdown::render('$(<F)', output_dir = here::here('docs/slides/lectures'))"

slideweb : docs/slides/index.html

docs/slides/index.html : slides/index.Rmd $(htmlfiles)
	cd slides; Rscript -e "rmarkdown::render_site('index.Rmd')"

buildclass: lectures slideweb
