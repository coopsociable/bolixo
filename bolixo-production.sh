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
if [ "$1" = "" ] ; then
	menutest -s $0
elif [ "$1" = "compute" ] ; then # prod: Update stats in news database
	export LXCSOCK=on
	$(TESTSH) compute
elif [ "$1" = "trli" ] ; then	# db: Access trli database
	mysql -S /var/lib/lxc/sqlddata/rootfs/var/lib/mysql/mysql.sock $DBNAME
elif [ "$1" = "trliusers" ] ; then # db: Access trliusers database
	mysql -S /var/lib/lxc/sqlduser/rootfs/var/lib/mysql/mysql.sock $DBNAMEU
elif [ "$1" = "createdb" ] ; then # db: Access trliusers database
	echo -n "mysql root password : "
	read pass
	export MYSQL_PWD=$pass
	/usr/lib/trli-test.sh createdb
elif [ "$1" = "createsqluser" ] ; then # db: Configure sql user
	echo -n "Enter new root password : "
	read pass
	/usr/lib/trli-test.sh createsqlusers
	cat <<-EOF >/tmp/root.sql
	delete from user where user='root' and host != 'localhost';
	delete from user where user='';
	update user set password=password('$pass') where user='root';
	EOF
	/var/lib/lxc/sqlddata/sqlddata.runsql mysql </tmp/root.sql
	/var/lib/lxc/sqlddata/sqlddata.runsql mysql </tmp/trli.sql
	/var/lib/lxc/sqlddata/sqlddata.admsql reload
	/var/lib/lxc/sqlduser/sqlduser.runsql mysql </tmp/root.sql
	/var/lib/lxc/sqlduser/sqlduser.runsql mysql </tmp/trliusers.sql
	/var/lib/lxc/sqlduser/sqlduser.admsql reload
elif [ "$1" = "test-system" ]; then # A: Checks components
	time -p trli-mon-control test
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
elif [ "$1" = "config" ] ; then # config: Generate config
	/usr/lib/trli-test.sh prodconfig
elif [ "$1" = "lxc0s" ] ; then # config: Produces the lxc0 scripts
	export SILENT=on
	$0 checks
	/usr/lib/trli-test.sh lxc0-web
	/usr/lib/trli-test.sh lxc0-webssl
	/usr/lib/trli-test.sh lxc0-mysql
	/usr/lib/trli-test.sh lxc0-exim
	/usr/lib/trli-test.sh lxc0-trlid
	/usr/lib/trli-test.sh lxc0-writed
	/usr/lib/trli-test.sh lxc0-sessiond
	/usr/lib/trli-test.sh lxc0-proto
elif [ "$1" = "webtest" ] ; then # P:
	shift
	/usr/lib/trli-test.sh webtest $*
elif [ "$1" = "webtest-static" ] ; then # P:
	shift
	/usr/lib/trli-test.sh webtest-static $*
elif [ "$1" = "webtest-direct" ] ; then # P:
	shift
	/usr/lib/trli-test.sh webtest-direct $*
elif [ "$1" = "webtest-direct-static" ] ; then # P:
	shift
	/usr/lib/trli-test.sh webtest-direct-static $*
elif [ "$1" = "webssltest" ] ; then # P:
	shift
	/usr/lib/trli-test.sh webssltest $*
elif [ "$1" = "webssltest-static" ] ; then # P:
	shift
	/usr/lib/trli-test.sh webssltest-static $*
elif [ "$1" = "stop-stop" ] ; then # prod: Stop the web
	/usr/lib/trli-test.sh stop-stop
elif [ "$1" = "stop-status" ] ; then # prod: status of trli-stop
	/usr/lib/trli-test.sh stop-status
elif [ "$1" = "stop-start" ] ; then # prod: Restart the web
	/usr/lib/trli-test.sh stop-start
elif [ "$1" = "eraseanon" ] ; then # prod: [nbsec default 1 day]
	NBSEC=`expr 60 \* 60 \* 24`
	if [ "$2" != "" ] ; then
		NBSEC=$2
	fi
	echo Erase anonymous session older than $NBSEC seconds
	/usr/lib/trli-test.sh eraseanon-lxc $NBSEC
elif [ "$1" = "listsessions" ] ; then # prod: list web sessions (offset)
	OFF=0
	if [ "$2" != "" ] ; then
		OFF=$2
	fi
	trli-sessiond-control -p /var/lib/lxc/sessiond/rootfs/var/run/blackhole/trli-sessiond.sock listsessions $OFF 100
elif [ "$1" = "mailctrl" ] ; then # config: Control writed sendmail
	if [ $# != 3 ] ;then
		echo "mailctrl 0|1 force_addr"
		exit 1
	fi
	/usr/lib/trli-test.sh mailctrl "$2" "$3"
elif [ "$1" = "loadusers" ] ; then # config: Load users from a file
	export LXCSOCK=on
	/usr/lib/trli-test.sh loadusers
elif [ "$1" = "loadnews" ] ; then # config: Load news from a directory
	shift
	/usr/lib/trli-test.sh loadnews $*
elif [ "$1" = "loadblog" ] ; then # config: Load blog from a directory (admin_pass,any)
	shift
	/usr/lib/trli-test.sh loadblog $*
elif [ "$1" = "monitor" ] ; then # prod: Test all trlids
	trli-mon-control status	
elif [ "$1" = "resetmsg" ] ; then # prod: Reset alarm
	trli-mon-control resetmsg
elif [ "$1" = "restart" ] ; then # prod: restart some services (webs, internals, ...)
	shift
	trli-mon-control autotest 0
	if [ "$1" = "webs" ] ; then
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
				SERVICES="$SERVICES trlid writed sessiond protocheck trli-mon trli-syslog compute"
			else
				SERVICES="$SERVICES $serv"
			fi
		done
		for serv in $SERVICES
		do
			echo "   " $serv
			if [ "$serv" = "horizon" ] ; then
				/etc/init.d/horizon restart
				for file in /var/lib/lxc/*/horizon-start.sh
				do
					$file
				done
			elif [ "$serv" = "web" -o "$serv" = "webssl" ] ; then
				echo "   Can't restart web or webssl, use webs"
			elif [ "$serv" = "trli-mon" ] ; then
				/var/lib/lxc/trli-mon-stop.sh
				/var/lib/lxc/trli-mon-start.sh
				trli-mon-control autotest 0
			elif [ "$serv" = "trli-syslog" ] ; then
				/var/lib/lxc/trli-syslog-stop.sh
				/var/lib/lxc/trli-syslog-start.sh
			elif [ "$serv" = "compute" ] ; then
				/var/lib/lxc/compute-stop.sh
				/var/lib/lxc/compute-start.sh
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
		$0 stop-start
	else
		echo "*** Can't stop the web"
		echo "*** Try to restart anyway"
		$0 stop-start
	fi
	trli-mon-control autotest 1
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
	. /etc/trli/admins.conf
	trli-writed-control -p /var/lib/lxc/writed/rootfs/var/run/blackhole/trli-writed-0.sock sendmail $ADMIN1 "This is title" "This is the body"
elif [ "$1" = "mon-sendmail" ] ; then # S: trli-mon will send a mail
	trli-mon-control testmail
elif [ "$1" = "install-web" ] ; then # prod: Replace web parts in running lxcs
	VCGI=/var/www/cgi-bin
	VHTML=/var/www/html
	VLXC=/var/lib/lxc
	install -m755 $VCGI/tlmpweb $VLXC/web/rootfs/$VCGI/tlmpweb
	install -m755 $VHTML/index.hc $VLXC/web/rootfs/$VHTML/index.hc
	install -m755 $VHTML/blog.hc $VLXC/web/rootfs/$VHTML/blog.hc
	install -m755 $VHTML/index.hc $VLXC/web-fail/rootfs/$VHTML/index.hc
	install -m755 $VHTML/blog.hc $VLXC/web-fail/rootfs/$VHTML/blog.hc
	install -m755 $VHTML/admin.hc $VLXC/webadm/rootfs/$VHTML/admin.hc
	for file in twitter.png robots.txt true-o-meter.html 7s.html  about.html  favicon.ico  guidelines.html  marker.html terms-of-use.html
	do
		install -m644 $VHTML/$file $VLXC/webssl/rootfs/$VHTML/$file
	done
elif [ "$1" = "rotatelog" ] ; then # prod: Rotate writed logs
	LOG=/var/lib/lxc/writed/rootfs/var/log/trli/trli-writed.log
	test -f $LOG.3 && mv $LOG.3 $LOG.4
	test -f $LOG.2 && mv $LOG.2 $LOG.3
	test -f $LOG.1 && mv $LOG.1 $LOG.2
	test -f $LOG   && mv $LOG   $LOG.1
	trli-writed-control -p /var/lib/lxc/writed/rootfs/var/run/blackhole/trli-writed-0.sock rotatelog
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
	trli-writed-control -p /var/lib/lxc/writed/rootfs/var/run/blackhole/trli-writed-0.sock newacctresend $2 $3
elif [ "$1" = "status" ] ; then # prod: Status of one service
	shift
	while [ "$1" != "" ]
	do
		echo ============== $1 ============
		/var/lib/lxc/$1/status.sh
		shift
	done
elif [ "$1" = "checkupdates" ] ; then # prod: Check all containers are up to date
	for lxc in trlid writed sessiond protocheck exim web webadm webssl sqlddata sqlduser
	do
		if [ -d /var/lib/lxc/$lxc ] ; then
			trli-cmp --name $lxc /var/lib/lxc/$lxc/$lxc.files
		fi
	done
elif [ "$1" = "test-listnews" ] ; then # P: Lists news (WORKERS,NBREP,NBROWS,IDONLY,VERBOSE)
	shift
	/usr/lib/trli-test.sh test-listnews $*
elif [ "$1" = "loadfail" ] ; then # prod: Switch web access (normal,backup,split)
	if [ "$THISSERVER" = "" ] ;then
		echo THISSERVER not defined in trli.conf
		exit 1
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
		while true
		do
			NB1=`blackhole-control connectload | fgrep "$S1" | (read a b c d e; echo $d)` 
			NB2=`blackhole-control connectload | fgrep "$S2" | (read a b c d e; echo $d)` 
			NB3=`blackhole-control connectload | fgrep "$S3" | (read a b c d e; echo $d)` 
			if [ "$NB1" = 0 -a "$NB2" = 0 -a "$NB3" = 0 ] ; then
				echo
				break
			else
				echo -n .
				sleep 1
				#echo $NB1 $NB2 $NB3
			fi
		done
	fi
elif [ "$1" = "calltest" ] ; then # A: Call /usr/lib/trli-test.sh
	export LXCSOCK=on
	shift
	/usr/lib/trli-test.sh $*
elif [ "$1" = "certificate-renew" ] ; then # prod: Renew the SSL certificate
	# Do a backup
	cd /etc
	tar zcf /tmp/letsencrypt-`date +%Y-%m-%d_%H:%M:%S`.tar.gz letsencrypt
	# Make sure the special /root/bin/apachectl is used
	export PATH=/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
	if [ "$2" = "test" ]; then
	        certbot renew --dry-run
	elif [ "$2" = "doit" ] ; then
        	if certbot renew
		then
			$0 restart exim
		fi
	else
        	echo test ou doit
	fi
else
	echo Invalid command
fi

