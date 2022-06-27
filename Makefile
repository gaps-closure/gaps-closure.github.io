PANDOC ?= pandoc
DOCS != find docs -name '*.md' | sort 
TITLE = docs/title.txt 
BIB = docs/bibliography.yaml
FLAGS = --standalone --wrap=auto --citeproc --bibliography=$(BIB)
SOURCES = $(TITLE) $(DOCS) 

all: doc.pdf doc.html 

doc.pdf: $(SOURCES)
	$(PANDOC) $(FLAGS) -o doc.pdf $(SOURCES)

doc.html: $(SOURCES) 
	$(PANDOC) $(FLAGS) -o doc.html $(SOURCES)

.PHONY: clean
clean:
	rm -rf doc.pdf doc.html