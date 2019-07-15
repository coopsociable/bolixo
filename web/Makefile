DINSTRUMENT:=$(shell test -f ../../instrument && echo -DINSTRUMENT)
OPTIONS=$(DINSTRUMENT) -funsigned-char -O2 -Wall -g -DVERSION=\"$(PACKAGE_REV)\" -I/usr/include/tlmp -I/usr/include/trlitool
all: webtabs.os util.os document.os document_fr.os index.os bolixoapi.os webapi.os public.os journey.os bolixo.os  \
	config.os mail.os projects.os index.hc webapi.hc public.hc journey.hc bolixoapi.hc bolixo.hc
.suffixes: .hcc .hc 
FLAGS=-Wall -Wno-unused-function

index.hc: index.os /usr/lib64/trlitool/trlitool.pic.a util.os webtabs.os document.os document_fr.os \
	config.os mail.os projects.os ../proto/webapi.protoh ../proto/bolixoapi.protoh \
	/usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p
	@echo $@
	@g++ $(OPTIONS) -g -shared -Wl,-soname,test.so.1 -o \
		$@ $< ../_dict.os /usr/lib64/trlitool/trlitool.pic.a util.os webtabs.os document.os document_fr.os \
		config.os mail.os projects.os /usr/lib/tlmp/lib/tlmpdoc.so /usr/lib/tlmp/lib/tlmpwebsql.so -lcrypto

%.hc: %.os /usr/lib64/trlitool/trlitool.pic.a util.os webtabs.os document.os document_fr.os \
	../proto/webapi.protoh ../proto/bolixoapi.protoh \
	/usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p
	@echo $@
	@g++ $(OPTIONS) -g -shared -Wl,-soname,test.so.1 -o \
		$@ $< ../_dict.os /usr/lib64/trlitool/trlitool.pic.a util.os document.os document_fr.os \
		/usr/lib/tlmp/lib/tlmpdoc.so /usr/lib/tlmp/lib/tlmpwebsql.so -lcrypto

%.os: %.hcc /usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p \
	 /usr/include/tlmp/tlmpdoc.h /usr/include/tlmp/tlmpdoc.p
	@echo tlmpwebcc $< $@
	@tlmpwebcc $< \
		| tlcc \
		--name $(basename $(notdir $@)).tlcc - /tmp/$(basename $(notdir $@)).cc
	@g++ $(OPTIONS) -DEXPORT= -fPIC $(FLAGS) -I. -I/usr/include/tlmp -I/usr/include/trlitool \
		-c /tmp/$(basename $(notdir $@)).cc  -o $@

webapi.os: webapi.hcc ../proto/webapi.protoh
bolixoapi.os: bolixoapi.hcc ../proto/bolixoapi.protoh ../proto/bolixod_client.protoh
bolixo.os: bolixo.hcc ../proto/bolixod_client.protoh

install: all
	@cp images-doc/*.jpg *.jpg *.png *.svg *.hc *.html robots.txt favicon.ico $(RPM_BUILD_ROOT)/var/www/html/.
	@cp tlmplibs $(RPM_BUILD_ROOT)/var/www/html/.tlmplibs
	@cp conditions-d-utilisation.html  terms-of-use.html $(RPM_BUILD_ROOT)/var/www/html/.


clean:
	rm -f *.hc *.o *.os genbackground

util.os: util.hcc util.h /usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p
	@echo tlmpwebcc $< $@
	@tlmpwebcc $< \
		| tlcc \
		--name $(basename $(notdir $@)).tlcc - /tmp/$(basename $(notdir $@)).cc
	@g++ -fPIC -Wall -DEXPORT= $(OPTIONS) -I. -c /tmp/util.cc -o util.os

webtabs.os: webtabs.tlcc webtabs.h util.h /usr/include/tlmp/tlmpweb.h /usr/include/tlmp/tlmpweb.p
	cctlcc -fPIC -Wall $(OPTIONS) -c webtabs.tlcc -o webtabs.os

../proto/webapi.protoh: ../proto/webapi.proto ../proto/bod_client.proto
	cd .. && \
	build-protocol --request_obj REQUEST_JSON --request_info_obj REQUEST_JSON_INFO \
		--connect_info_obj CONNECT_HTTP_INFO --name webapi \
		--protoch proto/webapi.protoch proto/webapi.proto >proto/webapi.protoh

private.png: private.scad Makefile
	openscad --imgsize 20,20 -oprivate.png --colorscheme=Nature --camera=0,0,50,0,0,0 private.scad
	convert private.png -fuzz 20% -transparent white private.png 

new.png: new.scad Makefile
	openscad --imgsize 20,20 -onew.png -Dview=\"new\" --colorscheme=Nature --camera=0,0,50,0,0,0 new.scad
	convert new.png -fuzz 20% -transparent white new.png 
	openscad --imgsize 20,20 -oback.png -Dview=\"back\" --colorscheme=Nature --camera=0,0,50,0,0,0 new.scad
	convert back.png -fuzz 20% -transparent white back.png 
	openscad --imgsize 20,20 -omodified.png -Dview=\"modified\" --colorscheme=Nature --camera=0,0,50,0,0,0 new.scad
	convert modified.png -fuzz 20% -transparent white modified.png 
	openscad --imgsize 20,20 -oseen.png -Dview=\"seen\" --colorscheme=Nature --camera=0,0,50,0,0,0 new.scad
	convert seen.png -fuzz 20% -transparent white seen.png 

bolixo.png: bolixo.scad Makefile
	openscad --imgsize 200,40 -obolixo.png -Dview=\"bolixo\" --colorscheme=Nature --camera=70,20,110,70,20,0 bolixo.scad
	convert bolixo.png -fuzz 20% -transparent white bolixo.png 

favicon.jpg: bolixo.scad Makefile
	openscad --imgsize 40,40 -ofavicon.png -Dview=\"favicon\" --colorscheme=Nature --camera=35,20,160,35,20,0 bolixo.scad
	convert favicon.png -fuzz 20% -transparent white favicon.jpg 

admin.jpg: admin.scad Makefile
	openscad --imgsize 40,40 -oadmin.png -Dview=\"gear\" --colorscheme=Nature --camera=0,0,60,0,0,0 admin.scad
	convert admin.png admin.jpg
	rm -f admin.png

admin-photo.jpg: admin.scad Makefile
	openscad --imgsize 100,100 -oadmin-photo.png -Dview=\"juggler\" --colorscheme=Nature --camera=20,20,100,20,20,0 admin.scad
	convert admin-photo.png admin-photo.jpg
	rm -f admin-photo.png

dev-photo.jpg: admin.scad Makefile
	openscad --imgsize 100,100 -odev-photo.png -Dview=\"dev\" --colorscheme=Nature --camera=5,10,120,5,10,0 admin.scad
	convert dev-photo.png dev-photo.jpg
	rm -f dev-photo.png

news-photo.jpg: admin.scad Makefile
	openscad --imgsize 100,100 -onews-photo.png -Dview=\"news\" --colorscheme=Nature --camera=5,5,60,5,5,0 admin.scad
	convert news-photo.png news-photo.jpg
	rm -f news-photo.png

no-mini-photo.jpg: no-mini-photo.scad Makefile
	openscad --imgsize 40,40 -ono-mini-photo.png --colorscheme=Nature --camera=0,0,400,0,0,0 no-mini-photo.scad
	convert no-mini-photo.png no-mini-photo.jpg
	rm -f no-mini-photo.png

no-photo.jpg:
	convert -font helvetica -size 100x100 xc:white \
		-stroke black -fill lightgray -draw "roundrectangle 5,5 95,95 10,10" \
		-pointsize 50 -stroke black -fill lightblue no-photo.jpg
	#-draw "text 35,65 ?" /tmp/photo.jpg


genbackground: genbackground.tlcc
	cctlcc -Wall genbackground.tlcc -o genbackground -lstdc++

background: genbackground
	cp background.scad /tmp
	./genbackground a >/tmp/test.scad
	openscad --autocenter --imgsize 2048,2048 -obackground.png --colorscheme=Nature --camera=125,125,600,125,125,0 /tmp/test.scad
	convert background.png -fuzz 20% -transparent white background.png
