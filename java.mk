PANDOC ?= pandoc
DOCS := $(shell find docs/Java -name '*.md' | sort)
TITLE = docs/Java/title.txt 
BIB = docs/Java/bibliography.bib
CSL= docs/Java/bibliography.csl 
FLAGS = --from=markdown+lists_without_preceding_blankline \
		--number-sections \
		--resource-path docs/Java \
 		--toc --toc-depth=2 \
		--standalone \
		--wrap=auto \
		--citeproc \
		--bibliography=$(BIB) \
		--csl=$(CSL) \
		--pdf-engine=xelatex
SOURCES = $(TITLE) $(DOCS)

jdocs: jdoc.pdf jdoc.html 

jdoc.pdf: $(SOURCES)
	$(PANDOC) $(FLAGS) -o jdoc.pdf $(SOURCES)

jdoc.html: $(SOURCES) 
	$(PANDOC) $(FLAGS) --self-contained --template=toc-sidebar.html -B nav -o jdoc.html $(SOURCES)

.PHONY: install-jdoc
install-jdoc: jdocs
	cp jdoc.pdf jdoc.html $(INSTALL_PREFIX)

.PHONY: clean-jdoc
clean-jdoc:
	rm -rf jdoc.pdf jdoc.html
