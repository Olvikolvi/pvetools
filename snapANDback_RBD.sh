#!/bin/bash
set -e
POOL=$1
DATE=`date '+%Y%m%d%H%M%S'`
SNAPNAME="RBD$DATE"
TMP="/mnt/tmpdisk/"

if [ ! -d $TMP ]; then
  echo "Target folder $TMP does not exists"
  exit
fi

if [ -z "$POOL" ]; then
 echo "POOL puuttuu"
 exit
fi

DISKS=`rbd -p $POOL ls`
for DISK in $DISKS
do
   LAST=`rbd -p $POOL ls -l | grep $DISK | egrep '@RBD[0-9]{14}|excl' | tail -n 1 | awk '{print $1}'`
   if [ -z "$LAST" ]; then
     LAST=$DISK
   fi
   echo "Found disk $LAST"
   LATEST+=" $LAST"
   rbd  -p $POOL snap create --snap $SNAPNAME $DISK
done

for TODISK in $LATEST
do
  TOSNAP=`sed 's/.*@//' <<< $TODISK`
  DISK=`sed 's/@.*//' <<< $TODISK`
  if [ "$TOSNAP" == "$DISK" ]; then
    FILENAME=$TMP$DISK"_INIT_"$SNAPNAME".rbd.iso.gz"
    ionice rbd -p $POOL export "$DISK" - | nice gzip -1 > $FILENAME
  else
    FILENAME=$TMP$DISK"_"$TOSNAP"_"$SNAPNAME".rbd.diff.gz"
    #from = vanhempi  #to = uudempi
    ionice rbd -p $POOL export-diff --from-snap "$TOSNAP" "$DISK" --snap "$SNAPNAME" - | nice gzip -1 > $FILENAME
  fi
  echo "Exported and gzipped from $DISK: $TOSNAP <> $SNAPNAME to file $FILENAME"
  echo "Uploading to sftp server.."
  ./upload.sh $FILENAME ftp/$POOL/
  rm $FILENAME
  echo "done. Check: ./list.sh ftp/$POOL/"
done
