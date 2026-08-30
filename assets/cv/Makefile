main=main
summaryf=summary
compile=latexmk -lualatex -silent -use-make
PYTHON = python3

all:
	$(PYTHON) preprocess.py
	${compile} ${main}
	@echo "Done ....!"

pdf:
	${compile} ${main}

bib:
	${compile} ${main}

clean:
	# -c tells latexmk to remove all temporary/auxiliary files automatically
	latexmk -c ${main}
	rm -f *.aux *.log *.dvi *.blg *.bbl \
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
