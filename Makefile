include c.mk 

all: cdocs

.PHONY: install
install: install-cdoc

.PHONY: clean
clean: clean-cdoc