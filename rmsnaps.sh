#!/bin/bash
ID=$1
START=$2
IFS=$'\n'
for row in $(qm listsnapshot $ID|sort|grep "VM$START"); do
IFS=' '
read a b c <<< $row

if [ "$a" == "current" ]; then
  continue
fi

qm delsnapshot $ID $a

done
