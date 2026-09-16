main=main
summaryf=summary
compile=latexmk -lualatex -silent -use-make
PYTHON = python3

DOCKER_IMAGE = cv-texlive
GIT_ROOT = $(shell git rev-parse --show-toplevel)
GIT_SUBDIR = $(shell git rev-parse --show-prefix)
DOCKER_RUN = docker run --rm -v "$(GIT_ROOT)":/workdir -w /workdir/$(GIT_SUBDIR) $(DOCKER_IMAGE)
DOCKER_COMPILE = $(DOCKER_RUN) latexmk -lualatex -silent -use-make

RM_AUX = rm -f *.aux *.log *.dvi *.blg *.bbl* \
          *.fls *.fdb_latexmk *.out     \
          *.brf *.snm *.toc *.nav       \
	  *.dat *.lua *.table *.loa *.table \
	  *.script \
	  *.pdfsync *synctex.gz

all:
	$(PYTHON) preprocess.py
	${compile} ${main}
	@echo "Done ....!"

pdf:
	${compile} ${main}

bib:
	${compile} ${main}

docker-build:
	docker build -t $(DOCKER_IMAGE) .

# Native-vs-container builds leave .fls/.fdb_latexmk files with absolute
# paths baked in from whichever TeX Live install produced them. Purge those
# first so latexmk doesn't try to resolve paths from the wrong environment.
docker: docker-build
	$(RM_AUX)
	$(DOCKER_RUN) python3 preprocess.py
	${DOCKER_COMPILE} ${main}
	@echo "Done (docker) ....!"

docker-clean:
	$(RM_AUX)
	@echo "Cleaned (docker) ....!"

clean:
	# -c tells latexmk to remove all temporary/auxiliary files automatically
	latexmk -c ${main}
	rm -f *.aux *.log *.dvi *.blg *.bbl* \
          *.fls *.fdb_latexmk *.out     \
          *.brf *.snm *.toc *.nav       \
	  *.dat *.lua *.table *.loa *.table \
	  *.script \
		  *.pdfsync *synctex.gz 
	@echo "Cleaned ....!"

cleanpdf:
	# -C tells latexmk to remove all generated PDFs as well
	latexmk -C ${main}
	@echo "Cleaned pdfs!"
