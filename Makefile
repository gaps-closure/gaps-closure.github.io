.PHONY: all
all: cdocs jdocs cppdocs

.PHONY: install
install: install-cdoc install-jdoc install-cppdoc

.PHONY: clean
clean: clean-cdoc clean-jdoc clean-cppdoc

c% install-c% clean-c%:
	make -f c.mk $@

j% install-j% clean-j%:
	make -f java.mk $@

cpp% install-cpp% clean-cpp%:
	make -f cpp.mk $@