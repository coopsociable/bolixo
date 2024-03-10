#!/bin/sh
LARGEIMAGE=$HOME/Images/large-image.jpg
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
	#echo addcontact $1 $2 $3
	if [ "$server" = "" ] ; then
		found=`./bofs -u jacques-A misc --contact_list --minimal | grep $user`
		if [ "$found" = "" ] ; then
			./bofs --nonstrict -u $1 misc --contact_request -u $user
			sleep 0.2
			./bofs --nonstrict -u $user misc --contact_manage -u $localuser
		fi
	else
		remoteuser=$2@$3
		found=`./bofs -u jacques-A misc --contact_list | grep $remoteuser`
		#echo addcontact found=$found
		if [ "$found" = "" ] ; then
			./bofs --nonstrict -u $1 misc --contact_request -u $remoteuser
			sleep 0.4
			ssh root@$server bofs --nonstrict -u $user misc --contact_manage -u $localuser@test1.bolixo.org
		fi
	fi
}
checklargeimage(){
	if [ ! -f $LARGEIMAGE ] ; then
		echo $LARGEIMAGE does not exist, ending
		exit 1
	fi
}
if [ "$1" = "" ] ; then
	if [ -x /usr/sbin/menutest ] ; then
		/usr/sbin/menutest -s $0
	else
		echo "No menutest, can't display help"
	fi
elif [ "$1" = "cleartest1" ] ; then # test: remove traces of test1.bolixo.org from preprods
	for SERVER in preprod preprod2 preprod3
	do
		ssh root@$SERVER.bolixo.org /root/bin/cleartest1 &
	done
	wait
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
elif [ "$1" = "sendtalk_file" ] ; then # test: send a bolixo file as a message
	USER=jacques-A
	./bofs -u $USER groups --set-member --groupname public --user jacquesg@preprod.bolixo.org
	./bofs -u $USER msgs -f -L /projects/jacques-A/public/mini-photo.jpg --groupname inbox --recipient jacques-B --recipient jacques-C --recipient jacquesg@preprod.bolixo.org
	./bofs -u $USER msgs -f -L /projects/jacques-A/public/mini-photo.jpg --groupname public --recipient jacques-C
	if [ "$2" != "keep" ] ; then
		./bofs -u $USER groups --set-member --groupname public --user jacquesg@preprod.bolixo.org --access -
	fi
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
	echo "==== contact request"
	for user in bolixodev bolixonews bolixonouvelles jacquesg
	do
		./bofs misc --contact_request -u $user@preprod.bolixo.org
	done
	echo "==== contact manage"
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
	# If all is good, removing a contact on this server does it on the remote server
	# Just in case, we do it on the remote server. 
	ssh root@$SERVER bofs -u jacques misc --contact_list --minimal | grep test1.bolixo.org | while read line
	do
		echo ssh root@$SERVER bofs -u jacques misc --contact_remove --user $line
		ssh root@$SERVER bofs -u jacques misc --contact_remove --user $line
	done
	$0 cleartest1
	echo "delete from id2name where name like '%@$SERVER';" | ./test.sh files
	echo "#### Invalid user"
	ssh root@$SERVER bofs -u jacques misc --contact_request -u jacques-AA@test1.bolixo.org
	echo "#### Local user without public key"
	# Take a backup
	PUBKEY=`echo "select pub_key from id2name where name='jacques-A';" | ./test.sh files --skip-column-names`
	# Erase public key for user jacques-A
	echo "update id2name set pub_key=null where name='jacques-A';" | ./test.sh files
	ssh root@$SERVER bofs -u jacques misc --contact_request -u jacques-A@test1.bolixo.org
	# Restore public key
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
	echo Contacts from test1.bolixo.org for jacques
	ssh root@$SERVER bofs -u jacques misc --contact_list --minimal | grep test1.bolixo.org
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
	checklargeimage
	./bofs msgs --shortmsg --groupname inbox --recipient $USER -F $LARGEIMAGE
	# Compare the size of the image
	REMOTESIZE=`ssh root@preprod.bolixo.org bofs -u jacquesg msgs -s --groupname inbox | head -1 | (read a b c d e f; echo $f)`
	LOCALSIZE=`stat --print="%s\n" $LARGEIMAGE`
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
	. scripts/chess-help.sh
	createdocument
	resetdocument
	echo "### Invalid moves on the first line, trapped by the second"
	for ((col=0; col<8; col++))
	do
		checkmove 0 $col 1 $col 0
		checkmove 7 $col 6 $col 0
	done
	echo "### Valid moves of the four knights"
	checkmove 0 1 2 0 0
	checkmove 0 1 2 2 0
	checkmove 0 6 2 5 0
	checkmove 0 6 2 7 0
	checkmove 7 1 5 0 0
	checkmove 7 1 5 2 0
	checkmove 7 6 5 5 0
	checkmove 7 6 5 7 0
	echo "### Valid moves of the pawns"
	for move in "6 1 4 1 1" "4 1 3 1 1" "1 0 3 0 1" "3 1 2 0 1"
	do
		checkmove $move
	done
	dump
	boardclear
	loadline 6 pppppppp
	setplayer 1 true true true 11 12
	setplayer 2 true false true 13 14
	dump
elif [ "$1" = "doc-chess-dump" ] ; then # test: dump the chess game
	DOCNAME=/projects/jacques-A/public/test.chess
	. scripts/chess-help.sh
	dump
elif [ "$1" = "doc-chess-pawnqueen" ] ; then # test: pawn promotion (to queen,...)
	DOCNAME=/projects/jacques-A/public/test.chess
	. scripts/chess-help.sh
	createdocument
	resetdocument
	boardclear
	loadline 0 __k_____
	loadline 1 _____P__
	loadline 7 __K_____
elif [ "$1" = "doc-whiteboard-3elms" ] ; then # test: test with 3 elements on the whiteboard document
	DOCNAME=/projects/jacques-A/public/test.white
	. scripts/whiteboard-help.sh
	createdocument
	resetdocument
	#addelm=label "text" type x y width height
	# Add 3 circle and connect them with 2 arrows
	echo "#### Add 3 circles"
	addelm elm1 elm1 ellipse 100 100 50 50
	addelm elm2 elm2 ellipse 100 200 50 50
	addelm elm3 elm3 ellipse 100 300 50 50
	docdump
	echo "#### Connect first circle to second"
	connect elm1 elm2 1
	docdump
	echo "#### Connect second circle to third"
	connect elm2 elm3 1
	docdump
	echo "#### Erase the middle circle"
	labeldelete elm2
	docdump
elif [ "$1" = "doc-whiteboard-2many" ] ; then # test: tests many 2 many  on the whiteboard document
	DOCNAME=/projects/jacques-A/public/test.white
	. scripts/whiteboard-help.sh
	createdocument
	resetdocument
	connect2_2(){
		connect $1 $3 1
		connect $2 $3 1
		connect $1 $4 1
		connect $2 $4 1
	}
	addellipse (){
		addelm $1 $1 ellipse $2 $3 50 50
	}
	# In all four cases, the 2 parents points to the 2 children
	# Create 4 ellipses: 2 parents on same line and 2 children on same line.
	addellipse para1 100 100
	addellipse para2 200 100
	addellipse elma1 100 300
	addellipse elma2 200 300
	connect2_2 para1 para2 elma1 elma2
	# Create 4 ellipses: 2 parents on same column and 2 children on same column.
	addellipse parb1 300 100
	addellipse parb2 300 200
	addellipse elmb1 500 100
	addellipse elmb2 500 200
	connect2_2 parb1 parb2 elmb1 elmb2
	# Create 4 ellipses: 2 parents on same line and 2 children on same line, parents are below.
	addellipse parc1 100 600
	addellipse parc2 200 600
	addellipse elmc1 100 400
	addellipse elmc2 200 400
	connect2_2 parc1 parc2 elmc1 elmc2
	# Create 4 ellipses: 2 parents on same column and 2 children on same column. Parents are after.
	addellipse pard1 500 400
	addellipse pard2 500 600
	addellipse elmd1 300 400
	addellipse elmd2 300 600
	connect2_2 pard1 pard2 elmd1 elmd2
	docdump
elif [ "$1" = "doc-whiteboard" ] ; then # test: many tests on the whiteboard document
	$0 doc-whiteboard-3elms
	$0 doc-whiteboard-2many
elif [ "$1" = "doc-whiteboard-imbed-reset" ] ; then # test: reset the white board
	DOCNAME=/projects/jacques-A/public/imbed.white
	. scripts/whiteboard-help.sh
	createdocument
	resetdocument
elif [ "$1" = "doc-whiteboard-imbed-fill" ] ; then # test: create images and embed documents in a white board
	DOCNAME=/projects/jacques-A/public/imbed.white
	. scripts/whiteboard-help.sh
	shift
	while [ "$1" != "" ]
	do
		if [ "$1" = "reset" ] ; then
			$0 doc-whiteboard-imbed-reset
		elif [ "$1" = "1c" ] ; then
			addelm elm1 "Chess game 1" rect 320 330 600 600
			textpos elm1 1
			assigndoc test.chess
			resetsel
		elif [ "$1" = "1w" ] ; then
			addelm elm1 "Whiteboard" rect 320 330 600 600
			textpos elm1 1
			assigndoc test.white A1
			resetsel
		elif [ "$1" = "1p" ] ; then
			addelm elm1 "Gallery" rect 320 330 600 600
			textpos elm1 1
			assigndoc test.pho main
			resetsel
		elif [ "$1" = "1u" ] ; then
			addelm elm1 "web" rect 320 330 600 600
			textpos elm1 1
			assignimg http://test1.bolixo.org/bolixo-arch.jpg
			resetsel
		elif [ "$1" = "2c" ] ; then
			addelm elm2 "Chess game 2" rect 930 330 600 600
			textpos elm2 1
			assigndoc test.chess
			resetsel
		elif [ "$1" = "2ww" ] ; then
			addelm elm2 "Chess game 2" rect 630 330 300 300
			addelm elm22 "Chess game 22" rect 1000 330 300 300
			textpos elm2 1
			textpos elm22 1
			assigndoc test.white A1
			resetsel
		elif [ "$1" = "2w" ] ; then
			addelm elm2 "Whiteboard 2" rect 930 330 600 600
			textpos elm2 1
			assigndoc test.white A1
			resetsel
		elif [ "$1" = "3" ] ; then
			addelm elm3 "Whiteboard 3" rect 1540 330 600 600
			textpos elm3 1
			assigndoc test.white A1
			resetsel
		elif [ "$1" = "4c" ] ; then
			addelm elm4 "Table" rect 600 800 300 300
			textpos elm4 1
			assigndoc test.chess
			#assigndoc noname.clc a1:d4
			resetsel
		elif [ "$1" = "4p" ] ; then
			addelm elm4 "Photos" rect 600 800 600 100
			textpos elm4 1
			assigndoc test.pho mini
			resetsel
		elif [ "$1" = "4t" ] ; then
			addelm elm4 "Table" rect 600 800 600 100
			textpos elm4 1
			assigndoc noname.clc a1:d4
			resetsel
		else
			echo Invalid option $1
		fi
		shift
	done
elif [ "$1" = "doc-whiteboard-imbed-clear" ] ; then # test: un assign image and embeds in white board
	DOCNAME=/projects/jacques-A/public/imbed.white
	. scripts/whiteboard-help.sh
	for label in elm1 elm2 elm3 elm4
	do
		labelselect $label 0
	done
	if [ "$2" = "doc" ] ; then
		assigndoc "" ""
	elif [ "$2" = "img" ] ; then
		assignimg "" ""
	else
		echo either doc or img
	fi
	resetsel
elif [ "$1" = "doc-whiteboard-imbed" ] ; then # test: setup a white board with imbeds
	$0 doc-whiteboard-imbed-reset
	shift
	$0 doc-whiteboard-imbed-fill $*
elif [ "$1" = "doc-whiteboard-imbed-dump" ] ; then # test: dump whiteboard
	DOCNAME=/projects/jacques-A/public/imbed.white
	. scripts/whiteboard-help.sh
	docdump
elif [ "$1" = "doc-calc" ] ; then # test: many test on spreadsheet document
	DOCNAME=/projects/jacques-A/public/test.sheet
	. scripts/calc-help.sh
	createdocument
	resetdocument
	setcells a1:c1 1,2,3
	setcells a2:c2 1,2,3
	setcells a3:c3 1,2,3
	setcells a4:d4 "=sum(a1:a3),=sum(b1:b3),=sum(c1:c3),=sum(a4:c4)"
	getcells a1:d4
	getvals a1:d4
	dump
elif [ "$1" = "doc-word" ] ; then # test: many test on text document
	DOCNAME=/projects/jacques-A/public/test.doc
	. scripts/word-help.sh
	createdocument
	resetdocument
	setline 0 "this is the first line and it is a long line that creates a paragraph spanning multiple lines. I am adding more and more stuff to reach the goal of a longer line. Now it is getting long enouch I believe."
	setline 2 "this is the third line"
	setline 3 "bullet 1"
	setline 4 "bullet 2"
	setline 5 "Numeric 1"
	setline 6 "Numeric 2"
	setline 7 "Center"
	# Invalid setline
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setline=7 a b"
	setlisttype 3 1 
	setlisttype 4 1 
	settablevel 3 1
	settablevel 4 1
	setlisttype 5 2 
	setlisttype 6 2 
	setlisttype 7 3 
	setimage 8 http://test1.bolixo.org/icon.png
	setimbed 9 test.white a1
	docdump
	$0 doc-word-print | grep -v gamesequence=
elif [ "$1" = "doc-word-print" ] ; then # test: print the test document
	DOCNAME=/projects/jacques-A/public/test.doc
	. scripts/word-help.sh
	docprint
elif [ "$1" = "doc-photos-dump" ] ; then # test: dump test.pho
	DOCNAME=/projects/jacques-A/public/test.pho
	. scripts/photos-help.sh
	docdump
elif [ "$1" = "doc-vidconf" ] ; then # test: generate content in a video conference
	NB=$2
	if [ "$NB" = "" ] ; then
		NB=100
	fi
	DOCNAME=/projects/jacques-A/public/test.vdc
	. scripts/vidconf-help.sh
	createdocument
	FILM=~/films/frag_bunny.mp4
	base64 $FILM -w40000| head -$NB| while read line
	do
		append $line
	done
elif [ "$1" = "doc-photos" ] ; then # test: many test on photo gallery document
	DOCNAME=/projects/jacques-A/public/test.pho
	. scripts/photos-help.sh
	createdocument
	resetdocument
	if [ "$2" = "" ] ; then
		setimage 0 mini-photo.jpg
		setimage 1 photo.jpg
		setimage 2 http://test1.bolixo.org/whiteboard.jpg
		setimage 3 http://test1.bolixo.org/project.jpg
		addimage http://test1.bolixo.org/project.jpg
		addimage http://test1.bolixo.org/project.jpg
		addimage http://test1.bolixo.org/project.jpg
	elif [ "$2" = "change" ] ; then
		# Same as above, but the second image is changed
		setimage 0 mini-photo.jpg
		setimage 1 mini-photo.jpg
		setimage 2 http://test1.bolixo.org/whiteboard.jpg
		setimage 3 http://test1.bolixo.org/project.jpg
		addimage http://test1.bolixo.org/project.jpg
		addimage http://test1.bolixo.org/project.jpg
		addimage http://test1.bolixo.org/project.jpg
	elif [ "$2" = "few1" ]; then
		# Only one image
		setimage 0 mini-photo.jpg
	elif [ "$2" = "few2" ]; then
		# Only two images
		setimage 0 mini-photo.jpg
		setimage 1 photo.jpg
	elif [ "$2" = "few3" ]; then
		# Only three images
		setimage 0 mini-photo.jpg
		setimage 1 photo.jpg
		setimage 2 http://test1.bolixo.org/whiteboard.jpg
	elif [ "$2" = "many" ]; then
		# Add many images
		for ((i=0; i<10; i++))
		do
			addimage mini-photo.jpg
			addimage photo.jpg
			addimage http://test1.bolixo.org/whiteboard.jpg
		done
	elif [ "$2" = "doc-example" ] ; then
		# Use to create the image in the documentation
		addimage mini-photo.jpg
		addimage photo.jpg
		addimage http://test1.bolixo.org/bolixo.png
		addimage http://test1.bolixo.org/chess.jpg
		setcaption mini-photo.jpg 'This is the small picture'
		setcaption photo.jpg 'This is the large picture. It is shown on the public page and on bolixo.org'
		setcaption http://test1.bolixo.org/bolixo.png "This is Bolixo official logo"
		setcaption http://test1.bolixo.org/chess.jpg "This is a chess game screen shot"
		exit 0
	elif [ "$2" = "doc-example-fr" ] ; then
		# Use to create the image in the documentation
		addimage mini-photo.jpg
		addimage photo.jpg
		addimage http://test1.bolixo.org/bolixo.png
		addimage http://test1.bolixo.org/chess-fr.jpg
		setcaption mini-photo.jpg 'Ceci est une petite image'
		setcaption photo.jpg 'Ceci est la grande image. Elle apparaît dans la page publique et sur bolixo.org'
		setcaption http://test1.bolixo.org/bolixo.png "Voici le logo officiel de Bolixo"
		setcaption http://test1.bolixo.org/chess-fr.jpg "Ceci est une saisie d'écran d'une partie d'échec"
		exit 0
	else
		echo Unknown option $2 >&2
	fi
	setcaption mini-photo.jpg 'This is the small picture'
	setcaption photo.jpg 'This is the large picture. It is shown on the public page and on bolixo.org'
	# Set the caption on a missing picture
	setcaption wrong-picture 'some text'
	docdump
elif [ "$1" = "infowrite" ] ; then # test: publish info to directory server
	USER=jacques-A
	echo Create mini-photo.jpg and photo.jpg for all users
	for letter in A B C Z
	do
		if [ -x /usr/bin/convert ]; then
			convert -font helvetica -size 40x40 xc:white -pointsize 37 -draw "text 5,32 '$letter'" /tmp/mini-photo.jpg
			./bofs -u jacques-$letter cp /tmp/mini-photo.jpg bo://projects/jacques-$letter/public/mini-photo.jpg
			convert -font helvetica -size 100x100 xc:white \
                                -stroke black -fill blue -draw "roundrectangle 5,5 95,95 10,10" \
				-pointsize 50 -stroke black -fill red -draw "text 35,65 $letter" /tmp/photo.jpg
			./bofs -u jacques-$letter cp /tmp/photo.jpg bo://projects/jacques-$letter/public/photo.jpg
		else
			echo no convert utility, install ImangeMagick
		fi
	done
	for ((i=0; i<3; i++))
	do
		OPTPHOTO=
		if [ "$i" = 1 ] ; then
			OPTPHOTO="--publish_photo --publish_mini_photo"
		fi
		echo "#### test $i OPTPHOTO=$OPTPHOTO"
		./bofs -u $USER bolixoapi \
			--publish \
			--fullname	"$USER $i fullname" \
			--city		"$USER $i city" \
			--state		"$USER $i state" \
			--country	"$USER $i country" \
			--publish_bosite \
			--website	"$USER $i website" \
			--interest	"$USER $i interest so far" \
			$OPTPHOTO infowrite
		echo "select * from users where name='$USER';" | ./test.sh bolixo
		ls /var/lib/bolixod/test1.bolixo.org/$USER-*
	done
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
	./bofs -t --nonstrict -u $USER msgs --listshortmsgs --groupname onegroup --groupowner $USER
	echo "#### list messages for jacquesg@preprod.bolixo.org"
	ssh root@preprod.bolixo.org bofs -t --nonstrict -u jacquesg msgs --listshortmsgs --groupname onegroup --groupowner jacques-A@test1.bolixo.org
	echo "#### list messages for jacques@preprod2.bolixo.org"
	ssh root@preprod2.bolixo.org bofs -t --nonstrict -u jacques msgs --listshortmsgs --groupname onegroup --groupowner jacques-A@test1.bolixo.org
elif [ "$1" = "remote-group" ] ; then # test: group with remote members, create,send,cleanup
	$0 remote-group-create
	$0 remote-group-messages
	$0 remote-group-cleanup
elif [ "$1" = "remote-project" ] ; then # test: project with remote members, create,send,cleanup
	USER=jacques-A
	showlists(){
		echo ---Local
		./bofs -u $USER groups --print-lists
		echo ---Remote
		ssh root@preprod.bolixo.org bofs -u admin groups --print-lists --owner $USER@test1.bolixo.org
	}
	echo ------- Before
	#ssh root@preprod.bolixo.org bofs -u admin groups --print-groups --owner jacques-A@test1.bolixo.org
	showlists
	echo ------ Add group public to project newprj
	./bofs -u jacques-A groups --set-group --listname newprj --groupname public --access W
	showlists
	echo ----- Add remote user to group public
	./bofs -u jacques-A groups --set-member --groupname public --user jacquesg@preprod.bolixo.org --access R
	showlists
	echo ----- Remove group public from project newprj
	./bofs -u jacques-A groups --set-group --listname newprj --groupname public --access -
	showlists
	echo ----- Remove remote user from group public
	./bofs -u jacques-A groups --set-member --groupname public --user jacquesg@preprod.bolixo.org --access -
	showlists
else
	echo command
fi

