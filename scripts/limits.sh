#!/bin/sh
if [ "$1" = "" ] ; then
	if [ -x /usr/sbin/menutest ] ; then
		/usr/sbin/menutest -s $0
	else
		echo "No menutest, can't display help"
	fi
elif [ "$1" = "longurl" ] ;then # test: Create a message with a long URL
	# bod shows NB lines by default
	NB=5
	rm -f /tmp/msg.txt
	for ((i=1; i<$NB; i++))
	do
		echo line $i: image should be visible >>/tmp/msg.txt
	done
	echo "line 5 is a line with more than 80 character long ending with a _IMG=http://test1.bolixo.org/talk1.jpg?agument1=0&argument2=0&argument3=0&argument4=0" >>/tmp/msg.txt
	./bofs msgs -t -G public -F /tmp/msg.txt
	rm -f /tmp/msg.txt
	for ((i=1; i<$NB; i++))
	do
		echo line $i: image invisible >>/tmp/msg.txt
	done
	echo "line 5 is a line with more than 80 character long ending with a long URL making it invisible _IMG=http://test1.bolixo.org/talk1.jpg?agument1=0&argument2=0&argument3=0&argument4=0" >>/tmp/msg.txt
	./bofs msgs -t -G public -F /tmp/msg.txt
else
	echo command
fi

