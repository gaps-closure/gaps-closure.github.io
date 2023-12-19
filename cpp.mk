PANDOC ?= pandoc
DOCS != find docs/cpp -name '*.md' | sort 
TITLE = docs/cpp/title.txt 
BIB = docs/cpp/bibliography.bib
CSL= docs/cpp/bibliography.csl 
FLAGS = --number-sections \
		--resource-path docs/cpp \
 		--toc --toc-depth=2 \
		--standalone \
		--wrap=auto \
		--citeproc \
		--bibliography=$(BIB) \
		--csl=$(CSL) \
		--pdf-engine=xelatex
SOURCES = $(TITLE) $(DOCS)

cppdocs: cppdoc.pdf cppdoc.html 

cppdoc.pdf: $(SOURCES)
	$(PANDOC) $(FLAGS) -o cppdoc.pdf $(SOURCES)

cppdoc.html: $(SOURCES) 
	$(PANDOC) $(FLAGS) --self-contained --template=toc-sidebar.html -B nav -o cppdoc.html $(SOURCES)

.PHONY: install-cppdoc
install-cppdoc: cppdocs
	cp cppdoc.pdf cppdoc.html $(INSTALL_PREFIX)

.PHONY: clean-cppdoc
clean-cppdoc:
	rm -rf cppdoc.pdf cppdoc.html
