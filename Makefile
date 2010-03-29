VERSION=$(shell grep Version control | awk '{print $$2}')

all:
	@true
 
deb:
ifeq (root, $(shell whoami))
	debra create debian control
	mkdir -p debian/usr/local/lib/site_ruby/
	cp lib/clint.rb debian/usr/local/lib/site_ruby/
	mkdir -p debian/usr/local/share/man/man7
	cp man/man7/clint.7.gz debian/usr/local/share/man/man7/
	chown -R root:root debian
	debra build debian clint_$(VERSION)_all.deb
	debra destroy debian
else
	@echo "You must be root to build a Debian package."
endif
