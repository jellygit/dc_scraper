#!/bin/bash
while [ 1 ] 
do
	perl libxml.pl
	sec=($RANDOM)
	sec=$((sec%=5))
	sec=$((sec+2))
	echo "sleep $sec"
	sleep $sec

done

