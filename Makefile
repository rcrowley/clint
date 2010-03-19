all:
	@true
 
deb:
	debra create debian control
	mkdir -p debian/usr/local/lib/site_ruby/
	cp lib/clint.rb debian/usr/local/lib/site_ruby/
	mkdir -p debian/usr/local/share/man/man7
	cp man/man7/clint.7.gz debian/usr/local/share/man/man7/
	debra build debian clint_0.1.5-1_all.deb
	debra destroy debian
