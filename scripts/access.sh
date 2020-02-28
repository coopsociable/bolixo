#!/bin/sh
inittest(){
	./bofs misc --writeconfig -L eng
}
listdir(){
	./bofs -t -u $1 ls -l bo:/$2
	./bofs -u admin ls --nostatus -l bo:/$2 | while read a b c d e f g h
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
# Add contact $2@$3 to $1
# $2 is remote.
addcontact(){
	localuser=$1
	user=$2
	server=$3
	if [ "$server" = "" ] ; then
		found=`(./bofs -u jacques-A misc --contact_list --request_by_me --minimal; ./bofs -u jacques-A misc --contact_list --minimal)|grep $user`
		if [ "$found" = "" ] ; then
			./bofs --nonstrict -u $1 misc --contact_request -u $user
			sleep 0.2
			./bofs --nonstrict -u $user misc --contact_manage -u $localuser
		fi
	else
		remoteuser=$2@$3
		found=`(./bofs -u jacques-A misc --contact_list --request_by_me --minimal; ./bofs -u jacques-A misc --contact_list --minimal)|grep $remoteuser`
		if [ "$found" = "" ] ; then
			./bofs --nonstrict -u $1 misc --contact_request -u $remoteuser
			sleep 0.2
			ssh root@$server bofs --nonstrict -u $user misc --contact_manage -u $localuser@test1.bolixo.org
		fi
	fi
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
	./bofs -t -u admin ls -l bo://
	for user in `./bofs -u admin ls bo://projects`
	do
		echo user $user
		listdir $user /projects/$user
	done
elif [ "$1" = "msgs" ] ; then # test: List all short messages
	./bofs -t -u admin ls -l bo://
	for user in `./bofs -u admin ls bo://msgs`
	do
		echo user $user
		listdir $user /msgs/$user
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
	echo Sleep 5 seconds
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
elif [ "$1" = "remote-contact-fail" ] ; then # test: Perform remote contact request with failure
	SERVER=preprod2.bolixo.org
	# Remove all contacts from $SERVER
	./bofs -u jacques-A misc --contact_list --minimal | grep $SERVER | while read line
	do
		echo ./bofs -u jacques-A misc --contact_remove --user $line
		./bofs -u jacques-A misc --contact_remove --user $line
	done
	ssh root@$SERVER /root/bin/cleartest1
	echo Sleep 5 seconds
	sleep 5
	echo "delete from id2name where name like '%@$SERVER';" | ./test.sh files
	echo "#### Invalid user"
	ssh root@$SERVER bofs -u jacques misc --contact_request -u jacques-AA@test1.bolixo.org
	echo "#### Local user without public key"
	# Erase public key for user jacques-A
	PUBKEY=`echo "select pub_key from id2name where name='jacques-A';" | ./test.sh files --skip-column-names`
	echo "update id2name set pub_key=null where name='jacques-A';" | ./test.sh files
	ssh root@$SERVER bofs -u jacques misc --contact_request -u jacques-A@test1.bolixo.org
	echo "update id2name set pub_key='$PUBKEY' where name='jacques-A';" | ./test.sh files
	echo "#### remote user have no public key"
	PUBKEY=`echo "select pub_key from id2name where name='jacques';" | ssh root@$SERVER bo files --skip-column-names`
	echo "update id2name set pub_key=null where name='jacques';" | ssh root@$SERVER bo files
	ssh root@$SERVER bofs -u jacques misc --contact_request -u jacques-A@test1.bolixo.org
	echo "update id2name set pub_key='$PUBKEY' where name='jacques';" | ssh root@$SERVER bo files
	echo "#### Contact request works"
	ssh root@$SERVER bofs -u jacques misc --contact_request -u jacques-A@test1.bolixo.org
	./bofs --nonstrict -u jacques-A misc --contact_manage -u jacques@preprod2.bolixo.org
	echo Contacts from $SERVER for jacques-A
	./bofs -u jacques-A misc --contact_list --minimal | grep $SERVER
elif [ "$1" = "contact-utf8" ] ; then # test: Perform contact request UTF-8
	user=jacques-éà
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
	./test.sh listsessions | utils/show-notifies | sort | uniq
	./bofs --logout --session $SESSIONA
	./bofs --logout --session $SESSIONB
	./bofs --logout --session $SESSIONC
elif [ "$1" = "cp-admin" ] ; then # test: admin writes files on behalf of another user
	NAME=admin.txt
	echo hello >/tmp/$NAME
        ./bofs -u admin cp -O jacques-A /tmp/$NAME bo://projects/jacques-A/public/$NAME
        ./bofs -t -u jacques-A ls -l bo://projects/jacques-A/public
        ./bofs -u admin cp -O jacques-B /tmp/$NAME bo://projects/jacques-A/public/$NAME
        ./bofs -t -u jacques-A ls -l bo://projects/jacques-A/public
        ./bofs -u admin cp -O unknown /tmp/$NAME bo://projects/jacques-A/public/$NAME
        ./bofs -t -u jacques-A ls -l bo://projects/jacques-A/public
        ./bofs -u admin cp -O jacques-D /tmp/$NAME bo://projects/jacques-A/public/$NAME
        ./bofs -t -u jacques-A ls -l bo://projects/jacques-A/public
        rm -f /tmp/$NAME
elif [ "$1" = "badnames" ] ; then # test: Try to use bad names for users, projects and groups
	./bofs groups -g -G "to#to"
	./bofs groups -g -G "inbox"
	./bofs groups -l -L "to#to"
	./bofs groups -l -L "inbox"
elif [ "$1" = "setaccess" ] ; then # test: set the access parameters of a file
	# Create 2 projects
	./bofs groups -l -L project1
	./bofs groups -l -L project2
	# Now create a file which will belong to jacques-A, project public
	# Inherited from the parent directory
	ls | ./bofs cat --pipeto bo://projects/jacques-A/public/file1
	./bofs -t ls -l bo://projects/jacques-A/public
	# Assign the file to project project1
	./bofs groups --set-access -L project1 --listmode w /projects/jacques-A/public/file1
	./bofs -t ls -l bo://projects/jacques-A/public
	# Assign the file to another user
	./bofs -u admin groups --set-access --user jacques-B /projects/jacques-A/public/file1
	./bofs -t ls -l bo://projects/jacques-A/public
	# Assign the file to a new project. This will fail because the file is now owned by jacques-B
	./bofs groups --set-access -L project2 --listmode w /projects/jacques-A/public/file1
	./bofs -t ls -l bo://projects/jacques-A/public
	# Assign the file to a new project, but this time done by admin (It will work)
	./bofs -u admin groups --set-access --listowner jacques-A -L project2 --listmode w /projects/jacques-A/public/file1
	./bofs -t ls -l bo://projects/jacques-A/public
	# Cleanup
	./bofs -u admin rm bo://projects/jacques-A/public/file1
	./bofs groups --delete-list -L project1
	./bofs groups --delete-list -L project2
elif [ "$1" = "doc-chess" ] ; then # test: various test on the chess game
	echo boBOCHES >/tmp/test.chess
	DOCNAME=/projects/jacques-A/public/test.chess
	./bofs cp /tmp/test.chess bo:/$DOCNAME
	./bofs documents --noscripts --playstep --docname $DOCNAME --step newgame=0
	echo "### Invalid moves on the first line, trapped by the second"
	for ((col=0; col<8; col++))
	do
		MOVE=0,$col,1,$col,0
		./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=$MOVE
		MOVE=7,$col,6,$col,0
		./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=$MOVE
	done
	echo "### Valid moves of the four knights"
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=0,1,2,0,0
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=0,1,2,2,0
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=0,6,2,5,0
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=0,6,2,7,0
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=7,1,5,0,0
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=7,1,5,2,0
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=7,6,5,5,0
	./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=7,6,5,7,0
	echo "### Valid moves of the pawns"
	#./bofs documents --noscripts --playstep --docname $DOCNAME --step clear=0
	#./bofs documents --noscripts --playstep --docname $DOCNAME --step loadline=0:pppppppp
	for move in 6,1,4,1,1 4,1,3,1,1 1,0,3,0,1 3,1,2,0,1
	do
		./bofs documents --noscripts --playstep --docname $DOCNAME --step checkmove=$move
	done
elif [ "$1" = "doc-chess-dump" ] ; then # test: help debug chess game
	DOCNAME=/projects/jacques-A/public/test.chess
	./bofs documents --noscripts --playstep --docname $DOCNAME --step dump=0
elif [ "$1" = "remote-member" ] ; then # test: create groups with remote members
	USER=jacques-A
	echo "#### Create group remote, add 1 local member and 2 remote members"
	./bofs -u $USER groups --create-group --groupname remote
	./bofs -u $USER groups --set-member --groupname remote --user jacques-B
	./bofs -u $USER groups --set-member --groupname remote --user jacquesg@preprod.bolixo.org
	./bofs -u $USER groups --set-member --groupname remote --user bolixodev@preprod.bolixo.org
	./bofs -u $USER groups --print-groups --only_owner
	echo "#### print-group on remote server"
	ssh root@preprod.bolixo.org bofs groups --print-groups -O jacques-A@test1.bolixo.org --only_owner
	echo "#### remove one remote user from group"
	./bofs -u $USER groups --set-member --groupname remote --user jacquesg@preprod.bolixo.org --access -
	ssh root@preprod.bolixo.org bofs groups --print-groups -O jacques-A@test1.bolixo.org --only_owner
	echo "#### remove second remote user from group"
	./bofs -u $USER groups --set-member --groupname remote --user bolixodev@preprod.bolixo.org --access -
	ssh root@preprod.bolixo.org bofs groups --print-groups -O jacques-A@test1.bolixo.org --only_owner
	./bofs -u $USER groups --print-groups --only_owner
	echo "#### Delete group remote"
	./bofs -u $USER groups --delete-group --groupname remote
	./bofs -u $USER groups --print-groups --only_owner
elif [ "$1" = "delete-group" ] ; then # test: create a group with messages and delete it
	USER=jacques-A
	echo "#### Create group onegroup with 2 members"
	./bofs -u $USER groups --create-group --groupname onegroup
	./bofs -u $USER groups --set-member --groupname onegroup --user $USER
	./bofs -u $USER groups --set-member --groupname onegroup --user jacques-B
	./bofs -u $USER groups --set-member --groupname onegroup --user jacques-C
	./bofs -u $USER groups --print-groups --only_owner
	echo "#### Write some messages"
	./bofs -u jacques-B msgs --shortmsg --groupname onegroup --groupowner $USER --content "message from jacques-B"
	./bofs -u jacques-C msgs --shortmsg --groupname onegroup --groupowner $USER --content "message from jacques-C"
	./bofs -t -u $USER msgs --listshortmsgs --groupname onegroup --groupowner $USER
	echo "#### Delete group onegroup"
	./bofs -u $USER groups --delete-group --groupname onegroup
	./bofs -u $USER groups --print-groups --only_owner
	./bofs -t -u $USER ls -l bo://msgs/$USER/short-inbox
	./test.sh deleteitems --doit
elif [ "$1" = "remote-group-create" ] ; then # test: group with remote members, create
	USER=jacques-A
	addcontact $USER jacques-B
	addcontact $USER jacquesg  preprod.bolixo.org
	addcontact $USER bolixodev preprod.bolixo.org
	addcontact $USER jacques   preprod2.bolixo.org
	addcontact $USER clemence  preprod2.bolixo.org
	echo "#### Create group onegroup with 6 members"
	./bofs -u $USER groups --create-group --groupname onegroup
	./bofs -u $USER groups --set-member --groupname onegroup --user $USER
	./bofs -u $USER groups --set-member --groupname onegroup --user jacques-B
	./bofs -u $USER groups --set-member --groupname onegroup --user jacquesg@preprod.bolixo.org
	./bofs -u $USER groups --set-member --groupname onegroup --user bolixodev@preprod.bolixo.org
	./bofs -u $USER groups --set-member --groupname onegroup --user jacques@preprod2.bolixo.org
	./bofs -u $USER groups --set-member --groupname onegroup --user clemence@preprod2.bolixo.org
	echo "#### Show all members"
	./bofs -u $USER groups --print-groups --only_owner
	echo "#### Show members on preprod"
	ssh root@preprod.bolixo.org bofs -u admin groups --print-groups --only_owner -O $USER@test1.bolixo.org
	echo "#### Show members on preprod2"
	ssh root@preprod2.bolixo.org bofs -u admin groups --print-groups --only_owner -O $USER@test1.bolixo.org
elif [ "$1" = "remote-group-cleanup" ] ; then # test: group with remote members, cleanup
	USER=jacques-A
	echo "#### Cleanup"
	./bofs -u $USER groups --set-member --groupname onegroup --user jacquesg@preprod.bolixo.org --access -
	./bofs -u $USER groups --set-member --groupname onegroup --user bolixodev@preprod.bolixo.org --access -
	./bofs -u $USER groups --set-member --groupname onegroup --user jacques@preprod2.bolixo.org --access -
	./bofs -u $USER groups --set-member --groupname onegroup --user clemence@preprod2.bolixo.org --access -
	ssh root@preprod.bolixo.org bo deleteitems --doit
	ssh root@preprod2.bolixo.org bo deleteitems --doit
	./bofs -u $USER groups --delete-group --groupname onegroup
	echo "#### print-groups"
	./bofs -u $USER groups --print-groups --only_owner
	echo "#### print-groups on preprod"
	ssh root@preprod.bolixo.org bofs -u admin groups --print-groups --only_owner -O $USER@test1.bolixo.org
	echo "#### print-groups on preprod2"
	ssh root@preprod2.bolixo.org bofs -u admin groups --print-groups --only_owner -O $USER@test1.bolixo.org
	./test.sh deleteitems --doit
elif [ "$1" = "remote-group-messages" ] ; then # test: group with remote members, send messages
	USER=jacques-A
	echo "#### Send messages"
	# All 6 members will send a message
	./bofs -u $USER msgs --shortmsg --groupname onegroup --groupowner $USER -C "message from $USER"
	./bofs -u jacques-B msgs --shortmsg --groupname onegroup --groupowner $USER -C "message from jacques-B"
	ssh root@preprod.bolixo.org bofs -u jacquesg msgs --shortmsg --groupname onegroup --groupowner $USER@test1.bolixo.org -C "message_from_jacquesg@preprod.bolixo.org"
	ssh root@preprod.bolixo.org bofs -u bolixodev msgs --shortmsg --groupname onegroup --groupowner $USER@test1.bolixo.org -C "message_from_bolixodev@preprod.bolixo.org"
	ssh root@preprod2.bolixo.org bofs -u jacques msgs --shortmsg --groupname onegroup --groupowner $USER@test1.bolixo.org -C "message_from_jacques@preprod2.bolixo.org"
	ssh root@preprod2.bolixo.org bofs -u clemence msgs --shortmsg --groupname onegroup --groupowner $USER@test1.bolixo.org -C "message_from_clemence@preprod2.bolixo.org"
	echo "#### list messages for $USER"
	./bofs --nonstrict -u $USER msgs --listshortmsgs --groupname onegroup --groupowner $USER
	echo "#### list messages for jacquesg@preprod.bolixo.org"
	ssh root@preprod.bolixo.org bofs --nonstrict -u jacquesg msgs --listshortmsgs --groupname onegroup --groupowner jacques-A@test1.bolixo.org
	echo "#### list messages for jacques@preprod2.bolixo.org"
	ssh root@preprod2.bolixo.org bofs --nonstrict -u jacques msgs --listshortmsgs --groupname onegroup --groupowner jacques-A@test1.bolixo.org
elif [ "$1" = "remote-group" ] ; then # test: group with remote members, create,send,cleanup
	$0 remote-group-create
	$0 remote-group-messages
	$0 remote-group-cleanup
else
	echo command
fi

