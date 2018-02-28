#!/bin/sh
# Script to populate groups
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
	#./test.sh test-create_group_list A list1
	$0 reset
	./bofs -u jacques-A groups --create-group-list -L Alist1
	./bofs -u admin     groups --create-group-list -L Alonglist2 --owner jacques-A
	./bofs -u jacques-B groups --create-group-list -L Blist1
	./bofs -u jacques-C groups --create-group-list -L Clist1
	./bofs -u jacques-A groups --create-group -G Agroup1
	./bofs -u jacques-A groups --create-group -G Agroup-2
	./bofs -u jacques-B groups --create-group -G Bgroup1
	./bofs -u jacques-C groups --create-group -G Cgroup1

	./bofs -u jacques-A groups --set-group -L Alist1 -G Agroup1 -A R
	./bofs -u admin     groups --set-group -L Alonglist2 -G Agroup1 -A W --owner jacques-A
	./bofs -u jacques-B groups --set-group -L Blist1 -G Bgroup1 -A R
	./bofs -u jacques-C groups --set-group -L Clist1 -G Cgroup1 -A R

	./bofs -u jacques-A groups --set-member -G Agroup1 -U jacques-A -AR -Rdba
	./bofs -u admin     groups --set-member -G Agroup1 -U jacques-B -AW -R "" --owner jacques-A
	./bofs -u jacques-A groups --set-member -G Agroup1 -U jacques-C -A" " -R ""
	./bofs -u jacques-B groups --set-member -G Bgroup1 -U jacques-A -AR -Rdba
	for user in jacques-A jacques-B jacques-C
	do
		echo "------- $user"
		./bofs -u $user groups --print-lists
		./bofs -u $user groups --print-groups
	done
	for ((i=0; i<100; i++))
	do
		CONTENT=
		for ((j=0; j<20; j++))
		do
			CONTENT="$CONTENT\nThis is the body number $i,$j"
		done
		./bofs -u jacques-B msgs -n -D jacques-A -D jacques-C -T "This is title number $i" -C "$CONTENT"
	done
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

