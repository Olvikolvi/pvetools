#!/bin/bash

DATE=`date '+%Y%m%d%H%M%S'`

declare -A LAST=()

for SNAPSHOT in $(./list.sh |awk '{print $9}' | sort)
do
NAME=$(echo ${SNAPSHOT} | sed 's/.rbd.iso.gz//g' | sed 's/.rbd.diff.gz//g')
IFS=_ read disk from to <<<"$NAME"
IFS=- read vm vmid disk diskid <<<"$disk"
from=$(echo $from| sed 's/[^0-9]*//g')
to=$(echo $to| sed 's/[^0-9]*//g')

if [ "$to" == "" ]; then
  continue;
fi

#poistetaan kaikki 3kk vanhemmat tiedostot..
#jos init tiedosto kaikki diffit sen alta pois myös, koska ei voi palauttaa niistä
if [ $(($to+300000000)) -lt $DATE ] || [ "${LAST[$vmid_$diskid]}" -eq "$from" ]; then
 LAST[$vmid_$diskid]=$to
 echo "Poista $SNAPSHOT"
# ./sftp_rm.sh $SNAPSHOT
fi

done
