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
else
	echo command
fi

