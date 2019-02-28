#!/bin/sh
## db: Database
## prod: Production
## config: Configuration
## S: Test sequences
## P: Performance
## config: Configuration
## A: Development
## T: Individual tests
export LANG=eng
TESTSH=/usr/lib/bolixo-test.sh
if ! id $USER 2>/dev/null >/dev/null
then
	echo USER variable wrongly set, ending
	exit 1
fi
if [ ! -f $HOME/bolixo.conf ] ; then
	ROOTPASS=root`date +%N`
	BODPASS=bod`date +%N`
	WRITEDPASS=write`date +%N`
	BOLIXODPASS=bolixod`date +%N`
	ADMINPASS=admin`date +%N`
	HOSTNAME=`hostname`
	cat /usr/share/bolixo/bolixo.conf | \
		sed "s/rootpass/$ROOTPASS/" | \
		sed "s/bodpass/$BODPASS/" | \
		sed "s/writedpass/$WRITEDPASS/" | \
		sed "s/bolixodpass/$BOLIXODPASS/" | \
		sed "s/adminpass/$ADMINPASS/" | \
		sed "s/_HOSTNAME_/$HOSTNAME/" \
		>/root/bolixo.conf
fi
. ~/bolixo.conf
BOD_SOCK=/var/lib/lxc/bod/rootfs/tmp/bod-0.sock
WRITED_SOCK=/var/lib/lxc/writed/rootfs/tmp/bo-writed-0.sock
SESSIOND_SOCK=/var/lib/lxc/sessiond/rootfs/tmp/bo-sessiond.sock
export TRLIPATH=/usr/sbin
export TRLICONF=/etc/trli
export TRLILOG=/var/log/trli
VSOURCE=/SOURCE
if [ "$PREPRODOPTION" != "" ] ; then
	VSOURCE=
fi
check_loadfail(){
	W1=`blackhole-control connectload | grep "$1 $3" | (read a b c d w f; echo $w)`
	if [ "$W1" = "" ] ; then
		# Possible if there has been no connection yet
		W1=100
	fi
	WF1=`blackhole-control connectload | grep "$2 $3" | (read a b c d w f; echo $w)`
	if [ "$W1" = 100 -a "$WF1" = 1 ] ; then
		echo "   " $1 $2 normal
	elif [ "$W1" = 1 -a "$WF1" = 100 ] ; then
		echo "   " $1 $2 backup
	elif [ "$W1" = 100 -a "$WF1" = 100 ] ; then
		echo "   " $1 $2 split
	else
		echo "***" $1 $2 strange state
	fi
}
step(){
	echo -n bolixo-production $1" (n) "
	read line
	if [ "$line" != "n" ] ; then
		bolixo-production $1
	else
		echo skipped
	fi
}
stepnote(){
	echo -n "$* "
	read line
}
if [ "$1" = "" ] ; then
	menutest -s $0
elif [ "$1" = "compute" ] ; then # prod: Update stats in news database
	export LXCSOCK=on
	$(TESTSH) compute
elif [ "$1" = "files" ] ; then	# db: Access files database
	shift
	mysql -S /var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock $DBNAME $*
elif [ "$1" = "users" ] ; then # db: Access users database
	shift
	mysql -S /var/lib/lxc/bosqlduser/rootfs/var/lib/mysql/mysql.sock $DBNAMEU $*
elif [ "$1" = "bolixo" ] ; then # db: Access bolixo (directory) database
	shift
	mysql -S /var/lib/lxc/bosqldbolixo/rootfs/var/lib/mysql/mysql.sock $DBNAMEBOLIXO $*
elif [ "$1" = "createdb" ] ; then # db: Access trliusers database
	if [ "$MYSQL_PWD" = "" ] ; then
		echo -n "mysql root password : "
		read pass
		export MYSQL_PWD=$pass
	fi
	/usr/lib/bolixo-test.sh createdb
	if [ -d /var/lib/lxc/bosqldbolixo/rootfs ] ; then
		echo createbolixodb
		/usr/lib/bolixo-test.sh createbolixodb
	fi
elif [ "$1" = "createsqluser" ] ; then # db: Configure sql user
	unset MYSQL_PWD
	/usr/lib/bolixo-test.sh createsqlusers
	if [ -d /var/lib/lxc/bosqlddata/rootfs ] ; then
		/var/lib/lxc/bosqlddata/bosqlddata.runsql mysql </tmp/files.sql
		/var/lib/lxc/bosqlddata/bosqlddata.admsql reload
	fi
	if [ -d /var/lib/lxc/bosqlduser/rootfs ] ; then
		/var/lib/lxc/bosqlduser/bosqlduser.runsql mysql </tmp/users.sql
		/var/lib/lxc/bosqlduser/bosqlduser.admsql reload
	fi
	if [ -d /var/lib/lxc/bosqldbolixo/rootfs ] ; then
		/var/lib/lxc/bosqldbolixo/bosqldbolixo.runsql mysql </tmp/bolixo.sql
		/var/lib/lxc/bosqldbolixo/bosqldbolixo.admsql reload
	fi
elif [ "$1" = "test-system" ]; then # A: Checks components
	time -p bo-mon-control test
elif [ "$1" = "checks" ]; then # A: Sanity checks blackhole
	if blackhole-control status >/dev/null 2>/dev/null
	then
		echo Blackhole ok
	else
		echo "*** Blackhole not available"
	fi
	if horizon-control status 2>/dev/null| fgrep unix:/var/run/blackhole/horizon-master.sock | grep -q MASTER
	then
		echo horizon connected
	else
		echo "*** Horizon not connected"
	fi
elif [ "$1" = "blackhole-start" ]; then # config: Starts blackholes service or reload
	if killall -0 conproxy 2>/dev/null
	then
		echo conproxy is running
	else
		echo Start conproxy
		/etc/init.d/conproxy start
	fi
	if killall -0 horizon 2>/dev/null
	then
		echo Reload horizon
		/etc/init.d/horizon reload
	else
		echo Start horizon
		/etc/init.d/horizon start
	fi
	if killall -0 blackhole 2>/dev/null
	then
		echo Reload blackhole
		/etc/init.d/blackhole reload
	else
		echo Start blackhole
		/etc/init.d/blackhole start
	fi
elif [ "$1" = "secrets" ] ; then # config: Generate secrets
	HOSTNAME=`hostname`
	if [ ! -f /etc/bolixo/secrets.admin ] ; then
		echo Write /etc/bolixo/secrets.admin
		NANO=`date +%N`
		sed "s/ adm/ $NANO/" </usr/share/bolixo/secrets.admin >/etc/bolixo/secrets.admin
		chmod 600 /etc/bolixo/secrets.admin
	fi
	if [ ! -f /etc/bolixo/secrets.client ] ; then
		echo Write /etc/bolixo/secrets.client
		NANO=`date +%N`
		sed "s/ foo/ $NANO/" </usr/share/bolixo/secrets.client >/etc/bolixo/secrets.client
		chmod 600 /etc/bolixo/secrets.client
	fi
	if [ ! -f /root/data/manager.conf ] ; then
		mkdir -p /root/data
		echo Write /root/data/manager.conf
		CLI=`head -1 /etc/bolixo/secrets.client | (read a b; echo $b)`
		ADM=`head -1 /etc/bolixo/secrets.admin | (read a b; echo $b)`
		MYIP=`ifconfig eth0 | grep "inet " | ( read a b c; echo $b)`
		sed "s/ #CLI/ $CLI/" </usr/share/bolixo/manager.conf \
			| sed "s/ #ADM/ $ADM/" \
			| sed "s/testhost/localhost/" \
			| sed "s/#MYIP/$MYIP/" >/root/data/manager.conf
	fi
	if [ ! -f /root/.bofs.conf ] ; then
		echo Write /root/.bofs.conf
		CLI=`head -1 /etc/bolixo/secrets.client | (read a b; echo $b)`
		ADM=`head -1 /etc/bolixo/secrets.admin | (read a b; echo $b)`
		sed "s/ #CLI/ $CLI/" </usr/share/bolixo/bofs.conf \
			| sed "s/ #ADM/ $ADM/" \
			| sed "s/_HOSTNAME_/$HOSTNAME/" \
			| sed "s/adminpass/$ADMINPASSWORD/" \
			>/root/.bofs.conf
	fi
elif [ "$1" = "config" ] ; then # config: Generate config
	/usr/lib/bolixo-test.sh prodconfig
elif [ "$1" = "make-mysql-log" ] ; then # config: mysql strace log for lxc0
	/usr/lib/bolixo-test.sh make-mysql-log 
elif [ "$1" = "make-httpd-log" ] ; then # config: httpd strace log for lxc0
	/usr/lib/bolixo-test.sh make-httpd-log 
elif [ "$1" = "make-exim-log" ] ; then # config: exim strace log for lxc0
	/usr/lib/bolixo-test.sh make-exim-log 
elif [ "$1" = "lxc0s" ] ; then # config: Produces the lxc0 scripts
	export SILENT=on
	export LXCSOCK=off
	$0 checks
	test -d /var/lib/lxc/web && /usr/lib/bolixo-test.sh lxc0-web
	test -d /var/lib/lxc/webssl && /usr/lib/bolixo-test.sh lxc0-webssl
	# test.sh generates only the needed sql containers
	/usr/lib/bolixo-test.sh lxc0-mysql
	test -d /var/lib/lxc/exim && /usr/lib/bolixo-test.sh lxc0-exim
	test -d /var/lib/lxc/bod && /usr/lib/bolixo-test.sh lxc0-bod
	test -d /var/lib/lxc/writed && /usr/lib/bolixo-test.sh lxc0-writed
	test -d /var/lib/lxc/sessiond && /usr/lib/bolixo-test.sh lxc0-sessiond
	test -d /var/lib/lxc/keysd && /usr/lib/bolixo-test.sh lxc0-keysd
	test -d /var/lib/lxc/bolixod && /usr/lib/bolixo-test.sh lxc0-bolixod
	test -d /var/lib/lxc/publishd && /usr/lib/bolixo-test.sh lxc0-publishd
	test -d /var/lib/lxc/protocheck && /usr/lib/bolixo-test.sh lxc0-proto
elif [ "$1" = "webtest" ] ; then # P:
	shift
	/usr/lib/bolixo-test.sh webtest $*
elif [ "$1" = "webtest-static" ] ; then # P:
	shift
	/usr/lib/bolixo-test.sh webtest-static $*
elif [ "$1" = "webtest-direct" ] ; then # P:
	shift
	/usr/lib/bolixo-test.sh webtest-direct $*
elif [ "$1" = "webtest-direct-static" ] ; then # P:
	shift
	/usr/lib/bolixo-test.sh webtest-direct-static $*
elif [ "$1" = "webssltest" ] ; then # P:
	shift
	/usr/lib/bolixo-test.sh webssltest $*
elif [ "$1" = "webssltest-static" ] ; then # P:
	shift
	/usr/lib/bolixo-test.sh webssltest-static `bofs --printcred` $*
elif [ "$1" = "stop-stop" ] ; then # prod: Stop the web
	/usr/lib/bolixo-test.sh stop-stop
elif [ "$1" = "stop-status" ] ; then # prod: status of trli-stop
	/usr/lib/bolixo-test.sh stop-status
elif [ "$1" = "stop-start" ] ; then # prod: Restart the web
	/usr/lib/bolixo-test.sh stop-start
elif [ "$1" = "eraseanon" ] ; then # prod: [nbsec (default 1 day) anonymous normal admin]
	NBSEC=`expr 60 \* 60 \* 24`
	shift
	if [ "$1" != "" ] ; then
		NBSEC=$1
		shift
	fi
	echo Erase anonymous session older than $NBSEC seconds
	/usr/lib/bolixo-test.sh eraseanon-lxc $NBSEC $*
elif [ "$1" = "listsessions" ] ; then # prod: list web sessions (offset)
	OFF=0
	if [ "$2" != "" ] ; then
		OFF=$2
	fi
	bo-sessiond-control -p /var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock listsessions $OFF 100
elif [ "$1" = "mailctrl" ] ; then # config: Control writed sendmail
	if [ $# != 3 ] ;then
		echo "mailctrl 0|1 force_addr"
		exit 1
	fi
	/usr/lib/bolixo-test.sh mailctrl "$2" "$3"
elif [ "$1" = "monitor" ] ; then # prod: Test all trlids
	bo-mon-control status	
elif [ "$1" = "resetmsg" ] ; then # prod: Reset alarm
	bo-mon-control resetmsg
elif [ "$1" = "restart" ] ; then # prod: restart some services (webs, internals, ...)
	shift
	bo-mon-control autotest 0
	if [ "$1" = "" ] ; then
		echo bolixo-production restart service ...
		echo All services may be restarted any time except horizon
		echo services are:
		echo
		echo "    " internals "(restart everything except the databases, web and exim)"
		echo "    " sqls "(restart all databases)"
		echo "    " webs "(All four web... services)"
		echo "    " horizon "(may loose few connections)"
		echo "    " bo-mon bod bolixod keysd protocheck publishd sessiond trli-syslog writed
		echo "    " exim
		echo "    " bosqlddata bosqlduser bosqldbolixo
		echo
	elif [ "$1" = "webs" ] ; then
		$0 loadfail normal
		echo Restarting webssl-fail and web-fail
		/var/lib/lxc/webssl-fail/webssl-fail.stop
		/var/lib/lxc/webssl-fail/webssl-fail.start
		/var/lib/lxc/web-fail/web-fail.stop
		/var/lib/lxc/web-fail/web-fail.start
		echo -n "sleep 5 seconds to make sure the backup services have started"
		sleep 5
		echo
		$0 loadfail backup
		echo Restarting webssl and web
		/var/lib/lxc/webssl/webssl.stop
		/var/lib/lxc/webssl/webssl.start
		/var/lib/lxc/web/web.stop
		/var/lib/lxc/web/web.start
		echo -n "sleep 5 seconds to make sure the normal services have started"
		sleep 5
		echo
		$0 loadfail normal
		echo Normal operation resumed
	elif $0 stop-stop
	then
		SERVICES=
		for serv in $*
		do
			if [ "$serv" = "internals" ] ; then
				SERVICES="$SERVICES bo-mon trli-syslog"
				for std in bolixod bod writed sessiond keysd publishd protocheck
				do
					if [ -d /var/lib/lxc/$std/rootfs ] ; then
						SERVICES="$SERVICES $std"
					fi
				done
			elif [ "$serv" = "sqls" ] ; then
				for db in bosqlddata bosqlduser bosqldbolixo
				do
					if [ -d /var/lib/lxc/$db/rootfs ] ; then
						SERVICES="$SERVICES $db"
					fi
				done
			else
				SERVICES="$SERVICES $serv"
			fi
		done
		keysd_restarted=
		for serv in $SERVICES
		do
			echo "   " $serv
			if [ "$serv" = "keysd" ] ; then
				keysd_restarted=true
			fi
			if [ "$serv" = "horizon" ] ; then
				/etc/init.d/horizon restart
				for file in /var/lib/lxc/*/horizon-start.sh
				do
					$file
				done
			elif [ "$serv" = "web" -o "$serv" = "webssl" ] ; then
				echo "   Can't restart web or webssl, use webs"
			elif [ "$serv" = "bo-mon" ] ; then
				/var/lib/lxc/bo-mon-stop.sh
				/var/lib/lxc/bo-mon-start.sh
				bo-mon-control autotest 0
			elif [ "$serv" = "trli-syslog" ] ; then
				/var/lib/lxc/trli-syslog-stop.sh
				/var/lib/lxc/trli-syslog-start.sh
			else
				DIR=/var/lib/lxc/$serv
				if [ -d "$DIR" ] ; then
					if $DIR/$serv.stop; then
						if ! $DIR/$serv.start; then
						       echo $serv.start failed
						fi
					else
						echo $serv.stop failed
					fi

				else
					echo Directory $DIR does not exist
				fi
			fi
		done
		if [ "$keysd_restarted" != "" ] ; then
			echo Service keysd was restarted
			/usr/sbin/bo-keysd-control -p /var/lib/lxc/keysd/rootfs/var/run/blackhole/bo-keysd.sock setpassphrase
		fi
		$0 stop-start
	else
		echo "*** Can't stop the web"
		echo "*** Try to restart anyway"
		$0 stop-start
	fi
	bo-mon-control autotest 1
elif [ "$1" = "autotest" ] ; then # prod: turn bo-mon autotest on or off (1 o 0)
	bo-mon-control autotest $2
elif [ "$1" = "syslog-status" ] ; then # syslog: Status of the syslog daemon
	trli-syslog-control status
elif [ "$1" = "syslog-reset" ] ; then # syslog: Reset errors in syslog
	trli-syslog-control reseterrors
elif [ "$1" = "syslog-clear" ] ; then # syslog: Clear all messages in syslog
	trli-syslog-control clearlogs
elif [ "$1" = "syslog-tail" ] ; then # syslog: Shows the last syslog lines
	trli-syslog-control tail
elif [ "$1" = "syslog-logs" ] ; then # syslog: Shows the syslog lines
	trli-syslog-control logs
elif [ "$1" = "writed-sendmail" ] ; then # S: writed will send a mail
	. /etc/bolixo/admins.conf
	bo-writed-control -p /var/lib/lxc/writed/rootfs/var/run/blackhole/bo-writed-0.sock sendmail $ADMIN1 "This is title" "This is the body"
elif [ "$1" = "mon-sendmail" ] ; then # S: bo-mon will send a mail
	bo-mon-control testmail
elif [ "$1" = "install-web" ] ; then # prod: Replace web parts in running lxcs
	VCGI=/var/www/cgi-bin
	VHTML=/var/www/html
	VLXC=/var/lib/lxc
	for w in web web-fail
	do
		install -m755 $VCGI/tlmpweb $VLXC/$w/rootfs/$VCGI/tlmpweb
		install -m755 $VHTML/index.hc $VLXC/$w/rootfs/$VHTML/index.hc
		install -m755 $VHTML/public.hc $VLXC/$w/rootfs/$VHTML/public.hc
		install -m755 $VHTML/bolixo.hc $VLXC/$w/rootfs/$VHTML/bolixo.hc
		install -m755 $VHTML/webapi.hc $VLXC/$w/rootfs/$VHTML/webapi.hc
		install -m755 $VHTML/bolixoapi.hc $VLXC/$w/rootfs/$VHTML/bolixoapi.hc
		for dict in bolixo tlmpsql tlmpweb
		do
			install -m644 /usr/lib/tlmp/help.eng/$dict.eng $VLXC/$w/rootfs/usr/lib/tlmp/help.eng/$dict.eng
			install -m644 /usr/lib/tlmp/help.fr/$dict.fr $VLXC/$w/rootfs/usr/lib/tlmp/help.fr/$dict.fr
		done
	done
	for file in robots.txt about.html  favicon.ico terms-of-use.html\
	       bolixo.png background.png new.png modified.png seen.png private.png
	do
		install -m644 $VHTML/$file $VLXC/webssl/rootfs/$VHTML/$file
	done
elif [ "$1" = "rotatelog" ] ; then # prod: Rotate writed logs
	LOG=/var/lib/lxc/writed/rootfs/var/log/bolixo/bo-writed.log
	test -f $LOG.3 && mv $LOG.3 $LOG.4
	test -f $LOG.2 && mv $LOG.2 $LOG.3
	test -f $LOG.1 && mv $LOG.1 $LOG.2
	test -f $LOG   && mv $LOG   $LOG.1
	bo-writed-control -p /var/lib/lxc/writed/rootfs/var/run/blackhole/bo-writed-0.sock rotatelog
	mkdir -p /root/logs
	FILE=/root/logs/writedlog-`date +%F_%H:%M:%S`
	cp $LOG.1 $FILE
	gpg -e -r jack@solucorp.qc.ca $FILE
	rm -f $FILE
elif [ "$1" = "newacctresend" ] ; then # prod: Resend account confirmation mail [ to_stdout ]
	if [ "$2" = "" ] ; then
		echo newacctresend email [ to_stdout ]
		exit 1
	fi
	/usr/lib/bolixo-test.sh bo-writed-control newacctresend $2 $3
elif [ "$1" = "confirmuser" ] ; then # prod: Confirm a new user account
	if [ "$3" = "" ] ; then
		echo confirmuser nickname email
		exit 1
	fi
	/usr/lib/bolixo-test.sh bo-writed-control confirmuser $2
	/usr/lib/bolixo-test.sh bod-control publishemail $2 $3
elif [ "$1" = "del_incomplete" ] ; then # prod: Deletes un-confirmed user accounts (seconds)
	shift
	/usr/lib/bolixo-test.sh bo-writed-control del_incomplete $1 
elif [ "$1" = "disable" ] ; then # prod: Disable one user account
	shift
	/usr/lib/bolixo-test.sh bo-writed-control disable $1 
elif [ "$1" = "enable" ] ; then # prod: Enable one user account
	shift
	/usr/lib/bolixo-test.sh bo-writed-control enable $1 
elif [ "$1" = "status" ] ; then # prod: Status of one service
	shift
	while [ "$1" != "" ]
	do
		echo ============== $1 ============
		/var/lib/lxc/$1/status.sh
		shift
	done
elif [ "$1" = "checkupdates" ] ; then # prod: Check all containers are up to date
	for lxc in bod writed sessiond keysd bolixod protocheck exim web webadm webssl bosqlddata bosqlduser bosqldbolixo
	do
		if [ -d /var/lib/lxc/$lxc ] ; then
			trli-cmp --name $lxc /var/lib/lxc/$lxc/$lxc.files
		fi
	done
elif [ "$1" = "loadfail" ] ; then # prod: Switch web access (normal,backup,split)
	if [ "$THISSERVER" = "" ] ;then
		THISSERVER=localhost
	fi
	if [ "$2" = "normal" ] ; then
		W1=100
		W2=1
		WAIT=backup
		S1="$THISSERVER web-fail 80"
		S2="$THISSERVER webssl-fail$VSOURCE 80"
		S3="$THISSERVER webssl-fail$VSOURCE 443"
	elif [ "$2" = "backup" ] ; then
		W1=1
		W2=100
		WAIT=normal
		S1="$THISSERVER web 80"
		S2="$THISSERVER webssl$VSOURCE 80"
		S3="$THISSERVER webssl$VSOURCE 443"
	elif [ "$2" = "split" ] ; then
		W1=100
		W2=100
		S1=
		S2=
		S3=
	else
		echo normal,backup or split
		check_loadfail web web-fail 80
		check_loadfail webssl$VSOURCE webssl-fail$VSOURCE 80
		check_loadfail webssl$VSOURCE webssl-fail$VSOURCE 443
		exit 1
	fi
	echo Switching to web mode $2
	blackhole-control setweight $THISSERVER web 80 $W1
	blackhole-control setweight $THISSERVER web-fail 80 $W2
	blackhole-control setweight $THISSERVER webssl$VSOURCE 80 $W1
	blackhole-control setweight $THISSERVER webssl-fail$VSOURCE 80 $W2
	blackhole-control setweight $THISSERVER webssl$VSOURCE 443 $W1
	blackhole-control setweight $THISSERVER webssl-fail$VSOURCE 443 $W2
	# Now we wait for the connections to vanish on the normal or backup side
	if [ "$$1" != "" ] ; then
		echo -n "Waiting for $WAIT connections to end : "
		COUNT=0
		while true
		do
			NB1=`blackhole-control connectload | fgrep "$S1" | (read a b c d e; echo $d)` 
			NB2=`blackhole-control connectload | fgrep "$S2" | (read a b c d e; echo $d)` 
			NB3=`blackhole-control connectload | fgrep "$S3" | (read a b c d e; echo $d)` 
			if [ "$NB1" = 0 -a "$NB2" = 0 -a "$NB3" = 0 ] ; then
				echo
				break
			else
				COUNT=`expr $COUNT + 1`
				if [ "$COUNT" = "10" ] ; then
					echo
					echo $NB1 $S1
					echo $NB2 $S2
					echo $NB3 $S3
					COUNT=0
				fi
				echo -n .
				sleep 1
			fi
		done
	fi
elif [ "$1" = "deleteitems" ] ; then # db: Delete items and check integrity
	export DELETEITEMS_PWD=$BO_WRITED_PWD
	shift
	deleteitems --data_socket /var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock --data_dbserv localhost --data_dbname files --data_dbuser bowrited --integrity $@
elif [ "$1" = "calltest" ] ; then # A: Call /usr/lib/bolixo-test.sh
	export LXCSOCK=on
	shift
	/usr/lib/bolixo-test.sh "$@"
elif [ "$1" = "certificate-install" ]; then # prod: Install the SSL certificate
	# Make sure the special /root/bin/apachectl is used
	export PATH=/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
	NODENAME=$2
	if [ "$NODENAME" = "" ] ; then
		NODENAME=`echo $THISNODE | sed 's.//. .' | (read a b; echo $b)`
	fi
	ADD=/etc/httpd/conf.d/add.conf
	cat <<-EOF >$ADD
	<VirtualHost *:80>
		ServerAdmin admin@bolixo.org
		ServerName $NODENAME
		DocumentRoot /var/lib/lxc/webssl/rootfs/var/www/html
	</VirtualHost>
	EOF
	certbot --apache certonly
	rm -f $ADD
elif [ "$1" = "certificates" ] ; then # prod: Show SSL certifcates status
	certbot certificates
elif [ "$1" = "certificate-renew" ] ; then # prod: Renew the SSL certificate
	# Do a backup
	cd /etc
	tar zcf /tmp/letsencrypt-`date +%Y-%m-%d_%H:%M:%S`.tar.gz letsencrypt
	# Make sure the special /root/bin/apachectl is used
	export PATH=/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
	NODENAME=$3
	if [ "$NODENAME" = "" ] ; then
		NODENAME=`echo $THISNODE | sed 's.//. .' | (read a b; echo $b)`
	fi
	ADD=/etc/httpd/conf.d/add.conf
	cat <<-EOF >$ADD
	<VirtualHost *:80>
		ServerAdmin admin@bolixo.org
		ServerName $NODENAME
		DocumentRoot /var/lib/lxc/webssl/rootfs/var/www/html
	</VirtualHost>
	EOF
	echo ================ $ADD =======
	cat $ADD
	echo ================
	if [ "$2" = "test" ]; then
	        certbot certonly --apache -d $NODENAME --dry-run
	elif [ "$2" = "doit" ] ; then
        	if certbot certonly --apache -d $NODENAME
		then
			$0 restart exim
		fi
	else
        	echo test ou doit
		rm -f $ADD
		exit 1
	fi
	rm -f $ADD
	$0 restart webs
elif [ "$1" = "keysd-pass" ] ; then # prod: set keys passphrase
	/usr/sbin/bo-keysd-control -p /var/lib/lxc/keysd/rootfs/var/run/blackhole/bo-keysd.sock setpassphrase
elif [ "$1" = "record-keysd-pass" ] ; then # prod: Record the keysd passphrase for next reboot
	read -s -p "Enter keysd pass-phrase : " pass
	export KEYSDPASS="$pass"
	echo
	if bo-keysd-control -p /var/lib/lxc/keysd/rootfs/var/run/blackhole/bo-keysd.sock checkpassphrase
	then
		echo $pass >/root/keysd.pass
		echo Pass phrase recorded
	else
		echo "***" Pass phrase not recorded
	fi
elif [ "$1" = "install-required" ] ; then # config: install required packages
	echo dnf install lxc lxc-templates \
		gd \
		mariadb-server mariadb-connector-c boost-date-time \
		freetype httpd mod_ssl \
		libvirt-daemon libvirt-daemon-driver-network \
		libvirt-daemon-config-network libvirt-client \
		libvirt-daemon-driver-qemu bridge-utils \
		time strace exim vim-enhanced certbot python3-certbot-apache \
		bash-completion
elif [ "$1" = "generate-system-pubkey" ] ; then # config: Generate the node public key
	/usr/lib/bolixo-test.sh generate-system-pubkey
elif [ "$1" = "registernode" ] ; then # config: Register this node in the directory
	/usr/lib/bolixo-test.sh registernode
elif [ "$1" = "createadmin" ] ; then # config: Create the admin acccount
	/usr/lib/bolixo-test.sh createadmin
elif [ "$1" = "start-everything" ] ; then # config: Start all bolixo services
	/root/bolixostart.sh
elif [ "$1" = "install-sequence" ] ; then # config: Interative sequence to start a node from scratch
	if [ ! -f /root/stracelogs/log.web -o ! -f /root/stracelogs/log.exim -o ! -f /root/stracelogs/log.mysql ] ; then
		echo lxc0 log files are missing in /root/stracelogs
		echo execute
		echo "    " bolixo-production make-httpd-log
		echo "    " bolixo-production make-mysql-log
		echo "    " bolixo-production make-exim-log
		exit 1
	fi
	step secrets
	stepnote edit/configure /root/data/manager.conf /root/.bofs.conf
	step config
	step blackhole-start
	step checks
	step lxc0s
	step start-everything
	step createsqluser
	step createdb
	step test-system
	step generate-system-pubkey
	step createadmin
	step syslog-clear
	step syslog-reset
	step test-system
elif [ "$1" = "install-sequence-publish" ] ; then # config: Complete install-sequence once everything is running
	step registernode
	echo Register admin for this node in the directory
	ADMINH=admin@`hostname`
	echo bofs bolixoapi recordemail $THISNODE admin $ADMINH
	bofs bolixoapi recordemail $THISNODE admin $ADMINH
else
	echo Invalid command
fi

