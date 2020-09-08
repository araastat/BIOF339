
rmdfiles=$(wildcard slides/lectures/*.Rmd)
htmlfiles=$(patsubst %.Rmd, docs/%.html, $(rmdfiles))
slidewebfiles=$(wildcard slides/*.Rmd)
toplevel=$(wildcard *.Rmd)
toplevelweb=$(patsubst %.Rmd, docs/%.html, $(toplevel))

.PHONY : variables
variables:
	@echo toplevel: $(toplevel)

buildtop : $(toplevelweb)
docs/%.html: %.Rmd _site.yml
		Rscript -e "rmarkdown::render_site('.')"

lectures : $(htmlfiles)

docs/slides/lectures/%.html: slides/lectures/%.Rmd
	Rscript -e "setwd(here::here('slides/lectures')); rmarkdown::render('$(<F)', output_dir = here::here('docs/slides/lectures'))"

slideweb : docs/slides/index.html

docs/slides/index.html : slides/index.Rmd $(rmdfiles)
	Rscript -e "setwd('slides');rmarkdown::render_site('index.Rmd')"

buildclass: lectures slideweb
