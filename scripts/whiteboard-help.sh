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
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "resetselect=3"
}
# Select one element: label 0|1|2
# 0 normal selection
# 1 parent selection
# 2 grouping selection
labelselect(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "labelselect=$1 $2"
}
# Select the line type between selected elements and parents.
selectline(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "selectline=$1"
}
# Select the box type for one element
boxtype(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "boxtype=$1 $2"
}
# Position the text for an element (0=inside,1=top,2=bottom,3=left,4=right)
textpos(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "textpos=$1 $2"
}
# Delete one element using its label
labeldelete(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "labeldelete=$1"
}
docdump(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "dump="
}
# connect parent child linetype
connect(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME \
		--step "resetselect=3" \
		--step "labelselect=$1 1" \
		--step "labelselect=$2 0" \
		--step "selectline=$3" \
		--step "resetselect=3"
}

