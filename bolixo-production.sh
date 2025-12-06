#!/usr/bin/sh
## db: Database
## prod: Production
## config: Configuration
## S: Test sequences
## P: Performance
## config: Configuration
## A: Development
## T: Individual tests
## syslog: System logs
## accounts: User accounts
export LANG=eng
TESTSH=/usr/lib/bolixo-test.sh
if ! id $USER 2>/dev/null >/dev/null
then
	echo USER variable wrongly set, ending
	exit 1
fi
getmainip(){
	# We must find the interface
	DEV=`ifconfig | grep ^[a-z]. | grep -v lo: | grep -v veth | grep -v virbr | (read a b; echo $a | sed s/://)`
	ifconfig $DEV | grep "inet " | ( read a b c; echo $b)
}

BOLIXOCONFCREATED=
# For all other command, we create bolixo.conf on the fly
if [ "$1" != "install-required" ] ; then
	if [ ! -f $HOME/bolixo.conf ] ; then
		echo
		echo /root/bolixo.conf must be created from /usr/share/bolixo/bolixo.conf
		if [ ! -x /usr/bin/ifconfig ] ; then
			echo
			echo "    "Attention creation failed
			echo
			echo "    "ifconfig utility not installed
			echo "    "Make sure to run bolixo-production install-required
			echo
			exit 1
		fi
		ROOTPASS=root`date +%N`
		BODPASS=bod`date +%N`
		WRITEDPASS=write`date +%N`
		BOLIXODPASS=bolixod`date +%N`
		ADMINPASS=admin`date +%N`
		HOSTNAME=`hostname`
		MYIP=`getmainip`
		# By default, do not change anything
		PREPROD1="s/#PREPROD/#PREPROD/"
		PREPROD2="s/#THIS/#THIS/"
		case $MYIP in
		192.168.122.*)
			PREPROD1="s/#PREPROD/PREPROD/"
			PREPROD2="s/#THIS/THIS/"
			echo Preproduction server detected
			;;
		esac
		cat /usr/share/bolixo/bolixo.conf | \
			sed "s/rootpass/$ROOTPASS/" | \
			sed "s/bodpass/$BODPASS/" | \
			sed "s/writedpass/$WRITEDPASS/" | \
			sed "s/bolixodpass/$BOLIXODPASS/" | \
			sed "s/adminpass/$ADMINPASS/" | \
			sed "s/_HOSTNAME_/$HOSTNAME/" | \
			sed $PREPROD1 | \
			sed $PREPROD2 \
			>/root/bolixo.conf
		echo
		# Tell install-sequence that bolixo.conf was created
		BOLIXOCONFCREATED=yes
	fi
	. ~/bolixo.conf
fi
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
		echo "   " $1 $2 $3 normal
	elif [ "$W1" = 1 -a "$WF1" = 100 ] ; then
		echo "   " $1 $2 $3 backup
	elif [ "$W1" = 100 -a "$WF1" = 100 ] ; then
		echo "   " $1 $2 $3 split
	else
		echo "***" $1 $2 strange state
	fi
}
STEPLOG=/var/log/bolixo-install.log
step(){
	CMD=$1
	
	echo "**********" bolixo-production $CMD >>$STEPLOG
	if [ "$STEPY" != "" ] ; then
		echo bolixo-production $CMD
		bolixo-production $CMD 2>&1 | tee -a $STEPLOG
	else
		if [ "$STEPy" != "" ]; then
			echo -n bolixo-production $*" (y) "
		else
			echo -n bolixo-production $*" (n) "
		fi
		read line
		if [ "$line" = "n" ] ; then
			echo skipped | tee -a $STEPLOG
		elif [ "$line" = "y" ] ; then
			bolixo-production $CMD 2>&1 | tee -a $STEPLOG
		else
			if [ "$STEPy" != "" ]; then
				bolixo-production $CMD 2>&1 | tee -a $STEPLOG
			else
				echo skipped | tee -a $STEPLOG
			fi
		fi
	fi
}
stepnote(){
	echo -n "$* "
	read line
}
if [ "$1" = ""  -o "$1" = "--manpage" -o "$1" = "--tlmpdoc" ] ; then
	menutest -s $0 $1
elif [ "$1" = "files" ] ; then	# db: Access files database
	shift
	mysql -S /var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock $DBNAME $*
elif [ "$1" = "temp" ] ; then	# db: Access temp database
	shift
	mysql -uroot -S /var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock $DBNAMET $*
elif [ "$1" = "users" ] ; then # db: Access users database
	shift
	mysql -S /var/lib/lxc/bosqlduser/rootfs/var/lib/mysql/mysql.sock $DBNAMEU $*
elif [ "$1" = "bolixo" ] ; then # db: Access bolixo (directory) database
	shift
	mysql -S /var/lib/lxc/bosqldbolixo/rootfs/var/lib/mysql/mysql.sock $DBNAMEBOLIXO $*
elif [ "$1" = "createdb" ] ; then # db: Create databases
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
	ROOTPWD=$MYSQL_PWD
	unset MYSQL_PWD
	/usr/lib/bolixo-test.sh createsqlusers
	if [ -d /var/lib/lxc/bosqlddata/rootfs ] ; then
		/var/lib/lxc/bosqlddata/bosqlddata.runsql mysql </tmp/files.sql
		/var/lib/lxc/bosqlddata/bosqlddata.admsql password $ROOTPWD
		/var/lib/lxc/bosqlddata/bosqlddata.admsql reload
	fi
	if [ -d /var/lib/lxc/bosqlduser/rootfs ] ; then
		/var/lib/lxc/bosqlduser/bosqlduser.runsql mysql </tmp/users.sql
		/var/lib/lxc/bosqlduser/bosqlduser.admsql password $ROOTPWD
		/var/lib/lxc/bosqlduser/bosqlduser.admsql reload
	fi
	if [ -d /var/lib/lxc/bosqldbolixo/rootfs ] ; then
		/var/lib/lxc/bosqldbolixo/bosqldbolixo.runsql mysql </tmp/bolixo.sql
		/var/lib/lxc/bosqldbolixo/bosqldbolixo.admsql password $ROOTPWD
		/var/lib/lxc/bosqldbolixo/bosqldbolixo.admsql reload
	fi
elif [ "$1" = "checks" ]; then # A: Sanity checks blackhole
	if blackhole-control status >/dev/null 2>/dev/null
	then
		echo Blackhole ok
	else
		echo "*** Blackhole not available"
	fi
	if horizon-control status 2>/dev/null| grep -F unix:/var/run/blackhole/horizon-master.sock | grep -q MASTER
	then
		echo horizon connected
	else
		echo "*** Horizon not connected"
	fi
elif [ "$1" = "blackhole-start" ]; then # config: Starts blackholes service or reload
	startserv(){
		echo Start $1
		if [ -x /etc/init.d/$1 ] ;then
			/etc/init.d/$1 start
		else
			systemctl start $1
		fi
	}
	reloadserv(){
		echo Reload $1
		if [ -x /etc/init.d/$1 ] ;then
			/etc/init.d/$1 reload
		else
			systemctl reload $1
		fi
	}
	if killall -0 conproxy 2>/dev/null
	then
		echo conproxy is running
	else
		startserv conproxy
	fi
	if killall -0 horizon 2>/dev/null
	then
		reloadserv horizon
	else
		startserv horizon
	fi
	if killall -0 blackhole 2>/dev/null
	then
		reloadserv blackhole
	else
		startserv blackhole
	fi
elif [ "$1" = "blackhole-enable" ] ; then # config: Enable blackhole service at server start
	systemctl enable blackhole horizon conproxy
elif [ "$1" = "getmainip" ] ; then # config: Get public IP of this server
	getmainip
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
		MYIP=`$0 getmainip`
		sed "s/ #CLI/ $CLI/g" </usr/share/bolixo/manager.conf \
			| sed "s/ #ADM/ $ADM/g" \
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
elif [ "$1" = "coturn-config" ] ; then # config: Install and configure the coturn server
	COTURNCONF=/etc/coturn/turnserver.conf
	if [ -f $COTURNCONF.original ] ; then
		echo
		echo coturn-config can only be used once
		echo To rerun this command, move $COTURNCONF.original to $COTURNCONF
		echo
		exit 1
	fi
	if rpm -q coturn >/dev/null 2>/dev/null
	then
		echo "    "coturn is already installed
	else
		dnf install coturn
	fi
	cp $COTURNCONF $COTURNCONF.original
	NAME=`hostname`
	SECRET=`cat /etc/bolixo/vidconf.secret`
	MYIP=`$0 getmainip`
	cat <<-EOF >>$COTURNCONF
response-origin-only-with-rfc5780
realm=$NAME
server-name=$NAME
fingerprint

listening-ip=$MYIP
external-ip=$MYIP
listening-port=3478
min-port=10000
max-port=20000

use-auth-secret
static-auth-secret=$SECRET
log-file=/var/log/coturn/turnserver.log
verbose
EOF
	echo "    "$COTURNCONF was updated
	echo "    "A copy was done in $COTURNCONF.original
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
	test -d /var/lib/lxc/documentd && /usr/lib/bolixo-test.sh lxc0-documentd
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
elif [ "$1" = "instrument" ] ; then # prod: Turn instrumentation on and off
	if [ "$2" = "" ] ; then
		echo "bolixo-production instrument 0|1"
		exit 1
	fi
	CTRL="bod-controls bo-mon-control bo-writed-control bo-sessiond-control publishd-control documentd-control bo-websocket-control"
	if [ -d /var/lib/lxc/bolixod/rootfs ] ; then
		CTRL="$CTRL bolixod-controls"
	fi
	for cmd in $CTRL
	do
		$0 calltest $cmd instrument $2
	done
elif [ "$1" = "eraseanon" ] ; then # prod: [old (default 1 day) anonymous normal admin]
	OLD=1d
	shift
	if [ "$1" != "" ] ; then
		OLD=$1
		shift
	fi
	if [ $# != 0 -a $# != 3  ]; then
		echo you must supply a flag for every type of account
       		echo The flag is 0 or 1
		echo anonymous user admin
		exit 1
	fi
	echo Erase anonymous session older than $OLD 
	/usr/lib/bolixo-test.sh eraseanon-lxc $OLD $*
elif [ "$1" = "eraseaoldnotes" ] ; then # prod: [old (default 10 day) ]
	OLD=10d
	shift
	if [ "$1" != "" ] ; then
		OLD=$1
		shift
	fi
	/usr/lib/bolixo-test.sh bo-sessiond-control eraseoldnotes $OLD
elif [ "$1" = "listsessions" ] ; then # prod: list web sessions (offset)
	if [ "$2" != "" ] ; then
		OFF=$2
		bo-sessiond-control -p /var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock listsessions $OFF 100
	else
		# List all sessions. Should be done inside bo-sessiond-control
		OFF=0
		while true
		do
			NB=`bo-sessiond-control -p /var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock listsessions $OFF 100 | wc -l`
			if [ "$NB" = 1 ] ; then
				break
			fi
			bo-sessiond-control -p /var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock listsessions $OFF 100 
			OFF=`expr $OFF + 100`
		done
	fi
elif [ "$1" = "who" ] ; then # accounts: who is connected
	echo "Last action          Last ping            User"
	echo "-------------------  -------------------  ---------------------------"
	$0 listsessions | grep ^000 | grep @ | while read a b c d e f g h
	do
		echo "$f  $g  $d"
	done | sort
elif [ "$1" = "listusers" ] ; then # accounts: list user accounts
	shift
	listusers "$@"
elif [ "$1" = "show-interest" ] ; then # accounts: show the interest table
	$0 files --column-names --table <<-EOF
	select id2name.name as User,id2.name as Interest, dirid from interests
		join id2name on id2name.userid=interests.userid
		join id2name as id2 on id2.userid=interests.check_userid
		order by id2name.name,id2.name;
	EOF
elif [ "$1" = "mailctrl" ] ; then # config: Control writed sendmail
	if [ $# != 3 ] ;then
		echo "mailctrl 0|1 force_addr"
		exit 1
	fi
	/usr/lib/bolixo-test.sh mailctrl "$2" "$3"
elif [ "$1" = "test-system" ]; then # prod: Perform a test loop using the bolixo monitor
	time -p bo-mon-control test
elif [ "$1" = "monitor" ] ; then # prod: Reports last run of the bolixo monitor
	bo-mon-control status	
elif [ "$1" = "resetmsg" ] ; then # prod: Reset alarm in bolixo monitor
	$0 syslog-reset
	bo-mon-control resetmsg
elif [ "$1" = "update-script" ] ; then # prod: Apply update scripts
	CURSTATES=/root/update.states
	NEWSTATES=/root/update.newstates
	rm -f $CURSTATES $NEWSTATES
	echo "select name from updates" | bo users >$CURSTATES
	shift
	/usr/lib/bolixo-update -s $CURSTATES -n $NEWSTATES $*
	RET=$?
	if [ -f $NEWSTATES ] ; then
		for state in `cat $NEWSTATES`
		do
			echo "insert into updates (name) values ('$state');" | bo users
		done
	fi
	exit $RET
elif [ "$1" = "restart" ] ; then # prod: restart some services (webs, internals, ...)
	shift
	if $0 update-script --test
	then
		flock --close /var/run/bolixo-restart.lock $0 restart-nolock $*
	else
		echo
		echo "System is not up to date"
		echo "Can't restart $*"
		echo The command
		echo "    bolixo-production update-script --doit"
		echo must be used to update the system
		echo
	fi
elif [ "$1" = "restart-nolock" ] ; then # prod: restart without locking some services (webs, internals, ...)
	shift
	bo-mon-control autotest 0
	if [ "$1" = "" ] ; then
		echo bolixo-production restart service ...
		echo All services may be restarted any time except horizon
		echo services are:
		echo
		echo "    " most "(internals + webs)"
		echo "    " internals "(restart everything except the databases, web and exim)"
		echo "    " sqls "(restart all databases)"
		echo "    " webs "(All four web... services)"
		echo "    " blackhole conproxy
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
	elif [ "$1" = "most" ] ; then
		$0 restart-nolock internals
		$0 instrument 0
		echo
		$0 restart-nolock webs
		echo
		$0 test-system
	else	
		KEYSDPASS=
		SERVICES=
		for serv in $*
		do
			if [ "$serv" = "internals" ] ; then
				SERVICES="$SERVICES bo-mon trli-syslog"
				for std in bolixod bod writed sessiond keysd publishd documentd protocheck
				do
					if [ -d /var/lib/lxc/$std/rootfs ] ; then
						SERVICES="$SERVICES $std"
					fi
				done
				KEYSDPASS=needed
			elif [ "$serv" = "sqls" ] ; then
				for db in bosqlddata bosqlduser bosqldbolixo
				do
					if [ -d /var/lib/lxc/$db/rootfs ] ; then
						SERVICES="$SERVICES $db"
					fi
				done
			elif [ "$serv" = "keysd" ] ; then
				KEYSDPASS=needed
				SERVICES="$SERVICES keysd"
			else
				SERVICES="$SERVICES $serv"
			fi
		done
		if [ -f /root/keysd.pass ] ;then
			export KEYSDPASS=`cat /root/keysd.pass`
			shred -u /root/keysd.pass
		elif [ "$KEYSDPASS" != "" ]; then
			echo -n "keysd will be restarted, please enter its passphrase : "
			read -s KEYSDPASS
			echo
		fi
		keysd_restarted=
		if $0 stop-stop
		then
			for serv in $SERVICES
			do
				echo "   " $serv
				if [ "$serv" = "keysd" ] ; then
					keysd_restarted=true
				fi
				if [ "$serv" = "horizon" ] ; then
					systemctl restart horizon
					for file in /var/lib/lxc/*/horizon-start.sh
					do
						$file
					done
					/var/lib/lxc/bo-mon-stop.sh
					/var/lib/lxc/bo-mon-start.sh
					bo-mon-control autotest 0
				elif [ "$serv" = "blackhole" ] ; then
					systemctl restart blackhole
				elif [ "$serv" = "conproxy" ] ; then
					systemctl restart conproxy
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
			# Process delayed scripts
			MUSTSLEEP=1
			for serv in $SERVICES
			do
				DELAYED=/var/lib/lxc/$serv/$serv.start-delayed
				if [ -x $DELAYED ] ; then
					if [ "$MUSTSLEEP" = 1 ] ; then
						sleep 2
						MUSTSLEEP=0
					fi
					$DELAYED
				fi
			done
			if [ "$keysd_restarted" != "" ] ; then
				echo Service keysd was restarted, passphrase in place
				sleep 0.5
				if /usr/sbin/bo-keysd-control -p /var/lib/lxc/keysd/rootfs/var/run/blackhole/bo-keysd.sock setpassphrase $KEYSDPASS
				then
					echo Pass phrase ok
				else
					echo ERROR: Pass phrase wrong
					/usr/sbin/bo-keysd-control -p /var/lib/lxc/keysd/rootfs/var/run/blackhole/bo-keysd.sock setpassphrase
				fi
			fi
			$0 stop-start
		else
			echo "*** Can't stop the web"
			echo "*** Try to restart anyway"
			$0 stop-start
		fi
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
elif [ "$1" = "syslog-logerrs" ] ; then # syslog: Shows the syslog error lines
	trli-syslog-control logerrs
elif [ "$1" = "writed-sendmail" ] ; then # S: writed will send a mail
	if [ ! -f /etc/bolixo/admins.conf ] ; then
		echo /etc/bolixo/admins.conf not configured
		exit 1
	fi
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
elif [ "$1" = "newacctresend" ] ; then # accounts: Resend account confirmation mail [ to_stdout ]
	if [ "$2" = "" ] ; then
		echo newacctresend email [ to_stdout ]
		exit 1
	fi
	/usr/lib/bolixo-test.sh bo-writed-control newacctresend $2 $3
elif [ "$1" = "confirmuser" ] ; then # accounts: Confirm a new user account
	if [ "$3" = "" ] ; then
		echo confirmuser nickname email
		exit 1
	fi
	/usr/lib/bolixo-test.sh bo-writed-control confirmuser $2
	/usr/lib/bolixo-test.sh bod-control publishemail $2 $3
elif [ "$1" = "del_incomplete" ] ; then # accounts: Deletes un-confirmed user accounts (seconds)
	shift
	/usr/lib/bolixo-test.sh bo-writed-control del_incomplete $1 
elif [ "$1" = "disable" ] ; then # accounts: Disable one user account
	shift
	/usr/lib/bolixo-test.sh bo-writed-control disable $1 
elif [ "$1" = "enable" ] ; then # accounts: Enable one user account
	shift
	/usr/lib/bolixo-test.sh bo-writed-control enable $1 
elif [ "$1" = "status" ] ; then # prod: Status of one service
	shift
	if [ "$1" = "" ] ; then
		echo -n "List of Bolixo components: "
		for dir in /var/lib/lxc/*
		do
			if [ -x $dir/status.sh ] ; then
				echo -n `basename $dir` " "
			fi
		done
		echo
	else
		while [ "$1" != "" ]
		do
			echo ============== $1 ============
			script=/var/lib/lxc/$1/status.sh
			if [ ! -x $script ] ; then
				echo $1 is not a bolixo component
			else
				/var/lib/lxc/$1/status.sh
			fi
			shift
		done
	fi
elif [ "$1" = "checkupdates" ] ; then # prod: Check all containers are up to date
	for lxc in bod writed sessiond keysd bolixod protocheck exim web webadm webssl bosqlddata bosqlduser bosqldbolixo
	do
		if [ -d /var/lib/lxc/$lxc ] ; then
			trli-cmp --name $lxc /var/lib/lxc/$lxc/$lxc.files
		fi
	done
elif [ "$1" = "update" ] ; then # prod: Update all bolixo related packages using dnf
	shift
	exec dnf update  --disablerepo "*" --enablerepo bolixo --refresh "$@"
elif [ "$1" = "loadfail" ] ; then # prod: Switch web access (normal,backup,split)
	if [ "$THISSERVER" = "" ] ;then
		THISSERVER=localhost
	fi
	if [ "$2" = "normal" ] ; then
		W1=100
		W2=1
		WAIT=backup
		DISCONNECT=web-fail
		S1="$THISSERVER web-fail 80"
		S2="$THISSERVER web-fail /var/run/websocket.sock"
		S3="$THISSERVER webssl-fail$VSOURCE 80"
		S4="$THISSERVER webssl-fail$VSOURCE 443"
	elif [ "$2" = "backup" ] ; then
		W1=1
		W2=100
		WAIT=normal
		DISCONNECT=web
		S1="$THISSERVER web 80"
		S2="$THISSERVER web /var/run/websocket.sock"
		S3="$THISSERVER webssl$VSOURCE 80"
		S4="$THISSERVER webssl$VSOURCE 443"
	elif [ "$2" = "split" ] ; then
		W1=100
		W2=100
		S1=
		S2=
		S3=
		S4=
	else
		echo normal,backup or split
		check_loadfail web web-fail 80
		check_loadfail web web-fail /var/run/websocket.sock
		check_loadfail webssl$VSOURCE webssl-fail$VSOURCE 80
		check_loadfail webssl$VSOURCE webssl-fail$VSOURCE 443
		exit 1
	fi
	echo Switching to web mode $2
	blackhole-control setweight $THISSERVER web 80 $W1
	blackhole-control setweight $THISSERVER web-fail 80 $W2
	blackhole-control setweight $THISSERVER web /var/run/websocket.sock $W1
	blackhole-control setweight $THISSERVER web-fail /var/run/websocket.sock $W2
	blackhole-control setweight $THISSERVER webssl$VSOURCE 80 $W1
	blackhole-control setweight $THISSERVER webssl-fail$VSOURCE 80 $W2
	blackhole-control setweight $THISSERVER webssl$VSOURCE 443 $W1
	blackhole-control setweight $THISSERVER webssl-fail$VSOURCE 443 $W2
	# Now we wait for the connections to vanish on the normal or backup side
	if [ "$$1" != "" ] ; then
		# kill all notification sockets. Those socket takes a long time to end normally.
		/usr/sbin/bo-sessiond-control -p /var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock disconnect_waitings
		/usr/sbin/bo-websocket-control -p /var/lib/lxc/$DISCONNECT/rootfs/var/run/websocket-control.sock disconnectworkers
		echo -n "Waiting for $WAIT connections to end : "
		COUNT=0
		while true
		do
			NB1=`blackhole-control connectload | grep -F "$S1" | (read a b c d e; echo $d)` 
			NB2=`blackhole-control connectload | grep -F "$S2" | (read a b c d e; echo $d)` 
			NB3=`blackhole-control connectload | grep -F "$S3" | (read a b c d e; echo $d)` 
			NB4=`blackhole-control connectload | grep -F "$S4" | (read a b c d e; echo $d)` 
			if [ "$NB1" = 0 -a "$NB2" = 0 -a "$NB3" = 0 -a $NB4 = 0 ] ; then
				echo
				break
			else
				COUNT=`expr $COUNT + 1`
				if [ "$COUNT" = "10" ] ; then
					echo
					echo $NB1 $S1
					echo $NB2 $S2
					echo $NB3 $S3
					echo $NB4 $S4
					COUNT=0
				fi
				echo -n .
				/usr/sbin/bo-sessiond-control -p /var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock disconnect_waitings
				sleep 1
			fi
		done
	fi
elif [ "$1" = "deleteitems" ] ; then # db: Delete items and check integrity
	export DELETEITEMS_PWD=$BO_WRITED_PWD
	shift
	MAXUSER=`$0 users -s <<-EOF
		SELECT auto_increment FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'users';
	EOF`
	deleteitems --data_socket /var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock --data_dbserv localhost --data_dbname files --data_dbuser bowrited --maxuserid $MAXUSER --integrity $@
elif [ "$1" = "deleteoldmsgs" ] ; then # prod: Delete old msgs
	shift
	flock --close /var/run/bolixo-restart.lock /usr/sbin/deleteoldmsgs $*
elif [ "$1" = "calltest" ] ; then # A: Call /usr/lib/bolixo-test.sh
	export LXCSOCK=on
	shift
	/usr/lib/bolixo-test.sh "$@"
elif [ "$1" = "certificate-install" ]; then # config: Install the SSL certificate
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
elif [ "$1" = "certificate-renew" ] ; then # prod: Renew the SSL certificate: test|doit [ host-name ]
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
        	echo test or doit [ host-name ]
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
	LIST="lxc lxc-templates \
		mariadb-server mariadb-connector-c boost-date-time \
		liberation-sans-fonts dejavu-sans-fonts freetype httpd mod_ssl \
		dejavu-serif-fonts stockfish \
		libvirt-daemon libvirt-daemon-driver-network \
		libvirt-daemon-config-network libvirt-client \
		libvirt-daemon-driver-qemu bridge-utils \
		time strace exim vim-enhanced certbot python3-certbot-apache \
		bash-completion wget ImageMagick qqwing dnsmasq ebtables net-tools iptables"
	echo The following packages must be installed
	echo
	echo $LIST
	echo
	echo -n "Would you like to install them now (y/n) ? "
	read yes
	if [ "$yes" = "y" ] ; then
		dnf install $LIST
	fi
elif [ "$1" = "generate-system-pubkey" ] ; then # config: Generate the node public key
	/usr/lib/bolixo-test.sh generate-system-pubkey
elif [ "$1" = "registernode" ] ; then # config: Register this node in the directory
	/usr/lib/bolixo-test.sh registernode
elif [ "$1" = "createadmin" ] ; then # config: Create the admin acccount
	/usr/lib/bolixo-test.sh createadmin
elif [ "$1" = "start-everything" ] ; then # config: Start all bolixo services
	journalctl -u bolixo -f &
	systemctl start bolixo
	vkillall -n ROOT -q journalctl
elif [ "$1" = "genkeysdpass" ] ; then # config: Generate the bo-keysd passphrase
	echo -n `date +%N` >/root/keysd.pass
	dd if=/dev/random count=8 bs=1 2>/dev/null | od -x | head -1 | (read a b c d e; echo $b$c$d$e) >>/root/keysd.pass 
	cp -f /root/keysd.pass /root/keysd.pass.backup
	echo
	echo "**** Attention *****"
	echo
	echo "A pass phrase for the private keys management daemon bo-keysd"
	echo "has been generated in file /root/keysd.pass.backup"
	echo "You must retrieve this pass phrase and store it safely"
	echo
	echo "Once stored, erase this file using the following command"
	echo "    "shred -u /root/keysd.pass.backup
	echo
	echo "Leaving this file there won't make administration simpler"
	echo
elif [ "$1" = "disable-some-services" ] ; then # config: Disable services mariadb,exim and httpd
	checkserv(){
		if vkillall -n ROOT -t -q $2
		then
			echo "    "Service $1 is running, incompatible with Bolixo, stopped and disabled
			systemctl stop $1
			systemctl disable $1
		elif systemctl is-enabled $1 >/dev/null
		then
			echo "    "Disable $1
			systemctl disable $1
		fi
	}
	checkserv httpd httpd
	if systemctl is-active httpd.socket >/dev/null
	then
		echo "    "Stop httpd.socket
		systemctl stop httpd.socket
	fi
	if systemctl is-enabled httpd.socket >/dev/null
	then
		echo "    "Disable httpd.socket
		systemctl disable httpd.socket
	fi
	checkserv exim exim
	checkserv mariadb mariadbd
elif [ "$1" = "make-lxc0-logs" ] ; then # config: Produce lxc0 logs for exim, httpd and mariadb if needed
	if [ ! -f /root/stracelogs/log.web -o ! -f /root/stracelogs/log.exim -o ! -f /root/stracelogs/log.mysql ] ; then
		echo lxc0 log files are missing in /root/stracelogs
		echo we must execute the following commands:
		echo
		echo "  "bolixo-production make-httpd-log
		bolixo-production make-httpd-log
		echo
		echo "  "bolixo-production make-mysql-log
		bolixo-production make-mysql-log
		echo
		echo "  "bolixo-production make-exim-log
		bolixo-production make-exim-log
		
	fi
elif [ "$1" = "config_admins_conf" ] ; then # config: Configure the file /etc/bolixo/admin.conf
	CONF=/etc/bolixo/admins.conf
	if [ -f $CONF ] ; then
		ADMIN=`grep ^ADMIN1= $CONF | sed s/ADMIN1=//`
		if [ "$ADMIN" != "" ] ; then
			echo File $CONF already configured. Email will be sent to $ADMIN
			exit 0
		else
			echo File $CONF exist, but does not contain the ADMIN1= line
		fi
	else
		echo "# Enter the email of the person or group responsible for Bolixo alert" >$CONF
		echo "ADMIN1=" >>$CONF
		echo File $CONF has been created
	fi
	echo -n "Would you like to edit the file ? y/n "
	read line
	if [ "$line" = "y" ] ; then
		vim $CONF
	fi
elif [ "$1" = "install-sequence" ] ; then # config: Interative sequence to start a node from scratch
	echo
	echo "All messages logged to $STEPLOG"
	echo
	STEPy=on
	STEPY=
	if [ "$2" = "-y" ] ; then
		# Default for step() function is yes
		STEPy=on
	elif [ "$2" = "-n" ] ; then
		# Default for step() function is no
		STEPy=
	elif [ "$2" = "-Y" ] ; then
		# Batch mode: The step function default to yes
		STEPY=on
	elif [ "$2" != "" ] ; then
		echo "bolixo-production install-sequence [ -n | -y | -Y ]"
		echo "  -n: enter means don't do it"
		echo "  -y: enter means do it"
		echo "  -Y: batch mode, yes to all"
		exit 1
	fi
	echo "#### install-sequence " `date` >>$STEPLOG
	echo The host name is `hostname`
	echo -n "Is this valid (y/n) ?"
	read yes
	if [ "$yes" != "y" ] ; then
		echo
		echo PLease fix that and restart bolixo-production install-sequence. Aborting
		if [ "$BOLIXOCONFCREATED" != "" ] ; then
			rm -f $HOME/bolixo.conf
			echo $HOME/bolixo.conf was deleted, it will be created next time you lauch install-sequence
		fi
		echo
		exit 1
	fi
	step disable-some-services
	step make-lxc0-logs
	step secrets
	stepnote edit/configure /root/data/manager.conf /root/.bofs.conf, press enter when done
	step config
	step coturn-config
	step blackhole-start
	step blackhole-enable
	step checks
	step lxc0s
	step genkeysdpass
	step config_admins_conf
	step start-everything
	step createsqluser
	step createdb
	step test-system
	echo
	echo "There are errors with the bod service: adm_sess=0. This is normal"
	echo "There are errors also in the syslog service: normal"
	echo
	step generate-system-pubkey
	step createadmin
	step "restart bod"
	step syslog-clear
	step syslog-reset
	step test-system
	echo
	echo The should be no errors this time
	echo
elif [ "$1" = "load-timezones" ]; then # db: load timezone definitions
	$0 calltest load-timezones
elif [ "$1" = "install-sequence-publish" ] ; then # config: Complete install-sequence once everything is running
	step registernode
	echo Register admin for this node in the directory
	ADMINH=admin@`hostname`
	echo bofs bolixoapi recordemail $THISNODE admin $ADMINH
	bofs bolixoapi recordemail $THISNODE admin $ADMINH
elif [ "$1" = "running" ] ; then # prod: Enable/Disable all crond tasks
	shift
	RUNFILE=/etc/bolixo/running
	if [ "$1" = "on" ] ; then
		echo Create control file $RUNFILE
		touch $RUNFILE
	elif [ "$1" = "off" ] ; then
		echo Remove control file $RUNFILE
		rm -f $RUNFILE
	else
		echo on or off
	fi
elif [ "$1" = "sqlfixe" ] ; then # prod: Repair SQL after an unclean shutdown
	for sql in data user bolixo
	do
		cd /var/lib/lxc/bosqld$sql || exit -1
		if lxc-info bosqld$sql 2>/dev/null | grep -q RUNNING
		then
			echo SQL $sql is running
		elif [ ! -d data/mysql ] ;then
			echo Recupere bosqld$sql/data/mysql
			mv rootfs/var/lib/mysql data/mysql
			mv rootfs/var/log/mariadb/mariadb.log data/mariadb.log
		else
			echo SQL $sql is not running, clean shutdown
		fi
	done
	if [ "$2" = "start" ]; then
		for sql in data user bolixo
		do
			/var/lib/lxc/bosqld$sql/bosqld$sql.start
		done
	fi
elif [ "$1" = "exim-runq" ] ; then # prod: Execute runq on te exim container
	lxc-attach -n exim runq
elif [ "$1" = "exim-rm" ] ; then # prod: Remove some message from exim queue
	shift
	eximrm $@
elif [ "$1" = "exim-mailq" ] ; then # prod: Print exim queue
	lxc-attach -n exim mailq
elif [ "$1" = "account-unlock" ] ; then # accounts: unlock an account
	if [ "$2" = "" ]; then
		echo account name
		exit 1
	fi
	if $0 account-exist $2 >/dev/null
	then
		$0 users <<-EOF
		update users set nbfail=0 where name = '$2';
		EOF
	fi
elif [ "$1" = "account-status" ] ; then # accounts: show account status
	if [ "$2" = "" ]; then
		echo account name
		exit 1
	fi
	$0 users --table <<-EOF
	select name,email,nbfail,created,confirmed,lastaccess,deleted,disabled from users where name = '$2';
	EOF
elif [ "$1" = "account-exist" ] ; then # accounts: tell if one account exist
	if [ "$2" = "" ]; then
		echo account name
		exit 1
	fi
	COUNT=`$0 users -s <<-EOF
	select count(*) from users where name = '$2';
	EOF`
	if [ "$COUNT" = 1 ]; then
		echo account exist
		exit 0
	else
		echo account does not exist >&2
		exit 1
	fi
else
	echo Invalid command
fi

