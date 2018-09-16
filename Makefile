CURDIR=trli
MANPAGES=/usr/share/man
PACKAGE_REV:=$(shell ./makeversion $(BUILD_SVNVER))
PROGS=_dict.o bod bod-client bod-control bo-writed bo-writed-control bo-sessiond bo-sessiond-control \
      bo-manager bofs ssltestsign bo-keysd bo-keysd-control
#bo-log bo-log-control \
#      bo-mon bo-mon-control
DOCS=
OPTIONS=-funsigned-char -O2 -Wall -g -DVERSION=\"$(PACKAGE_REV)\" -I/usr/include/tlmp -I/usr/include/trlitool
LIBS=/usr/lib64/trlitool/trlitool.a -llinuxconf -lstdc++ -lcrypto
TLMP_LIB=/usr/lib/tlmp
LDEVEL=/usr/lib/linuxconf-devel
.SUFFIXES: .o .tex .tlcc .cc .png .uml
all: $(PROGS) msg.eng msg.fr
	make -Cweb install

msg:
	$(LDEVEL)/msgscan bolixo \
		bolixo.dic bolixo.m EF *.cc *.tlcc web/*.tlcc web/*.hcc

compile: $(PROGS)
	#make -Cweb 

bofs: bofs.tlcc proto/bod_client.protoh proto/webapi.protoh filesystem.h _dict.o
	cctlcc -Wall $(OPTIONS) bofs.tlcc _dict.o -o bofs $(LIBS) -lssl

_dict.o: _dict.cc bolixo.m
	gcc -Wall -c _dict.cc -o _dict.o
	gcc -Wall -fPIC -c _dict.cc -o _dict.os

bod: bod.tlcc filesystem.o proto/bod_control.protoh proto/bod_client.protoh proto/bod_admin.protoh \
	proto/bo-writed_client.protoh proto/bo-sessiond_client.protoh
	cctlcc -Wall $(OPTIONS) bod.tlcc filesystem.o _dict.o -o bod $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bod-client: bod-client.tlcc proto/bod_client.protoh proto/bod_admin.protoh \
	proto/bo-sessiond_admin.protoh
	cctlcc -Wall $(OPTIONS) bod-client.tlcc -o bod-client $(LIBS)

bod-control: bod-control.tlcc proto/bod_control.protoh
	cctlcc -Wall $(OPTIONS) bod-control.tlcc _dict.o -o bod-control $(LIBS)

bo-writed: bo-writed.tlcc filesystem.o proto/bo-writed_control.protoh proto/bo-writed_client.protoh \
	proto/bo-sessiond_admin.protoh proto/bo-log.protoh proto/bo-keysd_control.protoh
	cctlcc -Wall $(OPTIONS) bo-writed.tlcc filesystem.o _dict.o -o bo-writed $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-writed-control: bo-writed-control.tlcc
	cctlcc -Wall $(OPTIONS) bo-writed-control.tlcc _dict.o -o bo-writed-control $(LIBS)

bo-sessiond: bo-sessiond.tlcc proto/bo-sessiond_control.protoh \
       	proto/bo-sessiond_client.protoh proto/bo-sessiond_admin.protoh proto/session_log.protoh
	cctlcc -Wall $(OPTIONS) bo-sessiond.tlcc -o bo-sessiond $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-sessiond-control: bo-sessiond-control.tlcc proto/bo-sessiond_control.protoh
	cctlcc -Wall $(OPTIONS) bo-sessiond-control.tlcc -o bo-sessiond-control $(LIBS)

bo-log: trli-log.tlcc proto/trli-log.protoh proto/trli-log-control.protoh proto/trli-log-admin.protoh
	cctlcc -Wall $(OPTIONS) trli-log.tlcc -o trli-log $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-log-control: trli-log-control.tlcc proto/trli-log-control.protoh
	cctlcc -Wall $(OPTIONS) trli-log-control.tlcc -o trli-log-control $(LIBS) 

bo-manager: bo-manager.tlcc
	cctlcc -Wall $(OPTIONS) bo-manager.tlcc /usr/lib64/trlitool/manager.o -o bo-manager $(LIBS)

bo-mon: bo-mon.tlcc proto/bod_client.protoh proto/bo_mon_control.protoh \
		proto/trli_syslog_control.protoh proto/trli_stop_control.protoh
	cctlcc -Wall $(OPTIONS) bo-mon.tlcc -o bo-mon $(LIBS)

bo-mon-control: bo-mon-control.tlcc proto/bo_mon_control.protoh
	cctlcc -Wall $(OPTIONS) bo-mon-control.tlcc -o bo-mon-control $(LIBS)

bo-keysd: bo-keysd.tlcc proto/bo-keysd_control.protoh
	cctlcc -Wall $(OPTIONS) bo-keysd.tlcc -o bo-keysd $(LIBS) -lcrypto -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-keysd-control: bo-keysd-control.tlcc proto/bo-keysd_control.protoh
	cctlcc -Wall $(OPTIONS) bo-keysd-control.tlcc -o bo-keysd-control $(LIBS)

proto/bo-log-control.protoh: proto/bo-log-control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bo_log_control \
	       --protoch proto/bo-log-control.protoch proto/bo-log-control.proto >proto/bo-log-control.protoh

proto/bo-log-admin.protoh: proto/bo-log-admin.proto
	build-protocol --secretmode --arg "int no" --arg "HANDLE_INFO *c" --name bo_log_admin \
	       --protoch proto/bo-log-admin.protoch proto/bo-log-admin.proto >proto/bo-log-admin.protoh

proto/bo_mon_control.protoh: proto/bo_mon_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bo_mon_control \
	       --protoch proto/bo_mon_control.protoch proto/bo_mon_control.proto >proto/bo_mon_control.protoh

proto/bod_control.protoh: proto/bod_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bod_control \
	       --protoch proto/bod_control.protoch proto/bod_control.proto >proto/bod_control.protoh

proto/bod_client.protoh: proto/bod_client.proto
	build-protocol --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bod_client \
		--protodef proto/bod_client.protodef --protoch proto/bod_client.protoch proto/bod_client.proto >proto/bod_client.protoh
		

proto/bod_admin.protoh: proto/bod_admin.proto
	build-protocol --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bod_admin \
		--protoch proto/bod_admin.protoch proto/bod_admin.proto >proto/bod_admin.protoh

proto/bo-writed_control.protoh: proto/bo-writed_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_writed_control \
		--protoch proto/bo-writed_control.protoch proto/bo-writed_control.proto >proto/bo-writed_control.protoh

proto/bo-writed_client.protoh: proto/bo-writed_client.proto
	build-protocol --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_writed_client \
		--protoch proto/bo-writed_client.protoch proto/bo-writed_client.proto >proto/bo-writed_client.protoh

proto/bo-log.protoh: proto/bo-log.proto
	build-protocol --add_timestamp --file_mode --name bo_log \
		--protoch proto/bo-log.protoch proto/bo-log.proto >proto/bo-log.protoh

proto/session_log.protoh: proto/session_log.proto
	build-protocol --add_timestamp --file_mode --name session_log \
		--protoch proto/session_log.protoch proto/session_log.proto >proto/session_log.protoh

proto/bo-sessiond_control.protoh: proto/bo-sessiond_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_sessiond_control \
		--protoch proto/bo-sessiond_control.protoch proto/bo-sessiond_control.proto >proto/bo-sessiond_control.protoh

proto/bo-sessiond_client.protoh: proto/bo-sessiond_client.proto
	build-protocol --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_sessiond_client \
		--protoch proto/bo-sessiond_client.protoch proto/bo-sessiond_client.proto >proto/bo-sessiond_client.protoh

proto/bo-sessiond_admin.protoh: proto/bo-sessiond_admin.proto
	build-protocol --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_sessiond_admin \
		--protoch proto/bo-sessiond_admin.protoch proto/bo-sessiond_admin.proto >proto/bo-sessiond_admin.protoh

proto/bo-keysd_control.protoh: proto/bo-keysd_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bo_keysd_control \
		--protoch proto/bo-keysd_control.protoch proto/bo-keysd_control.proto >proto/bo-keysd_control.protoh

proto/webapi.protoh: proto/webapi.proto
	build-protocol --request_obj REQUEST_JSON --request_info_obj REQUEST_JSON_INFO \
		--connect_info_obj CONNECT_HTTP_INFO --name webapi \
		--protoch proto/webapi.protoch proto/webapi.proto >proto/webapi.protoh

ssltestsign: ssltestsign.tlcc
	cctlcc $(OPTIONS) ssltestsign.tlcc -o ssltestsign -lstdc++ -lcrypto
	
filesystem.o: filesystem.tlcc filesystem.h proto/bod_client.protoh
	cctlcc -Wall $(OPTIONS) -c filesystem.tlcc -o filesystem.o

clean:
	rm -f $(PROGS) *.o *.os proto/*.protoh proto/*.protoch proto/*.protodef web/*.hc web/*.os


install: msg.eng msg.fr
	mkdir -p $(RPM_BUILD_ROOT)/etc/bolixo
	mkdir -p $(RPM_BUILD_ROOT)/usr/sbin
	mkdir -p $(RPM_BUILD_ROOT)/usr/lib
	mkdir -p $(RPM_BUILD_ROOT)/var/www/html
	mkdir -p $(RPM_BUILD_ROOT)/var/log/bolixo
	mkdir -p $(RPM_BUILD_ROOT)/etc/init.d
	install -m755 bolixo-production.sh $(RPM_BUILD_ROOT)/usr/sbin/bolixo-production
	install -m755 test.sh $(RPM_BUILD_ROOT)/usr/lib/bolixo-test.sh
	install -m755 bod $(RPM_BUILD_ROOT)/usr/sbin/bod
	install -m755 bod-client $(RPM_BUILD_ROOT)/usr/sbin/bodd-client
	install -m755 bod-control $(RPM_BUILD_ROOT)/usr/sbin/bod-control
	install -m755 bo-writed $(RPM_BUILD_ROOT)/usr/sbin/bo-writed
	install -m755 bo-writed-control $(RPM_BUILD_ROOT)/usr/sbin/bo-writed-control
	install -m755 bo-sessiond $(RPM_BUILD_ROOT)/usr/sbin/bo-sessiond
	install -m755 bo-sessiond-control $(RPM_BUILD_ROOT)/usr/sbin/bo-sessiond-control
	install -m755 bolixo-manager $(RPM_BUILD_ROOT)/usr/sbin/bolixo-manager
	install -m755 bo-log $(RPM_BUILD_ROOT)/usr/sbin/bo-log
	install -m755 bo-log-control $(RPM_BUILD_ROOT)/usr/sbin/bo-log-control
	install -m755 bo-mon $(RPM_BUILD_ROOT)/usr/sbin/bo-mon
	install -m755 bo-mon-control $(RPM_BUILD_ROOT)/usr/sbin/bo-mon-control
	install -m755 web/index.hc $(RPM_BUILD_ROOT)/var/www/html/index.hc
	install -m755 web/admin.hc $(RPM_BUILD_ROOT)/var/www/html/admin.hc
	install -m644 web/favicon.ico $(RPM_BUILD_ROOT)/var/www/html/favicon.ico
	install -m644 web/about.html $(RPM_BUILD_ROOT)/var/www/html/about.html
	install -m644 web/robots.txt $(RPM_BUILD_ROOT)/var/www/html/robots.txt
	install -m644 web/7s.html $(RPM_BUILD_ROOT)/var/www/html/7s.html
	install -m644 web/twitter.png $(RPM_BUILD_ROOT)/var/www/html/twitter.png
	install -m644 data/http_check.conf $(RPM_BUILD_ROOT)/etc/trli/http_check.conf
	install -m755 bolixoserv.sysv $(RPM_BUILD_ROOT)/etc/init.d/bolixoserv

msg.eng:
	@mkdir -p $(TLMP_LIB)/help.eng
	@echo Producing $(TLMP_LIB)/help.eng/bolixo.eng
	@$(LDEVEL)/msgcomp -p./ $(TLMP_LIB)/help.eng/bolixo.eng eE bolixo

msg.fr:
	@mkdir -p $(TLMP_LIB)/help.fr
	@echo Producing $(TLMP_LIB)/help.fr/bolixo.fr
	@$(LDEVEL)/msgcomp -p./ -pmessages/fr/ $(TLMP_LIB)/help.fr/bolixo.fr TFeE bolixo

msgupd:
	$(LDEVEL)/msgupd -s./ -dmessages/fr/  -rE bolixo

msgclean:
	$(LDEVEL)/msgclean bolixo.dic


RPMTOPDIR=$(HOME)/rpmbuild
RPM=rpmbuild

buildspec:
	sed s/RPMREV/$(RPMREV)/ <$(CURDIR).spec \
		|  sed s/REV/$(PACKAGE_REV)/ \
		> $(RPMTOPDIR)/SPECS/$(CURDIR)-$(PACKAGE_REV).spec
	rm -fr /tmp/$(CURDIR)-$(PACKAGE_REV)
	mkdir /tmp/$(CURDIR)-$(PACKAGE_REV)
	cp -a * /tmp/$(CURDIR)-$(PACKAGE_REV)/.
	(cd /tmp/$(CURDIR)-$(PACKAGE_REV)/ && make clean && \
		cd .. && tar zcvf $(RPMTOPDIR)/SOURCES/$(CURDIR)-$(PACKAGE_REV).src.tar.gz $(CURDIR)-$(PACKAGE_REV))
	rm -fr /tmp/$(CURDIR)-$(PACKAGE_REV)


buildrpm: buildspec
	unset LD_PRELOAD; $(RPM) -ba $(RPMTOPDIR)/SPECS/$(CURDIR)-$(PACKAGE_REV).spec


REPO=http://svn.solucorp.qc.ca/repos/solucorp/lasuite
distrpm:
	@eval `svn cat $(REPO)/trunk/Makefile | grep ^PACKAGE_REV=` ; \
	$(MAKE) COPY="svn export --force $(REPO)/trunk/" \
	PACKAGE_REV="$${PACKAGE_REV}r`svn st -u Makefile | tail -1 | while read a b c d ; do echo $$d ; done`" \
	buildrpm

