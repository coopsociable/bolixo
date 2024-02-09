#!/usr/bin/sh
# Simple functions to help create spreadsheet from bash

if [ "$DOCNAME" = "" ] ; then
	echo Variable DOCNAME is not defined
	echo DOCNAME is the path of the document: /project/user/project-name/documentname
	exit 1
fi
BOFS=/usr/bin/bofs
if [ -x ./bofs ] ; then
	BOFS=./bofs
fi
# Create a spreadsheet
createdocument(){
	echo boBOCALC |	$BOFS cat --pipeto ht:/$DOCNAME
}
# Erase all elements from the document
resetdocument(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step resetgame=
}
# setcells range value[,value ... ]
setcells(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setcells=$1,$2"
}
getcells(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "getcells=$1"
}
getvals(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "getvals=$1"
}
dump(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "dump="
}
