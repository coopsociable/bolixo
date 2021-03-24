#!/usr/bin/sh
# Simple functions to help create photos gallery from bash

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
	echo boBOPHOT >/tmp/test.pho
	$BOFS cp /tmp/test.pho bo:/$DOCNAME
}
# Erase all elements from the document
resetdocument(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step resetgame=
}
# setcaption image caption
setcaption(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setcaption=$1 \"$2\""
}
# setimage image-number image/url
setimage(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setimage=$1 '$2'"
}
# addimage image/url
addimage(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "addimage='$1'"
}
docdump(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "dump="
}

