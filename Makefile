
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

slideweb : docs/slides_top/index.html

docs/slides_top/index.html : slides/index.Rmd $(rmdfiles)
	cd slides; Rscript -e "rmarkdown::render_site('index.Rmd')"

buildclass: lectures slideweb

