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
if [ "$BOLIXCONF" = "" ] ; then
	BOLIXOCONF=`pwd`/data
fi
if [ "$BOLIXOLOG" = "" ] ; then
	BOLIXOLOG=/tmp
fi
SOCKU=/var/lib/lxc/bosqlduser/rootfs/var/lib/mysql/mysql.sock
SOCKN=/var/lib/lxc/bosqlddata/rootfs/var/lib/mysql/mysql.sock
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
LXCSOCK=on
if [ "$LXCSOCK" != "" ] ; then
	BOD_SOCK=/var/lib/lxc/bod/rootfs/var/run/blackhole/bod-0.sock
	WRITED_SOCK=/var/lib/lxc/writed/rootfs/var/run/blackhole/bo-writed-0.sock
	SESSIOND_SOCK=/var/lib/lxc/sessiond/rootfs/var/run/blackhole/bo-sessiond.sock
	WRITEDLOG=/var/lib/lxc/writed/rootfs/var/log/bolixo/bo-writed.log
elif [ "$BOD_SOCK" = "" ] ; then
	BOD_SOCK=/tmp/bod.sock
	WRITED_SOCK=/tmp/bo-writed.sock
	SESSIOND_SOCK=/tmp/bo-sessiond.sock
fi
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
	echo "mv $DATA/mariadb.log $ROOTFS/var/log/mariadb/mariadb.log" >>$REST
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
elif [ "$1" = "files" ] ; then	# db: Access trli database
	mysql -uroot -S $SOCKN $DBNAME
elif [ "$1" = "users" ] ; then # db: Access trliusers database
	mysql -uroot -S $SOCKU  $DBNAMEU
elif [ "$1" = "bod" ] ; then # A: Runs bod
	OPTIONS="--mysecret foo --admin_secrets $BOLIXOCONF/secrets.admin --client_secrets $BOLIXOCONF/secrets.client --user $USER \
		--dbserv $BOD_DBSERV --dbuser $BOD_DBUSER --dbname $BOD_DBNAME --bindaddr 0.0.0.0 \
		--sqltcpport 3307 --adminhost $HORIZONIP1 --sesshost $HORIZONIP1 --workers 1"
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
		--mysecret adm --data_dbserv $BO_WRITED_DBSERV --data_dbuser $BO_WRITED_DBUSER --data_dbname $BO_WRITED_DBNAME \
		--users_dbserv $BO_WRITED_DBSERV --users_dbuser $BO_WRITED_DBUSER --users_dbname $BO_WRITED_DBNAMEU \
		--mailfrom no-reply@solucorp.qc.ca \
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
elif [ "$1" = "bod-control" ] ; then # A: Talks to bod
	shift
	$BOLIXOPATH/bod-control --control $BOD_SOCK $*
elif [ "$1" = "bod-client" ] ; then # A: Executes the bod test client
	shift
	$BOLIXOPATH/bod-client --host "" -p $BODCLIENTPORT --adm_port $BODADMINPORT --sessport $SESSIONDADMINPORT --client_secret foo --admin_secret adm "$@"
elif [ "$1" = "bo-writed-control" ] ; then # A: Talks to writed
	shift
	$BOLIXOPATH/bo-writed-control --control $WRITED_SOCK "$@"
elif [ "$1" = "bo-sessiond-control" ] ; then # A: Talks to sessiond
	shift
	$BOLIXOPATH/bo-sessiond-control --control $SESSIOND_SOCK $*
elif [ "$1" = "createdb" ] ; then # db: Create databases
	mysqladmin -uroot -S $SOCKU create $DBNAMEU
	mysql -uroot -S $SOCKU $DBNAMEU <<-EOF
		create table users (
			userid int primary key auto_increment,
			userid_str char(40),
			deleteid char(40),
			name char(50),
			password char(41),
			email varchar(100),
			lang int default 0,
			admin bool default false,
			nbfail int default 0,
			created datetime default current_timestamp,
			confirmed datetime default null,
			lastaccess datetime default null,
			deleted datetime default null,
			disabled datetime default null
		);
		create index users_email on users (email);
		create index users_idstr on users (userid_str);
		create table user_interest (
			userid int,
			subjectid int);
		create index user_sub on user_interest (userid,subjectid);
	EOF
	mysqladmin -uroot -S $SOCKN create $DBNAME
	mysql -uroot -S $SOCKN $DBNAME <<-EOF
		create table id2name(
			userid int not null,
			name char(50)
		);
		create unique index userid_idx on id2name (userid);
		insert into id2name (userid,name) values (-1,"Anonymous");

		create table ids (
			id int primary key auto_increment,
			ownerid int default null,
			uuid char(40)
		);
		create index ids_uuid on ids (uuid);

		create table files (
			id int,
			ownerid int default null,
			modified datetime default current_timestamp,
			sign char(40)
		);
		create index files_id on files (id);

		create table dirs_content (
			dirid int,
			itemid int,
			modified datetime,
			type char,
			name varchar(100)
		);
		create index dirs_content on dirs_content (dirid);
	EOF
elif [ "$1" = "dropdb" ] ; then # db: Drop databases
	mysqladmin -uroot -S $SOCKN -f drop $DBNAME
	mysqladmin -uroot -S $SOCKU -f drop $DBNAMEU
elif [ "$1" = "filldb" ] ; then # db: Fill database (old)
	# Put test data
	NEWSCNT1=5
	NEWSCNT2=10
	LONG=
	shift
	while [ "$1" != "" ]
	do
		if [ "$1" = "big" ] ; then
			NEWSCNT1=500
			NEWSCNT2=1000
		elif [ "$1" = "real" ] ; then
			LONG="<br>This is the first ...... line<br>This is the second ............ line<br>This is the third ............line<br>This is the last line"
		else
			echo unknown keyword $1: filldb big,real
			exit 1
		fi
		shift
	done
	echo "truncate table news;"      >/tmp/filldb.sql
	echo "truncate table $DBNAMEU.users;" >>/tmp/filldb.sql
	echo "truncate table comments;" >>/tmp/filldb.sql
	echo "truncate table proofs;"   >>/tmp/filldb.sql
	echo "insert into news (newsid_str,authorid,url,title,content,approved,userid) values" >>/tmp/filldb.sql
	for ((i=1; i<$NEWSCNT1; i++))
	do
		printf	"  ('news%03d',1,'this is url%03d','this is title%03d','content number %03d%s',now(),1),\n" $i $i $i $i "$LONG" >>/tmp/filldb.sql
	done
	for ((i=$NEWSCNT1; i<$NEWSCNT2; i++))
	do
		printf	"  ('news%03d',1,'this is url%03d','this is title%03d','content number %03d%s',null,1),\n" $i $i $i $i "$LONG" >>/tmp/filldb.sql
	done
	printf	"  ('news%03d',1,'this is url%03d','this is title%03d','content number %03d',now(),1);\n" 100 100 100 100 >>/tmp/filldb.sql
	echo "insert into proofs (proofid_str,newsid,title,content,userid) values" >>/tmp/filldb.sql
	for ((i=1; i<10; i++))
	do
		printf	"  ('proof%03d',%d,'Proof title%03d','Proof content number %03d',1),\n" $i $i $i $i >>/tmp/filldb.sql
	done
	printf	"  ('proof%03d',%d,'Proof title%03d','Proof content number %03d',1);\n" 100 100 100 100 >>/tmp/filldb.sql

	#echo "insert into $DBNAMEU.users (userid_str,name,email,admin,password,confirmed) values ('admin-id','admin','admin@foo.com',true,password('admin'),now());" >>/tmp/filldb.sql
	#echo "insert into id2name (userid,name) values (1,'admin-id');" >>/tmp/filldb.sql

	mysql -h$DBSERV $DBNAME </tmp/filldb.sql
elif [ "$1" = "resetdb" ] ; then # db: drops and creates databases
	echo Erase $DBNAME and $DBNAMEU database
	$0 dropdb
	echo Create new ones
	$0 createdb
elif [ "$1" = "listsessions" ] ; then # prod: Lists sessions
	export LXCSOCK=on
	$0 bo-sessiond-control listsessions 0 100
elif [ "$1" = "test-system" ] ; then # T: Tests all trli components
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
	if $BOLIXOPATH/bo-mon-control -p /tmp/bo-mon.sock test
	then
		echo ok
	else
		echo fail
	fi
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
	rm -f $WRITEDLOG
	$0 bo-writed-control truncatelog	
	NEWSCNT1=5
	NEWSCNT2=10
	LONG="This is some text"
	LONGTITLE=
	shift
	$0 bo-writed-control mailctrl 0 keep
	while [ "$1" != "" ]
	do
		if [ "$1" = "big" ] ; then
			NEWSCNT1=500
			NEWSCNT2=1000
		elif [ "$1" = "medium" ] ; then
			NEWSCNT1=50
			NEWSCNT2=100
		elif [ "$1" = "real" ] ; then
			LONGTITLE=" this is a long title, normally long title, as expected"
			LONG="<br>This is the first ...... line<br>This is the second ............ line<br>This is the third ............line<br>This is the last line"
			LONG="$LONG<br>This is the first ...... line<br>This is the second ............ line<br>This is the third ............line<br>This is the last line"
		elif [ "$1" = "mail" ] ; then
			$0 bo-writed-control mailctrl 1 keep
		else
			echo unknown keyword $1: filldb big,real
			exit 1
		fi
		shift
	done
	$0 resetdb 
	$0 test-system
	for user in admin A B C D E F
	do
		$0 test-adduser $user
	done
	echo "Make user admin administrator"
	$0 bo-writed-control makeadmin admin@truelies.news 1
	echo ==== admin
	$0 test-deleteuser D
	$0 test-deleteuser E
	$0 test-deleteuser F
	echo ==== sessions
	$0 bo-sessiond-control listsessions 0 1000
	$0 bo-writed-control mailctrl 1 keep
elif [ "$1" = "test-sendmail" ] ;then # prod: ask writed to send one email
	./bo-writed-control -p /var/lib/lxc/writed/rootfs/tmp/bo-writed-0.sock sendmail jack@dns.solucorp.qc.ca test body1
elif [ "$1" = "eraseanon-lxc" ] ; then # prod:
	export LXCSOCK=on
	NBSEC=0
	if [ "$2" != "" ] ; then
		NBSEC=$2
	fi
	$0 bo-sessiond-control eraseold $NBSEC 1 0 0
elif [ "$1" = "test-sequence-lxc" ] ; then # S: Reloads and fills database lxc mode
	export LXCSOCK=on
	shift
	$0 test-sequence $*
elif [ "$1" = "test-mkdir" ] ; then # T: Add one director (letter dir suffix)
	shift
	if [ "$2" = "" ] ; then
		echo test-mkdir letter dirpath
		exit 1
	fi
	$0 bod-client --testmkdir "$1" --extra "$2"
elif [ "$1" = "test-addfile" ] ; then # T: Add one file (letter dir suffix)
	shift
	if [ "$1" = "" ] ; then
		echo test-addfile letter [ dir suffix ]
		exit 1
	fi
	$0 bod-client --testaddfile "$1" --extra "$2" --extra2 "$3"
elif [ "$1" = "createsqlusers" ] ; then # db: Generates SQL to create users
	TRLISQL=/tmp/files.sql
	USERSQL=/tmp/users.sql
	FROMTRLID=192.168.5.2
	FROMWRITED=192.168.5.3
	rm -f $TRLISQL $USERSQL
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
	echo $TRLISQL and $USERSQL were produced
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
elif [ "$1" = "lxc0-bod" ]; then # prod:
	export LANG=eng
	$0 bod lxc0 &
	sleep 1
	$0 bod-control quit
	mkdir -p /var/lib/lxc/bod
	trli-lxc0 $LXC0USELINK \
		--filelist /var/lib/lxc/bod/bod.files \
		--savefile /var/lib/lxc/bod/bod.save \
		--restorefile /var/lib/lxc/bod/bod.restore \
		$EXTRALXCPROG \
		-i /usr/sbin/trli-init -l /tmp/log -n bod -p $BOLIXOPATH/bod >/var/lib/lxc/bod/bod-lxc0.sh
	chmod +x /var/lib/lxc/bod/bod-lxc0.sh
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
		-i /usr/sbin/trli-init -l /tmp/log -n writed -p $BOLIXOPATH/bo-writed >/var/lib/lxc/writed/writed-lxc0.sh
	chmod +x /var/lib/lxc/writed/writed-lxc0.sh
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
	for w in web web-fail
	do
		mkdir -p /var/lib/lxc/$w
		/usr/sbin/trli-lxc0 $LXC0USELINK \
			--filelist /var/lib/lxc/$w/$w.files \
			--savefile /var/lib/lxc/$w/$w.save \
			--restorefile /var/lib/lxc/$w/$w.restore \
			$EXTRALXCPROG \
			-i /usr/sbin/trli-init -l $LOG -l /tmp/log.web2 \
			-e /var/www/html/index.hc \
			-e /usr/sbin/trli-stop \
			-n $w -p /usr/sbin/httpd >/var/lib/lxc/$w/$w-lxc0.sh
			chmod +x /var/lib/lxc/$w/$w-lxc0.sh
	done
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
			-e /var/www/html/7s.html \
			-e /var/www/html/robots.txt \
			-e /var/www/html/twitter.png \
			-i /usr/sbin/trli-init \
			-l $LOG \
			-n $w -p /usr/sbin/httpd >/var/lib/lxc/$w/$w-lxc0.sh
		chmod +x /var/lib/lxc/$w/$w-lxc0.sh
	done
elif [ "$1" = "lxc0-mysql" ]; then # prod:
	ROOTLOG=/root/stracelogs/log.mysql
	LOG=/tmp/log.mysql
	if [ -f $ROOTLOG ] ; then
		LOG=$ROOTLOG
	elif [ ! -f $LOG ] ; then
		echo $LOG missing
		echo do strace -f -o $LOG /usr/libexec/mysqld --basedir=/usr --user=mysql
		echo mysqladmin shutdown
		exit 1
	fi
	echo bosqlddata
	mkdir -p /var/lib/lxc/bosqlddata
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		$EXTRALXCPROG \
		--filelist /var/lib/lxc/bosqlddata/bosqlddata.files \
		-i /usr/sbin/trli-init \
		-e /usr/bin/mysqladmin -e /usr/bin/mysql \
		-d /var/lib/mysql \
		-d /usr/lib64/mysql/plugin \
		-l $LOG \
		-n bosqlddata -p /usr/libexec/mysqld >/var/lib/lxc/bosqlddata/bosqlddata-lxc0.sh
	chmod +x /var/lib/lxc/bosqlddata/bosqlddata-lxc0.sh
	echo bosqlduser
	mkdir -p /var/lib/lxc/bosqlduser
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		$EXTRALXCPROG \
		--filelist /var/lib/lxc/sqlduser/sqlduser.files \
		-i /usr/sbin/trli-init \
		-e /usr/bin/mysqladmin -e /usr/bin/mysql \
		-d /var/lib/mysql \
		-d /usr/lib64/mysql/plugin \
		-l $LOG \
		-n bosqlduser -p /usr/libexec/mysqld >/var/lib/lxc/bosqlduser/bosqlduser-lxc0.sh
	chmod +x /var/lib/lxc/bosqlduser/bosqlduser-lxc0.sh
	mysql_save bosqlddata
	mysql_save bosqlduser
	mysql_restore bosqlddata
	mysql_restore bosqlduser
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
	echo exim
	mkdir -p /var/lib/lxc/exim
	/usr/sbin/trli-lxc0 $LXC0USELINK \
		$EXTRALXCPROG \
		--filelist /var/lib/lxc/exim/exim.files \
		-i /usr/sbin/trli-init \
		-l $LOG \
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
	$0 checks
	export SILENT=on
	$0 lxc0-bod
	$0 lxc0-writed
	$0 lxc0-sessiond
	$0 lxc0-proto
	$0 lxc0-web
	$0 lxc0-webssl
	$0 lxc0-mysql
	$0 lxc0-exim
elif [ "$1" = "webprodtest" ] ; then # P: Webtest on production
	time -p /usr/sbin/trli-webtest -h $PRODIP -p 443 -n 50 -N 20 >/dev/null
elif [ "$1" = "webtest" ] ; then # P:
	$0 test-system
	shift
	time -p /usr/sbin/trli-webtest -h 192.168.4.1 -p 9080 -n 50 -N 20 $*
elif [ "$1" = "webtest-static" ] ; then # P:
	$0 test-system
	shift
	time -p /usr/sbin/trli-webtest -f /static.html -h 192.168.4.1 -p 9080 -n 50 -N 20 $*
elif [ "$1" = "webtest-direct" ] ; then # P:
	$0 test-system
	shift
	time -p /usr/sbin/trli-webtest -h 192.168.122.5 -p 80 -n 50 -N 20 $*
elif [ "$1" = "webtest-direct-static" ] ; then # P:
	$0 test-system
	shift
	time -p /usr/sbin/trli-webtest -f /static.html -h 192.168.122.5 -p 80 -n 50 -N 20 $*
elif [ "$1" = "webssltest" ] ; then # P: (bk)
	$0 test-system
	shift
	IP=192.168.122.8
	PORT=80
	if [ "$1" = "bk" ] ; then
		IP=192.168.4.2
		PORT=9080
		shift
	fi
	time -p /usr/sbin/trli-webtest -h $IP -p $PORT -n 50 -N 20 $*
elif [ "$1" = "webssltest-static" ] ; then # P:
	$0 test-system
	shift
	time -p /usr/sbin/trli-webtest -f /static.html -h 192.168.122.8 -p 80 -n 50 -N 20 $*
elif [ "$1" = "stop-status" ] ; then # P: status of trli-stop
	echo "==== web ===="
	/usr/sbin/trli-stop-control -p /var/lib/lxc/web/rootfs/tmp/trli-stop.sock status
	echo "==== webadm ==="
	/usr/sbin/trli-stop-control -p /var/lib/lxc/webadm/rootfs/tmp/trli-stop.sock status
elif [ "$1" = "stop-stop" ] ; then # P: stop the web
	echo web
	/usr/sbin/trli-stop-control -p /var/lib/lxc/web/rootfs/tmp/trli-stop.sock stop
	echo webadm
	/usr/sbin/trli-stop-control -p /var/lib/lxc/webadm/rootfs/tmp/trli-stop.sock stop
elif [ "$1" = "stop-start" ] ; then # P: restart the web
	echo web
	/usr/sbin/trli-stop-control -p /var/lib/lxc/web/rootfs/tmp/trli-stop.sock start
	echo webadm
	/usr/sbin/trli-stop-control -p /var/lib/lxc/webadm/rootfs/tmp/trli-stop.sock start
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
		/usr/sbin/trli-cmp --name $lxc /var/lib/lxc/$lxc/$lxc.files
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
else
	echo test.sh command ...
fi

