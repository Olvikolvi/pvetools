#!/bin/bash
downTime=0
lastAlert=0
lastAccessTime=$(date +"%s")
if [ -n "$1" ]
then
  IP2PING=$1
fi
if [ ! $IP2PING ]; then
  IP2PING='8.8.8.8'
fi

echo "Starting to ping $IP2PING every 1 sec.. " $(date)
#counter=0

while [ true ]; do

#if [ $counter == 8 ]; then
# IP2PING='8.8.8.1'
#else 
# if [ $counter == 16 ]; then
#   IP2PING='8.8.8.8'
# fi
#fi
#counter=$(expr $counter + 1)
#echo $counter

if ! ping -w1 -c1 $IP2PING >& /dev/null; then
    downTime=$(( $(date +"%s") - $lastAccessTime ))
else
    if [ $lastAlert != 0 ]; then
      echo "Back online after $downTime seconds"
      lastAlert=0
    fi
    downTime=0
    lastAccessTime=$(date +"%s")
fi

sleep 1

if [ $downTime -ge 10 ]; then
   if [ $lastAlert != $lastAccessTime ]; then
     dateformatted=$(date -d @${lastAccessTime})
     echo "Network down! Last access was $dateformatted"
     lastAlert=$lastAccessTime
   fi
fi
done
