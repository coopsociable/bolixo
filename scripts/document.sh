#!/usr/bin/sh
# Various scripts to create image for documentation

whiteboard(){
	. scripts/whiteboard-help.sh
	createdocument
	resetdocument
	addelm elm1 elm1 ellipse 100 100 50 50
	textpos elm1 1
	addelm elm2 elm2 ellipse 250 100 50 50
	textpos elm2 1
	addelm elm3 elm3 ellipse 100 300 50 50
	textpos elm3 3
	addelm elm4 elm4 ellipse 250 300 50 50
	textpos elm4 4

	connect elm1 elm3 1
	connect elm2 elm3 3
	connect elm2 elm4 4

	addelm elm5 "$1" rect 500 200 200 300
	textpos elm5 1
	boxtype elm5 2


	resetsel
	labelselect elm5 2
	addelm elm6 base ellipse 100 50 50 50
	textpos elm6 1
	addelm elm7 elm1 ellipse 50 250 50 50
	textpos elm7 2
	addelm elm8 elm2 ellipse 150 250 50 50
	textpos elm8 2
	connect elm6 elm7 1
	connect elm6 elm8 2
	resetsel
	labelselect elm1 1
	labelselect elm2 1
	labelselect elm3 0
	labelselect elm4 0
	labelselect elm5 2
}

if [ "$1" = "" ] ; then
	if [ -x /usr/sbin/menutest ] ; then
		/usr/sbin/menutest -s $0
	else
		echo "No menutest, can't display help"
	fi
elif [ "$1" = "whiteboard" ] ; then # White board sample
	DOCNAME=/projects/jacques-A/public/doc.white
	whiteboard group-1
elif [ "$1" = "whiteboard-fr" ] ; then # White board french sample
	DOCNAME=/projects/jacques-A/public/doc.blanc
	whiteboard groupe-1
else
	echo command
fi
