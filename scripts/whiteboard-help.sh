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
	echo boBOWHIT |	$BOFS cat --pipeto ht:/$DOCNAME
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
# Set the base text size of all caption.
# Number >= 0 (default is 10)
textsize(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "textsize=$1"
}
# Set the caption of an object
# label
# new text (generally quoted)
settext(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "settext=$1 '$2'"
}
# Set the relative size of an object
# label
# size (may be negative since it is added to the base text size)
settextsize(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "settextsize=$1 '$2'"
}
# Set the color of the bullet for text
# label value
# The value 0 means black, and 3 means hidden
bullettype(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "bullettype=$1 $2"
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
# label
# type: 0=solid, 1=dash, 2=dotted, 3=hidden
boxtype(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "boxtype=$1 $2"
}
# Position the text for an element (0=inside,1=top,2=bottom,3=left,4=right)
textpos(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "textpos=$1 $2"
}
# Assign an image to selected elements
# The image is either a URL or a path inside the project
assignimg(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "image=url:$1"
}
# Delete one element using its label
labeldelete(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "labeldelete=$1"
}
# Move selected elements: newx newy
move(){
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "mousemove=$1,$2,false,false"
}
# Resize selected elements: direction,mode
# direction: 1 to grow, -1 to shrink
# mode: 0 to resize on all axis
#       1 to resize vertically
#       2 to resize horizontally 
resize(){
	shiftkey=false
	controlkey=false
	if [ "$2" = 1 ] ; then
		shiftkey=true
	elif [ "$2" = 2 ] ; then
		controlkey=true
	elif [ "$2" != 0 ] ; then
		echo resize, invalide mode
		exit 1
	fi
	$BOFS documents --noscripts --playstep --docname $DOCNAME --step "wheel=$1,$shiftkey,$controlkey"
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

