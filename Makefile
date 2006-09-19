CURDIR=bolixo
PACKAGE_REV=0.0
PROGS=bolixod bolixo boshell
LOCAL_CLEAN=local_clean
LOCAL_INSTALL=local_install
INCLUDEDIRECTIVES+=`xml-config --cflags`
EXTRALIBS=`xml-config --libs`
OBJS=bolibfs.o bolixo.o bomail.o bomisc.o boxml.o version.o _dict.o
OBJSGUI=bonode.o
prog: $(PROGS) libbolixo.a

include /usr/lib/linuxconf-devel/ccrules.mak
LDEVEL=/usr/lib/linuxconf-devel

proto:
	tlproto -DPROTO_EXCL -c+ -f$(CURDIR).pm -ceo -f$(CURDIR).p *.tlcc \
		-b$(CURDIR).h+$(CURDIR).pm \
		-bbolixod.tlcc+$(CURDIR).pm \
		-bbonode.h+$(CURDIR).pm \
		-bbolibfs.h+$(CURDIR).pm \
		-bbomail.h+$(CURDIR).pm \
		-bbolixogui.tlcc+$(CURDIR).pm

msg:
	$(LDEVEL)/msgscan $(CURDIR) \
		$(CURDIR).dic $(CURDIR).m EF *.{cc,tlcc}
	
msg.eng:
	$(LDEVEL)/msgcomp -p./ /tmp/$(CURDIR).eng eE $(CURDIR)

bolixod: bolixod.o $(OBJS)
	$(GPPLINK) bolixod.o $(OBJS) -o bolixod -ltlmpsql -llinuxconf \
		-L/usr/lib64/mysql -L/usr/lib/mysql -lmysqlclient $(EXTRALIBS)

bolixo: bolixogui.o $(OBJS) $(OBJSGUI)
	$(GPPLINK) bolixogui.o $(OBJS) $(OBJSGUI) -o bolixo -llinuxconf \
		-ltlmpwork $(EXTRALIBS)

botest: botest.o $(OBJS)
	$(GPPLINK) botest.o $(OBJS) -o /tmp/botest -llinuxconf \
		$(EXTRALIBS)

boshell: boshell.o $(OBJS)
	$(GPPLINK) boshell.o $(OBJS) -o boshell -llinuxconf \
		$(EXTRALIBS)

libbolixo.a: $(OBJS)
	ar cr libbolixo.a $(OBJS)

db.h:
	sqlgen_interface --database bolixo users documents nodes relations >db.h

version.o: Makefile
	@echo "const char *version = \"$(PACKAGE_REV)\";" >/tmp/version.c
	gcc -c /tmp/version.c -o version.o

local_clean:
	rm -f $(PROGS)

msg.clean:
	/usr/lib/linuxconf-devel/msgclean $(CURDIR).dic
	$(MAKE) msg
	$(MAKE) clean



USR_BIN=$(RPM_BUILD_ROOT)/usr/bin
USR_LIB_TLMP=$(USR_LIB)/tlmp
X64=$(shell test -d /lib64 && echo 64)
USR_LIB=$(RPM_BUILD_ROOT)/usr/lib$(X64)
USR_INCLUDE_TLMP=$(RPM_BUILD_ROOT)/usr/include/tlmp

local_install: msg.eng
	mkdir -p $(USR_BIN)
	mkdir -p $(USR_LIB_TLMP)/help.eng
	install bolixod $(USR_BIN)/bolixod
	install bolixo $(USR_BIN)/bolixo
	install boshell $(USR_BIN)/boshell
	install /tmp/bolixo.eng $(USR_LIB_TLMP)/help.eng

install-devel:
	mkdir -p $(USR_LIB)
	install libbolixo.a $(USR_LIB)
	install bomail.h $(USR_INCLUDE_TLMP)

_dict.o: _dict.cc $(CURDIR).m
