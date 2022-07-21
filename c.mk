PANDOC ?= pandoc
DOCS != find docs/C -name '*.md' | sort 
TITLE = docs/C/title.txt 
BIB = docs/C/bibliography.yaml
FLAGS = --number-sections --toc --toc-depth=2 --standalone --wrap=auto --citeproc --bibliography=$(BIB)
SOURCES = $(TITLE) $(DOCS) 

cdocs: cdoc.pdf cdoc.html 

cdoc.pdf: $(SOURCES)
	$(PANDOC) $(FLAGS) -o cdoc.pdf $(SOURCES)

cdoc.html: $(SOURCES) 
	$(PANDOC) $(FLAGS) -o cdoc.html $(SOURCES)

.PHONY: clean
clean:
	rm -rf cdoc.pdf cdoc.html
