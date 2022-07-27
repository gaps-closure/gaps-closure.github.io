all: cdocs jdocs  

.PHONY: install
install: install-cdoc install-jdoc 

.PHONY: clean
clean: clean-cdoc clean-jdoc 

c% install-c% clean-c%:
	make -f c.mk $@

j% install-j% clean-j%:
	make -f java.mk $@