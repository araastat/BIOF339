
rmdfiles=$(wildcard slides/lectures/*.Rmd)
htmlfiles=$(patsubst %.Rmd, docs/%.html, $(rmdfiles))
slidewebfiles=$(wildcard slides/*.Rmd)
toplevel=$(wildcard *.Rmd)
toplevelweb=$(patsubst %.Rmd, docs/%.html, $(toplevel))
canvasfiles=$(wildcard forCanvas/*.Rmd)
canvasweb=$(patsubst %.Rmd, docs/%.html, $(canvasfiles))
w1files=$(wildcard slides/lectures/week1/*.Rmd)
w1filesweb = $(patsubst %.Rmd, docs/%.html, $(w1files)1)

.PHONY : variables
variables:
	@echo htmlfiles: $(htmlfiles)
	@echo slidewebfiles: $(slidewebfiles)
	@echo canvasweb: $(canvasweb)
	@echo w1files: $(w1files)	

.PHONY : lectures
lectures : $(htmlfiles)

docs/slides/lectures/%.html : slides/lectures/%.Rmd
	Rscript -e "setwd(here::here('slides/lectures')); rmarkdown::render('$(<F)', output_dir = here::here('docs/slides/lectures'))"


.PHONY : w1
w1 : $(w1files)
docs/slides/lectures/week1/%.html : slides/lectures/week1/%.Rmd
		Rscript -e "setwd(here::here('slides/lectures/week1')); rmarkdown::render('$(<F)', output_dir=here::here('docs/slides/lectures/week1'))"
	

slideweb : docs/slides/index.html


docs/slides/index.html: slides/index.Rmd $(rmdfiles)
	cd slides; Rscript -e "rmarkdown::render_site('.')"
	cp -r docs/slides_top/* docs/slides

forcanvas : $(canvasweb)

docs/forCanvas/%.html: forCanvas/%.Rmd
		Rscript -e "setwd(here::here('forCanvas')); rmarkdown::render('$(<F)', output_dir = here::here('docs/forCanvas'))"

topbuild : $(toplevelweb)

docs/%.html: ./%.Rmd _site.yml
	Rscript -e "rmarkdown::render_site('.')"
	cp -r docs/toplevel/* docs
	
	
buildclass: lectures slideweb

