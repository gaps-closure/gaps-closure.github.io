PANDOC ?= pandoc
DOCS != find docs/C -name '*.md' | sort 
TITLE = docs/C/title.txt 
BIB = docs/C/bibliography.bib
CSL= docs/C/bibliography.csl 
FLAGS = --number-sections \
 		--toc --toc-depth=2 \
		--standalone \
		--wrap=auto \
		--citeproc \
		--bibliography=$(BIB) \
		--csl=$(CSL) \
		--pdf-engine=xelatex
SOURCES = $(TITLE) $(DOCS)

cdocs: cdoc.pdf cdoc.html 

cdoc.pdf: $(SOURCES)
	$(PANDOC) $(FLAGS) -o cdoc.pdf $(SOURCES)

cdoc.html: $(SOURCES) 
	$(PANDOC) $(FLAGS) --self-contained --template=toc-sidebar.html -B nav -o cdoc.html $(SOURCES)

.PHONY: install-cdoc
install-cdoc: cdocs
	cp cdoc.pdf cdoc.html $(INSTALL_PREFIX)

.PHONY: clean-cdoc
clean-cdoc:
	rm -rf cdoc.pdf cdoc.html
