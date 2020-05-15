#!/bin/sh
## db: Database
## prod: Production
## S: Test sequences
## P: Performance
## config: Configuration
## A: Development
## T: Individual tests
. ~/bolixo.conf
if [ "$BOLIXOPATH" = "" ] ; then
	BOLIXOPATH=`pwd`
fi
if [ "$BOLIXOCONF" = "" ] ; then
	BOLIXOCONF=`pwd`/data
fi
if [ "$BOLIXOLOG" = "" ] ; then
	BOLIXOLOG=/tmp
fi
BOFS=bofs
if [ -x ./bofs ] ; then
	BOFS=./bofs
fi
INCLUDELANGS="-e /usr/lib/tlmp/help.eng/bolixo.eng -e /usr/lib/tlmp/help.fr/bolixo.fr"
SOCKU=/var/lib/lxc/bosqlduser/rootfs/var/lib/mysql/mysql.sock
SOCKN=/var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock
SOCKB=/var/lib/lxc/bosqldbolixo/rootfs/var/lib/mysql/mysql.sock
EXTRALXCPROG="$EXTRALXCPROG -d/var/run/blackhole -d/var/log/bolixo -e /etc/localtime"
HORIZONIP1=192.168.4.1
IPSESSIOND=192.168.5.4
WRITEDLOG=/tmp/bo-writed.log
SOCKTESTDIR=/tmp/tests
if [ -d /var/run/tests ] ; then
	SOCKTESTDIR=/var/run/tests
fi
BODCLIENTPORT=$SOCKTESTDIR/B-bod-*-client-9000.sock
BODADMINPORT=$SOCKTESTDIR/B-bod-*-admin-9000.sock
SESSIONDADMINPORT=$SOCKTESTDIR/A-sessiond-*-admin-9200.sock
SESSIONDCLIENTPORT=$SOCKTESTDIR/A-sessiond-*-client-9200.sock
if [ "$LXCSOCK" = "" ] ; then
	LXCSOCK=on
fi
if [ "$LXCSOCK" == "on" ] ; then
	BOLIXOD_SOCK=/var/lib/lxc/bolixod/rootfs/var/run/blackhole/bolixod-0.sock
	BOLIXOD_SOCKS=/var/lib/lxc/bolixod/rootfs/var/run/blackhole/bolixod-*.sock
	PUBLISHD_SOCK=/var/lib/lxc/publishd/rootfs/var/run/blackhole/publishd.sock
	DOCUMENTD_SOCK=/var/lib/lxc/documentd/rootfs/var/run/blackhole/documentd.sock
	WEBSOCKET_SOCK=/var/lib/lxc/web/rootfs/var/run/websocket-control.sock
	BOD_SOCK=/var/lib/lxc/bod/rootfs/var/run/blackhole/bod-2.sock
	BOD_SOCKS=/var/lib/lxc/bod/rootfs/var/run/blackhole/bod-*.sock
	WRITED_SOCK=/var/lib/lxc/writed/rootfs/var/run/blackhole/bo-writed-0.sock
	SESSIOND_SOCK=/var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock
	KEYSD_SOCK=/var/lib/lxc/keysd/rootfs/var/run/blackhole/bo-keysd.sock
	WRITEDLOG=/var/lib/lxc/writed/rootfs/var/log/bolixo/bo-writed.log
	BO_MON_SOCK=/var/run/blackhole/bo-mon.sock
elif [ "$BOD_SOCK" = "" ] ; then
	BOLIXOD_SOCK=/tmp/bolixod.sock
	PUBLISHD_SOCK=/tmp/publishd.sock
	DOCUMENTD_SOCK=/tmp/documentd.sock
	BOD_SOCK=/tmp/bod.sock
	WRITED_SOCK=/tmp/bo-writed.sock
	SESSIOND_SOCK=/tmp/bo-sessiond.sock
	KEYSD_SOCK=/tmp/bo-keysd.sock
	BO_MON_SOCK=/tmp/bo-mon.sock
fi
if [ -x bo-webtest ] ; then
	BOWEBTEST=./bo-webtest
else
	BOWEBTEST=/usr/sbin/bo-webtest
fi
webtest(){
	#$0 test-system
	page=$1
	url=$2
	shift; shift
	OPTS=
	n=-n50
	N=-N20
	USEEN=
	while [ $# != 0 ]
	do
		case $1 in
		-u)
			shift
			eval `$BOFS -u $1 --printcred`
			USEEN=1
			;;
		-n*)
			n=$1
			;;
		-N*)
			N=$1
			;;
		-T)
			page="$page?test=1"
			;;
		*)
			OPTS="$OPTS $1"
			;;
		esac
		shift
	done
	if [ "$USEEN" = "" ] ; then
		eval `$BOFS --printcred`
	fi
	time -p $BOWEBTEST -f $page -h $url $n $N $OPTS
}
mysql_save(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	SAVE=/var/lib/lxc/$1/$1.save
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $SAVE
	echo "mkdir -p $DATA" >>$SAVE
	echo "test -d $DATA/mysql && echo \"$DATA/mysql directory already exists, can't save\" && exit 1" >>$SAVE
	echo "mv $ROOTFS/var/lib/mysql $DATA/mysql" >>$SAVE
	echo "mv $ROOTFS/var/log/mariadb/mariadb.log $DATA" >>$SAVE
	chmod +x $SAVE
}
mysql_restore(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	REST=/var/lib/lxc/$1/$1.restore
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $REST
	echo "test ! -d $DATA/mysql &&  echo \"$DATA/mysql directory does not exists, can't restore\" && exit 1" >>$REST
	echo "rm -fr $ROOTFS/var/lib/mysql" >>$REST
	echo "mv $DATA/mysql $ROOTFS/var/lib/mysql" >>$REST
	echo "test -f $DATA/mariadb.log && mv $DATA/mariadb.log $ROOTFS/var/log/mariadb/mariadb.log" >>$REST
	chmod +x $REST
}
exim_save(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	SAVE=/var/lib/lxc/$1/$1.save
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $SAVE
	echo "mkdir -p $DATA" >>$SAVE
	echo "test -d $DATA/exim && echo \"$DATA/exim directory already exists, can't save\" && exit 1" >>$SAVE
	echo "mv $ROOTFS/var/spool/exim $DATA/exim" >>$SAVE
	echo "mv $ROOTFS/var/log/exim/main.log $DATA" >>$SAVE
	chmod +x $SAVE
}
exim_restore(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	REST=/var/lib/lxc/$1/$1.restore
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $REST
	echo "test ! -d $DATA/exim &&  echo \"$DATA/exim directory does not exists, can't restore\" && exit 1" >>$REST
	echo "rm -fr $ROOTFS/var/spool/exim" >>$REST
	echo "mv $DATA/exim $ROOTFS/var/spool/exim" >>$REST
	echo "mv $DATA/main.log $ROOTFS/var/log/exim/main.log" >>$REST
	chmod +x $REST
}
writed_save(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	SAVE=/var/lib/lxc/$1/$1.save
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $SAVE
	echo "mkdir -p $DATA" >>$SAVE
	echo "test -d $DATA/bo-writed.log && echo \"$DATA/bo-writed.log already exists, can't save\" && exit 1" >>$SAVE
	echo "mv $ROOTFS/var/log/bolixo/bo-writed.log $DATA/bo-writed.log" >>$SAVE
	echo "umount $ROOTFS/var/lib/bolixo || true" >>$SAVE
	chmod +x $SAVE
}
writed_restore(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	REST=/var/lib/lxc/$1/$1.restore
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $REST
	echo "mkdir -p $ROOTFS/var/lib/bolixo" >>$REST
	echo "mount --bind /var/lib/bolixo $ROOTFS/var/lib/bolixo" >>$REST
	echo "test ! -f $DATA/bo-writed.log &&  echo \"$DATA/bo-writed.log does not exists, can't restore\" && exit 1" >>$REST
	echo "mv $DATA/bo-writed.log $ROOTFS/var/log/bolixo" >>$REST
	chmod +x $REST
}
bolixod_save(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	SAVE=/var/lib/lxc/$1/$1.save
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $SAVE
	echo "mkdir -p $DATA" >>$SAVE
	echo "umount $ROOTFS/var/lib/bolixod || true" >>$SAVE
	chmod +x $SAVE
}
bolixod_restore(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	REST=/var/lib/lxc/$1/$1.restore
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $REST
	echo "mkdir -p $ROOTFS/var/lib/bolixod" >>$REST
	echo "mount --bind /var/lib/bolixod $ROOTFS/var/lib/bolixod" >>$REST
	chmod +x $REST
}
bod_save(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	SAVE=/var/lib/lxc/$1/$1.save
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $SAVE
	echo "mkdir -p $DATA" >>$SAVE
	echo "umount $ROOTFS/var/lib/bolixo || true" >>$SAVE
	chmod +x $SAVE
}
bod_restore(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	REST=/var/lib/lxc/$1/$1.restore
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $REST
	echo "mkdir -p $ROOTFS/var/lib/bolixo" >>$REST
	echo "mount -oro --bind /var/lib/bolixo $ROOTFS/var/lib/bolixo" >>$REST
	chmod +x $REST
}
publishd_save(){
	bod_save $*
}
publishd_restore(){
	bod_restore $*
}
documentd_save(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	SAVE=/var/lib/lxc/$1/$1.save
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $SAVE
	echo "mkdir -p $DATA" >>$SAVE
	echo "rm -f $DATA/game.*" >>$SAVE
	echo "if [ -f $ROOTFS/tmp/game.0 ]; then" >>$SAVE
       	echo "    mv -f $ROOTFS/tmp/game.* $DATA/." >>$SAVE
	echo "else" >>$SAVE
	echo "    true" >>$SAVE
	echo "fi" >>$SAVE
	chmod +x $SAVE
}
documentd_restore(){
	ROOTFS=/var/lib/lxc/$1/rootfs
	REST=/var/lib/lxc/$1/$1.restore
	DATA=/var/lib/lxc/$1/data
	echo "#!/bin/sh" > $REST
	echo "if [ -f $DATA/game.0 ];then" >>$REST
       	echo "    cp -f $DATA/game.* $ROOTFS/tmp/." >>$REST
	echo "    chmod 666 $ROOTFS/tmp/game.*" >>$REST
	echo "else" >>$REST
	echo "    true" >>$REST
	echo "fi" >>$REST
	chmod +x $REST
}
cmpsequence(){
	STOP=$1
	shift
	rm -f /tmp/bofs.testuuids
	ssh root@preprod.bolixo.org rm -f /tmp/bofs.testuuids
	ssh root@preprod2.bolixo.org rm -f /tmp/bofs.testuuids
	ssh root@preprod.bolixo.org bofs --clearpubcache --pubsite test1.bolixo.org
	ssh root@preprod2.bolixo.org bofs --clearpubcache --pubsite test1.bolixo.org
	unset LANG
	CMPDIR=/tmp/cmp-test
	rm -fr $CMPDIR
	mkdir $CMPDIR
	for test in $*
	do
		OPT=
		if [ "$test" = "public" ]; then
			OPT=jacques-A
		fi
		$0 syslog-clear
		echo test=$test
		./scripts/access.sh $test $OPT >$CMPDIR/$test.out 2>$CMPDIR/$test.err
		$0 syslog-logs >$CMPDIR/$test.log
		if [ "$STOP" != "" ] ; then
			$0 test-system
			echo == $test.out
			diff -c ../cmp-test/$test.out /tmp/cmp-test/$test.out
			echo == $test.err
			diff -c ../cmp-test/$test.err /tmp/cmp-test/$test.err
			echo == $test.log
			diff -c ../cmp-test/$test.log /tmp/cmp-test/$test.log
			echo -n "Enter to continue "
			read line
		fi
	done
	$0 bo-sessiond-control resetnotifies
	cd ../cmp-test
	REFTESTDIR=`pwd`
	RUNTESTDIR=/tmp/cmp-test
	cd $RUNTESTDIR
	for file in *
	do
		diff -c $REFTESTDIR/$file /tmp/cmp-test/$file
	done
	NBREF=`ls $REFTESTDIR | wc -l`
	NBTST=`ls $RUNTESTDIR | wc -l`
	if [ "$NBREF" != "$NBTST" ] ; then
		echo "******"
		echo NBREF=$NBREF NBTST=$NBTST
	fi
}
if [ "$1" = "" ] ; then
	if [ -x /usr/sbin/menutest ] ; then
		/usr/sbin/menutest -s $0
	else
		echo "No menutest, can't display help"
	fi
elif [ "$1" = "checks" ]; then # A: Sanity checks
	if blackhole-control -p /tmp/blackhole.sock status >/dev/null 2>/dev/null
	then
		echo Blackhole ok
	else
		echo "*** Blackhole not available"
	fi
	if horizon-control -p /tmp/horizon.sock status 2>/dev/null| fgrep unix:/tmp/horizon-master.sock | grep -q MASTER
	then
		echo horizon connected
	else
		echo "*** Horizon not connected"
	fi
elif [ "$1" = "deleteitems" ] ; then # db: Delete items and check integrity
	export DELETEITEMS_PWD=$BO_WRITED_PWD
	shift
	./deleteitems --data_socket /var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock --data_dbserv localhost --data_dbname files --data_dbuser root --integrity $@
elif [ "$1" = "files" ] ; then	# db: Access files database
	shift
	mysql $* -uroot -S $SOCKN $DBNAME
elif [ "$1" = "users" ] ; then # db: Access users database
	mysql -uroot -S $SOCKU  $DBNAMEU
elif [ "$1" = "bolixo" ] ; then # db: Access bolixo nodes database
	mysql -uroot -S $SOCKB  $DBNAMEBOLIXO
elif [ "$1" = "temp" ] ; then	# db: Access temp database
	mysql -uroot -S $SOCKN $DBNAMET
elif [ "$1" = "bolixod" ] ; then # A: Runs bolixod
	OPTIONS="--mysecret foo --client_secrets $BOLIXOCONF/secrets.client --user $USER \
		--dbserv $BOLIXOD_DBSERV --dbuser $BOLIXOD_DBUSER --dbname $BOLIXOD_DBNAME  \
		--clientport 1"
	shift
	WORKERS=1
	while [ $# -gt 0 ]; do
		if [ "$1" = "debug" ] ; then
			OPTIONS="--debug $OPTIONS"
		elif [ "$1" = "lxc0" ] ; then
			STRACE="strace -o /tmp/log -f"
		else
			WORKERS=$1
		fi
		shift
	done
	if [ "$WORKERS" = 1 ] ;then
		OPTIONS="$OPTIONS --control $BOLIXOD_SOCK"
		if [ "$SILENT" = "on" ] ; then
			echo bolixod
		else
			echo $BOLIXOPATH/bolixod $OPTIONS
		fi
		$STRACE $BOLIXOPATH/bolixod $OPTIONS
	else
		for ((work=0; work<$WORKERS; work++))
		do
			PORT=$work
			SOCK="/tmp/bolixod-$work.sock"
			WOPTIONS="$OPTIONS --debugfile /tmp/bolixod.log --clientport $PORT --daemon --control $SOCK"
			echo ./bolixod $WOPTIONS 
			$BOLIXOPATH/bolixod $WOPTIONS
		done
	fi
elif [ "$1" = "documentd" ] ; then # A: Runs bolixod
	OPTIONS="--user $USER \
		--client-secrets $BOLIXOCONF/secrets.client \
		"
	shift
	WORKERS=1
	while [ $# -gt 0 ]; do
		if [ "$1" = "debug" ] ; then
			OPTIONS="--debug $OPTIONS"
		elif [ "$1" = "lxc0" ] ; then
			STRACE="strace -o /tmp/log -f"
		fi
		shift
	done
	OPTIONS="$OPTIONS --control $DOCUMENTD_SOCK"
	if [ "$SILENT" = "on" ] ; then
		echo documentd
	else
		echo $BOLIXOPATH/documentd $OPTIONS
	fi
	mkdir -p /var/lib/lxc/documentd/rootfs/var/run/blackhole
	$STRACE $BOLIXOPATH/documentd $OPTIONS
elif [ "$1" = "publishd" ] ; then # A: Runs bolixod
	OPTIONS="--user $USER \
		--hostname test1.bolixo.org --client_secrets $BOLIXOCONF/secrets.client \
		--dbserv $BOD_DBSERV --dbuser $BOD_DBUSER --dbname $BOD_DBNAME  \
		"
	shift
	WORKERS=1
	while [ $# -gt 0 ]; do
		if [ "$1" = "debug" ] ; then
			OPTIONS="--debug $OPTIONS"
		elif [ "$1" = "lxc0" ] ; then
			STRACE="strace -o /tmp/log -f"
		fi
		shift
	done
	OPTIONS="$OPTIONS --control $PUBLISHD_SOCK"
	if [ "$SILENT" = "on" ] ; then
		echo publishd
	else
		echo $BOLIXOPATH/publishd $OPTIONS
	fi
	$STRACE $BOLIXOPATH/publishd $OPTIONS
elif [ "$1" = "bod" ] ; then # A: Runs bod
	OPTIONS="--mysecret foo --admin_secrets $BOLIXOCONF/secrets.admin --client_secrets $BOLIXOCONF/secrets.client --user $USER \
		--dbserv $BOD_DBSERV --dbuser $BOD_DBUSER --dbname $BOD_DBNAME --bindaddr 0.0.0.0 \
		--sqltcpport 3307 --adminhost $HORIZONIP1 --sesshost $HORIZONIP1 --workers 1 --nodename=foo"
	shift
	WORKERS=1
	while [ $# -gt 0 ]; do
		if [ "$1" = "debug" ] ; then
			OPTIONS="--debug $OPTIONS"
		elif [ "$1" = "lxc0" ] ; then
			STRACE="strace -o /tmp/log -f"
		else
			WORKERS=$1
		fi
		shift
	done
	if [ "$WORKERS" = 1 ] ;then
		OPTIONS="$OPTIONS --control $BOD_SOCK"
		if [ "$SILENT" = "on" ] ; then
			echo bod
		else
			echo $BOLIXOPATH/bod $OPTIONS
		fi
		$STRACE $BOLIXOPATH/bod $OPTIONS
	else
		for ((work=0; work<$WORKERS; work++))
		do
			PORT=`expr 9000 + $work`
			SOCK="/tmp/bod-$work.sock"
			WOPTIONS="$OPTIONS --debugfile /tmp/bod.log --tcpport $PORT --daemon --control $SOCK"
			echo ./bod $WOPTIONS 
			$BOLIXOPATH/bod $WOPTIONS
		done
	fi
elif [ "$1" = "bo-writed" ] ; then # A: Runs writed
	OPTIONS="--logfile $BOLIXOLOG/bo-writed.log --user $USER --secrets $BOLIXOCONF/secrets.client \
		--mysecret adm --mypubsecret cli --data_dbserv $BO_WRITED_DBSERV --data_dbuser $BO_WRITED_DBUSER --data_dbname $BO_WRITED_DBNAME \
		--users_dbserv $BO_WRITED_DBSERV --users_dbuser $BO_WRITED_DBUSER --users_dbname $BO_WRITED_DBNAMEU \
		--mailfrom no-reply@solucorp.qc.ca --nodename $THISNODE \
		--sessionhost $HORIZONIP1 --sqltcpport 3307"
	shift
	WORKERS=1
	while [ $# -gt 0 ]; do
		if [ "$1" = "debug" ] ; then
			OPTIONS="--debug $OPTIONS"
		elif [ "$1" = "lxc0" ] ; then
			STRACE="strace -o /tmp/log -f"
		else
			WORKERS=$1
		fi
		shift
	done
	if [ "$WORKERS" = 1 ] ;then
		OPTIONS="$OPTIONS --control /tmp/bo-writed.sock"
		if [ "$SILENT" = "on" ]; then
			echo writed
		else
			echo $BOLIXOPATH/bo-writed $OPTIONS 
		fi
		$STRACE $BOLIXOPATH/bo-writed $OPTIONS
	else
		for ((work=0; work<$WORKERS; work++))
		do
			PORT=`expr 9100 + $work`
			SOCK="/tmp/bo-writed-$work.sock"
			WOPTIONS="$OPTIONS --tcpport $PORT --daemon --control $SOCK"
			echo ./bo-writed $WOPTIONS 
			$BOLIXOPATH/bo-writed $WOPTIONS
		done
	fi
elif [ "$1" = "bo-sessiond" ] ; then # A: Runs sessiond
	OPTIONS="--control /tmp/bo-sessiond.sock --user $USER --client-secrets $BOLIXOCONF/secrets.client \
		--admin-secrets $BOLIXOCONF/secrets.admin --bindaddr $IPSESSIOND" 
	shift
	while [ $# -gt 0 ] ; do
		if [ "$1" = "debug" ] ; then
			OPTIONS="--debug $OPTIONS"
		elif [ "$1" = "lxc0" ] ; then
			STRACE="strace -o /tmp/log -f"
		fi
		shift
	done
	if [ "$SILENT" = "on" ] ; then
		echo sessiond
	else
		echo $BOLIXOPATH/bo-sessiond $OPTIONS
	fi
	$STRACE $BOLIXOPATH/bo-sessiond $OPTIONS
elif [ "$1" = "bo-keysd" ] ; then # A: Runs keysd
	OPTIONS="--control /tmp/bo-keysd.sock --user $USER \
		--data_dbserv $BO_WRITED_DBSERV --data_dbuser $BO_WRITED_DBUSER \
		--users_dbserv $BO_WRITED_DBSERV --users_dbuser $BO_WRITED_DBUSER"
	shift
	while [ $# -gt 0 ] ; do
		if [ "$1" = "debug" ] ; then
			OPTIONS="--debug $OPTIONS"
		elif [ "$1" = "lxc0" ] ; then
			STRACE="strace -o /tmp/log -f"
		fi
		shift
	done
	if [ "$SILENT" = "on" ] ; then
		echo keysd
	else
		echo $BOLIXOPATH/bo-keysd $OPTIONS
	fi
	$STRACE $BOLIXOPATH/bo-keysd $OPTIONS
elif [ "$1" = "documentd" ] ; then # A: Runs documentd
	./documentd -c /tmp/documentd.sock --admin-secrets data/secrets.admin --user `id -un`
elif [ "$1" = "reload" ] ; then # S: Reloads the database using writed log
	$0 resetdb
	OPTIONS="--data_dbserv $DBSERV --data_dbuser $TRLI_WRITED_DBUSER --data_dbname $DBNAME \
		--users_dbserv $DBSERVU --users_dbuser $TRLI_WRITED_DBUSER --users_dbname $DBNAMEU \
		--sqltcpport 3307"
	LOG=$WRITEDLOG
	if [ "$2" != "" ] ; then
		LOG=$2
	fi
	./trli-log $OPTIONS $LOG
elif [ "$1" = "reload-lxc" ] ; then # S: Reloads the database using writed log
	export LXCSOCK=on
	$0 reload /var/lib/lxc/writed/rootfs/tmp/bo-writed.log
elif [ "$1" = "dumplog" ] ;then # S: Shows the writed log
	./trli-log --dump --normuuid /var/lib/lxc/writed/rootfs/tmp/bo-writed.log
elif [ "$1" = "cmplog" ] ;then # S: Compares the writed log with the reference
	./trli-log --dump --normuuid /tmp/bo-writed.log >/tmp/normuuid.log
	diff -c data/normuuid.log /tmp/normuuid.log
elif [ "$1" = "cmplxclog" ] ;then # S: Compares the lxc writed log with the reference
	./trli-log --dump --normuuid /var/lib/lxc/writed/rootfs/tmp/bo-writed.log >/tmp/normuuid.log
	diff -c data/normuuid.log /tmp/normuuid.log
elif [ "$1" = "bolixod-control" ] ; then # A: Talks to bolixod
	shift
	$BOLIXOPATH/bolixod-control --control $BOLIXOD_SOCK $*
elif [ "$1" = "bolixod-controls" ] ; then # A: Talks to all bolixod
	shift
	for sock in $BOLIXOD_SOCKS
	do
		$BOLIXOPATH/bolixod-control --control $sock $*
	done
elif [ "$1" = "bo-websocket-control" ] ; then # A: Talks to bo-websocket
	shift
	$BOLIXOPATH/bo-websocket-control --control $WEBSOCKET_SOCK $*
elif [ "$1" = "documentd-control" ] ; then # A: Talks to documentd
	shift
	$BOLIXOPATH/documentd-control --control $DOCUMENTD_SOCK $*
elif [ "$1" = "publishd-control" ] ; then # A: Talks to publishd
	shift
	$BOLIXOPATH/publishd-control --control $PUBLISHD_SOCK $*
elif [ "$1" = "bod-control" ] ; then # A: Talks to bod
	shift
	$BOLIXOPATH/bod-control --control $BOD_SOCK $*
elif [ "$1" = "bod-controls" ] ; then # A: Talks to all bod servers
	shift
	for sock in $BOD_SOCKS
	do
		$BOLIXOPATH/bod-control --control $sock $*
	done
elif [ "$1" = "bod-client" ] ; then # A: Executes the bod test client
	shift
	$BOLIXOPATH/bod-client --host "" -p $BODCLIENTPORT --adm_port $BODADMINPORT \
		--sessclientport $SESSIONDCLIENTPORT --sessport $SESSIONDADMINPORT --client_secret foo --admin_secret adm "$@"
elif [ "$1" = "bo-writed-control" ] ; then # A: Talks to writed
	shift
	$BOLIXOPATH/bo-writed-control --control $WRITED_SOCK "$@"
elif [ "$1" = "bo-sessiond-control" ] ; then # A: Talks to sessiond
	shift
	$BOLIXOPATH/bo-sessiond-control --control $SESSIOND_SOCK $*
elif [ "$1" = "bo-keysd-control" ] ; then # A: Talks to keysd
	shift
	$BOLIXOPATH/bo-keysd-control --control $KEYSD_SOCK $*
elif [ "$1" = "createbolixodb" ] ; then # db: Create bolixo nodes database
	ENGINE=myisam
	mysqladmin -uroot -S $SOCKB create $DBNAMEBOLIXO
	mysql -uroot -S $SOCKB $DBNAMEBOLIXO <<-EOF
		create table nodes (
			nodeid int primary key auto_increment,
			nodename varchar(100),
			nbuser int default 0,
			created datetime default current_timestamp,
			pub_key text default null
		)engine=$ENGINE;
		create index nodes_nodename on nodes (nodename);
		create table users (
			userid int primary key auto_increment,
			nodeid int,
			name char(40),
			fullname char(40),
			address1 varchar(100),
			address2 varchar(100),
			city varchar(50),
			zipcode varchar(20),
			state varchar(40),
			country varchar(40),
			email varchar(100),
			phone varchar(40),
			fax varchar(40),
			bolixosite varchar(100),
			website varchar(100),
			interest text
		)engine=$ENGINE;
		create index users_name on users (name);
		create index users_nodeid on users (nodeid);
		create table emails (
			nodeid int,
			userid varchar(40),
			email varchar(100)
		)engine=$ENGINE;
		create index emails_email on emails (email);
		create index emails_userid on emails (userid);
		create index emails_nodeid on emails (nodeid);
	EOF
elif [ "$1" = "createdb" ] ; then # db: Create databases
	ENGINE=myisam
	mysqladmin -uroot -S $SOCKU create $DBNAMEU
	mysql -uroot -S $SOCKU $DBNAMEU <<-EOF
		create table users (
			userid int primary key auto_increment,
			userid_str char(40),
			deleteid char(40),
			name char(50),
			password char(41),
			email varchar(100),
			admin bool default false,
			nbfail int default 0,
			created datetime default current_timestamp,
			confirmed datetime default null,
			lastaccess datetime default null,
			deleted datetime default null,
			disabled datetime default null,
			priv_key text default null,
			pub_key text default null
		)engine=$ENGINE;
		create index users_email on users (email);
		create index users_idstr on users (userid_str);
		insert into users (userid,userid_str,name,confirmed) values (-2,"--system--","--system--",now());
		create table user_interest (
			userid int,
			subjectid int
		)engine=$ENGINE;
		create index user_sub on user_interest (userid,subjectid);
	EOF
	mysqladmin -uroot -S $SOCKN create $DBNAME
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		create table id2name(
			userid int not null,
			name char(50),
			pub_key text default null
		)engine=$ENGINE;
		create unique index id2name_userid on id2name (userid);
		create unique index id2name_name   on id2name (name);
		insert into id2name (userid,name) values (-1,"Anonymous");
		insert into id2name (userid,name) values (-2,"--system--");

		create table ids (
			id int primary key auto_increment,
			ownerid int default null,
			group_list_id int default null,
			listmode char default ' ',
			uuid char(21)
		) engine=$ENGINE;
		create index ids_uuid on ids (uuid);
		--insert into ids (id,ownerid,uuid) values (0,0,"root");
		--update ids set id=0 where uuid='root';

		create table files (
			id int,
			modified datetime default current_timestamp,
			filetype tinyint unsigned default 0,
			title varchar(200),
			content text,
			signature varchar(400),
			modifiedby int default 0
		)engine=$ENGINE;
		create index files_id on files (modified,id);

		create table dirs_content (
			dirid int,
			itemid int,
			eventtime datetime(6) default current_timestamp,
			modified datetime,
			type tinyint unsigned,
			name varchar(100),
			copiedby int default 0
		) engine=$ENGINE;
		create index dirs_content_dirid on dirs_content (dirid);
		create index dirs_content_name on dirs_content (name);
		create index dirs_content_itemid on dirs_content (itemid);
		create index dirs_content_eventtime on dirs_content (eventtime);
		create table groups (
			id int primary key auto_increment,
			ownerid int,
			name varchar(100),
			description varchar(100) default ''
		)engine=$ENGINE;
		create unique index groups_owner on groups(ownerid,name);
		create table group_members(
			groupid int,
			userid int,
			role varchar(20) default null,
			access char
		)engine=$ENGINE;
		create unique index group_members_id on group_members (groupid,userid);
		create table group_lists(
			id int primary key auto_increment,
			ownerid int,
			name varchar(100),
			description varchar(100) default ''
		)engine=$ENGINE;
		create unique index group_lists_owner on group_lists(ownerid,name);
		create table group_list_members(
			group_list_id int,
			groupid int,
			defaultaccess char
		)engine=$ENGINE;
		create index group_list_members_id on group_list_members(group_list_id);
		create table marks(
			userid int,
			itemid int,
			modified datetime
		)engine=$ENGINE;
		create unique index marks_ids on marks(userid,itemid);
		create table contact_requests(
			userid int,
			reqid int,
			message varchar(200) default ' ',
			status tinyint unsigned default 0,
			reqdate datetime default current_timestamp
		)engine=$ENGINE;
		create unique index contact_requests_ids on contact_requests(userid,reqid);
		create table config(
			userid int,
			lang char(10) default 'eng',
			dateformat tinyint default 0,
			public_view tinyint default 0,
			public_dir varchar(30) default ''
		)engine=$ENGINE;
		create unique index config_userid on config(userid);	
		create table interests(
			userid int,
			check_userid int,
			dirid int,
			since date
		)engine=$ENGINE;
		create index interests_userid on interests(userid);
		create index interests_checkid on interests(check_userid);
		create table userinfo(
			userid int,
			publish tinyint default 0,
			bosite_visible tinyint default 0,
			publish_photo tinyint default 0,
			publish_miniphoto tinyint default 0,
			fullname char(40),
			address1 varchar(100),
			address2 varchar(100),
			city varchar(50),
			zipcode varchar(20),
			state varchar(40),
			country varchar(40),
			email varchar(100),
			phone varchar(40),
			fax varchar(40),
			website varchar(100),
			interest text
		)engine=$ENGINE;
		create unique index userinfo_userid on userinfo(userid);
	EOF
	$0 createdb-patch1
	$0 createdb-patch2
	$0 createdb-patch4
	$0 createdb-patch6
	$0 createdb-patch7
	$0 createdb-patch8
	mysqladmin -uroot -S $SOCKN create $DBNAMET
	mysql -uroot -S $SOCKN $DBNAMET <<-EOF
		create table formids(
			id int primary key auto_increment,
			formid varchar(100),
			sessionid char(30)
		)engine=$ENGINE;
		create unique index formids_formid on formids(formid,sessionid);
		create table formvars(
			id int,
			name varchar(100),
			val text
		)engine=$ENGINE;
		create index formvars_id on formvars(id);
	EOF
	if [ "$ADMINPASSWORD" = "" ] ; then
		echo ADMINPASSWORD is not defined in ~/bolixo.conf
		echo -n "Enter password: "	
		read ADMINPASSWORD
	fi
	# Fill the updates table
	if [ -x utils/bolixo-update ] ; then
		CMD="utils/bolixo-update --list-updates -c update-script --statefile /dev/null"
	else
		CMD="/usr/lib/bolixo-update --list-updates --statefile /dev/null"
	fi
	$CMD | while read name
	do
		echo "insert into updates (name) values ('$name');" | $0 users
	done
elif [ "$1" = "createdb-patch1" ]; then # db: add nodes table to db files
	ENGINE=myisam
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		create table nodes (
			nodeid int primary key auto_increment,
			nodename varchar(100),
			created datetime default current_timestamp,
			pub_key text default null
		)engine=$ENGINE;
		create unique index nodes_nodename on nodes (nodename);
		create table interests_remote(
			userid int,
			nodename varchar(100),
			created datetime default current_timestamp
		)engine=$ENGINE;
		create index interests_userid on interests_remote (userid);
	EOF
elif [ "$1" = "createdb-patch2" ]; then # db: add anonymous messages
	ENGINE=myisam
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		alter table config add anon_messages tinyint unsigned default 0;
	EOF
elif [ "$1" = "createdb-patch3" ]; then # db: add eventtime index to dirs_content
	ENGINE=myisam
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		create index dirs_content_eventtime on dirs_content (eventtime);
	EOF
elif [ "$1" = "createdb-patch4" ]; then # db: add notifications table
	ENGINE=myisam
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		create table notifications(
			userid int,
			notify_key varchar(100),
			ui tinyint unsigned default 1,
			active_ui tinyint unsigned default 0,
			email tinyint unsigned default 0,
			digest tinyint unsigned	default 0
		)engine=$ENGINE;
		create unique index notification_userid on notifications(userid,notify_key);
	EOF
elif [ "$1" = "createdb-patch5" ]; then # db: make formvars name varchar(100)
	ENGINE=myisam
	mysql -uroot -S $SOCKN $DBNAMET <<-EOF
		alter table formvars modify name varchar(100);
	EOF
elif [ "$1" = "createdb-patch6" ]; then # db: add zone field to table config
	ENGINE=myisam
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		alter table config add timezone varchar(30) default 'system';
	EOF
elif [ "$1" = "createdb-patch7" ]; then # db: add recipients field to table files
	ENGINE=myisam
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		alter table files add recipients varchar(250) default null;
	EOF
elif [ "$1" = "createdb-patch8" ]; then # db: add table updates
	ENGINE=myisam
	mysql -uroot -S $SOCKU $DBNAMEU <<-EOF
		create table updates (
			name char(30),
			done datetime default current_timestamp
		);
	EOF
elif [ "$1" = "load-timezones" ]; then # db: load timezone definitions
	mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -S $SOCKN mysql
elif [ "$1" = "generate-system-pubkey" ] ; then # config: Generate the system public key
	echo Generate --system-- crypto key
	$0 bo-keysd-control genkey --system--
elif [ "$1" = "createadmin" ] ; then # config: Create the admin account
	echo Create admin account
	$0 bo-writed-control mailctrl 0 keep
	$0 bo-writed-control adduser admin admin@$HOSTNAME $ADMINPASSWORD eng \
		&& $0 bo-writed-control confirmuser admin \
		&& $0 bo-writed-control makeadmin admin@$HOSTNAME 1
	$0 bo-writed-control mailctrl 1 keep
	$0 wait-for-keysd
	# Make the admin account visible (public page)
	echo $BOFS -u admin misc -w -V 1
	$BOFS -u admin misc -w -V 1
	$BOFS -u admin cp /var/www/html/admin.jpg bo://projects/admin/public/mini-photo.jpg
	$BOFS -u admin cp /var/www/html/admin-photo.jpg bo://projects/admin/public/photo.jpg
elif [ "$1" = "registernode" ]; then # config: Register this node in bolixo.org
	if [ -s /var/lib/lxc/bolixod/rootfs/var/run/blackhole/bolixod-0.sock ]; then
		$0 bolixod-control deletenode $THISNODE
	fi
	echo Register this node to the directory server
	echo $BOFS bolixoapi registernode $THISNODE
	$BOFS bolixoapi registernode $THISNODE
elif [ "$1" = "dropbolixodb" ] ; then # db: Drop databases
	mysqladmin -uroot -S $SOCKB -f drop $DBNAMEBOLIXO
elif [ "$1" = "dropdb" ] ; then # db: Drop databases
	mysqladmin -uroot -S $SOCKN -f drop $DBNAME
	mysqladmin -uroot -S $SOCKU -f drop $DBNAMEU
	mysqladmin -uroot -S $SOCKN -f drop $DBNAMET
	rm -fr /var/lib/bolixo/*
elif [ "$1" = "filldb" ] ; then # db: Fill database with test accounts (many)
	$0 bo-writed-control mailctrl 0 keep
	echo ==== Create some users
	for user in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z éà
	do
		$0 test-adduser $user
	done
	if [ "$2" = "many" ] ; then
		for ((i=0; i<10; i++))
		do
			for user in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
			do
				$0 test-adduser $user$i
			done
		done
	fi
	if false
	then
		echo ==== Create filesystem
		for dir in /msgs /msg-projects /projects /homes
		do
			$0 test-mkdir admin $dir
			$0 test-set_access admin $dir "" "#all" p
		done
	fi
elif [ "$1" = "resetdb" ] ; then # db: drops and creates databases
	echo Erase $DBNAME and $DBNAMEU database
	$0 dropdb
	echo Create new ones
	$0 createdb
elif [ "$1" = "listsessions" ] ; then # prod: Lists sessions
	export LXCSOCK=on
	$0 bo-sessiond-control listsessions 0 100
elif [ "$1" = "test-system" ] ; then # T: Tests all bolixo components
	shift
	NBREP=1
	if [ "$1" != "" ] ; then
		NBREP=$1
	fi
	$0 bod-client --testsystem --nbrep $NBREP
elif [ "$1" = "test-monitor" ] ; then # T: Tests all bods
	OPT=
	if [ "$2" = verbose ] ; then
		OPT=-v
	fi
	export LXCSOCK=off
	if $0 bo-mon-control test
	then
		echo ok
	else
		echo fail
	fi
elif [ "$1" = "bo-mon-control" ] ; then # A: Talks to bo-mon
	shift
	$BOLIXOPATH/bo-mon-control -p $BO_MON_SOCK $*
elif [ "$1" = "test-createsessions" ] ; then # T: Creates many sessions
	shift
	NBREP=1
	if [ "$1" != "" ] ; then
		NBREP=$1
	fi
	time -p $0 bod-client --testcreatesessions --nbrep $NBREP
	$0 bo-sessiond-control status
elif [ "$1" = "test-adduser" ] ; then # T: Add a user and confirm
	shift
	$0 bod-client --testadduser $1 
elif [ "$1" = "test-addincomplete" ] ; then # T: Adds a user without confirm
	shift
	$0 bod-client --testaddincomplete $1 
elif [ "$1" = "test-delincomplete" ] ; then # T: Deletes un-confirmed user accounts
	shift
	$0 bo-writed-control del_incomplete $1 
elif [ "$1" = "test-deleteuser" ] ; then # T: Deletes one user account
	shift
	$0 bod-client --testdeleteuser $1 --exec1 "$0 bo-sessiond-control listsessions 0 10"
	$0 bo-sessiond-control status
elif [ "$1" = "test-login" ] ; then # T: Login sequence
	shift
	$0 bod-client --testlogin $1 --exec1 "$0 bo-sessiond-control listsessions 0 10"
	$0 bo-sessiond-control status
elif [ "$1" = "test-rotatelog" ] ; then # prod: Rotate writed log
	export LXCSOCKS=on
	mv /var/lib/lxc/writed/rootfs/tmp/writed.log /var/lib/lxc/writed/rootfs/tmp/writed.log.1
	$0 bo-writed-control rotatelog
elif [ "$1" = "test-sequence" ] ; then # S: Reloads database (big,medium,real,nomail)
	./bofs --clearpubcache --pubsite test1.bolixo.org
	./bofs --clearpubcache --pubsite ""
	rm -f $WRITEDLOG
	$0 syslog-clear
	$0 syslog-reset
	$0 bo-writed-control truncatelog	
	ALL=
	MANY=
	CMP=
	CMPSANE=
	shift
	$0 bo-writed-control mailctrl 0 keep
	while [ "$1" != "" ]
	do
		if [ "$1" = "mail" ] ; then
			$0 bo-writed-control mailctrl 1 keep
		elif [ "$1" = "all" ]; then
			ALL=1
		elif [ "$1" = "cmp" ]; then
			CMP=1
		elif [ "$1" = "cmpsane" ]; then
			CMPSANE=1
		elif [ "$1" = "many" ]; then
			MANY=many
		else
			echo unknown keyword $1: mail
			exit 1
		fi
		shift
	done
	$0 dropbolixodb
	$0 createbolixodb
	rm -f /var/lib/bolixo/*
	rm -fr /var/lib/bolixod/*
	$0 resetdb 
	$0 documentd-control endgames
	$0 generate-system-pubkey
	$0 test-system
	$0 registernode
	$0 createadmin
	$0 filldb $MANY
	$0 test-deleteuser E
	$0 test-deleteuser F
	#echo ==== sessions
	#$0 bo-sessiond-control listsessions 0 1000
	$0 bo-writed-control mailctrl 1 keep
	if [ "$ALL" = 1 ] ; then
		./scripts/groups.sh sequence
	fi
	$0 wait-for-keysd
	echo "======= logs ====="
	$0 syslog-logs
	if [ "$CMP" = 1 ] ; then
		echo ======= cmp ======
		$0 cmp-sequence
	elif [ "$CMPSANE" = 1 ] ; then
		echo ======= cmpsane ======
		$0 cmpsane-sequence
	fi
elif [ "$1" = "wait-for-keysd" ] ; then # S: wait until keysd has generated all keys
	echo ======= wait for keysd ====
	$0 bo-keysd-control waitidle
elif [ "$1" = "test-sendmail" ] ;then # prod: ask writed to send one email
	./bo-writed-control -p /var/lib/lxc/writed/rootfs/tmp/bo-writed-0.sock sendmail jack@dns.solucorp.qc.ca test body1
elif [ "$1" = "cmp-sequence" ] ; then # S: Execute QA tests
	cmpsequence "$2" cleartest1 directory createsubdir projects msgs ivldsession public remote-contact remote-interest contact-utf8 notifications \
		remote-sendlarge cp-admin badnames setaccess remote-member delete-group remote-group remote-contact-fail infowrite doc-chess doc-whiteboard
elif [ "$1" = "cmpsane-sequence" ] ; then # S: Execute QA tests
	cmpsequence "$2" cleartest1 directory createsubdir projects msgs  public remote-contact remote-interest contact-utf8 notifications \
		remote-sendlarge cp-admin setaccess remote-member remote-group infowrite
elif [ "$1" = "eraseanon-lxc" ] ; then # prod: [  time [ anonymous normal admin ] ]
	export LXCSOCK=on
	OLD=0d
	ANONYMOUS=1
	NORMAL=0
	ADMIN=0
	if [ "$2" != "" ] ; then
		OLD=$2
	fi
	if [ "$3" != "" ] ; then
		ANONYMOUS="$3"
	fi
	if [ "$4" != "" ] ; then
		NORMAL="$4"
	fi
	if [ "$5" != "" ] ; then
		ADMIN="$5"
	fi
	echo eraseold $OLD $ANONYMOUS $NORMAL $ADMIN
	$0 bo-sessiond-control eraseold $OLD $ANONYMOUS $NORMAL $ADMIN
elif [ "$1" = "test-sequence-lxc" ] ; then # S: Reloads and fills database lxc mode
	export LXCSOCK=on
	shift
	$0 test-sequence $*
elif [ "$1" = "test-listdir" ] ; then # T: List content of a directory (letter dir )
	shift
	if [ "$2" = "" ] ; then
		echo test-listdir letter dirpath
		exit 1
	fi
	$0 bod-client --testlistdir "$1" --extra "$2"
elif [ "$1" = "test-mkdir" ] ; then # T: Add one directory (letter dir )
	shift
	if [ "$2" = "" ] ; then
		echo test-mkdir letter dirpath
		exit 1
	fi
	$0 bod-client --testmkdir "$1" --extra "$2"
elif [ "$1" = "test-rmdir" ] ; then # T: Remove one directory (letter dir )
	shift
	if [ "$2" = "" ] ; then
		echo test-rmdir letter dirpath
		exit 1
	fi
	$0 bod-client --testrmdir "$1" --extra "$2"
elif [ "$1" = "test-addfile" ] ; then # T: Add one file (letter file-path content)
	shift
	if [ "$3" = "" ] ; then
		echo test-addfile letter file-path content
		exit 1
	fi
	$0 bod-client --testaddfile "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-addfile-bob" ] ; then # T: Add one file (letter file-path content-or-abspath)
	shift
	if [ "$3" = "" ] ; then
		echo test-addfile-bob letter file-path content-or-abspath
		exit 1
	fi
	$0 bod-client --testaddfile_bob "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-modifyfile" ] ; then # T: Modify one file (letter dir suffix)
	shift
	if [ "$3" = "" ] ; then
		echo test-modifyfile letter file-path content
		exit 1
	fi
	$0 bod-client --testmodifyfile "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-modifyfile-bob" ] ; then # T: Modify one file (letter file-path content-or-abspath)
	shift
	if [ "$3" = "" ] ; then
		echo test-modifyfile-bob letter file-path content-or-abspath
		exit 1
	fi
	$0 bod-client --testmodifyfile_bob "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-rename" ] ; then # T: Rename a file or directory (letter oldpath newpath)
	shift
	if [ "$3" = "" ] ; then
		echo test-rename letter oldpath newpath
		exit 1
	fi
	$0 bod-client --testrename "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-copy" ] ; then # T: Copy a file or directory (letter srcpath dstpath)
	shift
	if [ "$3" = "" ] ; then
		echo test-copy letter srcpath dstpath
		exit 1
	fi
	$0 bod-client --testcopy "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-readfile" ] ; then # T: Read one file (letter path)
	shift
	if [ "$2" = "" ] ; then
		echo test-readfile letter path
		exit 1
	fi
	$0 bod-client --testreadfile "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-readfile_bob" ] ; then # T: Modify one file (letter path)
	shift
	if [ "$2" = "" ] ; then
		echo test-readfile_bob letter path
		exit 1
	fi
	$0 bod-client --testreadfile_bob "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-delfile" ] ; then # T: Remove one file (letter dir suffix)
	shift
	if [ "$1" = "" ] ; then
		echo test-delfile letter [ dir suffix ]
		exit 1
	fi
	$0 bod-client --testdelfile "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-create_group_list" ] ; then # T: Create a group list (letter listname [ owner ] )
	shift
	if [ "$2" == "" ]; then
		echo test-create_group_list letter listname [ owner ]
		exit 1
	fi
	$0 bod-client --testcreate_group_list "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-create_group" ] ; then # T: Create a group (letter groupname [ owner ] )
	shift
	if [ "$2" == "" ]; then
		echo test-create_group letter groupname [ owner ]
		exit 1
	fi
	$0 bod-client --testcreate_group "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "test-set_group" ] ; then # T: Put a group into a list (letter listname groupname defaultaccess [ owner ] )
	shift
	if [ "$4" == "" ]; then
		echo test-set_group letter listname groupname defaultaccess [ owner ]
		exit 1
	fi
	$0 bod-client --testset_group "$1" --extra "$2" --extra2 "$3" --extra3 "$4" --extra4 "$5"
elif [ "$1" = "test-set_member" ] ; then # T: Put a user into a group (letter groupname user access role [ owner ] )
	shift
	if [ "$4" == "" ]; then
		echo test-set_member letter groupname user access [ role owner ]
		exit 1
	fi
	$0 bod-client --testset_member "$1" --extra "$2" --extra2 "$3" --extra3 "$4" --extra4 "$5" --extra5 "$6"
elif [ "$1" = "test-set_access" ] ; then # T: Assign ownership of a file or directory (letter filename owner listname listmode )
	shift
	if [ "$5" == "" ]; then
		echo test-set_access letter filename owner listname [ listmode ]
		exit 1
	fi
	$0 bod-client --testset_access "$1" --extra "$2" --extra2 "$3" --extra3 "$4" --extra4 "$5"
elif [ "$1" = "test-verifysign" ] ; then # T: Verify the RSA signature of a message [ nbrep http_nbrep ]
	NBREP=1
	HNBREP=1
	if [ "$2" != "" ] ; then
		NBREP=$2
	fi
	if [ "$3" != "" ] ; then
		HNBREP=$3
	fi
	echo Sign a message for user admin/1
	MSG=`./test.sh bo-keysd-control  sign 1 toto1alllllllllllllllllllllllllllllllllllllllllllll`
	echo MSG=$MSG
	echo Validate signature
	./test.sh bod-client --testverifysign admin --extra "$MSG"
	$BOFS               misc --nbrep $NBREP --verifysign --nickname admin --message "$MSG"
	$BOFS -u hjacques-A misc --nbrep $HNBREP --verifysign --nickname admin --message "$MSG"
	echo Validate signature for modified message
	./test.sh bod-client --testverifysign admin --extra "a $MSG"
	$BOFS               misc --verifysign --nickname admin --message "a $MSG"
	$BOFS -u hjacques-A misc --verifysign --nickname admin --message "a $MSG"
elif [ "$1" = "createsqlusers" ] ; then # db: Generates SQL to create users
	TRLISQL=/tmp/files.sql
	USERSQL=/tmp/users.sql
	BOLIXOSQL=/tmp/bolixo.sql
	rm -f $TRLISQL $USERSQL $BOLIXOSQL
	(
	echo "delete from user;"
	echo "delete from db;"
	echo "insert into user (host,user,password,select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Reload_priv,Shutdown_priv,Process_priv,File_priv,Grant_priv,References_priv,
	Index_priv,Alter_priv,Show_db_priv,Super_priv,
	Create_tmp_table_priv,Lock_tables_priv,Execute_priv,Repl_slave_priv,Repl_client_priv,Create_view_priv,Show_view_priv,Create_routine_priv,
        Alter_routine_priv,Create_user_priv,Event_priv,Trigger_priv,Create_tablespace_priv,ssl_cipher,x509_issuer,x509_subject,authentication_string)
	values
	('localhost','root',password('$MYSQL_PWD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','');"
	echo "create user '$BOD_DBUSER'@'localhost' identified by '$BOD_PWD';"
	echo "create user '$BO_WRITED_DBUSER'@'localhost' identified by '$BO_WRITED_PWD';"
	echo "insert into db (host,db,user,select_priv) values ('localhost','$DBNAME','$BOD_DBUSER','y');"
	echo "insert into db (host,db,user,select_priv,Insert_priv,Update_priv,Delete_priv) values ('localhost','$DBNAME','$BO_WRITED_DBUSER','y','y','y','y');"
	echo "insert into db (host,db,user,select_priv,Insert_priv,Update_priv,Delete_priv) values ('localhost','$DBNAMET','$BOD_DBUSER','y','y','y','y');"
	) >$TRLISQL
	(
	echo "delete from user;"
	echo "delete from db;"
	echo "insert into user (host,user,password,select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Reload_priv,Shutdown_priv,Process_priv,File_priv,Grant_priv,References_priv,
	Index_priv,Alter_priv,Show_db_priv,Super_priv,
	Create_tmp_table_priv,Lock_tables_priv,Execute_priv,Repl_slave_priv,Repl_client_priv,Create_view_priv,Show_view_priv,Create_routine_priv,
        Alter_routine_priv,Create_user_priv,Event_priv,Trigger_priv,Create_tablespace_priv,ssl_cipher,x509_issuer,x509_subject,authentication_string)
	values
	('localhost','root',password('$MYSQL_PWD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','');"
	echo "create user '$BO_WRITED_DBUSER'@'localhost' identified by '$BO_WRITED_PWD';"
	echo "insert into db (host,db,user,select_priv,Insert_priv,Update_priv,Delete_priv) values ('localhost','$DBNAMEU','$BO_WRITED_DBUSER','y','y','y','y');"
	) >$USERSQL
	(
	echo "delete from user;"
	echo "delete from db;"
	echo "insert into user (host,user,password,select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Reload_priv,Shutdown_priv,Process_priv,File_priv,Grant_priv,References_priv,
	Index_priv,Alter_priv,Show_db_priv,Super_priv,
	Create_tmp_table_priv,Lock_tables_priv,Execute_priv,Repl_slave_priv,Repl_client_priv,Create_view_priv,Show_view_priv,Create_routine_priv,
        Alter_routine_priv,Create_user_priv,Event_priv,Trigger_priv,Create_tablespace_priv,ssl_cipher,x509_issuer,x509_subject,authentication_string)
	values
	('localhost','root',password('$MYSQL_PWD'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','','','','');"
	echo "create user '$BOLIXOD_DBUSER'@'localhost' identified by '$BOLIXOD_PWD';"
	echo "insert into db (host,db,user,select_priv,Insert_priv,Update_priv,Delete_priv) values ('localhost','$DBNAMEBOLIXO','$BOLIXOD_DBUSER','y','y','y','y');"
	) >$BOLIXOSQL
	$0 createsqlusers-patch1 /tmp/files.sql
	echo $TRLISQL, $USERSQL and $BOLIXOSQL were produced
elif [ "$1" = "createsqlusers-patch1" ] ; then # db: Add publishd to bd files
	if [ "$2" != "" ] ; then
		TRLISQL=$2
	else
		TRLISQL=/tmp/files-patch1.sql
		rm -f $TRLISQL
		echo "use mysql;" >$TRLISQL
		echo "File $TRLISQL is produced"
		echo "run bolixo-production files <$TRLISQL"
		echo "/var/lib/lxc/bosqlddata/bosqlddata.admsql -pdb_root_password reload"
	fi
	(
	echo "create user '$PUBLISHD_DBUSER'@'localhost' identified by '$PUBLISHD_PWD';"
	echo "insert into db (host,db,user,select_priv) values ('localhost','$DBNAME','$PUBLISHD_DBUSER','y');"
	) >>$TRLISQL
elif [ "$1" = "printconfig" ] ; then # config:
	./bo-manager -c data/manager.conf --devmode printconfig localhost
elif [ "$1" = "infraconfig" ] ; then # config: minimal config for development
	BKPATH=/usr/sbin
	if [ "$2" != "" ]; then
			BKPATH=$2
	fi
	./bo-manager --inframode -c data/manager.conf --devmode --devip writed --devip sessiond --devip bod --blackhole_path $BKPATH printconfig testhost
elif [ "$1" = "fullconfig" ] ; then # config: Almost complete configuration for development
	BKPATH=/usr/sbin
	if [ "$2" != "" ]; then
			BKPATH=$2
	fi
	./bo-manager -c data/manager.conf --blackhole_path $BKPATH \
		--boduser $BOD_DBUSER --writeduser $BO_WRITED_DBUSER \
		--devmode printconfig testhost
	#cp alarm.sh /tmp
elif [ "$1" = "prodconfig" ] ; then # config: Complete configuration for production
	BKPATH=/usr/sbin
	if [ "$2" != "" ]; then
			BKPATH=$2
	fi
	$BOLIXOPATH/bo-manager $PREPRODOPTION -c /root/data/manager.conf --blackhole_path $BKPATH \
		--boduser $BOD_DBUSER --writeduser $BO_WRITED_DBUSER \
		printconfig localhost
elif [ "$1" = "infrastatus" ] ; then # prod: Summary of everything
	blackhole-control -p /tmp/blackhole.sock status
	echo
	echo ===horizon
	horizon-control -p /tmp/horizon.sock status
	echo
	echo ===conproxy
	conproxy-control -p /tmp/conproxy.sock status
	conproxy-control -p /tmp/conproxy.sock connections 
	echo
	echo ===rejects
	blackhole-control -p /tmp/blackhole.sock rejects
	echo ===loads
	blackhole-control -p /tmp/blackhole.sock connectload
elif [ "$1" = "rulecon" ] ; then # prod: Summary of used connections
	$0 infrastatus | grep nbcon= | grep -v nbcon=0
elif [ "$1" = "stopall" ] ; then # A: Stop all services with a *.sock in /tmp
	for file in /tmp/*.sock
	do
		case $file in
		/tmp/blackhole.sock)
			blackhole-control -p /tmp/blackhole.sock quit
			rm -f $file
			;;
		/tmp/horizon.sock)
			horizon-control -p /tmp/horizon.sock quit
			rm -f $file
			;;
		/tmp/conproxy.sock)
			conproxy-control -p /tmp/conproxy.sock quit
			rm -f $file
			;;
		/tmp/bod*.sock*)
			./bod-control -p $file quit
			rm -f $file
			;;
		/tmp/bo-writed*.sock)
			./bo-writed-control -p $file quit
			rm -f $file
			;;
		/tmp/bo-sessiond.sock)
			./bo-sessiond-control -p /tmp/bo-sessiond.sock quit
			rm -f $file
			;;
		*)
			echo No rule for file $file
			;;
		esac
	done
elif [ "$1" = "blackhole-control" ] ; then # A: Talks to blackhole
	shift
	blackhole-control -p /tmp/blackhole.sock $*
elif [ "$1" = "lxc0-bolixod" ]; then # prod:
	export LANG=eng
	$0 bolixod lxc0 &
	sleep 1
	# Force bolixod to make a resolver request
	$0 bolixod-control help_connect xxx.bolixo.org 25 quit >/dev/null
	$0 bolixod-control quit
	mkdir -p /var/lib/lxc/bolixod
	trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/bolixod/bolixod.files \
		--savefile /var/lib/lxc/bolixod/bolixod.save \
		--restorefile /var/lib/lxc/bolixod/bolixod.restore \
		-e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
		$EXTRALXCPROG \
		$INCLUDELANGS \
		-i /usr/sbin/trli-init -l /tmp/log -n bolixod -p $BOLIXOPATH/bolixod >/var/lib/lxc/bolixod/bolixod-lxc0.sh
	chmod +x /var/lib/lxc/bolixod/bolixod-lxc0.sh
	bolixod_save bolixod
	bolixod_restore bolixod
elif [ "$1" = "lxc0-publishd" ]; then # prod:
	export LANG=eng
	export LXCSOCK=off
	$0 publishd lxc0 &
	sleep 1
	# Force publishd to make a resolver request
	$0 publishd-control help_connect xxx.bolixo.org 25 quit >/dev/null
	$0 publishd-control quit
	mkdir -p /var/lib/lxc/publishd
	trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/publishd/publishd.files \
		--savefile /var/lib/lxc/publishd/publishd.save \
		--restorefile /var/lib/lxc/publishd/publishd.restore \
		-e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
		$EXTRALXCPROG \
		$INCLUDELANGS \
		-i /usr/sbin/trli-init -l /tmp/log -n publishd -p $BOLIXOPATH/publishd >/var/lib/lxc/publishd/publishd-lxc0.sh
	chmod +x /var/lib/lxc/publishd/publishd-lxc0.sh
	publishd_save publishd
	publishd_restore publishd
elif [ "$1" = "lxc0-documentd" ]; then # prod:
	export LANG=eng
	export LXCSOCK=off
	$0 documentd lxc0 &
	sleep 1
	$0 documentd-control quit
	mkdir -p /var/lib/lxc/documentd
	strace -o /tmp/log.qqwing qqwing --generate 1 --compact --solution --difficulty easy >/dev/null
	trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/documentd/documentd.files \
		--savefile /var/lib/lxc/documentd/documentd.save \
		--restorefile /var/lib/lxc/documentd/documentd.restore \
		$EXTRALXCPROG \
		$INCLUDELANGS \
		-e /usr/share/fonts/dejavu/DejaVuSerif.ttf \
		-e /usr/share/fonts/dejavu/DejaVuSans.ttf \
		-e /usr/share/fonts/liberation*/LiberationSans-Regular.ttf \
		-e /bin/sh \
		-i /usr/sbin/trli-init -l /tmp/log -l /tmp/log.qqwing \
		-n documentd -p $BOLIXOPATH/documentd >/var/lib/lxc/documentd/documentd-lxc0.sh
	chmod +x /var/lib/lxc/documentd/documentd-lxc0.sh
	documentd_save documentd
	documentd_restore documentd
elif [ "$1" = "lxc0-bod" ]; then # prod:
	export LANG=eng
	$0 bod lxc0 &
	sleep 1
	# Force bod to make a resolver request
	$0 bod-control help_connect xxx.bolixo.org 25 quit >/dev/null
	$0 bod-control quit
	mkdir -p /var/lib/lxc/bod
	trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/bod/bod.files \
		--savefile /var/lib/lxc/bod/bod.save \
		--restorefile /var/lib/lxc/bod/bod.restore \
		-e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
		$EXTRALXCPROG \
		$INCLUDELANGS \
		-i /usr/sbin/trli-init -l /tmp/log -n bod -p $BOLIXOPATH/bod >/var/lib/lxc/bod/bod-lxc0.sh
	chmod +x /var/lib/lxc/bod/bod-lxc0.sh
	bod_save bod
	bod_restore bod
elif [ "$1" = "lxc0-writed" ]; then # prod:
	export LANG=eng
	$0 bo-writed lxc0 &
	sleep 1
	$0 bo-writed-control quit
	mkdir -p /var/lib/lxc/writed
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/writed/writed.files \
		--savefile /var/lib/lxc/writed/writed.save \
		--restorefile /var/lib/lxc/writed/writed.restore \
		$EXTRALXCPROG \
		$INCLUDELANGS \
		-i /usr/sbin/trli-init -l /tmp/log -n writed -p $BOLIXOPATH/bo-writed >/var/lib/lxc/writed/writed-lxc0.sh
	chmod +x /var/lib/lxc/writed/writed-lxc0.sh
	writed_save writed
	writed_restore writed
elif [ "$1" = "lxc0-sessiond" ]; then # prod:
	export LANG=eng
	rm -f /tmp/sessions.log
	$0 bo-sessiond lxc0 &
	sleep 1
	$0 bo-sessiond-control quit
	mkdir -p /var/lib/lxc/sessiond
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/sessiond/sessiond.files \
		--savefile /var/lib/lxc/sessiond/sessiond.save \
		--restorefile /var/lib/lxc/sessiond/sessiond.restore \
		$EXTRALXCPROG \
		-i /usr/sbin/trli-init -l /tmp/log -n sessiond -p $BOLIXOPATH/bo-sessiond >/var/lib/lxc/sessiond/sessiond-lxc0.sh
	chmod +x /var/lib/lxc/sessiond/sessiond-lxc0.sh
elif [ "$1" = "lxc0-keysd" ]; then # prod:
	export LANG=eng
	$0 bo-keysd lxc0 &
	sleep 1
	$0 bo-keysd-control quit
	mkdir -p /var/lib/lxc/keysd
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/keysd/keysd.files \
		--savefile /var/lib/lxc/keysd/keysd.save \
		--restorefile /var/lib/lxc/keysd/keysd.restore \
		$EXTRALXCPROG \
		-i /usr/sbin/trli-init -l /tmp/log -n keysd -p $BOLIXOPATH/bo-keysd >/var/lib/lxc/keysd/keysd-lxc0.sh
	chmod +x /var/lib/lxc/keysd/keysd-lxc0.sh
elif [ "$1" = "lxc0-proto" ]; then # prod:
	export LANG=eng
	echo proto
	DATA=data/http_check.conf
	if [ -f /etc/bolixo/http_check.conf ] ; then
		DATA=/etc/bolixo/http_check.conf
	fi
	strace -o /tmp/log /usr/sbin/protocheck-2factors --control /tmp/protocheck-0.sock --user apache --pidfile /tmp/protocheck-0.pid --daemon --follow_mode --unlocked --bind 127.0.0.7 --port 9080 \
		--http $DATA --learnfile /tmp/learn.log
	/usr/sbin/protocheck-2factors-control -p /tmp/protocheck-0.sock quit
	mkdir -p /var/lib/lxc/protocheck
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/protocheck/protocheck.files \
		--savefile /var/lib/lxc/protocheck/protocheck.save \
		--restorefile /var/lib/lxc/protocheck/protocheck.restore \
		$EXTRALXCPROG \
		-i /usr/sbin/trli-init -l /tmp/log -n protocheck -p /usr/sbin/protocheck-2factors >/var/lib/lxc/protocheck/protocheck-lxc0.sh
	chmod +x /var/lib/lxc/protocheck/protocheck-lxc0.sh
elif [ "$1" = "make-httpd-log" ] ; then # config: httpd strace log for lxc0
	mkdir -p /root/stracelogs
	echo  httpd is started. Wait and killall httpd in another console
	strace -f -o /root/stracelogs/log.web /usr/sbin/httpd 
	echo /root/stracelogs/log.web was produced
elif [ "$1" = "lxc0-web" ]; then # prod:
	#su - root -c "nohup strace -o /tmp/log.root -f /usr/sbin/httpd --daemon"
	#su - root -c "killall httpd"
	ROOTLOG=/root/stracelogs/log.web
	LOG=/tmp/log.web
	if [ -f $ROOTLOG ] ; then
		LOG=$ROOTLOG
	elif [ ! -f $LOG ] ; then
		echo $LOG missing
		echo do strace -f -o $LOG /usr/sbin/httpd
		echo killall httpd
		exit 1
	fi
	echo web
	strace -f -o /tmp/log.web2 /var/www/cgi-bin/tlmpweb >/dev/null
	if [ -x utils/dnsrequest ] ; then
		strace -f -o /tmp/log.web3 utils/dnsrequest >/dev/null
	elif [ -f /usr/lib/dnsrequest ] ; then
		strace -f -o /tmp/log.web3 /usr/lib/dnsrequest >/dev/null
	fi
	if [ -x bo-websocket ] ; then
		strace -f -o /tmp/log.web4 ./bo-websocket --help >/dev/null
	elif [ -f /usr/sbin/bo-websocket ] ; then
		strace -f -o /tmp/log.web4 /usr/sbin/bo-websocket --help >/dev/null
	fi
	for w in web web-fail
	do
		JOURNEY=
		if [ -f /var/www/html/journey.hc ] ; then
			JOURNEY="-e /var/www/html/journey.hc"
		fi
		mkdir -p /var/lib/lxc/$w
		/usr/sbin/trli-lxc0 $LXC0USELINK \
			--filelist /var/lib/lxc/$w/$w.files \
			--savefile /var/lib/lxc/$w/$w.save \
			--restorefile /var/lib/lxc/$w/$w.restore \
			--preserve /tmp/agent.log \
			--preserve /tmp/login.log \
			$EXTRALXCPROG \
			-i /usr/sbin/trli-init -l $LOG -l /tmp/log.web2 -l /tmp/log.web3 -l /tmp/log.web4 \
			-e /var/www/html/index.hc \
			-e /var/www/html/webapi.hc \
			-e /var/www/html/bolixoapi.hc \
			-e /var/www/html/bolixo.hc \
			-e /var/www/html/public.hc \
			$JOURNEY \
			-e /usr/lib/tlmp/templates/default/webtable.tpl \
			-e /usr/sbin/trli-stop \
			-e /usr/lib/tlmp/lib/tlmpdoc.so.1 \
			-e /usr/lib/tlmp/lib/tlmpwebsql.so.1 \
			-e /usr/lib/tlmp/lib/tlmpsql.so \
			-e /usr/lib/tlmp/help.eng/tlmpsql.eng \
			-e /usr/lib/tlmp/help.eng/bolixo.eng \
			-e /usr/lib/tlmp/help.fr/bolixo.fr \
			-e /usr/lib/tlmp/help.fr/tlmpsql.fr \
			-e /usr/lib/tlmp/help.fr/tlmpweb.fr \
			-e /var/www/html/.tlmplibs \
			-e /usr/share/fonts/dejavu/DejaVuSerif.ttf \
			-e /usr/share/fonts/dejavu/DejaVuSans.ttf \
			-e /usr/share/fonts/liberation*/LiberationSans-Regular.ttf \
			-e /var/www/html/no-mini-photo.jpg \
			-e /var/www/html/no-photo.jpg \
			-e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
			-n $w -p /usr/sbin/httpd >/var/lib/lxc/$w/$w-lxc0.sh
			chmod +x /var/lib/lxc/$w/$w-lxc0.sh
	done
	if false
	then
		echo webadm
		mkdir -p /var/lib/lxc/webadm
		/usr/sbin/trli-lxc0 $LXC0USELINK \
			--filelist /var/lib/lxc/webadm/webadm.files \
			--savefile /var/lib/lxc/webadm/webadm.save \
			--restorefile /var/lib/lxc/webadm/webadm.restore \
			$EXTRALXCPROG \
			-i /usr/sbin/trli-init -l $LOG -l /tmp/log.web2 \
			-e /var/www/html/admin.hc \
			-e /usr/sbin/trli-stop \
			-n webadm -p /usr/sbin/httpd >/var/lib/lxc/webadm/webadm-lxc0.sh
		chmod +x /var/lib/lxc/webadm/webadm-lxc0.sh
	fi
elif [ "$1" = "lxc0-webssl" ]; then # prod:
	ROOTLOG=/root/stracelogs/log.web
	LOG=/tmp/log.web
	if [ -f $ROOTLOG ] ; then
		LOG=$ROOTLOG
	elif [ ! -f $LOG ] ; then
		echo $LOG missing
		exit 1
	fi
	echo webssl
	for w in webssl webssl-fail
	do
		mkdir -p /var/lib/lxc/$w
		/usr/sbin/trli-lxc0 $LXC0USELINK \
			--filelist /var/lib/lxc/$w/$w.files \
			--savefile /var/lib/lxc/$w/$w.save \
			--restorefile /var/lib/lxc/$w/$w.restore \
			-d /var/www/html \
			$EXTRALXCPROG \
			-e /var/www/html/favicon.ico \
			-e /var/www/html/robots.txt \
			-e /var/www/html/private.png \
			-e /var/www/html/zip.png \
			-e /var/www/html/bolixo.png \
			-e /var/www/html/background.png \
			-e /var/www/html/new.png \
			-e /var/www/html/modified.png \
			-e /var/www/html/seen.png \
			-e /var/www/html/back.png \
			-e /var/www/html/terms-of-use.html \
			-e /var/www/html/conditions-d-utilisation.html \
			-e /var/www/html/dot3-fr.jpg \
			-e /var/www/html/dot3.jpg \
			-e /var/www/html/main-fr.jpg \
			-e /var/www/html/main.jpg \
			-e /var/www/html/project-fr.jpg \
			-e /var/www/html/project.jpg \
			-e /var/www/html/talk1-fr.jpg \
			-e /var/www/html/talk1.jpg \
			-e /var/www/html/talk2-fr.jpg \
			-e /var/www/html/talk2.jpg \
			-e /var/www/html/talk3-fr.jpg \
			-e /var/www/html/talk3.jpg \
			-e /var/www/html/talk-fr.jpg \
			-e /var/www/html/talk.jpg \
			-e /var/www/html/talk-list.jpg \
			-e /var/www/html/talk-list-fr.jpg \
			-e /var/www/html/talk-msgs.jpg \
			-e /var/www/html/talk-msgs-fr.jpg \
			-e /var/www/html/talk-documents.jpg \
			-e /var/www/html/talk-documents-fr.jpg \
			-e /var/www/html/talk-menu.jpg \
			-e /var/www/html/talk-menu-fr.jpg \
			-e /var/www/html/profile.jpg \
			-e /var/www/html/profile-fr.jpg \
			-e /var/www/html/inbox-ui.jpg \
			-e /var/www/html/inbox-ui-fr.jpg \
			-e /var/www/html/group-inbox-ui.jpg \
			-e /var/www/html/group-inbox-ui-fr.jpg \
			-e /var/www/html/narrowscreen.jpg \
			-e /var/www/html/email-outline.svg \
			-e /var/www/html/email-open-outline.svg \
			-e /var/www/html/notifications.jpg \
			-e /var/www/html/notifypopup.jpg \
			-e /var/www/html/notifications-fr.jpg \
			-e /var/www/html/notifypopup-fr.jpg \
			-e /var/www/html/list-infoline.jpg \
			-e /var/www/html/list-infoline-fr.jpg \
			-e /var/www/html/sudoku.jpg \
			-e /var/www/html/sudoku-fr.jpg \
			-e /var/www/html/checkers.jpg \
			-e /var/www/html/checkers-fr.jpg \
			-e /var/www/html/chess.jpg \
			-e /var/www/html/chess-fr.jpg \
			-e /var/www/html/add-interests.jpg \
			-e /var/www/html/add-interests-fr.jpg \
			-e /var/www/html/contact-request.jpg \
			-e /var/www/html/contact-request-fr.jpg \
			-e /var/www/html/whiteboard-menu.jpg \
			-e /var/www/html/whiteboard.jpg \
			-e /var/www/html/whiteboard-fr.jpg \
			-e /var/www/html/whiteboard-example.jpg \
			-e /var/www/html/whiteboard-example-fr.jpg \
			-i /usr/sbin/trli-init \
			-l $LOG \
			-n $w -p /usr/sbin/httpd >/var/lib/lxc/$w/$w-lxc0.sh
		chmod +x /var/lib/lxc/$w/$w-lxc0.sh
	done
elif [ "$1" = "make-mysql-log" ] ; then # config: mysql strace log for lxc0
	mkdir -p /root/stracelogs
	if [ ! -d /var/lib/mysql/mysql ] ; then
		echo Initialize base mysql tables
		mysql_install_db --user=mysql
	fi
	echo "wait a bit and do 'mysqladmin shutdown' in another console"
	strace -f -o /root/stracelogs/log.mysql /usr/libexec/mysqld --basedir=/usr --user=mysql
	echo /root/stracelogs/log.mysql was produced
elif [ "$1" = "lxc0-mysql" ]; then # config:
	ROOTLOG=/root/stracelogs/log.mysql
	LOG=/tmp/log.mysql
	if [ -f $ROOTLOG ] ; then
		LOG=$ROOTLOG
	elif [ ! -f $LOG ] ; then
		echo $LOG missing
		echo do strace -f -o $LOG /usr/libexec/mysqld --basedir=/usr --user=mysql
		echo mysqladmin shutdown
		echo
		echo bolixo-production make-mysql-log
		exit 1
	fi
	if [ -d /var/lib/lxc/bosqlddata ] ; then
		echo bosqlddata
		/usr/sbin/trli-lxc0 $LXC0USELINK \
			$EXTRALXCPROG \
			--filelist /var/lib/lxc/bosqlddata/bosqlddata.files \
			-i /usr/sbin/trli-init \
			-e /usr/bin/mysqladmin -e /usr/bin/mysql \
			-x /var/lib/mysql \
			-l $LOG \
			-n bosqlddata -p /usr/libexec/mysqld >/var/lib/lxc/bosqlddata/bosqlddata-lxc0.sh
		chmod +x /var/lib/lxc/bosqlddata/bosqlddata-lxc0.sh
		mysql_save bosqlddata
		mysql_restore bosqlddata
	fi
	if [ -d /var/lib/lxc/bosqlduser ] ; then
		echo bosqlduser
		/usr/sbin/trli-lxc0 $LXC0USELINK \
			$EXTRALXCPROG \
			--filelist /var/lib/lxc/bosqlduser/bosqlduser.files \
			-i /usr/sbin/trli-init \
			-e /usr/bin/mysqladmin -e /usr/bin/mysql \
			-x /var/lib/mysql \
			-l $LOG \
			-n bosqlduser -p /usr/libexec/mysqld >/var/lib/lxc/bosqlduser/bosqlduser-lxc0.sh
		chmod +x /var/lib/lxc/bosqlduser/bosqlduser-lxc0.sh
		mysql_save bosqlduser
		mysql_restore bosqlduser
	fi
	if [ -d /var/lib/lxc/bosqldbolixo ] ; then
		echo bosqldbolixo
		/usr/sbin/trli-lxc0 $LXC0USELINK \
			$EXTRALXCPROG \
			--filelist /var/lib/lxc/bosqldbolixo/bosqldbolixo.files \
			-i /usr/sbin/trli-init \
			-e /usr/bin/mysqladmin -e /usr/bin/mysql \
			-x /var/lib/mysql \
			-l $LOG \
			-n bosqldbolixo -p /usr/libexec/mysqld >/var/lib/lxc/bosqldbolixo/bosqldbolixo-lxc0.sh
		chmod +x /var/lib/lxc/bosqldbolixo/bosqldbolixo-lxc0.sh
		mysql_save bosqldbolixo
		mysql_restore bosqldbolixo
	fi
elif [ "$1" = "make-exim-log" ] ; then # config: exim strace log for lxc0
	mkdir -p /root/stracelogs
	strace -f -o /root/stracelogs/log.exim /usr/sbin/exim -bd -q1h
	sleep 5
	killall exim
	echo /root/stracelogs/log.exim was produced
elif [ "$1" = "lxc0-exim" ]; then # prod:
	ROOTLOG=/root/stracelogs/log.exim
	LOG=/tmp/log.exim
	if [ -f $ROOTLOG ] ; then
		LOG=$ROOTLOG
	elif [ ! -f $LOG ] ; then
		echo $LOG missing
		echo do strace -f -o /tmp/log.exim /usr/sbin/exim -bd -q1h
		echo killall exim
		exit 1
	fi
	# /bin/bash is needed so lxc-attach works (eximrm and mailq)
	echo exim
	mkdir -p /var/lib/lxc/exim
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		$EXTRALXCPROG \
		--filelist /var/lib/lxc/exim/exim.files \
		-i /usr/sbin/trli-init \
		-l $LOG \
		-e /bin/bash \
		-d /var/spool/exim \
		-d /usr/lib64/exim/*/lookups \
		-n exim -p /usr/sbin/exim  >/var/lib/lxc/exim/exim-lxc0.sh
	echo mkdir -p /var/lib/lxc/exim/rootfs/usr/bin >>/var/lib/lxc/exim/exim-lxc0.sh
	echo ln -s ../sbin/exim /var/lib/lxc/exim/rootfs/usr/bin/runq >>/var/lib/lxc/exim/exim-lxc0.sh
	echo ln -s ../sbin/exim /var/lib/lxc/exim/rootfs/usr/bin/mailq >>/var/lib/lxc/exim/exim-lxc0.sh
	chmod +x /var/lib/lxc/exim/exim-lxc0.sh
	exim_save exim
	exim_restore exim
elif [ "$1" = "lxc0s" ] ; then # prod: generates lxc0 scripts for all components
	export LXCSOCK=off
	$0 checks
	export SILENT=on
	$0 lxc0-bolixod
	$0 lxc0-documentd
	$0 lxc0-publishd
	$0 lxc0-bod
	$0 lxc0-writed
	$0 lxc0-keysd
	$0 lxc0-sessiond
	$0 lxc0-proto
	$0 lxc0-web
	$0 lxc0-webssl
	$0 lxc0-mysql
	$0 lxc0-exim
elif [ "$1" = "webprodtest" ] ; then # P: Webtest on production
	shift
	webtest /index.hc https://alpha.bolixo.org -u alpha/admin $*
elif [ "$1" = "webtest" ] ; then # P:
	shift
	webtest /index.hc http://192.168.4.1:9080 $*
elif [ "$1" = "webtest-static" ] ; then # P:
	shift
	webtest /static.html http://192.168.4.1:9080 $*
elif [ "$1" = "webtest-direct" ] ; then # P:
	if [ "$PREPRODOPTION" != "" ] ; then
		IP=192.168.124.5
	else
		IP=192.168.122.5
	fi
	shift
	webtest /index.hc http://$IP $*
elif [ "$1" = "webtest-direct-static" ] ; then # P:
	#$0 test-system
	shift
	if [ "$PREPRODOPTION" != "" ] ; then
		IP=192.168.124.5
	else
		IP=192.168.122.5
	fi
	webtest /static.html http://$IP $*
elif [ "$1" = "webssltest" ] ; then # P: (bk)
	shift
	if [ "$1" = "bk" ] ; then
		IP=192.168.4.2:9080
		shift
	fi
	webtest /index.hc $THISNODE $*
elif [ "$1" = "webssltest-static" ] ; then # P:
	shift
	webtest /static.html $THISNODE $*
elif [ "$1" = "stop-status" ] ; then # P: status of trli-stop
	echo "==== web ===="
	/usr/sbin/trli-stop-control -p /var/lib/lxc/web/rootfs/tmp/trli-stop.sock status
	#echo "==== webadm ==="
	#/usr/sbin/trli-stop-control -p /var/lib/lxc/webadm/rootfs/tmp/trli-stop.sock status
elif [ "$1" = "stop-stop" ] ; then # P: stop the web
	echo stop-stop: Block internal services
	# We block new requests
	/usr/sbin/trli-stop-control -p /var/lib/lxc/web/rootfs/tmp/trli-stop.sock stop-nowait
	/usr/sbin/bo-websocket-control -p /var/lib/lxc/web/rootfs/var/run/websocket-control.sock pause
	# Then wait for every in flight process to end
	/usr/sbin/trli-stop-control -p /var/lib/lxc/web/rootfs/tmp/trli-stop.sock stop
	#echo webadm
	#/usr/sbin/trli-stop-control -p /var/lib/lxc/webadm/rootfs/tmp/trli-stop.sock stop
elif [ "$1" = "stop-start" ] ; then # P: restart the web
	echo stop-start: Resume internal services access
	/usr/sbin/trli-stop-control -p /var/lib/lxc/web/rootfs/tmp/trli-stop.sock start
	/usr/sbin/bo-websocket-control -p /var/lib/lxc/web/rootfs/var/run/websocket-control.sock resume
	#echo webadm
	#/usr/sbin/trli-stop-control -p /var/lib/lxc/webadm/rootfs/tmp/trli-stop.sock start
elif [ "$1" = "mailctrl" ] ; then # prod: Control writed sendmail
	if [ $# != 3 ] ;then
		echo "mailctrl 0|1 force_addr"
		exit 1
	fi
	$BOLIXOPATH/bo-writed-control -p /var/lib/lxc/writed/rootfs/var/run/blackhole/bo-writed-0.sock mailctrl $2 "$3"
elif [ "$1" = "loadusers" ] ; then # prod: Load users from file
	$0 mailctrl 0 keep
	$0 bod-client --loadusers ~/.bolixo.users
	$0 mailctrl 1 keep
	export LXCSOCK=on
	$0 bo-writed-control makeadmin admin@bolixo.org 1
elif [ "$1" = "checkupdates" ] ; then # prod: Check all containers are up to date
	for lxc in bod writed sessiond protocheck exim web webadm webssl bosqlddata bosqlduser
	do
		if [ -d /var/lib/lxc/$lxc ] ; then
			/usr/sbin/trli-cmp --name $lxc /var/lib/lxc/$lxc/$lxc.files
		fi
	done
elif [ "$1" = "syslog-tail" ] ; then # syslog: show end of syslog
	/usr/sbin/trli-syslog-control tail
elif [ "$1" = "syslog-logs" ] ; then # syslog: show syslogs
	/usr/sbin/trli-syslog-control logs
elif [ "$1" = "syslog-status" ] ; then # syslog: show syslog status
	/usr/sbin/trli-syslog-control status
elif [ "$1" = "syslog-reset" ] ; then # syslog: show syslog reseterrors
	/usr/sbin/trli-syslog-control reseterrors
elif [ "$1" = "syslog-clear" ] ; then # syslog: Clear all messages in syslog
	/usr/sbin/trli-syslog-control clearlogs
elif [ "$1" = "loadcon" ] ; then # prod: Shows connection load
	blackhole-control -p /tmp/blackhole.sock connectload
elif [ "$1" = "loadfail" ] ; then # prod: Control access to normal or fail web (normal,fail,split)
	if [ "$2" = "normal" ] ; then
		blackhole-control -p /tmp/blackhole.sock setweight testhost web 80 100
		blackhole-control -p /tmp/blackhole.sock setweight testhost web-fail 80 1
		blackhole-control -p /tmp/blackhole.sock setweight testhost webssl 80 100
		blackhole-control -p /tmp/blackhole.sock setweight testhost webssl-fail 80 1
	elif [ "$2" = "fail" ] ; then
		blackhole-control -p /tmp/blackhole.sock setweight testhost web 80 1
		blackhole-control -p /tmp/blackhole.sock setweight testhost web-fail 80 100
		blackhole-control -p /tmp/blackhole.sock setweight testhost webssl 80 1
		blackhole-control -p /tmp/blackhole.sock setweight testhost webssl-fail 80 100
	elif [ "$2" = "split" ] ; then
		blackhole-control -p /tmp/blackhole.sock setweight testhost web 80 100
		blackhole-control -p /tmp/blackhole.sock setweight testhost web-fail 80 100
		blackhole-control -p /tmp/blackhole.sock setweight testhost webssl 80 100
		blackhole-control -p /tmp/blackhole.sock setweight testhost webssl-fail 80 100
	else
		echo normal,fail or split
	fi
elif [ "$1" = "instrument" ] ; then # A: Report remote call statistics
	/var/lib/lxc/bod/status.sh >/dev/null	# Force a fflush
	echo -n "bod: "
	(echo -n 0
	cat /var/lib/lxc/bod/rootfs/tmp/instrument.log | while read t a b c
	do
		echo -n +$b
	done
	echo
	) | bc -l
	echo -n "web: "
	(echo -n 0
	cat /var/lib/lxc/web/rootfs/tmp/instrument.log | while read t a b c
	do
		if [ "$a" != "--------" ]; then
			echo -n +$b
		fi
	done
	echo
	) | bc -l
elif [ "$1" = "setnotify" ] ; then # T: Add some notifies in sessiond for jacques-A
	for notify in talks:jacques-A:public talks:jacques-A:anonymous talks:jacques-A:inbox main profile:Contact-req profile:Contacts
	do
		$0 bod-client --testsetnotify $notify --extra 2
	done
elif [ "$1" = "spellcheck" ] ; then # A: Spell check the bolixo.dic file
	utils/helpspell bolixo.dic >/tmp/bolixo.dic
	aspell -l en -c /tmp/bolixo.dic --mode=sgml
elif [ "$1" = "spelldiff" ] ; then # A: Show differences after spell check
	utils/helpspell bolixo.dic >/tmp/bolixo1.dic
	diff -c /tmp/bolixo.dic /tmp/bolixo1.dic | less -S
elif [ "$1" = "perfsql" ] ; then # A: run a performance test on a query
	shift
	if [ "$#" != 1 ] ; then
		echo sql file
		exit 1
	fi
	./perfsql -s localhost -p $MYSQL_PWD -Q $1
elif [ "$1" = "test_firstlines" ]; then # A: test the bod_firstlines function
	TESTFILE=/tmp/firstlines.txt
	>$TESTFILE
	for ((i=0; i<10; i++))
	do
		echo "hello how are you this morning. I was hoping to see you later today, but if it can't be, well, tomorrow is fine." >>$TESTFILE
	done
	./bod --mysecret toto --nodename toto --dbuser toto test_firstlines `cat $TESTFILE`
else
	echo test.sh command ...
fi

