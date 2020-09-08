
rmdfiles=$(wildcard slides/lectures/*.Rmd)
htmlfiles=$(patsubst %.Rmd, docs/%.html, $(rmdfiles))
slidewebfiles=$(wildcard slides/*.Rmd)
toplevel=$(wildcard *.Rmd)
toplevelweb=$(patsubst %.Rmd, docs/%.html, $(toplevel))
canvasfiles=$(wildcard forCanvas/*.Rmd)
canvasweb=$(patsubst %.Rmd, docs/%.html, $(canvasfiles))

.PHONY : variables
variables:
	@echo htmlfiles: $(htmlfiles)
	@echo slidewebfiles: $(slidewebfiles)
	@echo canvasweb: $(canvasweb)


lectures : $(htmlfiles)

docs/slides/lectures/%.html: slides/lectures/%.Rmd
	Rscript -e "setwd(here::here('slides/lectures')); rmarkdown::render('$(<F)', output_dir = here::here('docs/slides/lectures'))"

slideweb : docs/slides/index.html


docs/slides/index.html: slides/index.Rmd $(rmdfiles)
	cd slides; Rscript -e "rmarkdown::render_site('.')"
	cp -r docs/slides_top/* docs/slides

forcanvas : $(canvasweb)

docs/forCanvas/%.html: forCanvas/%.Rmd
		Rscript -e "setwd(here::here('forCanvas')); rmarkdown::render('$(<F)', output_dir = here::here('docs/forCanvas'))"

topbuild : $(toplevelweb)

docs/%.html: %.Rmd _site.yml
	Rscript -e "rmarkdown::render_site('.')"
	cp -r docs/toplevel/* docs
	
	
buildclass: lectures slideweb

