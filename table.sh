#!/bin/sh
DBNAME=bolixo
if [ $# = 0 ] ; then
	echo table.sh create [ mysql options ]
	echo table.sh delete [ mysql options ]
	echo Create the testplan database
elif [ "$1" = "create" ] ; then
	shift
	mysqladmin create $DBNAME $*
	mysql $DBNAME $* <<-EOF
		create table users (
			userid int not null auto_increment primary key,
			documentid int,
			id varchar(20) not null,
			unique (documentid,id),
			passw varchar(20),
			name varchar(100)
		);
		create table documents (
			documentid int not null auto_increment primary key,
			ownerid int,
			index (ownerid),
			name varchar(250) not null,
			index (name),
			unique (ownerid,name),
			descr text
		);
		create table nodes (
			nodeid int not null auto_increment primary key,
			documentid int,
			index (documentid),
			name varchar(100) not null,
			uuid varchar(30) not null,
			index (documentid,name),
			unique (documentid,uuid),
			ownerid int null null,
			type varchar(30) not null default 'text/shtml',
			descr text,
			image char(30),
			modif timestamp
		);
		create table relations (
			relationid int not null auto_increment primary key,
			documentid int,
			index (documentid),
			node1 int,
			node2 int,
			ownerid int,
			relate varchar(30),
			unique (documentid,node1,node2,relate),
			type varchar(30) not null default 'text/shtml',
			altname varchar(100),
			descr text,
			modif timestamp,
			orderkey int default 0,
			orderpol char default 'T'
		);
	EOF
elif [ "$1" = "delete" ] ; then
	shift
	mysqladmin drop $DBNAME $*
elif [ "$1" = "taches" ] ; then
	shift
	mysql $DBNAME $* <<-EOF
	EOF
elif [ "$1" = "update" ] ; then
	shift
	mysql $DBNAME $* <<-EOF
	EOF
fi

