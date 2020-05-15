#!/usr/bin/sh
# Simple functions to help create white board from bash

if [ "$DOCNAME" = "" ] ; then
	echo Variable DOCNAME is not defined
	echo DOCNAME is the path of the document: /project/user/project-name/documentname
	exit 1
fi
BOFS=/usr/bin/bofs
if [ -x ./bofs ] ; then
	BOFS=./bofs
fi
# Create a white board
createdocument(){
	echo boBOWHIT >/tmp/test.white
	$BOFS cp /tmp/test.white bo:/$DOCNAME
}
# Erase all elements from the document
resetdocument(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step resetgame=
}
# addelm label text type x y width height
addelm(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "addelm=$1 '$2' $3 $4 $5 $6 $7"
}
# Reset all selections
resetsel(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "resetselect=0"
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "resetselect=1"
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "resetselect=2"
}
labelselect(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "labelselect=$1 $2"
}
selectline(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "selectline=$1"
}
labeldelete(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "labeldelete=$1"
}
docdump(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "dump="
}
connect(){
	resetsel
	labelselect $1 1
	labelselect $2 0
	selectline $3
}

