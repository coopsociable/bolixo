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
elif [ "$1" = "userfiles" ] ; then # help: List user files
	shift
	if [ "$1" = "" ] ; then
			echo userid needed
			exit 1
	fi
	user=$1
	for inbox in `./bofs -u admin ls bo://msgs/$user/short-inbox`
	do
		echo inbox = $inbox
		./bofs -u admin ls -l bo://msgs/$user/short-inbox/$inbox
	done
	for dir in `./bofs -u admin ls bo://projects/$user`
	do
		echo project = $dir
		./bofs -u admin ls -l bo://projects/$user/$dir
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
	sleep 5
	for user in bolixodev bolixonews bolixonouvelles jacquesg
	do
		./bofs misc --contact_request -u $user@preprod.bolixo.org
	done
	for user in bolixodev bolixonews bolixonouvelles jacquesg
	do
		sleep 0.2
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
elif [ "$1" = "contact-utf8" ] ; then # test: Perform contact request UTF-8
	user=jacques-é
	./bofs misc --contact_request -u $user
	./bofs -u $user misc --contact_manage -u jacques-A@test1.bolixo.org
	./bofs -u jacques-B misc --contact_request -u $user
	./bofs -u $user misc --contact_manage -u jacques-B
	for id in $user jacques-A jacques-B
	do
		echo ==== Contacts for $id
		./bofs -u $id groups --print-contacts
	done
	for id in jacques-A jacques-B
	do
		echo ==== Inbox $id
		./bofs -u $id  -t msgs -s -G inbox
	done
elif [ "$1" = "remote-interest" ] ; then # test: add interest admin@preprod.bolixo.org
	./bofs misc --interest_set --int_user admin@preprod.bolixo.org
	./bofs -t misc --interest_list
	ssh root@preprod.bolixo.org /root/bin/adminmsgs 2
	sleep 1
	./bofs -t misc --interest_check
elif [ "$1" = "remote-sendlarge" ] ; then # test: Send large file to remote
	# This test works after some other tests have populated the contact list
	USER=jacquesg@preprod.bolixo.org
	NB=`./bofs groups --print-contacts | grep -c $USER`
	if [ "$NB" = 0 ] ; then
		echo Remote user $USER not in contact list >&2
		exit 1
	fi
	import -window root /tmp/image.png
	./bofs msgs --shortmsg --groupname inbox --recipient $USER -F /tmp/image.png
	# Compare the size of the image
	REMOTESIZE=`ssh root@preprod.bolixo.org bofs -u jacquesg msgs -s --groupname inbox | head -1 | (read a b c d e f; echo $f)`
	LOCALSIZE=`stat --print="%s\n" /tmp/image.png`
	if [ "$REMOTESIZE" != "$LOCALSIZE" ] ; then
		echo remote size differ from local size: local=$LOCALSIZE remote=$REMOTESIZE
	fi
	ssh root@preprod.bolixo.org bofs -t -u jacquesg msgs -s --groupname inbox
elif [ "$1" = "notifications" ] ; then # test: test notifications to session manager
	# We make sure all the users we generally use while testing are logged in
	# Then we generate activities triggering notifications and we see if the session
	# manager contains this stuff. If we are already logged in (using a browser)
	# while doing this test, it won't matter because of the sort | uniq.
	# This is true because notification are spreaded to all sessions of users
	./test.sh bo-sessiond-control resetnotifies
	SESSIONA=`./bofs -u jacques-A --login`
	SESSIONB=`./bofs -u jacques-B --login`
	SESSIONC=`./bofs -u jacques-C --login`

	# Make sure A B and C are connected	
	./bofs -u jacques-A misc --contact_request -u jacques-B
	./bofs -u jacques-B misc --contact_manage -u jacques-A
	./bofs -u jacques-A misc --contact_request -u jacques-C
	./bofs -u jacques-C misc --contact_manage -u jacques-A
	./bofs -u jacques-B misc --contact_request -u jacques-C
	./bofs -u jacques-C misc --contact_manage -u jacques-B
	# Make sure A B and C are members of each other public group
	./bofs -u jacques-A groups --set-member --groupname public --user jacques-B
	./bofs -u jacques-A groups --set-member --groupname public --user jacques-C
	./bofs -u jacques-B groups --set-member --groupname public --user jacques-A
	./bofs -u jacques-B groups --set-member --groupname public --user jacques-C
	./bofs -u jacques-C groups --set-member --groupname public --user jacques-A
	./bofs -u jacques-C groups --set-member --groupname public --user jacques-B
	# admin sends a message to his public group. Every account is interested in admin
	./bofs -u admin msgs --shortmsg -G public -C "test notifications: There is a new version available"
	# jacques-A sends a private message to B and C and B sends to A and C
	./bofs -u jacques-A msgs --shortmsg -G inbox -D jacques-B -D jacques-C -C "test notifications from jacques-A"
	./bofs -u jacques-B msgs --shortmsg -G inbox -D jacques-A -D jacques-C -C "test notifications from jacques-B"
	# A sends a message to B and C public group, B to A public group
	./bofs -u jacques-A msgs --shortmsg --groupowner jacques-B -G public -C "public jacques-B notifications from jacques-A"
	./bofs -u jacques-A msgs --shortmsg --groupowner jacques-C -G public -C "public jacques-C notifications from jacques-A"
	./bofs -u jacques-B msgs --shortmsg --groupowner jacques-A -G public -C "public jacques-A notifications from jacques-B"
	# Anonymous message to A B and C
	for user in A B C
	do
		# Make sure user accepts anonymous messages
		 ./bofs -u jacques-$user misc -w --anonmsgs 1
		./bofs msgs --shortmsg --groupowner jacques-$user -G anonymous -C "Anonymous message to jacques-$user"
	done
	# User Z perform a contact request to A B and C
	# Users A B C perform a contact request to Y and Y accepts
	for user in A B C
	do
		./bofs -u jacques-Z misc --contact_request -u jacques-$user
		./bofs -u jacques-$user misc --contact_request -u jacques-Y
		./bofs -u jacques-Y misc --contact_manage -u jacques-$user
	done
	#./test.sh listsessions | grep ^0
	./test.sh listsessions | grep notifies: | sort | uniq
	./bofs --logout --session $SESSIONA
	./bofs --logout --session $SESSIONB
	./bofs --logout --session $SESSIONC
else
	echo command
fi

