OPTIONS=-funsigned-char -O2 -Wall -g -DVERSION=\"$(PACKAGE_REV)\" -I/usr/include/tlmp -I/usr/include/trlitool
all: util.os index.hc 
.suffixes: .hcc .hc
FLAGS=-Wall -Wno-unused-function

%.hc: %.hcc /usr/lib64/trlitool/trlitool.os util.os
	@echo tlmpwebcc $< $@
	@tlmpwebcc $< \
		| tlcc \
		--name $(basename $(notdir $@)).tlcc - /tmp/$(basename $(notdir $@)).cc
	@g++ -DEXPORT= -fPIC $(FLAGS) -I. -I/usr/include/tlmp -I/usr/include/linuxconf -I/usr/include/trlitool \
		-c /tmp/$(basename $(notdir $@)).cc  -o /tmp/test.o
	@g++ -g -shared -Wl,-soname,test.so.1 -o \
		$@ /tmp/test.o /usr/lib64/trlitool/trlitool.os util.os -lcrypto
	@rm -f /tmp/test.o

install: all
	cp *.png *.hc *.html robots.txt favicon.ico $(RPM_BUILD_ROOT)/var/www/html/.

clean:
	rm -f *.hc *.o

util.os: util.tlcc util.h
	cctlcc -fPIC -Wall $(OPTIONS) -c util.tlcc -o util.os


