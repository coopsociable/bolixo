CURDIR=bolixo
MANPAGES=/usr/share/man
PACKAGE_REV:=$(shell ./makeversion $(BUILD_SVNVER))
DINSTRUMENT:=$(shell test -f ../instrument && echo -DINSTRUMENT)
ifeq ($(DINSTRUMENT),-DINSTRUMENT)
	INSTRUMENT=--instrument --getnow fdpass_getnow
endif
PROGS=_dict.o bod bod-client bod-control bo-writed bo-writed-control bo-sessiond bo-sessiond-control \
      bo-manager bofs ssltestsign bo-keysd bo-keysd-control bolixod bolixod-control perfsql \
      bo-mon bo-mon-control utils/eximexec utils/helpspell publishd publishd-control bo-webtest \
      documentd documentd-control rssd rssd-control deleteitems utils/cacheurl utils/email-log \
      utils/show-notifies utils/business-card waitevent utils/bo-remote-manage utils/bolixo-update \
      utils/dnsrequest bo-websocket bo-websocket-control utils/logssl utils/bolixo-arch 

# bo-log bo-log-control \
DOCS=
OPTIONS=$(DINSTRUMENT) -funsigned-char -O2 -Wall -g -DVERSION=\"$(PACKAGE_REV)\" -I/usr/include/tlmp -I/usr/include/trlitool
LIBS=/usr/lib64/trlitool/trlitool.a -ltlmp -lstdc++ -lcrypto
FILESYSTEMO=filesystem.o fs_makeid.o
TLMP_LIB=$(RPM_BUILD_ROOT)/usr/lib/tlmp
LDEVEL=/usr/lib64/tlmp-devel
.SUFFIXES: .o .tex .tlcc .cc .png .uml
all: $(PROGS) msg.eng msg.fr
	make -Cweb install

msg:
	$(LDEVEL)/msgscan bolixo \
		bolixo.dic bolixo.m EF *.cc *.tlcc web/*.tlcc web/*.hcc utils/*.tlcc

compile: $(PROGS)
	make -Cweb 

bo-webtest: bo-webtest.tlcc proto/webapi.protoh /usr/include/trlitool/trlitool.h
	cctlcc -Wall $(OPTIONS) bo-webtest.tlcc _dict.o -o bo-webtest $(LIBS) -lssl

bofs: bofs.o verify.o bofs_vidconf.o json.o websocket-client.o fs_makeid.o /usr/include/trlitool/trlitool.h
	cctlcc -Wall $(OPTIONS) bofs.o verify.o bofs_vidconf.o json.o websocket-client.o fs_makeid.o _dict.o -o bofs $(LIBS) -lssl 

bofs.o: bofs.tlcc bofs.h proto/bod_client.protoh proto/webapi.protoh proto/bolixoapi.protoh proto/webapi.protoh
	cctlcc -Wall $(OPTIONS) -c bofs.tlcc -o bofs.o

bofs_vidconf.o: bofs_vidconf.tlcc json.h bofs.h websocket-client.h
	cctlcc -Wall $(OPTIONS) -c bofs_vidconf.tlcc -o bofs_vidconf.o

json.o: json.tlcc json.h
	cctlcc -Wall $(OPTIONS) -c json.tlcc -o json.o

_dict.o: _dict.cc bolixo.m
	gcc -Wall -c _dict.cc -o _dict.o
	gcc -Wall -fPIC -c _dict.cc -o _dict.os

bolixod: bolixod.tlcc proto/bolixod_control.protoh proto/bolixod_client.protoh $(FILESYSTEMO) verify.o
	cctlcc -Wall $(OPTIONS) bolixod.tlcc $(FILESYSTEMO) verify.o _dict.o -o bolixod $(LIBS) -lssl -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bolixod-control: bolixod-control.tlcc proto/bolixod_control.protoh
	cctlcc -Wall $(OPTIONS) bolixod-control.tlcc _dict.o -o bolixod-control $(LIBS) 

bod: bod.o $(FILESYSTEMO) websocket-client.o _dict.o verify.o
	cctlcc -Wall $(OPTIONS) bod.o $(FILESYSTEMO) websocket-client.o verify.o _dict.o -o bod $(LIBS) -lssl -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bod.o: bod.tlcc proto/bod_control.protoh proto/bod_client.protoh proto/bod_admin.protoh \
	proto/bo-writed_client.protoh proto/bo-sessiond_client.protoh proto/bolixod_client.protoh \
	proto/documentd_client.protoh proto/bolixoapi.protoh proto/webapi.protoh _dict.o 
	cctlcc -Wall $(OPTIONS) -c bod.tlcc -o bod.o

websocket-client.o: websocket-client.tlcc websocket-client.h proto/webapi.protoh
	cctlcc -Wall $(OPTIONS) -c websocket-client.tlcc -o websocket-client.o

testwebsock: testwebsock.tlcc websocket-client.o
	cctlcc -g -Wall $(OPTIONS) -I/usr/include/trlitool testwebsock.tlcc websocket-client.o -o /tmp/testwebsock $(LIBS) -lssl

bod-client: bod-client.tlcc proto/bod_client.protoh proto/bod_admin.protoh \
	proto/bo-sessiond_admin.protoh
	cctlcc -Wall $(OPTIONS) bod-client.tlcc -o bod-client $(LIBS)

waitevent: waitevent.tlcc proto/bo-sessiond_client.protoh
	cctlcc -Wall $(OPTIONS) waitevent.tlcc -o waitevent $(LIBS)

bod-control: bod-control.tlcc proto/bod_control.protoh
	cctlcc -Wall $(OPTIONS) bod-control.tlcc _dict.o -o bod-control $(LIBS)

bo-writed: bo-writed.tlcc $(FILESYSTEMO) proto/bo-writed_control.protoh proto/bo-writed_client.protoh \
	proto/bo-sessiond_admin.protoh proto/bo-log.protoh proto/bo-keysd_control.protoh \
	proto/publishd_client.protoh 
	cctlcc -Wall $(OPTIONS) bo-writed.tlcc $(FILESYSTEMO) verify.o _dict.o -o bo-writed $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-writed-control: bo-writed-control.tlcc proto/bo-writed_control.protoh
	cctlcc -Wall $(OPTIONS) bo-writed-control.tlcc _dict.o -o bo-writed-control $(LIBS)

bo-sessiond: bo-sessiond.tlcc proto/bo-sessiond_control.protoh \
       	proto/bo-sessiond_client.protoh proto/bo-sessiond_admin.protoh proto/session_log.protoh
	cctlcc -Wall $(OPTIONS) bo-sessiond.tlcc -o bo-sessiond $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-sessiond-control: bo-sessiond-control.tlcc proto/bo-sessiond_control.protoh
	cctlcc -Wall $(OPTIONS) bo-sessiond-control.tlcc _dict.o -o bo-sessiond-control $(LIBS)

bo-log: bo-log.tlcc proto/bo-log.protoh proto/bo-log-control.protoh proto/bo-log-admin.protoh
	cctlcc -Wall $(OPTIONS) trli-log.tlcc -o trli-log $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-log-control: trli-log-control.tlcc proto/bo-log-control.protoh
	cctlcc -Wall $(OPTIONS) bo-log-control.tlcc -o bo-log-control $(LIBS) 

bo-manager: bo-manager.tlcc /usr/include/trlitool/manager.h
	cctlcc -Wall $(OPTIONS) bo-manager.tlcc _dict.o /usr/lib64/trlitool/manager.o -o bo-manager $(LIBS)

bo-mon: bo-mon.tlcc proto/bod_client.protoh proto/bo-mon_control.protoh _dict.o /usr/lib64/trlitool/trlitool_mon.o \
	proto/bolixod_client.protoh proto/bo-keysd_control.protoh proto/bo-websocket_control.protoh
	cctlcc -Wall $(OPTIONS) bo-mon.tlcc _dict.o /usr/lib64/trlitool/trlitool_mon.o -o bo-mon $(LIBS)

bo-mon-control: bo-mon-control.tlcc proto/bo-mon_control.protoh _dict.o
	cctlcc -Wall $(OPTIONS) bo-mon-control.tlcc _dict.o -o bo-mon-control $(LIBS)

bo-keysd: bo-keysd.tlcc proto/bo-keysd_control.protoh
	cctlcc -Wall $(OPTIONS) bo-keysd.tlcc -o bo-keysd $(LIBS) -lcrypto -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

bo-keysd-control: bo-keysd-control.tlcc proto/bo-keysd_control.protoh
	cctlcc -Wall $(OPTIONS) bo-keysd-control.tlcc -o bo-keysd-control $(LIBS)

publishd: publishd.tlcc proto/publishd_control.protoh proto/publishd_client.protoh _dict.o $(FILESYSTEMO)
	cctlcc -Wall $(OPTIONS) publishd.tlcc _dict.o $(FILESYSTEMO) -o publishd $(LIBS) -lssl \
		-ltlmpsql -L/usr/lib64/mysql -lmysqlclient

publishd-control: publishd-control.tlcc proto/publishd_control.protoh
	cctlcc -Wall $(OPTIONS) publishd-control.tlcc -o publishd-control $(LIBS)

bo-websocket: bo-websocket.tlcc proto/bod_client.protoh proto/bo-sessiond_client.protoh fs_makeid.o _dict.o \
	proto/bo-websocket_control.protoh
	cctlcc -Wall $(OPTIONS) bo-websocket.tlcc fs_makeid.o _dict.o -o bo-websocket $(LIBS) 

bo-websocket-control: bo-websocket-control.tlcc proto/bo-websocket_control.protoh
	cctlcc -Wall $(OPTIONS) bo-websocket-control.tlcc -o bo-websocket-control $(LIBS)

perfsql: perfsql.tlcc
	cctlcc -Wall $(OPTIONS) perfsql.tlcc -o perfsql $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

utils/bolixo-arch: utils/bolixo-arch.tlcc
	cctlcc $(OPTIONS) utils/bolixo-arch.tlcc -o utils/bolixo-arch -lstdc++

# Generate the graph showing relation between various containers in Bolixo.
# Set DOCNAME="--document other_bolixo_document"
gen-bolixo-arch: utils/bolixo-arch
	utils/bolixo-arch --genscript ${DOCNAME} >/tmp/script.sh && sh /tmp/script.sh

utils/business-card: utils/business-card.tlcc
	cctlcc -Wall utils/business-card.tlcc -o utils/business-card -lstdc++

utils/eximexec: utils/eximexec.cc
	g++ -Wall utils/eximexec.cc -o utils/eximexec

utils/helpspell: utils/helpspell.tlcc
	cctlcc -Wall utils/helpspell.tlcc -o utils/helpspell -lstdc++

utils/cacheurl: utils/cacheurl.tlcc
	cctlcc $(OPTIONS) utils/cacheurl.tlcc -o utils/cacheurl -lstdc++

utils/email-log: utils/email-log.tlcc
	cctlcc $(OPTIONS) utils/email-log.tlcc -o utils/email-log -lstdc++

utils/show-notifies: utils/show-notifies.tlcc
	cctlcc $(OPTIONS) utils/show-notifies.tlcc -o utils/show-notifies -lstdc++

utils/bo-remote-manage: utils/bo-remote-manage.tlcc _dict.o
	cctlcc $(OPTIONS) utils/bo-remote-manage.tlcc _dict.o -o utils/bo-remote-manage -lstdc++

utils/bolixo-update: utils/bolixo-update.tlcc _dict.o
	cctlcc $(OPTIONS) utils/bolixo-update.tlcc _dict.o -o utils/bolixo-update -lstdc++

utils/dnsrequest: utils/dnsrequest.cc _dict.o
	g++ $(OPTIONS) utils/dnsrequest.cc -o utils/dnsrequest

utils/logssl: utils/logssl.tlcc
	cctlcc $(OPTIONS) utils/logssl.tlcc -o utils/logssl -lstdc++


proto/publishd_control.protoh: proto/publishd_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name publishd_control \
	       --protoch proto/publishd_control.protoch proto/publishd_control.proto >proto/publishd_control.protoh

proto/bo-websocket_control.protoh: proto/bo-websocket_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bo_websocket_control \
	       --protoch proto/bo-websocket_control.protoch proto/bo-websocket_control.proto >proto/bo-websocket_control.protoh

proto/publishd_client.protoh: proto/publishd_client.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --name publishd_client \
	       --protoch proto/publishd_client.protoch proto/publishd_client.proto >proto/publishd_client.protoh

proto/bo-log-control.protoh: proto/bo-log-control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bo_log_control \
	       --protoch proto/bo-log-control.protoch proto/bo-log-control.proto >proto/bo-log-control.protoh

proto/bo-log-admin.protoh: proto/bo-log-admin.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --name bo_log_admin \
	       --protoch proto/bo-log-admin.protoch proto/bo-log-admin.proto >proto/bo-log-admin.protoh

proto/bo-mon_control.protoh: proto/bo-mon_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bo_mon_control \
	       --protoch proto/bo-mon_control.protoch proto/bo-mon_control.proto >proto/bo-mon_control.protoh

proto/bolixod_control.protoh: proto/bolixod_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bolixod_control \
	       --protoch proto/bolixod_control.protoch proto/bolixod_control.proto >proto/bolixod_control.protoh

proto/bolixod_client.protoh: proto/bolixod_client.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --name bolixod_client \
		--protodef proto/bolixod_client.protodef --protoch proto/bolixod_client.protoch proto/bolixod_client.proto >proto/bolixod_client.protoh
		

proto/bod_control.protoh: proto/bod_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bod_control \
	       --protoch proto/bod_control.protoch proto/bod_control.proto >proto/bod_control.protoh

proto/bod_client.protoh: proto/bod_client.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bod_client \
		--protodef proto/bod_client.protodef --protoch proto/bod_client.protoch proto/bod_client.proto >proto/bod_client.protoh
		

proto/bod_admin.protoh: proto/bod_admin.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bod_admin \
		--protoch proto/bod_admin.protoch proto/bod_admin.proto >proto/bod_admin.protoh

proto/bo-writed_control.protoh: proto/bo-writed_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_writed_control \
		--protoch proto/bo-writed_control.protoch proto/bo-writed_control.proto >proto/bo-writed_control.protoh

proto/bo-writed_client.protoh: proto/bo-writed_client.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_writed_client \
		--protoch proto/bo-writed_client.protoch proto/bo-writed_client.proto >proto/bo-writed_client.protoh

proto/documentd_calc.protoh: proto/documentd_calc.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_calc \
		--protoch proto/documentd_calc.protoch proto/documentd_calc.proto >proto/documentd_calc.protoh

proto/documentd_whiteboard.protoh: proto/documentd_whiteboard.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_whiteboard \
		--protoch proto/documentd_whiteboard.protoch proto/documentd_whiteboard.proto >proto/documentd_whiteboard.protoh

proto/documentd_sudoku.protoh: proto/documentd_sudoku.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_sudoku \
		--protoch proto/documentd_sudoku.protoch proto/documentd_sudoku.proto >proto/documentd_sudoku.protoh

proto/documentd_checkers.protoh: proto/documentd_checkers.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_checkers \
		--protoch proto/documentd_checkers.protoch proto/documentd_checkers.proto >proto/documentd_checkers.protoh

proto/documentd_chess.protoh: proto/documentd_chess.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_chess \
		--protoch proto/documentd_chess.protoch proto/documentd_chess.proto >proto/documentd_chess.protoh

proto/documentd_photos.protoh: proto/documentd_photos.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_photos \
		--protoch proto/documentd_photos.protoch proto/documentd_photos.proto >proto/documentd_photos.protoh

proto/documentd_vidconf.protoh: proto/documentd_vidconf.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_vidconf \
		--protoch proto/documentd_vidconf.protoch proto/documentd_vidconf.proto >proto/documentd_vidconf.protoh

proto/documentd_wordproc.protoh: proto/documentd_wordproc.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_wordproc \
		--protoch proto/documentd_wordproc.protoch proto/documentd_wordproc.proto >proto/documentd_wordproc.protoh

proto/documentd_tictacto.protoh: proto/documentd_tictacto.proto
	build-protocol --file_mode --req_reader_type DOC_READER --req_writer_type DOC_WRITER --name documentd_tictacto \
		--protoch proto/documentd_tictacto.protoch proto/documentd_tictacto.proto >proto/documentd_tictacto.protoh

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
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_sessiond_client \
		--protoch proto/bo-sessiond_client.protoch proto/bo-sessiond_client.proto >proto/bo-sessiond_client.protoh

proto/bo-sessiond_admin.protoh: proto/bo-sessiond_admin.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --arg "const char *host" --name bo_sessiond_admin \
		--protoch proto/bo-sessiond_admin.protoch proto/bo-sessiond_admin.proto >proto/bo-sessiond_admin.protoh

proto/bo-keysd_control.protoh: proto/bo-keysd_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name bo_keysd_control \
		--protoch proto/bo-keysd_control.protoch proto/bo-keysd_control.proto >proto/bo-keysd_control.protoh

proto/webapi.protoh: proto/webapi.proto
	build-protocol $(INSTRUMENT) --argpath --request_obj REQUEST_JSON --request_info_obj REQUEST_JSON_INFO \
		--connect_info_obj CONNECT_HTTP_INFO --name webapi \
		--protoch proto/webapi.protoch proto/webapi.proto >proto/webapi.protoh

proto/bolixoapi.protoh: proto/bolixoapi.proto proto/bolixod_client.protoh
	build-protocol $(INSTRUMENT) --request_obj REQUEST_JSON --request_info_obj REQUEST_JSON_INFO \
		--connect_info_obj CONNECT_HTTP_INFO --name bolixoapi \
		--protoch proto/bolixoapi.protoch proto/bolixoapi.proto >proto/bolixoapi.protoh

DOCGAMES=doc_tictacto.o doc_sudoku.o doc_wordproc.o doc_checkers.o doc_chess.o doc_whiteboard.o doc_calc.o doc_calc_eval.o doc_photos.o doc_vidconf.o
documentd: documentd.o documentd_menu.o _dict.o fs_makeid.o ${DOCGAMES}
	cctlcc -Wall $(OPTIONS) documentd.o documentd_menu.o fs_makeid.o ${DOCGAMES} _dict.o -o documentd $(LIBS) -lfreetype -lm

documentd.o: documentd.tlcc documentd.h proto/documentd_control.protoh proto/documentd_client.protoh 
	cctlcc -Wall $(OPTIONS) `freetype-config --cflags` -c documentd.tlcc -o documentd.o

doc_checkers.o: doc_checkers.tlcc documentd.h proto/documentd_checkers.protoh
	cctlcc -Wall $(OPTIONS) -c doc_checkers.tlcc -o doc_checkers.o

doc_chess.o: doc_chess.tlcc documentd.h proto/documentd_chess.protoh
	cctlcc -Wall $(OPTIONS) -c doc_chess.tlcc -o doc_chess.o

doc_photos.o: doc_photos.tlcc documentd.h proto/documentd_photos.protoh
	cctlcc -Wall $(OPTIONS) -c doc_photos.tlcc -o doc_photos.o

doc_vidconf.o: doc_vidconf.tlcc documentd.h proto/documentd_vidconf.protoh
	cctlcc -Wall $(OPTIONS) -c doc_vidconf.tlcc -o doc_vidconf.o

doc_wordproc.o: doc_wordproc.tlcc documentd.h documentd_menu.h proto/documentd_wordproc.protoh
	cctlcc -Wall $(OPTIONS) -c doc_wordproc.tlcc -o doc_wordproc.o

doc_whiteboard.o: doc_whiteboard.tlcc documentd.h documentd_menu.h proto/documentd_whiteboard.protoh
	cctlcc -Wall $(OPTIONS) -c doc_whiteboard.tlcc -o doc_whiteboard.o

doc_calc.o: doc_calc.tlcc doc_calc.h documentd.h documentd_menu.h proto/documentd_calc.protoh
	cctlcc -Wall $(OPTIONS) -c doc_calc.tlcc -o doc_calc.o

doc_calc_eval.o: doc_calc_eval.tlcc doc_calc.h documentd.h
	cctlcc -Wall $(OPTIONS) -c doc_calc_eval.tlcc -o doc_calc_eval.o

documentd_menu.o: documentd_menu.tlcc documentd_menu.h
	cctlcc -Wall $(OPTIONS) -c documentd_menu.tlcc -o documentd_menu.o

doc_sudoku.o: doc_sudoku.tlcc documentd.h proto/documentd_sudoku.protoh
	cctlcc -Wall $(OPTIONS) -c doc_sudoku.tlcc -o doc_sudoku.o

doc_tictacto.o: doc_tictacto.tlcc documentd.h proto/documentd_tictacto.protoh
	cctlcc -Wall $(OPTIONS) -c doc_tictacto.tlcc -o doc_tictacto.o

documentd-control: documentd-control.tlcc proto/documentd_control.protoh _dict.o
	cctlcc -Wall $(OPTIONS) documentd-control.tlcc _dict.o -o documentd-control $(LIBS)

proto/documentd_control.protoh: proto/documentd_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name documentd_control \
		--protoch proto/documentd_control.protoch proto/documentd_control.proto >proto/documentd_control.protoh

proto/documentd_client.protoh: proto/documentd_client.proto
	build-protocol $(INSTRUMENT) --secretmode --arg "int no" --arg "HANDLE_INFO *c" --name documentd_client \
		--protoch proto/documentd_client.protoch proto/documentd_client.proto >proto/documentd_client.protoh

deleteitems: deleteitems.tlcc _dict.o
	cctlcc -Wall $(OPTIONS) deleteitems.tlcc _dict.o -o deleteitems $(LIBS) -ltlmpsql -L/usr/lib64/mysql -lmysqlclient

rssd: rssd.tlcc proto/rssd_control.protoh proto/bod_client.protoh _dict.o xmlflat.o
	cctlcc -Wall $(OPTIONS) -I/usr/include/libxml2 rssd.tlcc xmlflat.o _dict.o -o rssd $(LIBS) -lssl -lxml2

xmlflat.o: xmlflat.tlcc
	cctlcc -Wall $(OPTIONS) -I/usr/include/libxml2 -c xmlflat.tlcc -o xmlflat.o

rssd-control: rssd-control.tlcc proto/rssd_control.protoh _dict.o
	cctlcc -Wall $(OPTIONS) rssd-control.tlcc _dict.o -o rssd-control $(LIBS)

proto/rssd_control.protoh: proto/rssd_control.proto
	build-protocol --arg "int no" --arg "HANDLE_INFO *c" --name rssd_control \
		--protoch proto/rssd_control.protoch proto/rssd_control.proto >proto/rssd_control.protoh


ssltestsign: ssltestsign.tlcc
	cctlcc $(OPTIONS) $(OLDRSA) ssltestsign.tlcc -o ssltestsign -lstdc++ -lcrypto
	
fs_makeid.o: fs_makeid.tlcc filesystem.h
	cctlcc -Wall $(OPTIONS) -c fs_makeid.tlcc -o fs_makeid.o

filesystem.o: filesystem.tlcc filesystem.h proto/bod_client.protoh
	cctlcc -Wall $(OPTIONS) -c filesystem.tlcc -o filesystem.o

verify.o: verify.tlcc filesystem.h
	cctlcc -Wall $(OPTIONS) -c verify.tlcc -o verify.o

number5: number5.tlcc json.h json.o
	cctlcc -Wall $(OPTIONS) number5.tlcc json.o -o number5 -lstdc++

clean:
	rm -f $(PROGS) *.o *.os proto/*.protoh proto/*.protoch proto/*.protodef web/*.hc web/*.os web/genbackground \
		web/webapi.proto.hcc


install: msg.eng msg.fr
	mkdir -p $(RPM_BUILD_ROOT)/etc/bolixo
	mkdir -p $(RPM_BUILD_ROOT)/usr/sbin
	mkdir -p $(RPM_BUILD_ROOT)/usr/bin
	mkdir -p $(RPM_BUILD_ROOT)/usr/lib
	mkdir -p $(RPM_BUILD_ROOT)/var/www/html
	mkdir -p $(RPM_BUILD_ROOT)/var/log/bolixo
	mkdir -p $(RPM_BUILD_ROOT)/var/lib/bolixo
	mkdir -p $(RPM_BUILD_ROOT)/var/lib/bolixod
	mkdir -p $(RPM_BUILD_ROOT)/etc/init.d
	mkdir -p $(RPM_BUILD_ROOT)/usr/share/bolixo
	mkdir -p $(RPM_BUILD_ROOT)/usr/share/bolixo/greetings
	mkdir -p $(RPM_BUILD_ROOT)/etc/bash_completion.d
	mkdir -p $(RPM_BUILD_ROOT)/etc/cron.hourly
	install -m644 data/greetings/greetings.lst $(RPM_BUILD_ROOT)/etc/bolixo/greetings.lst
	install -m644 data/default_interests.lst $(RPM_BUILD_ROOT)/etc/bolixo/default_interests.lst
	install -m644 data/greetings/*.eng $(RPM_BUILD_ROOT)/usr/share/bolixo/greetings/.
	install -m644 data/greetings/*.fr $(RPM_BUILD_ROOT)/usr/share/bolixo/greetings/.
	install -m644 data/secrets.admin $(RPM_BUILD_ROOT)/usr/share/bolixo/secrets.admin
	install -m644 data/secrets.client $(RPM_BUILD_ROOT)/usr/share/bolixo/secrets.client
	install -m644 data/manager.conf.ref $(RPM_BUILD_ROOT)/usr/share/bolixo/manager.conf
	install -m644 data/bolixo.conf $(RPM_BUILD_ROOT)/usr/share/bolixo/bolixo.conf
	install -m644 data/bofs.conf $(RPM_BUILD_ROOT)/usr/share/bolixo/bofs.conf
	install -m644 README $(RPM_BUILD_ROOT)/usr/share/bolixo/README
	install -m644 COPYING $(RPM_BUILD_ROOT)/usr/share/bolixo/COPYING
	install -m644 scripts/whiteboard-help.sh $(RPM_BUILD_ROOT)/usr/share/bolixo/whiteboard-help.sh
	install -m644 scripts/calc-help.sh $(RPM_BUILD_ROOT)/usr/share/bolixo/calc-help.sh
	install -m644 scripts/word-help.sh $(RPM_BUILD_ROOT)/usr/share/bolixo/word-help.sh
	install -m644 scripts/photos-help.sh $(RPM_BUILD_ROOT)/usr/share/bolixo/photos-help.sh
	install -m755 bolixo-production.sh $(RPM_BUILD_ROOT)/usr/sbin/bolixo-production
	ln -s bolixo-production $(RPM_BUILD_ROOT)/usr/sbin/bo
	install -m755 bo-complete $(RPM_BUILD_ROOT)/usr/lib/bo-complete
	install -m644 bash_complete $(RPM_BUILD_ROOT)/etc/bash_completion.d/bolixo
	install -m755 test.sh $(RPM_BUILD_ROOT)/usr/lib/bolixo-test.sh
	install -m755 bo-webtest $(RPM_BUILD_ROOT)/usr/sbin/bo-webtest
	install -m755 bod $(RPM_BUILD_ROOT)/usr/sbin/bod
	install -m755 bod-client $(RPM_BUILD_ROOT)/usr/sbin/bod-client
	install -m755 bod-control $(RPM_BUILD_ROOT)/usr/sbin/bod-control
	install -m755 bo-writed $(RPM_BUILD_ROOT)/usr/sbin/bo-writed
	install -m755 bo-writed-control $(RPM_BUILD_ROOT)/usr/sbin/bo-writed-control
	install -m755 bo-sessiond $(RPM_BUILD_ROOT)/usr/sbin/bo-sessiond
	install -m755 bo-sessiond-control $(RPM_BUILD_ROOT)/usr/sbin/bo-sessiond-control
	install -m755 bo-manager $(RPM_BUILD_ROOT)/usr/sbin/bo-manager
	install -m644 web/tlmplibs $(RPM_BUILD_ROOT)/var/www/html/.tlmplibs
	install -m755 web/index.hc $(RPM_BUILD_ROOT)/var/www/html/index.hc
	install -m755 web/public.hc $(RPM_BUILD_ROOT)/var/www/html/public.hc
	install -m755 web/bolixo.hc $(RPM_BUILD_ROOT)/var/www/html/bolixo.hc
	install -m755 web/webapi.hc $(RPM_BUILD_ROOT)/var/www/html/webapi.hc
	install -m755 web/bolixoapi.hc $(RPM_BUILD_ROOT)/var/www/html/bolixoapi.hc
	install -m644 web/favicon.ico $(RPM_BUILD_ROOT)/var/www/html/favicon.ico
	install -m644 web/favicon.jpg $(RPM_BUILD_ROOT)/var/www/html/favicon.jpg
	install -m644 web/icon.png $(RPM_BUILD_ROOT)/var/www/html/icon.png
	install -m644 web/dev-photo.jpg $(RPM_BUILD_ROOT)/var/www/html/dev-photo.jpg
	install -m644 web/news-photo.jpg $(RPM_BUILD_ROOT)/var/www/html/news-photo.jpg
	install -m644 web/about.html $(RPM_BUILD_ROOT)/var/www/html/about.html
	install -m644 web/robots.txt $(RPM_BUILD_ROOT)/var/www/html/robots.txt
	install -m644 web/private.png $(RPM_BUILD_ROOT)/var/www/html/private.png
	install -m644 web/zip.png $(RPM_BUILD_ROOT)/var/www/html/zip.png
	install -m644 web/pdf.png $(RPM_BUILD_ROOT)/var/www/html/pdf.png
	install -m644 web/new.png $(RPM_BUILD_ROOT)/var/www/html/new.png
	install -m644 web/modified.png $(RPM_BUILD_ROOT)/var/www/html/modified.png
	install -m644 web/seen.png $(RPM_BUILD_ROOT)/var/www/html/seen.png
	install -m644 web/back.png $(RPM_BUILD_ROOT)/var/www/html/back.png
	install -m644 web/bolixo.png $(RPM_BUILD_ROOT)/var/www/html/bolixo.png
	install -m644 web/background.png $(RPM_BUILD_ROOT)/var/www/html/background.png
	install -m644 web/no-mini-photo.jpg $(RPM_BUILD_ROOT)/var/www/html/no-mini-photo.jpg
	install -m644 web/no-photo.jpg $(RPM_BUILD_ROOT)/var/www/html/no-photo.jpg
	install -m644 web/admin.jpg $(RPM_BUILD_ROOT)/var/www/html/admin.jpg
	install -m644 web/admin-photo.jpg $(RPM_BUILD_ROOT)/var/www/html/admin-photo.jpg
	install -m644 web/email-open-outline.svg $(RPM_BUILD_ROOT)/var/www/html/email-open-outline.svg
	install -m644 web/email-outline.svg $(RPM_BUILD_ROOT)/var/www/html/email-outline.svg
	install -m644 web/conditions-d-utilisation.html $(RPM_BUILD_ROOT)/var/www/html/conditions-d-utilisation.html
	install -m644 web/terms-of-use.html $(RPM_BUILD_ROOT)/var/www/html/terms-of-use.html
	install -m644 web/webapi.openapi.yaml $(RPM_BUILD_ROOT)/var/www/html/webapi.openapi.yaml
	install -m644 data/http_check.conf $(RPM_BUILD_ROOT)/etc/bolixo/http_check.conf
	install -m755 bolixoserv.sysv $(RPM_BUILD_ROOT)/etc/init.d/bolixoserv
	install -m755 bolixod $(RPM_BUILD_ROOT)/usr/sbin/bolixod
	install -m755 bolixod-control $(RPM_BUILD_ROOT)/usr/sbin/bolixod-control
	install -m755 bo-websocket $(RPM_BUILD_ROOT)/usr/sbin/bo-websocket
	install -m755 bo-websocket-control $(RPM_BUILD_ROOT)/usr/sbin/bo-websocket-control
	install -m755 publishd $(RPM_BUILD_ROOT)/usr/sbin/publishd
	install -m755 publishd-control $(RPM_BUILD_ROOT)/usr/sbin/publishd-control
	install -m755 documentd $(RPM_BUILD_ROOT)/usr/sbin/documentd
	install -m755 documentd-control $(RPM_BUILD_ROOT)/usr/sbin/documentd-control
	install -m755 rssd $(RPM_BUILD_ROOT)/usr/sbin/rssd
	install -m755 rssd-control $(RPM_BUILD_ROOT)/usr/sbin/rssd-control
	install -m755 utils/rss-scan $(RPM_BUILD_ROOT)/usr/sbin/rss-scan
	install -m755 bo-keysd $(RPM_BUILD_ROOT)/usr/sbin/bo-keysd
	install -m755 bo-keysd-control $(RPM_BUILD_ROOT)/usr/sbin/bo-keysd-control
	install -m755 bo-mon $(RPM_BUILD_ROOT)/usr/sbin/bo-mon
	install -m755 bo-mon-control $(RPM_BUILD_ROOT)/usr/sbin/bo-mon-control
	install -m755 bofs $(RPM_BUILD_ROOT)/usr/bin/bofs
	install -m755 utils/create-rss-accounts $(RPM_BUILD_ROOT)/usr/sbin/create-rss-accounts
	install -m755 utils/logssl $(RPM_BUILD_ROOT)/usr/sbin/logssl
	install -m755 utils/logweb $(RPM_BUILD_ROOT)/usr/sbin/logweb
	install -m755 utils/logexim $(RPM_BUILD_ROOT)/usr/sbin/logexim
	install -m755 utils/eximrm $(RPM_BUILD_ROOT)/usr/sbin/eximrm
	install -m755 utils/eximexec $(RPM_BUILD_ROOT)/usr/lib/eximexec
	install -m755 utils/cacheurl $(RPM_BUILD_ROOT)/usr/lib/cacheurl
	install -m755 utils/email-log $(RPM_BUILD_ROOT)/usr/lib/email-log
	install -m755 utils/summary $(RPM_BUILD_ROOT)/usr/sbin/summary
	install -m755 utils/nbusers $(RPM_BUILD_ROOT)/usr/sbin/nbusers
	install -m755 utils/pendingusers $(RPM_BUILD_ROOT)/usr/sbin/pendingusers
	install -m755 utils/listusers $(RPM_BUILD_ROOT)/usr/sbin/listusers
	install -m755 utils/deleteoldmsgs $(RPM_BUILD_ROOT)/usr/sbin/deleteoldmsgs
	install -m755 deleteitems $(RPM_BUILD_ROOT)/usr/sbin/deleteitems
	install -m755 utils/erase-oldsesssions.hourly  $(RPM_BUILD_ROOT)/etc/cron.hourly/erase-oldsesssions
	install -m755 utils/document-save.hourly  $(RPM_BUILD_ROOT)/etc/cron.hourly/document-save
	install -m644 update-script $(RPM_BUILD_ROOT)/usr/share/bolixo/update-script
	install -m755 utils/bolixo-update $(RPM_BUILD_ROOT)/usr/lib/bolixo-update
	install -m755 utils/dnsrequest $(RPM_BUILD_ROOT)/usr/lib/dnsrequest
	mkdir -p $(RPM_BUILD_ROOT)/var/www/html/images-doc
	for file in web/images-doc/*.jpg; do install -m644 $$file $(RPM_BUILD_ROOT)/var/www/html/images-doc/.; done

#	install -m755 web/admin.hc $(RPM_BUILD_ROOT)/var/www/html/admin.hc
#	install -m755 bo-log $(RPM_BUILD_ROOT)/usr/sbin/bo-log
#	install -m755 bo-log-control $(RPM_BUILD_ROOT)/usr/sbin/bo-log-control

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
		| sed s/REV/$(PACKAGE_REV)/ \
		| sed s/BUILDOPTIONS/$(BUILDOPTIONS)/ \
		| utils/rpmdepend tlmp TLMPVERSION \
		| utils/rpmdepend tlmpsql TLMPSQLVERSION \
		| utils/rpmdepend trlitool TRLITOOLVERSION \
		| utils/rpmdepend tlmpweb TLMPWEBVERSION \
		> $(RPMTOPDIR)/SPECS/$(CURDIR)-$(PACKAGE_REV).spec
	rm -fr /tmp/$(CURDIR)-$(PACKAGE_REV)
	mkdir /tmp/$(CURDIR)-$(PACKAGE_REV)
	cp -a * /tmp/$(CURDIR)-$(PACKAGE_REV)/.
	(cd /tmp/$(CURDIR)-$(PACKAGE_REV)/ && make clean && \
		cd .. && tar zcvf $(RPMTOPDIR)/SOURCES/$(CURDIR)-$(PACKAGE_REV).src.tar.gz $(CURDIR)-$(PACKAGE_REV))
	rm -fr /tmp/$(CURDIR)-$(PACKAGE_REV)


buildrpm: buildspec
	unset LD_PRELOAD; $(RPM) -ba $(RPMTOPDIR)/SPECS/$(CURDIR)-$(PACKAGE_REV).spec

buildrpm_instrument:
	make BUILDOPTIONS="DINSTRUMENT=-DINSTRUMENT" buildrpm


REPO=https://solucorp.solutions/repos/solucorp/bolixo
distrpm:
	@eval `svn cat $(REPO)/trunk/Makefile | grep ^PACKAGE_REV=` ; \
	$(MAKE) COPY="svn export --force $(REPO)/trunk/" \
	PACKAGE_REV="$${PACKAGE_REV}r`svn st -u Makefile | tail -1 | while read a b c d ; do echo $$d ; done`" \
	buildrpm

