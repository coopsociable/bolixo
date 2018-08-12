#!/bin/sh
# Script to populate groups
FILES=/b6/files
if [ "$1" = "reset" ] ; then
	./test.sh files <<-EOF
		delete from groups;
		delete from group_members;
		delete from group_lists;
		delete from group_list_members;
	EOF
elif [ "$1" = "print" ] ; then
	echo "------ Groups -------"
	./test.sh files <<-EOF
		select * from groups;
	EOF
	echo "------ Group members -------"
	./test.sh files <<-EOF
		select * from group_members;
	EOF
	echo "------ Group lists -------"
	./test.sh files <<-EOF
		select * from group_lists;
	EOF
	echo "------ Group list members -------"
	./test.sh files <<-EOF
		select * from group_list_members;
	EOF
elif [ "$1" = "sequence" ] ; then
	NB=$2
	if [ "$NB" = "" ] ; then
		NB=5
	fi
	$0 reset
	# Make sure user A B C are in contact list of each other
	./bofs -u  jacques-A misc -r -u jacques-B
	./bofs -u  jacques-A misc -r -u jacques-C
	./bofs -u  jacques-B misc -r -u jacques-C
	./bofs -u  jacques-B misc -R -u jacques-A -s A
	./bofs -u  jacques-C misc -R -u jacques-A -s A
	./bofs -u  jacques-C misc -R -u jacques-B -s A
	# Then all the other users do a contact request to jacques-A
	for letter in D G H I J K L M N O P Q R S T U V W X Y Z
	do
		./bofs -u jacques-$letter misc -r -u jacques-A
	done
	# We create a public project for all users and put a small photo in each
	# test-sequence removes user E and F
	for letter in A B C D G H I J K L M N O P Q R S T U V W X Y Z
	do
		./bofs -u jacques-$letter groups --create-group-list -L public 
		./bofs -u jacques-$letter groups --set-list-desc -D "public list for jacques-$letter" -L public 
		./bofs -u jacques-$letter groups --create-project-dir -L public
		./bofs -u jacques-$letter groups -a -L "#all" -M R /projects/jacques-$letter/public
		./bofs -u jacques-$letter cp $FILES/mini-jacques-$letter.jpg bo://projects/jacques-$letter/public/mini-photo.jpg
	done
	# We create a public project for user jacques-A allowing both jacques-A and jacques-B to contribute
	./bofs -u jacques-A groups --create-group -G public
	./bofs -u jacques-A groups --set-group-desc -D "public group for jacques-A" -G public 
	./bofs -u jacques-A groups --set-group -L public -G public -A R
	./bofs -u jacques-A groups --set-member -G public -U jacques-A -AW
	./bofs -u jacques-A groups --set-member -G public -U jacques-B -AW

	./bofs -u jacques-A groups --create-group-list -L Alist1
	./bofs -u jacques-A groups --create-project-dir -L Alist1
	./bofs -u admin     groups --create-group-list -L Alonglist2 --owner jacques-A
	./bofs -u jacques-A groups --create-project-dir -L Alonglist2
	./bofs -u jacques-B groups --create-group-list -L Blist1
	./bofs -u jacques-B groups --create-project-dir -L Blist1
	./bofs -u jacques-C groups --create-group-list -L Clist1
	./bofs -u jacques-C groups --create-project-dir -L Clist1
	./bofs -u jacques-A groups --create-group -G Agroup1
	./bofs -u jacques-A groups --create-group -G Agroup-2
	./bofs -u jacques-B groups --create-group -G Bgroup1
	./bofs -u jacques-C groups --create-group -G Cgroup1
	./bofs -u jacques-A groups --create-group -G common
	./bofs -u jacques-B groups --create-group -G common

	./bofs -u jacques-A groups --set-group -L public -G Agroup1 -A W
	./bofs -u jacques-A groups --set-group -L Alist1 -G Agroup1 -A R
	./bofs -u admin     groups --set-group -L Alonglist2 -G Agroup1 -A W --owner jacques-A
	./bofs -u jacques-B groups --set-group -L Blist1 -G Bgroup1 -A R
	./bofs -u jacques-C groups --set-group -L Clist1 -G Cgroup1 -A R

	./bofs -u jacques-A groups --set-member -G Agroup1 -U jacques-A -AR -Rdba
	./bofs -u admin     groups --set-member -G Agroup1 -U jacques-B -AW -R "" --owner jacques-A
	./bofs -u jacques-A groups --set-member -G Agroup1 -U jacques-C -A" " -R ""
	./bofs -u jacques-A groups --set-member -G Agroup-2 -U jacques-A -AR -Rdba
	./bofs -u jacques-B groups --set-member -G Bgroup1 -U jacques-A -AW -Rdba
	./bofs -u jacques-B groups --set-member -G Bgroup1 -U jacques-B -AW -Rdba

	./bofs -u jacques-A groups --set-member -G common -U jacques-A -AW -Rdba
	./bofs -u jacques-A groups --set-member -G common -U jacques-B -AW -Rdba
	./bofs -u jacques-B groups --set-member -G common -U jacques-A -AW -Rdba
	./bofs -u jacques-B groups --set-member -G common -U jacques-B -AW -Rdba
	for user in jacques-A jacques-B jacques-C
	do
		echo "------- $user"
		./bofs -u $user groups --print-lists
		./bofs -u $user groups --print-groups
	done
	$0 writemails $NB
elif [ "$1" = "writemails" ] ; then
	NB=$2
	if [ "$NB" = "" ] ; then
		NB=5
	fi
	for ((i=0; i<$NB; i++))
	do
		>/tmp/mail.txt
		for ((j=0; j<20; j++))
		do
			echo "This is the body number $i,$j" >>/tmp/mail.txt
		done
		MSGID=`./bofs -u jacques-B msgs -n -D jacques-A -D jacques-C -T "This is title number $i" -F /tmp/mail.txt | (read a b; echo $b)`
		echo Msgid: $MSGID
		./bofs -u jacques-A msgs -r -I $MSGID -D jacques-C -D jacques-B -T "re A: This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-C msgs -r -I $MSGID -D jacques-A -D jacques-B -T "re C: This is title number $i" -F /tmp/mail.txt
		MSGID=`./bofs -u jacques-A msgs -n -M jacques-A -P Alist1 -T "A A/1 This is title number $i" -F /tmp/mail.txt | (read a b; echo $b)`
		echo Msgid: $MSGID
		./bofs -u jacques-A msgs -r -I $MSGID -M jacques-A -P Alist1 -T "re: A A/1 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-B msgs -r -I $MSGID -M jacques-A -P Alist1 -T "re: A A/1 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-C msgs -r -I $MSGID -M jacques-A -P Alist1 -T "re: A A/1 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-A msgs -n -M jacques-A -P Alist1 -R dba -T "dba A A/1 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-A msgs -n -M jacques-A -P Alonglist2 -T "A A/2 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-A msgs -n -M jacques-A -P Alonglist2 -R dba -T "dba A A/2 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-B msgs -n -M jacques-A -P Alist1 -T "B A/1 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-B msgs -n -M jacques-A -P Alonglist2 -T "B A/2 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-C msgs -n -M jacques-A -P Alist1 -T "C A/1 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-C msgs -n -M jacques-A -P Alonglist2 -T "C A/2 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-A msgs -n -M jacques-B -P Blist1 -T "A B/1 This is title number $i" -F /tmp/mail.txt
		./bofs -u jacques-A msgs -n -M jacques-B -P Blist1 -R dba -T "dba A B/1 This is title number $i" -F /tmp/mail.txt
	done
	# Create short messages
	./bofs              msgs -t -G Bgroup1 --groupowner jacques-B -C "Are you ready for lunch ?"
	./bofs -u jacques-B msgs -t -G Bgroup1 --groupowner jacques-B -C "Not possible today"
	# Test usage of the same group name
	./bofs              msgs -t -G common --groupowner jacques-A -C "Jacques-A writes to jacques-A:common"
	./bofs              msgs -t -G common --groupowner jacques-B -C "Jacques-A writes to jacques-B:common"
	./bofs -u jacques-B msgs -t -G common --groupowner jacques-A -C "Jacques-B writes to jacques-A:common"
	./bofs -u jacques-B msgs -t -G common --groupowner jacques-B -C "Jacques-B writes to jacques-B:common"
	./bofs msgs -t -G Agroup1 --groupowner jacques-A -F $FILES/file.mp3
	./bofs msgs -t -G Agroup1 --groupowner jacques-A -F $FILES/file.jpg
	./bofs msgs -t -G Agroup1 --groupowner jacques-A -F $FILES/file.gif
	./bofs msgs -t -G Agroup1 --groupowner jacques-A -F $FILES/file.png
	./bofs msgs -t -G Agroup1 --groupowner jacques-A -F $FILES/file.mp4
	# Populate projects
	for project in jacques-A/Alist1 jacques-A/Alonglist2 jacques-B/Blist1
	do
		for file in $FILES/file.*
		do
			base=`basename $file`
			echo "cp $file -> projects $project"
			./bofs cp $file bo://projects/$project/$base
		done
	done
	./bofs mkdir bo://projects/jacques-A/public/default
	./bofs cp $FILES/file.jpg bo://projects/jacques-A/public/default/file.jpg
	./bofs cp $FILES/intro.html bo://projects/jacques-A/public/default/intro.html
elif [ "$1" = "config" ] ; then
	./test.sh files <<-EOF
		insert into groups (id,name) values (100,'project1'), (101,'project2'), (102,'project3');
		insert into group_members (groupid,userid) values (100,2),(101,3),(102,4);
		insert into group_lists (id,name) values (10,'list1'), (11,'list2'), (12,'list3');
		insert into group_list_members (group_list_id,groupid) values (10,100),(10,101),(11,102);
	EOF
elif [ "$1" = "access" ] ; then
	if [ "$3" = "" ] ; then
		echo groups.sh access group_list_id userid
		exit 1
	else
		./test.sh files <<-EOF
			select * from group_list_members join group_members on group_list_members.groupid = group_members.groupid where group_list_members.group_list_id=$2 and userid=$3; 
		EOF
	fi
elif [ "$1" = "member" ] ; then
	if [ "$2" = "" ] ; then
		echo groups.sh member userid
		exit 1
	else
		./test.sh files <<-EOF
			select * from group_members join group_list_members on group_list_members.groupid = group_members.groupid
				join group_lists on group_list_members.group_list_id=group_lists.id
				where group_members.userid = $2; 
		EOF
	fi
elif [ "$1" = "print-lists" ] ; then
	if [ "$2" = "" ] ; then
		echo groups.sh print-lists userid
		exit 1
	else
		./test.sh files <<-EOF
			select group_lists.name,groups.name,group_list_members.defaultaccess
                        from group_lists
                        left join group_list_members on group_lists.id=group_list_members.group_list_id
                        left join groups on group_list_members.groupid=groups.id
			where group_lists.ownerid=$2;
		EOF
	fi

else
	echo reset print or config
fi

