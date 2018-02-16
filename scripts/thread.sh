#!/bin/sh
# Script to create a message thread
./test.sh test-mkdir A /news
./test.sh test-addfile    A /news/msg1 "This is a message"
./test.sh test-mkdir      A /news/msg1.dir
for ((i=0; i<5; i++))
do
	./test.sh test-addfile A /news/msg1.dir/rep$i "Answer to rep1 $i"
done
./test.sh test-listdir A /news
./test.sh test-listdir A /news/msg1.dir
