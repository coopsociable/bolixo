OPTIONS=-funsigned-char -O2 -Wall -g -DVERSION=\"$(PACKAGE_REV)\" -I/usr/include/tlmp -I/usr/include/trlitool
all: util.os document.os document_fr.os index.os bolixoapi.os webapi.os public.os journey.os bolixo.os  \
	index.hc webapi.hc public.hc journey.hc bolixoapi.hc bolixo.hc
.suffixes: .hcc .hc
FLAGS=-Wall -Wno-unused-function

%.hc: %.os /usr/lib64/trlitool/trlitool.pic.a util.os document.os document_fr.os \
	../proto/webapi.protoh ../proto/bolixoapi.protoh \
	/usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p
	@echo $@
	@g++ -g -shared -Wl,-soname,test.so.1 -o \
		$@ $< ../_dict.os /usr/lib64/trlitool/trlitool.pic.a util.os document.os document_fr.os \
		/usr/lib/tlmp/lib/tlmpdoc.so /usr/lib/tlmp/lib/tlmpwebsql.so -lcrypto

%.os: %.hcc /usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p \
	 /usr/include/tlmp/tlmpdoc.h /usr/include/tlmp/tlmpdoc.p
	@echo tlmpwebcc $< $@
	@tlmpwebcc $< \
		| tlcc \
		--name $(basename $(notdir $@)).tlcc - /tmp/$(basename $(notdir $@)).cc
	@g++ -DEXPORT= -fPIC $(FLAGS) -I. -I/usr/include/tlmp -I/usr/include/linuxconf -I/usr/include/trlitool \
		-c /tmp/$(basename $(notdir $@)).cc  -o $@

webapi.os: webapi.hcc ../proto/webapi.protoh
bolixoapi.os: bolixoapi.hcc ../proto/bolixoapi.protoh ../proto/bolixod_client.protoh
bolixo.os: bolixo.hcc ../proto/bolixod_client.protoh

install: all
	@cp *.png *.hc *.html robots.txt favicon.ico $(RPM_BUILD_ROOT)/var/www/html/.
	@cp tlmplibs $(RPM_BUILD_ROOT)/var/www/html/.tlmplibs

clean:
	rm -f *.hc *.o

util.os: util.tlcc util.h /usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p
	cctlcc -fPIC -Wall $(OPTIONS) -c util.tlcc -o util.os

../proto/webapi.protoh: ../proto/webapi.proto ../proto/bod_client.proto
	cd .. && \
	build-protocol --request_obj REQUEST_JSON --request_info_obj REQUEST_JSON_INFO \
		--connect_info_obj CONNECT_HTTP_INFO --name webapi \
		--protoch proto/webapi.protoch proto/webapi.proto >proto/webapi.protoh

private.png: private.scad
	openscad --imgsize 20,20 -oprivate.png --camera=0,0,50,0,0,0 private.scad

