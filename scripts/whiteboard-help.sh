#!/usr/bin/sh
# Simple functions to help create white board from bash
resetdocument(){
	./bofs documents --noscripts --playstep --docname $DOCNAME --step resetgame=
}
# addelm label text type x y width height
addelm(){
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "addelm=$1 '$2' $3 $4 $5 $6 $7"
}
# Reset all selections
resetsel(){
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "resetselect=0"
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "resetselect=1"
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "resetselect=2"
}
labelselect(){
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "labelselect=$1 $2"
}
selectline(){
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "selectline=$1"
}
labeldelete(){
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "labeldelete=$1"
}
docdump(){
	./bofs documents --noscripts --playstep --docname $DOCNAME --step "dump="
}
connect(){
	resetsel
	labelselect $1 1
	labelselect $2 0
	selectline $3
}

