#!/usr/bin/sh
# Simple functions to help create text from bash

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
	echo boBOWORD >/tmp/test.doc
	$BOFS cp /tmp/test.doc bo:/$DOCNAME
}
# Erase all elements from the document
resetdocument(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step resetgame=
}
# Set the content of a paragraph: nol 'text'
setline(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setline=$1 '$2'"
}
# Set the image of a paragraph: nol image/url
setimage(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setimage=$1 '$2'"
}
# Set a link to a document on a paragraph: nol document region
setimbed(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setimbed=$1 '$2' '$3'"
}
# Set the line attribute of a paragraph: nol listtype
# listtype: 0=normal, 1=bullet, 2=numeric, 3=center
setlisttype(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "setlisttype=$1 $2"
}
# set the tab level of a paragraph: nol tab_level (0 ... 8)
settablevel(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "settablevel=$1 $2"
}
docdump(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "dump="
}

