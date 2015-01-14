#!/bin/bash
while [ 1 ] 
do
	perl libxml.pl
	sec=($RANDOM)
	sec=$((sec%=5))
	sec=$((sec+7))
	echo "sleep $sec"
	sleep $sec

done

