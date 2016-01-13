DESTDIR :=

prefix := /usr/local
bindir := $(prefix)/bin

all:
	@echo "Nothing to build. make install to install"
.PHONY: all

install:
	install -m 755 ansible-vault-merge.sh $(DESTDIR)$(bindir)/ansible-vault-merge
	install -m 755 gpg-vault-password-file.sh $(DESTDIR)$(bindir)/gpg-vault-password-file
.PHONY: install

uninstall:
	rm -f $(DESTDIR)$(bindir)/ansible-vault-merge
	rm -f $(DESTDIR)$(bindir)/gpg-vault-password-file
.PHONY: uninstall
