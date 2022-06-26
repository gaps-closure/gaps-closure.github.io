PANDOC ?= pandoc
DOCS != find docs -name '*.md' | sort 
TITLE = docs/title.txt 
FLAGS = --standalone --template evisogel.latex --wrap=auto 


doc.pdf: $(TITLE) $(DOCS)
	$(PANDOC) $(FLAGS) -o doc.pdf $(TITLE) $(DOCS) 

.PHONY: clean
clean:
	rm -rf doc.pdf