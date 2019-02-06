#!/bin/sh
inittest(){
	./bofs misc --writeconfig -L eng
}
listdir(){
	./bofs -t -u $1 ls -l bo:/$2
	./bofs -u admin ls -l bo:/$2 | while read a b c d e f g h
	do
		case $a in
		D*)
			echo "       " $2/$h
			listdir $user $2/$h
			;;
		*)
			;;
		esac
	done
}
if [ "$1" = "" ] ; then
	if [ -x /usr/sbin/menutest ] ; then
		/usr/sbin/menutest -s $0
	else
		echo "No menutest, can't display help"
	fi
elif [ "$1" = "directory" ] ;then # test: Basic directory content
	inittest
	DIR=bo://projects/jacques-A
	./bofs mkdir $DIR/ppp
	echo test | ./bofs cat --pipeto $DIR/ppp/toto
	./bofs -t ls -l $DIR $DIR/ppp/toto
	./bofs rmdir $DIR/ppp
	echo test | ./bofs cat --pipeto $DIR/ppp/toto
elif [ "$1" = "projects" ] ; then # test: List all projects
	for user in `./bofs -u admin ls bo://projects`
	do
		echo user $user
		listdir $user /projects/$user
	done
elif [ "$1" = "createsubdir" ] ; then # test: Create a project, then a subdir
	PRJ=newprj
	if [ "$2" != "" ] ; then
		PRJ=$2
	fi
	./bofs groups --create-group-list --listname $PRJ
	./bofs mkdir bo://projects/jacques-A/$PRJ/sdir1
	./bofs -t ls -l bo://projects/jacques-A
	./bofs -t ls -l bo://projects/jacques-A/$PRJ
elif [ "$1" = "public" ] ; then # test: Make the content of one user public, post a message
	if [ "$2" = "" ] ; then
		echo user
		exit 1
	fi
	./bofs -u $2 mkdir bo://projects/$2/public/version1
	./bofs -u $2 misc --writeconfig --public_view 1 --public_dir version1
	NB=5
	if [ "$3" != "" ] ; then
		NB=$3
	fi
	for ((i=0; i<$NB; i++))
	do
		./bofs -u $2 msgs -t -G public --groupowner $2 -C "This is a great day!"
	done
	./bofs -t public -s --user $2
	./bofs -t ls -l bo://projects/$2/public/version1
elif [ "$1" = "ivldsession" ] ; then # test: Test access with invalid session (and node session)
	DIR=bo://projects/jacques-A
	bofs(){
		session=$1
		shift
		echo "##" ./bofs $*
		./bofs -t --session $session $* 2>&1
	}
	testseq(){
		if [ "$1" = "" ] ; then
			echo empty session
		fi
		sdir=$2
		bofs $1 ls -l $DIR 
		bofs $1 mkdir $DIR/$sdir 
		ls -l | bofs $1 cat --pipeto $DIR/$sdir/file 
		bofs $1 ls -l $DIR/$sdir 
		bofs $1 rm $DIR/$sdir/file
		bofs $1 ls -l $DIR/$sdir 
		bofs $1 rmdir $DIR/$sdir 
	}
	echo ===== Using jacques-A valid session
	SESSION=`./bofs --login`
	testseq $SESSION dir1
	./bofs --logout --session $SESSION
	echo ===== Using a bad session id
	testseq badsession dir1
	echo ===== Using node session
	SESSION=`./test.sh bod-control nodelogin http://test1.bolixo.org`
	testseq $SESSION dir1
	./test.sh bod-control nodelogout http://test1.bolixo.org $SESSION
elif [ "$1" = "remote-contact" ] ; then # test: Perform remote contact request
	ssh root@preprod.bolixo.org /root/bin/cleartest1
	for user in bolixodev bolixonews bolixonouvelles jacquesg
	do
		./bofs misc --contact_request -u $user@preprod.bolixo.org
	done
	for user in bolixodev bolixonews bolixonouvelles jacquesg
	do
		ssh root@preprod.bolixo.org bofs -u $user misc --contact_manage -u jacques-A@test1.bolixo.org
	done
	echo === Remote contacts
	for user in bolixodev bolixonews bolixonouvelles jacquesg
	do
		echo === $user
		./bofs --nonstrict -u preprod/$user groups --print-contacts
	done
	echo ==== Contacts for jacques-A
	./bofs groups --print-contacts
	echo ==== Inbox jacques-A
	./bofs -t msgs -s -G inbox
else
	echo command
fi

