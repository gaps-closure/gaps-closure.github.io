include c.mk 
include java.mk

all: cdocs jdocs 

.PHONY: install
install: install-cdoc install-jdoc

.PHONY: clean
clean: clean-cdoc clean-jdoc