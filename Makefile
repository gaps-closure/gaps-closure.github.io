PANDOC ?= pandoc
DOCS != find docs -name '*.md' | sort 
TITLE = docs/title.txt 
CITATIONS = docs/citations.yaml
FLAGS = --standalone --wrap=auto --citeproc --bibliography=$(CITATIONS)
SOURCES = $(TITLE) $(DOCS) 

all: doc.pdf doc.html 

doc.pdf: $(SOURCES)
	$(PANDOC) $(FLAGS) -o doc.pdf $(SOURCES)

doc.html: $(SOURCES) 
	$(PANDOC) $(FLAGS) -o doc.html $(SOURCES)

.PHONY: clean
clean:
	rm -rf doc.pdf doc.html