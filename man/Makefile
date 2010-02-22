ron=/var/lib/gems/1.8/bin/ron
gzip=/bin/gzip

RON=$(wildcard *.md)
ROFF=$(RON:.md=)

all: clean $(ROFF)

clean:
	rm -f $(ROFF)

%.1 %.2 %.3 %.4 %.5 %.6 %.7 %.8:
ifneq (, $(ron))
	$(ron) -b $@.md
	chmod 644 $@
ifneq (, $(gzip))
	$(gzip) -f $@
endif
endif

.PHONY: all clean
