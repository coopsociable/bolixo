#!/usr/bin/sh
# Simple functions to help interaction with video conference from bash

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
	echo boBOVIDC | $BOFS cat --pipeto ht:/$DOCNAME
}
# append base64_video_chunk
append(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "append=$1"
}
dump(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "dump="
}
